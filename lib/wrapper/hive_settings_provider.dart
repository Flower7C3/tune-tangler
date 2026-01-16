import 'package:flutter/material.dart';
import 'package:tune_tangler/entity/settings_profile.dart';

import '../config/app_config_fields.dart';
import '../entity/track.dart';
import 'hive_service.dart';

class HiveSettingsProvider extends ChangeNotifier {
  /// Version counter to force grid reload
  int _version = 0;

  int get version => _version;

  dynamic getConfig(dynamic key, {dynamic defaultValue}) => HiveService.get(key, defaultValue: defaultValue);

  Future<void> setConfig(AppConfigFieldKey key, dynamic value) async {
    HiveService.set(key, value);
    /// Use softReload() for all settings to update drawer UI immediately
    /// For locale, themeMode, and themeSeedColor, main_screen.dart already has
    /// Selectors that listen to these values directly and will update MaterialApp
    /// without needing a full reload (which would close the drawer)
    /// HomeScreen also has a Selector for locale to update AppWrapper.trans
    /// For gridRowsAmount and gridColsAmount, reload is handled after drawer close
    softReload();
  }

  List<SettingsProfile> get settingsProfilesList => HiveService.listProfiles;

  Future<void> addProfile(SettingsProfile value) async {
    HiveService.addProfile(value);
    reload();
  }

  Future<void> deleteProfile(int index) async {
    HiveService.deleteProfile(index);
    reload();
  }

  /// Notifies listeners about settings changes without triggering full reload
  /// This is used when settings are changed in drawer to update UI immediately
  /// without refreshing the entire screen
  Future<void> softReload() async {
    notifyListeners();
  }

  Future<void> reload() async {
    _version++;
    softReload();
  }

  Track getTrack(int rowIndex, int columnIndex) => getAndInitializeTrack(rowIndex, columnIndex);

  Track getAndInitializeTrack(int rowIndex, int columnIndex) {
    Track track = HiveService.get(TrackId(rowIndex, columnIndex));
    if (!track.streamsInitialized) {
      track.setStreamsInitialized();
      saveTrack(track);
    }
    return track;
  }

  Future<void> saveTrack(Track track) async {
    HiveService.set(track.id, track);
  }
}
