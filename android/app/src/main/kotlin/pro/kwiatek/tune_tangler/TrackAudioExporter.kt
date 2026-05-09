package pro.kwiatek.tune_tangler

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.SystemClock
import android.util.Log
import sonic.Sonic
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Growable PCM buffer using a primitive [ShortArray] (no boxed [Short] per sample like [ArrayList]).
 */
private class ShortPcmAccumulator(initialCapacity: Int) {
    private var data = ShortArray(initialCapacity.coerceAtLeast(4096))
    var size: Int = 0
        private set

    fun append(value: Short) {
        if (size >= data.size) {
            val grown = data.size * 2L
            val newCap = when {
                grown >= Int.MAX_VALUE / 2 -> Int.MAX_VALUE / 2
                grown < 16 -> 16
                else -> grown.toInt()
            }
            data = data.copyOf(newCap)
        }
        data[size++] = value
    }

    fun toShortArray(): ShortArray = if (size == data.size) data else data.copyOf(size)
}

/**
 * Offline export: trim + stereo pan + volume + tempo (pan → volume → tempo, matching former FFmpeg order),
 * then AAC-LC 192 kbps into .m4a.
 *
 * Uses [sonic.Sonic] (Apache 2.0, Bill Cox / waywardgeek).
 */
object TrackAudioExporter {

    private const val TAG = "TrackAudioExporter"
    private const val TIMEOUT_US = 20_000L
    private const val AAC_BIT_RATE = 192_000
    private const val CANCEL_CHECK_INTERVAL = 64

    private val exportCancelled = AtomicBoolean(false)

    private class ProgressThrottle(
        private val minDelta: Double = 0.012,
        private val forceEveryMs: Long = 100L,
    ) {
        private var lastP = -1.0
        private var lastTime = 0L

        fun emit(p: Double, sink: (Double) -> Unit) {
            val now = SystemClock.uptimeMillis()
            val clamped = p.coerceIn(0.0, 1.0)
            if (lastP < 0.0 ||
                clamped >= 0.997 ||
                kotlin.math.abs(clamped - lastP) >= minDelta ||
                now - lastTime >= forceEveryMs
            ) {
                lastP = clamped
                lastTime = now
                sink(clamped)
            }
        }
    }

    class ExportCancelledException : Exception("cancelled")

    @JvmStatic
    fun prepareExportSession() {
        exportCancelled.set(false)
    }

    @JvmStatic
    fun requestCancelExport() {
        exportCancelled.set(true)
    }

    private fun throwIfCancelled() {
        if (exportCancelled.get()) throw ExportCancelledException()
    }

    @JvmStatic
    fun exportProcessed(
        inputPath: String,
        outputPath: String,
        startMs: Long,
        endMs: Long,
        volume: Double,
        balance: Double,
        speed: Double,
        onProgress: ((Double) -> Unit)? = null,
    ) {
        val outFileEarly = File(outputPath)
        try {
            val inFile = File(inputPath)
            if (!inFile.isFile) throw IllegalArgumentException("Input not a file: $inputPath")

            val leftGain = (if (balance <= 0.0) 1.0 else 1.0 - balance) * volume
            val rightGain = (if (balance >= 0.0) 1.0 else 1.0 + balance) * volume

            val speedF = when {
                speed <= 0.0 -> 1.0f
                else -> speed.toFloat().coerceIn(0.25f, 4f)
            }

            val hasSonic = kotlin.math.abs(speedF - 1f) >= 1e-4f
            val decodeSpan = if (hasSonic) 0.40 else 0.50
            val encodeStart = if (hasSonic) 0.52 else 0.50
            val encodeSpan = 1.0 - encodeStart
            val throttle = ProgressThrottle()
            fun emit(p: Double) {
                if (onProgress != null) {
                    throttle.emit(p.coerceIn(0.0, 1.0), onProgress)
                }
            }

            emit(0.0)

            val (pcm, sampleRate, channels) = decodePcmS16Interleaved(
                inputPath = inputPath,
                startUs = startMs * 1000L,
                endUs = endMs * 1000L,
                onDecodeProgress = if (onProgress != null) {
                    { local -> emit(local * decodeSpan) }
                } else {
                    null
                },
            )

            throwIfCancelled()
            applyPanVolumeInterleaved(pcm, channels, leftGain, rightGain)

            throwIfCancelled()
            if (hasSonic) {
                emit((decodeSpan + encodeStart) / 2.0)
            }
            val processed = runThroughSonic(pcm, channels, sampleRate, speedF)

            throwIfCancelled()
            if (hasSonic) {
                emit(encodeStart - 0.02)
            }
            encodeAacM4a(
                pcmInterleaved = processed,
                sampleRate = sampleRate,
                channelCount = channels,
                outputPath = outputPath,
                onEncodeProgress = if (onProgress != null) {
                    { local -> emit(encodeStart + local * encodeSpan) }
                } else {
                    null
                },
            )
            emit(1.0)
        } catch (e: ExportCancelledException) {
            try {
                if (outFileEarly.exists()) outFileEarly.delete()
            } catch (_: Exception) {
            }
            throw e
        }
    }

