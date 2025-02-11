
import 'package:flutter/material.dart';

import 'app_global_config.dart';

enum AppConfigSpace {
  global,
  track,
}

enum AppConfigFieldKey {
  locale,
  themeMode,
  isThemeModeDark,
  isThemeModeLight,
  isThemeModeSystem,
  themeSeedColor,
  wakelockEnabled,
  recording,
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
  final String boxFieldName;
  final dynamic defaultValue;

  AppConfigField(this.key, this.boxFieldName, this.defaultValue);
}
final class AppGlobalConfigField  extends AppConfigField{
  AppGlobalConfigField(super.key, super.boxFieldName, super.defaultValue);
}

final class AppRecordingConfigField extends AppConfigField {
  AppRecordingConfigField(super.key, super.boxFieldName, super.defaultValue);
}

final class AppGlobalConfigFieldsCollection {
  static final List<AppConfigField> _fields = <AppConfigField>[
    AppGlobalConfigField(AppConfigFieldKey.locale, 'locale', AppGlobalConfig.languages.defaultValue),
    AppGlobalConfigField(AppConfigFieldKey.themeMode, 'themeMode', ThemeMode.dark),
    AppGlobalConfigField(AppConfigFieldKey.themeSeedColor, 'themeSeedColor', AppGlobalConfig.userInterfaceColor.defaultValue),
    AppGlobalConfigField(AppConfigFieldKey.wakelockEnabled, 'keepScreenOnEnabled', false),
    AppGlobalConfigField(AppConfigFieldKey.gridRowsAmount, 'gridRowsAmount', AppGlobalConfig.gridRows.defaultValue.toInt()),
    AppGlobalConfigField(AppConfigFieldKey.gridColsAmount, 'gridColsAmount', AppGlobalConfig.gridCols.defaultValue.toInt()),
    AppRecordingConfigField(AppConfigFieldKey.recordingInputDevice, 'recordingInputDevice', null),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioEncoder, 'recordingAudioEncoder', AppGlobalConfig.recordingAudioEncoder.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingSampleRate, 'recordingSampleRate', AppGlobalConfig.recordingSampleRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingBitRate, 'recordingBitRate', AppGlobalConfig.recordingBitRate.defaultValue),
    AppRecordingConfigField(AppConfigFieldKey.recordingAudioModeStereo, 'recordingAudioModeStereo', true),
    AppRecordingConfigField(AppConfigFieldKey.recordingAutoGain, 'recordingAudioAutoGain', false),
    AppRecordingConfigField(AppConfigFieldKey.recordingEchoCancel, 'recordingAudioEchoCancel', false),
    AppRecordingConfigField(AppConfigFieldKey.recordingNoiseSuppress, 'recordingAudioNoiseSuppress', false),
  ];

  static List<AppConfigField> get list => _fields;
  static List<AppGlobalConfigField> get listGlobal => list.whereType<AppGlobalConfigField>().toList();
  static List<AppRecordingConfigField> get listRecording => list.whereType<AppRecordingConfigField>().toList();

  static AppConfigField field(dynamic key) => list.firstWhere((item) => item.key == key);
}