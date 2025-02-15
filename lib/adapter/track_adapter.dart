import 'package:hive/hive.dart';

import '../entity/track.dart';

class TrackAdapter extends TypeAdapter<Track> {
  @override
  get typeId => 111;

  @override
  Track read(BinaryReader reader) {
    final Map data = reader.readMap();
    return Track.fromMap(data);
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer.writeMap(obj.toMap());
  }
}
