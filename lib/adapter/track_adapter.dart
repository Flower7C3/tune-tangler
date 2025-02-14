import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';
import 'package:tune_tangler/config/app_global_config.dart';

import '../entity/track.dart';
import 'track_adapter_key.dart';


class TrackAdapter extends TypeAdapter<Track> {
  @override
  get typeId => 111;

  @override
  Track read(BinaryReader reader) {
    final Map data = reader.readMap();
    TrackId trackId = data[TrackAdapterKey.trackId];
    Track track = Track(trackId);
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
    track.setPath(data[TrackAdapterKey.path],
        playbackStartAtPosition: data[TrackAdapterKey.playbackStartAtPosition], playbackEndAtPosition: data[TrackAdapterKey.playbackEndAtPosition]);
    return track;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap({
      TrackAdapterKey.trackId: obj.id,
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
