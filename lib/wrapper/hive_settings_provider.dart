import 'package:flutter/material.dart';

import '../config/app_config_fields.dart';
import '../entity/track.dart';
import 'hive_service.dart';

class HiveSettingsProvider extends ChangeNotifier {
  dynamic getConfig(dynamic key, {dynamic defaultValue}) => HiveService.get(key, defaultValue: defaultValue);

  Future<void> setConfig(AppConfigFieldKey key, dynamic value) async {
    HiveService.set(key, value);
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