    private fun decodePcmS16Interleaved(
        inputPath: String,
        startUs: Long,
        endUs: Long,
        onDecodeProgress: ((Double) -> Unit)? = null,
    ): Triple<ShortArray, Int, Int> {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(inputPath)
            val trackIndex = (0 until extractor.trackCount).firstOrNull { i ->
                val f = extractor.getTrackFormat(i)
                val mime = f.getString(MediaFormat.KEY_MIME) ?: return@firstOrNull false
                mime.startsWith("audio/")
            } ?: throw IllegalStateException("No audio track in $inputPath")
            extractor.selectTrack(trackIndex)
            val inputFormat = extractor.getTrackFormat(trackIndex)
            val mime = inputFormat.getString(MediaFormat.KEY_MIME)
                ?: throw IllegalStateException("Missing MIME")

            val decoder = MediaCodec.createDecoderByType(mime)
            try {
                decoder.configure(inputFormat, null, null, 0)
                decoder.start()

                extractor.seekTo(startUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)

                val pcmOut = ShortPcmAccumulator(estimateInitialPcmCapacity(inputFormat, startUs, endUs))
                var inputEos = false
                var outputEos = false
                var outSampleRate = 0
                var outChannels = 0
                var pcmEncoding = AudioFormat.ENCODING_PCM_16BIT

                val bufferInfo = MediaCodec.BufferInfo()
                var decodeCancelTick = 0
                var expectedShortsInWindow = 0L
                while (!outputEos) {
                    if (++decodeCancelTick % CANCEL_CHECK_INTERVAL == 0) {
                        throwIfCancelled()
                    }
                    if (!inputEos) {
                        val inIx = decoder.dequeueInputBuffer(TIMEOUT_US)
                        if (inIx >= 0) {
                            val inBuf = decoder.getInputBuffer(inIx)!!
                            inBuf.clear()
                            val size = extractor.readSampleData(inBuf, 0)
                            if (size < 0) {
                                decoder.queueInputBuffer(
                                    inIx,
                                    0,
                                    0,
                                    0L,
                                    MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                                )
                                inputEos = true
                            } else {
                                val pts = extractor.sampleTime
                                decoder.queueInputBuffer(inIx, 0, size, pts, 0)
                                extractor.advance()
                            }
                        }
                    }

                    when (val outIx = decoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)) {
                        MediaCodec.INFO_TRY_AGAIN_LATER -> {}
                        MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                            val fmt = decoder.outputFormat
                            outSampleRate = fmt.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                            outChannels = fmt.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                            if (fmt.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
                                pcmEncoding = fmt.getInteger(MediaFormat.KEY_PCM_ENCODING)
                            } else {
                                pcmEncoding = AudioFormat.ENCODING_PCM_16BIT
                            }
                            val spanUs = (endUs - startUs).coerceAtLeast(1L)
                            expectedShortsInWindow = (spanUs * outSampleRate / 1_000_000L * outChannels)
                                .coerceAtLeast(1L)
                        }
                        else -> {
                            if (outIx < 0) continue
                            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                                decoder.releaseOutputBuffer(outIx, false)
                                continue
                            }
                            if (bufferInfo.size > 0 && outSampleRate > 0 && outChannels > 0) {
                                val outBuf = decoder.getOutputBuffer(outIx)!!
                                appendPcmFromBuffer(
                                    outBuf,
                                    bufferInfo,
                                    outChannels,
                                    outSampleRate,
                                    pcmEncoding,
                                    startUs,
                                    endUs,
                                    pcmOut,
                                )
                                if (onDecodeProgress != null && expectedShortsInWindow > 0L) {
                                    val frac = (pcmOut.size.toDouble() / expectedShortsInWindow.toDouble())
                                        .coerceIn(0.0, 1.0)
                                    onDecodeProgress(frac)
                                }
                            }
                            decoder.releaseOutputBuffer(outIx, false)
                            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                                outputEos = true
                            }
                        }
                    }
                }

                if (outSampleRate <= 0 || outChannels <= 0) {
                    throw IllegalStateException("Decoder did not produce PCM (sr=$outSampleRate ch=$outChannels)")
                }
                if (pcmOut.size == 0) {
                    throw IllegalStateException("Decoded zero PCM samples (trim range?)")
                }
                onDecodeProgress?.invoke(1.0)
                return Triple(pcmOut.toShortArray(), outSampleRate, outChannels)
            } finally {
                try {
                    decoder.stop()
                } catch (_: Exception) {
                }
                try {
                    decoder.release()
                } catch (_: Exception) {
                }
            }
        } finally {
            try {
                extractor.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun estimateInitialPcmCapacity(inputFormat: MediaFormat, startUs: Long, endUs: Long): Int {
        val spanUs = (endUs - startUs).coerceAtLeast(1L)
        val spanMs = (spanUs / 1000L).coerceAtLeast(1L)
        val ch = inputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT).coerceAtLeast(1)
        val sr = inputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE).takeIf { it > 0 } ?: 48000
        val approxFrames = (spanMs * sr / 1000L).toInt() + sr
        // Cap initial allocation: long files grow the primitive array without boxing or a huge Object[].
        return (approxFrames * ch).coerceIn(4096, 4_000_000)
    }

    private fun appendPcmFromBuffer(
        buffer: ByteBuffer,
        info: MediaCodec.BufferInfo,
        channels: Int,
        sampleRate: Int,
        pcmEncoding: Int,
        startUs: Long,
        endUs: Long,
        out: ShortPcmAccumulator,
    ) {
        buffer.position(info.offset)
        buffer.limit(info.offset + info.size)
        val origOrder = buffer.order()
        buffer.order(ByteOrder.nativeOrder())

        if (pcmEncoding == AudioFormat.ENCODING_PCM_FLOAT) {
            buffer.order(ByteOrder.LITTLE_ENDIAN)
            val frameBytes = 4 * channels
            if (info.size < frameBytes) {
                buffer.order(origOrder)
                return
            }
            val totalFrames = info.size / frameBytes
            val pts = info.presentationTimeUs
            var frameIndex = 0
            while (frameIndex < totalFrames) {
                val framePtsUs = pts + frameIndex * 1_000_000L / sampleRate
                if (framePtsUs in startUs..endUs) {
                    repeat(channels) {
                        val f = buffer.float
                        val s = (f * 32767.0f).toInt().coerceIn(
                            Short.MIN_VALUE.toInt(),
                            Short.MAX_VALUE.toInt(),
                        )
                        out.append(s.toShort())
                    }
                } else {
                    buffer.position(buffer.position() + frameBytes)
                }
                frameIndex++
            }
        } else {
            buffer.order(ByteOrder.LITTLE_ENDIAN)
            val frameBytes = 2 * channels
            if (info.size < frameBytes) {
                buffer.order(origOrder)
                return
            }
            val totalFrames = info.size / frameBytes
            val pts = info.presentationTimeUs
            var frameIndex = 0
            while (frameIndex < totalFrames) {
                val framePtsUs = pts + frameIndex * 1_000_000L / sampleRate
                if (framePtsUs in startUs..endUs) {
                    repeat(channels) {
                        out.append(buffer.short)
                    }
                } else {
                    buffer.position(buffer.position() + frameBytes)
                }
                frameIndex++
            }
        }
        buffer.order(origOrder)
    }

    private fun applyPanVolumeInterleaved(
        pcm: ShortArray,
        channels: Int,
        leftGain: Double,
        rightGain: Double,
    ) {
        if (channels == 1) {
            val g = ((leftGain + rightGain) / 2.0).coerceIn(0.0, 4.0)
            var i = 0
            while (i < pcm.size) {
                pcm[i] = (pcm[i] * g).toInt().coerceIn(
                    Short.MIN_VALUE.toInt(),
                    Short.MAX_VALUE.toInt(),
                ).toShort()
                i++
            }
            return
        }
        if (channels != 2) {
            val g = ((leftGain + rightGain) / 2.0).coerceIn(0.0, 4.0)
            var i = 0
            while (i < pcm.size) {
                pcm[i] = (pcm[i] * g).toInt().coerceIn(
                    Short.MIN_VALUE.toInt(),
                    Short.MAX_VALUE.toInt(),
                ).toShort()
                i++
            }
            return
        }
        var i = 0
        while (i + 1 < pcm.size) {
            val l = pcm[i] * leftGain
            val r = pcm[i + 1] * rightGain
            pcm[i] = l.toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            pcm[i + 1] = r.toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            i += 2
        }
    }

    private fun runThroughSonic(
        pcm: ShortArray,
        channels: Int,
        sampleRate: Int,
        speed: Float,
    ): ShortArray {
        throwIfCancelled()
        if (kotlin.math.abs(speed - 1f) < 1e-4f) return pcm
        val sonic = Sonic(sampleRate, channels)
        sonic.setSpeed(speed)
        sonic.setPitch(1.0f)
        sonic.setRate(1.0f)
        val frames = pcm.size / channels
        sonic.writeShortToStream(pcm, frames)
        sonic.flushStream()
        val outFrames = sonic.samplesAvailable()
        if (outFrames <= 0) return ShortArray(0)
        val out = ShortArray(outFrames * channels)
        val readFrames = sonic.readShortFromStream(out, outFrames)
        if (readFrames <= 0) return ShortArray(0)
        return if (readFrames == outFrames) out else out.copyOf(readFrames * channels)
    }

    private fun encodeAacM4a(
        pcmInterleaved: ShortArray,
        sampleRate: Int,
        channelCount: Int,
        outputPath: String,
        onEncodeProgress: ((Double) -> Unit)? = null,
    ) {
        if (pcmInterleaved.isEmpty()) {
            throw IllegalStateException("No PCM samples to encode")
        }
        val outFile = File(outputPath)
        outFile.parentFile?.mkdirs()
        if (outFile.exists()) outFile.delete()

        val format = MediaFormat.createAudioFormat(
            MediaFormat.MIMETYPE_AUDIO_AAC,
            sampleRate,
            channelCount,
        ).apply {
            setInteger(
                MediaFormat.KEY_AAC_PROFILE,
                android.media.MediaCodecInfo.CodecProfileLevel.AACObjectLC,
            )
            setInteger(MediaFormat.KEY_BIT_RATE, AAC_BIT_RATE)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 64 * 1024)
        }

        val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
        try {
            encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            encoder.start()

            val muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            var muxerStarted = false
            var muxTrackIndex = -1

            try {
                var inputEos = false
                var outputEos = false
                var pcmOffset = 0
                var presentationUs = 0L
                val bufferInfo = MediaCodec.BufferInfo()
                var encodeCancelTick = 0
                val pcmTotal = pcmInterleaved.size.coerceAtLeast(1)

                while (!outputEos) {
                    if (++encodeCancelTick % CANCEL_CHECK_INTERVAL == 0) {
                        throwIfCancelled()
                    }
                    if (!inputEos) {
                        val inIx = encoder.dequeueInputBuffer(TIMEOUT_US)
                        if (inIx >= 0) {
                            val inBuf = encoder.getInputBuffer(inIx)!!
                            inBuf.clear()
                            val maxBytes = inBuf.remaining()
                            val maxShorts = maxBytes / 2
                            val alignedMax = maxShorts - (maxShorts % channelCount)
                            val remaining = pcmInterleaved.size - pcmOffset
                            if (remaining <= 0) {
                                encoder.queueInputBuffer(
                                    inIx,
                                    0,
                                    0,
                                    0L,
                                    MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                                )
                                inputEos = true
                                onEncodeProgress?.invoke(1.0)
                            } else {
                                val toCopy = remaining.coerceAtMost(alignedMax)
                                var i = 0
                                while (i < toCopy) {
                                    inBuf.putShort(pcmInterleaved[pcmOffset + i])
                                    i++
                                }
                                pcmOffset += toCopy
                                val frames = toCopy / channelCount
                                encoder.queueInputBuffer(inIx, 0, toCopy * 2, presentationUs, 0)
                                presentationUs += frames * 1_000_000L / sampleRate
                                onEncodeProgress?.invoke(
                                    (pcmOffset.toDouble() / pcmTotal.toDouble()).coerceIn(0.0, 1.0),
                                )
                            }
                        }
                    }

                    when (val outIx = encoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)) {
                        MediaCodec.INFO_TRY_AGAIN_LATER -> {}
                        MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                            if (muxerStarted) {
                                throw IllegalStateException("Unexpected second output format")
                            }
                            val outFormat = encoder.outputFormat
                            muxTrackIndex = muxer.addTrack(outFormat)
                            muxer.start()
                            muxerStarted = true
                        }
                        else -> {
                            if (outIx < 0) continue
                            if (muxerStarted && bufferInfo.size > 0) {
                                val encoded = encoder.getOutputBuffer(outIx)!!
                                encoded.position(bufferInfo.offset)
                                encoded.limit(bufferInfo.offset + bufferInfo.size)
                                muxer.writeSampleData(muxTrackIndex, encoded, bufferInfo)
                            }
                            encoder.releaseOutputBuffer(outIx, false)
                            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                                outputEos = true
                            }
                        }
                    }
                }

                if (!outFile.isFile || outFile.length() == 0L) {
                    throw IllegalStateException("Encoder produced empty file")
                }
                Log.i(TAG, "export ok: ${outFile.length()} bytes")
            } finally {
                try {
                    if (muxerStarted) {
                        muxer.stop()
                    }
                } catch (_: Exception) {
                }
                try {
                    muxer.release()
                } catch (_: Exception) {
                }
            }
        } finally {
            try {
                encoder.stop()
            } catch (_: Exception) {
            }
            try {
                encoder.release()
            } catch (_: Exception) {
            }
        }
    }
}
