import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../config/app_config_fields.dart';

class SettingsProfile {
  late InputDevice? recordingInputDevice;
  late AudioEncoder recordingAudioEncoder;
  late int recordingSampleRate;
  late int recordingBitRate;
  late bool recordingAudioModeStereo;
  late bool recordingAutoGain;
  late bool recordingEchoCancel;
  late bool recordingNoiseSuppress;
  late Locale locale;
  late ThemeMode themeMode;
  late Color themeSeedColor;
  late bool wakelockEnabled;
  late int gridRowsAmount;
  late int gridColsAmount;

  static SettingsProfile fromMap(Map data) {
    SettingsProfile settingsProfile = SettingsProfile();
    settingsProfile.recordingInputDevice =
        data[AppConfigFieldKey.recordingInputDevice];
    settingsProfile.recordingAudioEncoder =
        data[AppConfigFieldKey.recordingAudioEncoder];
    settingsProfile.recordingSampleRate =
        data[AppConfigFieldKey.recordingSampleRate];
    settingsProfile.recordingBitRate = data[AppConfigFieldKey.recordingBitRate];
    settingsProfile.recordingAudioModeStereo =
        data[AppConfigFieldKey.recordingAudioModeStereo];
    settingsProfile.recordingAutoGain =
        data[AppConfigFieldKey.recordingAutoGain];
    settingsProfile.recordingEchoCancel =
        data[AppConfigFieldKey.recordingEchoCancel];
    settingsProfile.recordingNoiseSuppress =
        data[AppConfigFieldKey.recordingNoiseSuppress];
    settingsProfile.locale = data[AppConfigFieldKey.locale];
    settingsProfile.themeMode = data[AppConfigFieldKey.themeMode];
    settingsProfile.themeSeedColor = data[AppConfigFieldKey.themeSeedColor];
    settingsProfile.wakelockEnabled = data[AppConfigFieldKey.wakelockEnabled];
    settingsProfile.gridRowsAmount = data[AppConfigFieldKey.gridRowsAmount];
    settingsProfile.gridColsAmount = data[AppConfigFieldKey.gridColsAmount];
    return settingsProfile;
  }

  Map toMap() => {
    AppConfigFieldKey.recordingInputDevice: recordingInputDevice,
    AppConfigFieldKey.recordingAudioEncoder: recordingAudioEncoder,
    AppConfigFieldKey.recordingSampleRate: recordingSampleRate,
    AppConfigFieldKey.recordingBitRate: recordingBitRate,
    AppConfigFieldKey.recordingAudioModeStereo: recordingAudioModeStereo,
    AppConfigFieldKey.recordingAutoGain: recordingAutoGain,
    AppConfigFieldKey.recordingEchoCancel: recordingEchoCancel,
    AppConfigFieldKey.recordingNoiseSuppress: recordingNoiseSuppress,
    AppConfigFieldKey.locale: locale,
    AppConfigFieldKey.themeMode: themeMode,
    AppConfigFieldKey.themeSeedColor: themeSeedColor,
    AppConfigFieldKey.wakelockEnabled: wakelockEnabled,
    AppConfigFieldKey.gridRowsAmount: gridRowsAmount,
    AppConfigFieldKey.gridColsAmount: gridColsAmount,
  };
}
