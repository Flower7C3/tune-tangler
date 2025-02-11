import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import 'package:tune_tangler/config/app_global_config.dart';

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
  playbackDuration,
  playbackStartAtPosition,
  playbackEndAtPosition,
  keyboardKey,
  audioSource,
}

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final typeId = 111;

  @override
  Track read(BinaryReader reader) {
    final Map<dynamic, dynamic> data = reader.readMap();
    var track = Track(data[TrackAdapterKey.rowIndex], data[TrackAdapterKey.colIndex]);
    track.setName(data[TrackAdapterKey.name]);
    track.setPlaybackReleaseMode(ReleaseMode.values[data[TrackAdapterKey.playbackReleaseMode]]);
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume] ?? AppGlobalConfig.trackPlaybackVolume.defaultValue);
    track.setPlaybackBalance(data[TrackAdapterKey.playbackBalance] ?? AppGlobalConfig.trackPlaybackBalance.defaultValue);
    track.setPlaybackSpeed(data[TrackAdapterKey.playbackSpeed] ?? AppGlobalConfig.trackPlaybackSpeed.defaultValue);
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey] ?? '');
    track.setAudioSource(data[TrackAdapterKey.audioSource]);
    track.setAudioEncoder(data[TrackAdapterKey.audioEncoder]);
    track.setSampleRate(data[TrackAdapterKey.sampleRate]);
    track.setBitRate(data[TrackAdapterKey.bitRate]);
    track.setPath(data[TrackAdapterKey.path], playbackStartAtPosition: data[TrackAdapterKey.playbackStartAtPosition], playbackEndAtPosition: data[TrackAdapterKey.playbackEndAtPosition]);
    return track;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap({
      TrackAdapterKey.rowIndex: obj.rowIndex,
      TrackAdapterKey.colIndex: obj.colIndex,
      TrackAdapterKey.name: obj.name.value,
      TrackAdapterKey.path: obj.path,
      TrackAdapterKey.playbackReleaseMode: obj.playbackReleaseMode.value.index,
      TrackAdapterKey.playbackVolume: obj.playbackVolume.value,
      TrackAdapterKey.playbackBalance: obj.playbackBalance.value,
      TrackAdapterKey.playbackSpeed: obj.playbackSpeed.value,
      TrackAdapterKey.playbackStartAtPosition: obj.playbackStartAtPosition.value,
      TrackAdapterKey.playbackEndAtPosition: obj.playbackEndAtPosition.value,
      TrackAdapterKey.keyboardKey: obj.keyboardKey.value,
      TrackAdapterKey.audioSource: obj.audioSource,
      TrackAdapterKey.audioEncoder: obj.audioEncoder,
      TrackAdapterKey.sampleRate: obj.sampleRate,
      TrackAdapterKey.bitRate: obj.bitRate,
    });
  }
}

class TrackAdapterKeyAdapter extends TypeAdapter<TrackAdapterKey> {
  @override
  final typeId = 112;

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

class TrackAudioSourceAdapter extends TypeAdapter<TrackAudioSource> {
  @override
  final typeId = 117;

  @override
  TrackAudioSource read(BinaryReader reader) {
    final int index = reader.readInt();
    return TrackAudioSource.values[index];
  }

  @override
  void write(BinaryWriter writer, TrackAudioSource obj) {
    writer.writeInt(obj.index);
  }
}
