import 'package:hive/hive.dart';

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  get typeId => 113;

  @override
  Duration read(BinaryReader reader) {
    final int index = reader.readInt();
    return Duration(microseconds: index);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}
