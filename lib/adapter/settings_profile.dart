import 'package:hive/hive.dart';

import '../entity/settings_profile.dart';

class SettingsProfileAdapter extends TypeAdapter<SettingsProfile> {
  @override
  SettingsProfile read(BinaryReader reader) {
    final Map data = reader.readMap();
    return SettingsProfile.fromMap(data);
  }

  @override
  int get typeId => 121;

  @override
  void write(BinaryWriter writer, SettingsProfile obj) {
    writer.writeMap(obj.toMap());
  }

}
