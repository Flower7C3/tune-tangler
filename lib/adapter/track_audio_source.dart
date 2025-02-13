import 'package:hive/hive.dart';

enum TrackAudioSource {
  recording,
  file,
}

class TrackAudioSourceAdapter extends TypeAdapter<TrackAudioSource> {
  @override
  get typeId => 117;

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
