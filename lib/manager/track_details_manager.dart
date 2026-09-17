import 'package:flutter/material.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/manager/recording_manager.dart';

import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';
import 'track_details_sheet.dart';

class TrackDetailsManager {
  final RecordingManager _recordingManager;
  late final TrackDetailsSheet _sheet;

  TrackDetailsManager(
    BuildContext context,
    HiveSettingsProvider settings,
    AppLocalizations trans,
    UIHelper uiHelper,
    TrackRepository trackRepository,
    this._recordingManager,
  ) {
    _sheet = TrackDetailsSheet(
      context,
      settings,
      trans,
      uiHelper,
      trackRepository,
      _recordingManager,
    );
  }

  void runClickAction(Track track) => switch (track.state.value) {
    TrackState.empty => _recordingManager.startRecording(track),
    TrackState.recording => _recordingManager.stopAndSaveRecording(track),
    TrackState.idle => track.startPlaying(),
    TrackState.playing => track.stopPlaying(),
    TrackState.paused => track.resumePlaying(),
    _ => null,
  };

  void openModal(Track track) => _sheet.open(track);
}
