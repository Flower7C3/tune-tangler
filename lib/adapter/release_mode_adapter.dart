import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';

class ReleaseModeAdapter extends TypeAdapter<ReleaseMode> {
  @override
  final typeId = 114;

  @override
  ReleaseMode read(BinaryReader reader) {
    final int index = reader.readInt();
    return ReleaseMode.values[index];
  }

  @override
  void write(BinaryWriter writer, ReleaseMode obj) {
    writer.writeInt(obj.index);
  }
}
