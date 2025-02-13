import 'package:flutter/material.dart';

import 'app_global_config.dart';

enum AppConfigSpace {
  global,
  track,
}

enum AppConfigFieldKey {
  locale,
  themeMode,
  themeSeedColor,
  wakelockEnabled,
  recordingInputDevice,
  recordingAudioEncoder,
  recordingSampleRate,
  recordingBitRate,
  recordingAudioModeStereo,
  recordingAutoGain,
  recordingEchoCancel,
  recordingNoiseSuppress,
  gridRowsAmount,
  gridColsAmount,
}

final class AppConfigField {
  final AppConfigFieldKey key;
  final dynamic defaultValue;

  AppConfigField(this.key, this.defaultValue);
}

final class AppGlobalConfigField extends AppConfigField {
  AppGlobalConfigField(super.key, super.defaultValue);
}

final class AppRecordingConfigField extends AppConfigField {
  AppRecordingConfigField(super.key, super.defaultValue);
}

final class AppGlobalConfigFieldsCollection {
  static final List<AppConfigField> _fields = <AppConfigField>[
    AppGlobalConfigField(AppConfigFieldKey.locale, AppGlobalConfig.languages.defaultValue),
    AppGlobalConfigField(AppConfigFieldKey.themeMode, ThemeMode.system),
    AppGlobalConfigField(AppConfigFieldKey.themeSeedColor, AppGlobalConfig.userInterfaceColor.defaultValue),
    AppGlobalConfigField(AppConfigFieldKey.wakelockEnabled, false),
    AppGlobalConfigField(AppConfigFieldKey.gridRowsAmount, AppGlobalConfig.gridRows.defaultValue.toInt()),
    AppGlobalConfigField(AppConfigFieldKey.gridColsAmount, AppGlobalConfig.gridCols.defaultValue.toInt()),
    AppRecordingConfigField(AppConfigFieldKey.recordingInputDevice, null),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioEncoder, AppGlobalConfig.recordingAudioEncoder.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingSampleRate, AppGlobalConfig.recordingSampleRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingBitRate, AppGlobalConfig.recordingBitRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioModeStereo, true),
    AppRecordingConfigField(AppConfigFieldKey.recordingAutoGain, false),
    AppRecordingConfigField(AppConfigFieldKey.recordingEchoCancel, false),
    AppRecordingConfigField(AppConfigFieldKey.recordingNoiseSuppress, false),
  ];

  static List<AppConfigField> get list => _fields;

  static List<AppGlobalConfigField> get listGlobal => list.whereType<AppGlobalConfigField>().toList();

  static List<AppRecordingConfigField> get listRecording => list.whereType<AppRecordingConfigField>().toList();

  static AppConfigField field(dynamic key) => list.firstWhere((item) => item.key == key);
}
