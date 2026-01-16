import 'package:flutter/material.dart';
import 'package:tune_tangler/entity/settings_profile.dart';

import '../config/app_config_fields.dart';
import '../entity/track.dart';
import 'hive_service.dart';

class HiveSettingsProvider extends ChangeNotifier {
  // Licznik wersji do wymuszenia odświeżenia widoku
  int _version = 0;
  int get version => _version;

  dynamic getConfig(dynamic key, {dynamic defaultValue}) =>
      HiveService.get(key, defaultValue: defaultValue);

  Future<void> setConfig(AppConfigFieldKey key, dynamic value) async {
    HiveService.set(key, value);
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

  Future<void> reload() async {
    _version++;
    notifyListeners();
  }

  Track getTrack(int rowIndex, int columnIndex) =>
      getAndInitializeTrack(rowIndex, columnIndex);

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
