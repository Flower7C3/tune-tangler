import 'package:hive/hive.dart';
import 'package:record/record.dart';

class AudioEncoderAdapter extends TypeAdapter<AudioEncoder> {
  @override
  get typeId => 116;

  @override
  AudioEncoder read(BinaryReader reader) {
    final index = reader.readInt();
    return AudioEncoder.values[index];
  }

  @override
  void write(BinaryWriter writer, AudioEncoder obj) {
    writer.writeInt(obj.index);
  }
}
