import 'package:flutter/material.dart';
import 'package:tune_tangler/entity/settings_profile.dart';

import '../config/app_config_fields.dart';
import '../config/keyboard_layout_preset.dart';
import '../entity/track.dart';
import 'hive_service.dart';

class HiveSettingsProvider extends ChangeNotifier {

  dynamic getConfig(dynamic key, {dynamic defaultValue}) {
    final raw = HiveService.get(key, defaultValue: defaultValue);
    if (key == AppConfigFieldKey.gridRowsAmount || key == AppConfigFieldKey.gridColsAmount) {
      return KeyboardLayoutPreset.coerceGridInt(raw);
    }
    if (key == AppConfigFieldKey.keyboardLayoutPreset) {
      return KeyboardLayoutPreset.fromStored(raw).name;
    }
    return raw;
  }

  Future<void> setConfig(AppConfigFieldKey key, dynamic value) async {
    switch (key) {
      case AppConfigFieldKey.keyboardLayoutPreset:
        final preset = KeyboardLayoutPreset.fromStored(value);
        await HiveService.set(key, preset.name);
        if (preset == KeyboardLayoutPreset.grid24) {
          await HiveService.set(AppConfigFieldKey.gridRowsAmount, KeyboardLayoutPreset.grid24Rows);
          await HiveService.set(AppConfigFieldKey.gridColsAmount, KeyboardLayoutPreset.grid24Cols);
        }
        break;
      case AppConfigFieldKey.gridRowsAmount:
        if (_activeKeyboardLayout == KeyboardLayoutPreset.grid24) {
          await HiveService.set(key, KeyboardLayoutPreset.grid24Rows);
        } else {
          await HiveService.set(key, KeyboardLayoutPreset.coerceGridInt(value));
        }
        break;
      case AppConfigFieldKey.gridColsAmount:
        if (_activeKeyboardLayout == KeyboardLayoutPreset.grid24) {
          await HiveService.set(key, KeyboardLayoutPreset.grid24Cols);
        } else {
          await HiveService.set(key, KeyboardLayoutPreset.coerceGridInt(value));
        }
        break;
      default:
        await HiveService.set(key, value);
    }
    reload();
  }

  KeyboardLayoutPreset get _activeKeyboardLayout => KeyboardLayoutPreset.fromStored(
    HiveService.get(AppConfigFieldKey.keyboardLayoutPreset),
  );

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
  Future<void> reload() async {
    notifyListeners();
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
