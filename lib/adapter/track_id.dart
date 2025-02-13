import 'package:hive/hive.dart';

import '../entity/track.dart';

class TrackIdAdapter extends TypeAdapter<TrackId> {
  @override
  get typeId => 118;

  @override
  TrackId read(BinaryReader reader) {
    final List<int> index = reader.readIntList();
    return TrackId(index[0], index[1]);
  }

  @override
  void write(BinaryWriter writer, TrackId obj) {
    writer.writeIntList(obj.toList());
  }
}
