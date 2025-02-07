import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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
  final typeId = 30;

  @override
  Track read(BinaryReader reader) {
    final Map<dynamic, dynamic> data = reader.readMap();
    var track = Track(data[TrackAdapterKey.rowIndex], data[TrackAdapterKey.colIndex]);
    track.setName(data[TrackAdapterKey.name]);
    if (data[TrackAdapterKey.recorderState] == null) {
      track.setRecorderState(RecorderState.empty);
    } else {
      RecorderState state = RecorderState.values[data[TrackAdapterKey.recorderState]];
      track.setRecorderState((state == RecorderState.ready) ? RecorderState.ready : RecorderState.empty);
    }
    track.setPlaybackReleaseMode(ReleaseMode.values[data[TrackAdapterKey.playbackReleaseMode]]);
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume] ?? AppGlobalConfig.trackPlaybackVolume.defaultValue);
    track.setPlaybackBalance(data[TrackAdapterKey.playbackBalance] ?? AppGlobalConfig.trackPlaybackBalance.defaultValue);
    track.setPlaybackSpeed(data[TrackAdapterKey.playbackSpeed] ?? AppGlobalConfig.trackPlaybackSpeed.defaultValue);
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey] ?? '');
    track.setPath(data[TrackAdapterKey.path]);
    return track;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap({
      TrackAdapterKey.rowIndex: obj.rowIndex,
      TrackAdapterKey.colIndex: obj.colIndex,
      TrackAdapterKey.name: obj.name.value,
      TrackAdapterKey.path: obj.path,
      TrackAdapterKey.recorderState: obj.recorderState.value.index,
      TrackAdapterKey.playbackReleaseMode: obj.playbackReleaseMode.value.index,
      TrackAdapterKey.playbackVolume: obj.playbackVolume.value,
      TrackAdapterKey.playbackBalance: obj.playbackBalance.value,
      TrackAdapterKey.playbackSpeed: obj.playbackSpeed.value,
      TrackAdapterKey.keyboardKey: obj.keyboardKey.value,
    });
  }
}

class TrackAdapterKeyAdapter extends TypeAdapter<TrackAdapterKey> {
  @override
  final typeId = 33;

  @override
  TrackAdapterKey read(BinaryReader reader) {
    final int index = reader.readInt();
    return TrackAdapterKey.values[index];
  }

  @override
  void write(BinaryWriter writer, TrackAdapterKey obj) {
    writer.writeInt(obj.index);
  }
}
