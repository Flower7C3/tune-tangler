package pro.kwiatek.tune_tangler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Draw behind system bars; Flutter applies MediaQuery insets for layout.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    companion object {
        private const val SCREENSHOT_CHANNEL = "pro.kwiatek.tune_tangler/screenshot"
        private const val AUDIO_EXPORT_CHANNEL = "pro.kwiatek.tune_tangler/audio_export"
        private const val AUDIO_EXPORT_PROGRESS_CHANNEL = "pro.kwiatek.tune_tangler/audio_export_progress"
        private const val ACTION = "pro.kwiatek.tune_tangler.SCREENSHOT_CMD"
    }

    private var methodChannel: MethodChannel? = null
    private var audioExportChannel: MethodChannel? = null
    private var audioExportProgressChannel: MethodChannel? = null
    private var receiver: BroadcastReceiver? = null
    private val audioExportExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREENSHOT_CHANNEL)

        audioExportChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_EXPORT_CHANNEL)
        audioExportProgressChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_EXPORT_PROGRESS_CHANNEL,
        )
        audioExportChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "cancelExportProcessed" -> {
                    TrackAudioExporter.requestCancelExport()
                    result.success(null)
                }
                "exportProcessed" -> {
                    audioExportExecutor.execute {
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val args = call.arguments as Map<String, Any?>
                            val inputPath = args["inputPath"] as String
                            val outputPath = args["outputPath"] as String
                            val startMs = (args["startMs"] as Number).toLong()
                            val endMs = (args["endMs"] as Number).toLong()
                            val volume = (args["volume"] as Number).toDouble()
                            val balance = (args["balance"] as Number).toDouble()
                            val speed = (args["speed"] as Number).toDouble()
                            TrackAudioExporter.prepareExportSession()
                            TrackAudioExporter.exportProcessed(
                                inputPath = inputPath,
                                outputPath = outputPath,
                                startMs = startMs,
                                endMs = endMs,
                                volume = volume,
                                balance = balance,
                                speed = speed,
                                onProgress = { p ->
                                    runOnUiThread {
                                        audioExportProgressChannel?.invokeMethod("setProgress", p)
                                    }
                                },
                            )
                            runOnUiThread { result.success(null) }
                        } catch (e: TrackAudioExporter.ExportCancelledException) {
                            runOnUiThread {
                                result.error("export_cancelled", e.message, null)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("export_failed", e.message, null)
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val cmd = intent?.getStringExtra("cmd") ?: return
                val args = HashMap<String, Any?>()
                intent.extras?.keySet()?.forEach { key ->
                    if (key != "cmd") args[key] = intent.getStringExtra(key)
                }
                runOnUiThread {
                    methodChannel?.invokeMethod(cmd, args)
                }
            }
        }

        val filter = IntentFilter(ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
    }

    override fun onDestroy() {
        receiver?.let { unregisterReceiver(it) }
        audioExportChannel?.setMethodCallHandler(null)
        audioExportProgressChannel = null
        audioExportExecutor.shutdown()
        super.onDestroy()
    }
}
