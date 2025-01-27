import 'package:hive/hive.dart';

import '../entity/track.dart';

enum TrackAdapterKey {
  rowIndex,
  colIndex,
  name,
  state,
  playbackMode,
  playbackVolume,
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
    track.setState(TrackState.values[data[TrackAdapterKey.state.toString()]]);
    track.setPlaybackMode(data[TrackAdapterKey.playbackMode.toString()]);
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume.toString()]);
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey.toString()]);
    return track;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap({
      TrackAdapterKey.rowIndex.toString(): obj.rowIndex(),
      TrackAdapterKey.colIndex.toString(): obj.colIndex(),
      TrackAdapterKey.name.toString(): obj.name(),
      TrackAdapterKey.state.toString(): obj.state().index,
      TrackAdapterKey.playbackMode.toString(): obj.isPlaybackModeSingle(),
      TrackAdapterKey.playbackVolume.toString(): obj.playbackVolume(),
      TrackAdapterKey.keyboardKey.toString(): obj.keyboardKey(),
    });
  }
}
