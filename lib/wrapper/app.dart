import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/manager/track_details_manager.dart';

import '../helper/ui_helper.dart';
import '../manager/recording_manager.dart';
import '../provider/permission_provider.dart';
import '../repository/track_repository.dart';
import '../src/generated/app_localizations.dart';
import 'hive_settings_provider.dart';

class AppWrapper {
  final HiveSettingsProvider settings;
  final PermissionProvider permissionProvider;
  final AudioRecorder audioRecorder;
  final TrackRepository trackRepository;
  final FocusNode focusNode;
  late TrackDetailsManager trackDetailsManager;
  late BuildContext context;
  late AppLocalizations trans;
  late UIHelper uiHelper;

  AppWrapper({
    required this.settings,
    required this.permissionProvider,
    required this.audioRecorder,
    required this.trackRepository,
    required this.focusNode,
  });

  void setContext(BuildContext ctx) {
    context = ctx;
    trans = AppLocalizations.of(context)!;
    uiHelper = UIHelper(context);
    RecordingManager recordingManager = RecordingManager(settings, trans, uiHelper, trackRepository, audioRecorder);
    trackDetailsManager = TrackDetailsManager(context, settings, trans, uiHelper, trackRepository, recordingManager);
  }
}
