import 'package:flutter/material.dart';

import 'app_global_config.dart';

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

final class AppScreenConfigField extends AppConfigField {
  AppScreenConfigField(super.key, super.defaultValue);
}

final class AppRecordingConfigField extends AppConfigField {
  AppRecordingConfigField(super.key, super.defaultValue);
}

final class AppConfigFieldsCollection {
  static final List<AppConfigField> _fields = <AppConfigField>[
    AppScreenConfigField(AppConfigFieldKey.locale, AppGlobalConfig.languages.defaultValue),
    AppScreenConfigField(AppConfigFieldKey.themeMode, ThemeMode.system),
    AppScreenConfigField(AppConfigFieldKey.themeSeedColor, AppGlobalConfig.userInterfaceColor.defaultValue),
    AppScreenConfigField(AppConfigFieldKey.wakelockEnabled, false),
    AppScreenConfigField(AppConfigFieldKey.gridRowsAmount, AppGlobalConfig.gridRows.defaultValue.toInt()),
    AppScreenConfigField(AppConfigFieldKey.gridColsAmount, AppGlobalConfig.gridCols.defaultValue.toInt()),
    AppRecordingConfigField(AppConfigFieldKey.recordingInputDevice, null),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioEncoder, AppGlobalConfig.recordingAudioEncoder.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingSampleRate, AppGlobalConfig.recordingSampleRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingBitRate, AppGlobalConfig.recordingBitRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioModeStereo, true),
    AppRecordingConfigField(AppConfigFieldKey.recordingAutoGain, false),
    AppRecordingConfigField(AppConfigFieldKey.recordingEchoCancel, false),
    AppRecordingConfigField(AppConfigFieldKey.recordingNoiseSuppress, false),
  ];

  static List<AppScreenConfigField> get listScreen => _fields.whereType<AppScreenConfigField>().toList();

  static List<AppRecordingConfigField> get listRecording => _fields.whereType<AppRecordingConfigField>().toList();

  static AppConfigField field(AppConfigFieldKey key) => _fields.firstWhere((item) => item.key == key);
}
