import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../helper/ui_helper.dart';
import '../provider/permission_provider.dart';
import '../repository/track_repository.dart';
import '../src/generated/app_localizations.dart';
import 'hive_settings_provider.dart';

class AppWrapper {
  final HiveSettingsProvider settings;
  late  AppLocalizations trans;
  final PermissionProvider permissionProvider;
  final AudioRecorder audioRecorder;
  final TrackRepository trackRepository;
  final FocusNode focusNode;
  final bool hasDynamicColor;
  final GlobalKey<ScaffoldState> scaffoldKey;
  late BuildContext context;
  late UIHelper uiHelper;

  AppWrapper({
    required this.settings,
    required this.permissionProvider,
    required this.audioRecorder,
    required this.trackRepository,
    required this.focusNode,
    required this.scaffoldKey,
    this.hasDynamicColor = false,
  });

  void setContext(BuildContext ctx) {
    context = ctx;
    trans = AppLocalizations.of(context)!;
    uiHelper = UIHelper(context);
  }
}
