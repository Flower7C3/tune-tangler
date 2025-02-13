import 'package:hive/hive.dart';

enum TrackAdapterKey {
  trackId,
  name,
  path,
  audioEncoder,
  bitRate,
  sampleRate,
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

class TrackAdapterKeyAdapter extends TypeAdapter<TrackAdapterKey> {
  @override
  get typeId => 112;

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
