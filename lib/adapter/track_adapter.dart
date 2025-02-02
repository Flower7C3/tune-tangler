import 'package:hive/hive.dart';
import 'package:record/record.dart';

import '../entity/track.dart';

enum TrackAdapterKey {
  rowIndex,
  colIndex,
  name,
  path,
  audioEncoder,
  bitRate,
  sampleRate,
  recorderState,
  playbackMode,
  playbackVolume,
  playbackBalance,
  playbackSpeed,
  keyboardKey,
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final typeId = 3;

  @override
  Track read(BinaryReader reader) {
    final Map<dynamic, dynamic> data = reader.readMap();
    var track = Track(data[TrackAdapterKey.rowIndex.toString()], data[TrackAdapterKey.colIndex.toString()]);
    track.setName(data[TrackAdapterKey.name.toString()]);
    int? audioEncoderIndex = data[TrackAdapterKey.audioEncoder.toString()];
    track.setAudioEncoder(audioEncoderIndex == null ? null : AudioEncoder.values[audioEncoderIndex]);
    track.setSampleRate(data[TrackAdapterKey.sampleRate.toString()]);
    track.setBitRate(data[TrackAdapterKey.bitRate.toString()]);
    if (data[TrackAdapterKey.recorderState] == null) {
      track.setRecordingState(RecorderState.empty);
    } else {
      RecorderState state = RecorderState.values[data[TrackAdapterKey.recorderState.toString()]];
      track.setRecordingState((state == RecorderState.ready) ? RecorderState.ready : RecorderState.empty);
    }
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume.toString()] ?? Track.defaultPlaybackVolume);
    track.setPlaybackBalance(data[TrackAdapterKey.playbackBalance.toString()] ?? Track.defaultPlaybackBalance);
    track.setPlaybackSpeed(data[TrackAdapterKey.playbackSpeed.toString()] ?? Track.defaultPlaybackSpeed);
    track.setPlaybackMode(data[TrackAdapterKey.playbackMode.toString()] ?? Track.defaultPlaybackModeSingle);
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey.toString()] ?? '');
    track.setPath(data[TrackAdapterKey.path.toString()]);
    return track;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap({
      TrackAdapterKey.rowIndex.toString(): obj.rowIndex,
      TrackAdapterKey.colIndex.toString(): obj.colIndex,
      TrackAdapterKey.name.toString(): obj.name.value,
      TrackAdapterKey.path.toString(): obj.path,
      TrackAdapterKey.audioEncoder.toString(): (obj.audioEncoder == null) ? 0 : obj.audioEncoder?.index,
      TrackAdapterKey.sampleRate.toString(): obj.sampleRate,
      TrackAdapterKey.bitRate.toString(): obj.bitRate,
      TrackAdapterKey.recorderState.toString(): obj.recorderState.index,
      TrackAdapterKey.playbackMode.toString(): obj.playbackModeSingle.value,
      TrackAdapterKey.playbackVolume.toString(): obj.playbackVolume.value,
      TrackAdapterKey.playbackBalance.toString(): obj.playbackBalance.value,
      TrackAdapterKey.playbackSpeed.toString(): obj.playbackSpeed.value,
      TrackAdapterKey.keyboardKey.toString(): obj.keyboardKey.value,
    });
  }
}
