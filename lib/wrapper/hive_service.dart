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
        _globalSettingsBox.put(AppGlobalConfigFieldsCollection.field(key).key.name, value);
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
            AppGlobalConfigFieldsCollection.field(key).key.name,
            defaultValue: AppGlobalConfigFieldsCollection.field(key).defaultValue,
          ),
        TrackId _ => _getTrack(key),
        Object() => throw UnimplementedError(),
        null => throw UnimplementedError(),
      };

  static Track _getTrack(TrackId trackId) {
    Track track = _trackSettingsBox.get(trackId.toString(), defaultValue: Track(trackId));
    if (!track.streamsInitialized) {
      track.setStreamsInitialized();
      set(trackId, track);
    }
    return track;
  }

  static Future<void> delete(String key, {AppConfigSpace space = AppConfigSpace.global}) async => switch (space) {
        AppConfigSpace.global => _globalSettingsBox.delete(AppGlobalConfigFieldsCollection.field(key).key.name),
        AppConfigSpace.track => await _trackSettingsBox.delete(key),
      };

  static bool containsKey(String key, {AppConfigSpace space = AppConfigSpace.global}) => switch (space) {
        AppConfigSpace.global => _globalSettingsBox.containsKey(AppGlobalConfigFieldsCollection.field(key).key.name),
        AppConfigSpace.track => _trackSettingsBox.containsKey(key),
      };
}
