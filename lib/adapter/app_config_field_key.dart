import 'package:hive/hive.dart';

import '../config/app_config_fields.dart';

class AppConfigFieldKeyAdapter extends TypeAdapter<AppConfigFieldKey> {
  @override
  get typeId => 122;

  @override
  AppConfigFieldKey read(BinaryReader reader) {
    final int index = reader.readInt();
    return AppConfigFieldKey.values[index];
  }

  @override
  void write(BinaryWriter writer, AppConfigFieldKey obj) {
    writer.writeInt(obj.index);
  }
}
