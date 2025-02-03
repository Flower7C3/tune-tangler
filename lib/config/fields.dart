
import 'package:flutter/material.dart';

import 'config.dart';

enum AppConfigSpace {
  global,
  track,
}

enum AppGlobalConfigFieldKey {
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

final class AppGlobalConfigField {
  final AppGlobalConfigFieldKey key;
  final String boxFieldName;
  final dynamic defaultValue;

  AppGlobalConfigField(this.key, this.boxFieldName, this.defaultValue);
}

final class AppGlobalConfigFieldsCollection {
  static final List<AppGlobalConfigField> _fields = <AppGlobalConfigField>[
    AppGlobalConfigField(AppGlobalConfigFieldKey.locale, 'locale', AppGlobalConfig.languages.defaultValue),
    AppGlobalConfigField(AppGlobalConfigFieldKey.themeMode, 'themeMode', ThemeMode.dark),
    AppGlobalConfigField(AppGlobalConfigFieldKey.themeSeedColor, 'themeSeedColor', AppGlobalConfig.userInterfaceColor.defaultValue),
    AppGlobalConfigField(AppGlobalConfigFieldKey.wakelockEnabled, 'keepScreenOnEnabled', false),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingInputDevice, 'recordingInputDevice', null),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingAudioEncoder, 'recordingAudioEncoder', AppGlobalConfig.recordingAudioEncoder.defaultValue),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingSampleRate, 'recordingSampleRate', AppGlobalConfig.recordingSampleRate.defaultValue),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingBitRate, 'recordingBitRate', AppGlobalConfig.recordingBitRate.defaultValue),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingAudioModeStereo, 'recordingAudioModeStereo', true),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingAutoGain, 'recordingAudioAutoGain', false),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingEchoCancel, 'recordingAudioEchoCancel', false),
    AppGlobalConfigField(AppGlobalConfigFieldKey.recordingNoiseSuppress, 'recordingAudioNoiseSuppress', false),
    AppGlobalConfigField(AppGlobalConfigFieldKey.gridRowsAmount, 'gridRowsAmount', AppGlobalConfig.gridRows.defaultValue.toInt()),
    AppGlobalConfigField(AppGlobalConfigFieldKey.gridColsAmount, 'gridColsAmount', AppGlobalConfig.gridCols.defaultValue.toInt()),
  ];

  static List<AppGlobalConfigField> get list => _fields;

  static AppGlobalConfigField field(dynamic key) => list.firstWhere((item) => item.key == key);
}