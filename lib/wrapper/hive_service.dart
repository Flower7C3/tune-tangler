import 'package:hive/hive.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/app_config_fields.dart';
import '../entity/track.dart';

class HiveService {
  static late Box _globalSettingsBox;
  static late Box _trackSettingsBox;

  static Future<void> init() async {
    _globalSettingsBox = await Hive.openBox('settings');
    _trackSettingsBox = await Hive.openBox<Track>('tracks');
  }

  static Future<void> dispose() async {
    _globalSettingsBox.close();
    _trackSettingsBox.close();
  }

  static Future<void> set(dynamic key, dynamic value, {bool updateState = false}) async {
    switch (key) {
      case AppConfigFieldKey _:
        _globalSettingsBox.put(AppConfigFieldsCollection.field(key).key.name, value);
        switch (key) {
          case AppConfigFieldKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
          default:
        }
        break;
      case TrackId _:
        _trackSettingsBox.put(key.toString(), value);
        break;
    }
  }

  static dynamic get(dynamic key, {dynamic defaultValue}) => switch (key) {
        AppConfigFieldKey _ => _globalSettingsBox.get(
            AppConfigFieldsCollection.field(key).key.name,
            defaultValue: AppConfigFieldsCollection.field(key).defaultValue,
          ),
        TrackId _ => _trackSettingsBox.get(
            key.toString(),
            defaultValue: Track(key),
          ),
        Object() => throw UnimplementedError(),
        null => throw UnimplementedError(),
      };

  static Future<void> delete(dynamic key) async => switch (key) {
        AppConfigFieldKey _ => _globalSettingsBox.delete(AppConfigFieldsCollection.field(key).key.name),
        TrackId _ => await _trackSettingsBox.delete(key.toString()),
        Object() => throw UnimplementedError(),
        null => throw UnimplementedError(),
      };

  static bool containsKey(dynamic key) => switch (key) {
        AppConfigFieldKey _ => _globalSettingsBox.containsKey(AppConfigFieldsCollection.field(key).key.name),
        TrackId _ => _trackSettingsBox.containsKey(key.toString()),
        Object() => throw UnimplementedError(),
        null => throw UnimplementedError(),
      };
}
