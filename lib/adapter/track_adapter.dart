import 'package:hive/hive.dart';
import 'package:tune_tangler/config/config.dart';

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
  playbackReleaseMode,
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
    if (data[TrackAdapterKey.recorderState] == null) {
      track.setRecordingState(RecorderState.empty);
    } else {
      RecorderState state = RecorderState.values[data[TrackAdapterKey.recorderState.toString()]];
      track.setRecordingState((state == RecorderState.ready) ? RecorderState.ready : RecorderState.empty);
    }
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume.toString()] ?? AppGlobalConfig.trackPlaybackVolume.defaultValue);
    track.setPlaybackBalance(data[TrackAdapterKey.playbackBalance.toString()] ?? AppGlobalConfig.trackPlaybackBalance.defaultValue);
    track.setPlaybackSpeed(data[TrackAdapterKey.playbackSpeed.toString()] ?? AppGlobalConfig.trackPlaybackSpeed.defaultValue);
    track.setPlaybackReleaseMode(data[TrackAdapterKey.playbackReleaseMode.toString()] ?? AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);
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
      TrackAdapterKey.recorderState.toString(): obj.recorderState.value.index,
      TrackAdapterKey.playbackReleaseMode.toString(): obj.playbackReleaseMode.value.index,
      TrackAdapterKey.playbackVolume.toString(): obj.playbackVolume.value,
      TrackAdapterKey.playbackBalance.toString(): obj.playbackBalance.value,
      TrackAdapterKey.playbackSpeed.toString(): obj.playbackSpeed.value,
      TrackAdapterKey.keyboardKey.toString(): obj.keyboardKey.value,
    });
  }
}
