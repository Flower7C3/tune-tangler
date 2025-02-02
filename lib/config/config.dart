import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../entity/track.dart';
import 'app_icon.dart';
import 'config_collection.dart';

enum ToastType {
  success,
  error,
}

enum ConfigSpace {
  global,
  track,
}

enum GlobalConfigKey {
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

final class GlobalConfigKeyNameDefaults {
  final GlobalConfigKey key;
  final String boxFieldName;
  final dynamic defaultValue;

  GlobalConfigKeyNameDefaults(this.key, this.boxFieldName, this.defaultValue);
}

final class AppGlobalConfig {
  static final List<GlobalConfigKeyNameDefaults> _fields = <GlobalConfigKeyNameDefaults>[
    GlobalConfigKeyNameDefaults(GlobalConfigKey.locale, 'locale', AppGlobalConfig.languages.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeMode, 'theme_mode', ThemeMode.dark),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeSeedColor, 'theme_color', AppGlobalConfig.userInterfaceColor.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.wakelockEnabled, 'keepScreenOnEnabled', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingInputDevice, 'recordingInputDevice', null),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAudioEncoder, 'recordingAudioEncoder', AppGlobalConfig.recordingAudioEncoder.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingSampleRate, 'recordingSampleRate', AppGlobalConfig.recordingSampleRate.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingBitRate, 'recordingBitRate', AppGlobalConfig.recordingBitRate.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAudioModeStereo, 'recordingAudioModeStereo', true),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAutoGain, 'recordingAudioAutoGain', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingEchoCancel, 'recordingAudioEchoCancel', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingNoiseSuppress, 'recordingAudioNoiseSuppress', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridRowsAmount, 'grid_rows_amount', gridRows.defaultValue?.toInt()),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridColsAmount, 'grid_cols_amount', gridCols.defaultValue?.toInt()),
  ];

  static List<GlobalConfigKeyNameDefaults> settingsFields() => _fields;

  static GlobalConfigKeyNameDefaults settingField(dynamic key) => settingsFields().firstWhere((item) => item.key == key);

  static final SliderConfigCollection gridRows = SliderConfigCollection(
    [],
    sliderValues: ConfigSliderValues(2, 8, 6),
    defaultValue: 6,
    valueFormatter: (dynamic value) => value.toStringAsFixed(0),
  );

  static final SliderConfigCollection gridCols = SliderConfigCollection(
    [],
    sliderValues: ConfigSliderValues(2, 10, 9),
    defaultValue: 4,
    valueFormatter: (dynamic value) => value.toStringAsFixed(0),
  );

  static final ConfigCollection permissions = ConfigCollection(
    [
      ConfigItem(Permission.microphone, icon: Icons.mic_rounded, translation: (trans) => trans.microphonePermission),
      ConfigItem(Permission.notification, icon: Icons.notifications_on_rounded, translation: (trans) => trans.notificationPermission),
      ConfigItem(Permission.audio, icon: Icons.speaker_rounded, translation: (trans) => trans.audioPermission),
    ],
  );

  static final ConfigCollection permissionsStatus = ConfigCollection(
    [
      ConfigItem(PermissionStatus.granted, translation: (trans) => trans.permissionStatusGranted),
      ConfigItem(PermissionStatus.denied, translation: (trans) => trans.permissionStatusDenied),
      ConfigItem(PermissionStatus.permanentlyDenied, translation: (trans) => trans.permissionStatusPermanentlyDenied),
      ConfigItem(PermissionStatus.restricted, translation: (trans) => trans.permissionStatusRestricted),
    ],
  );

  static final ConfigCollection trackPlaybackMode = ConfigCollection(
    [
      ConfigItem(1, icon: AppIcon.trackSinglePlaybackMode),
      ConfigItem(0, icon: AppIcon.trackRepeatPlaybackMode),
    ],
  );

  static final SliderConfigCollection trackPlaybackSpeed = SliderConfigCollection(
    [
      ConfigItem(0.5, icon: Symbols.speed_0_5x_rounded),
      ConfigItem(1.0, icon: Symbols.one_x_mobiledata_rounded),
      ConfigItem(1.5, icon: Symbols.speed_1_5x_rounded),
      ConfigItem(2.0, icon: Symbols.speed_2x_rounded),
    ],
    defaultValue: 1.0,
    valueFormatter: (dynamic value) => '{value}x'.replaceAll('{value}', value.toStringAsFixed(1)),
    sliderValues: ConfigSliderValues(0.1, 2.0, 19),
  );

  static final SliderConfigCollection trackPlaybackVolume = SliderConfigCollection(
    [
      ConfigItem(0.00, icon: Icons.volume_off_rounded),
      ConfigItem(0.25, icon: Icons.volume_mute_rounded),
      ConfigItem(0.50, icon: Icons.volume_down_rounded),
      ConfigItem(0.75, icon: Icons.volume_up_rounded),
      ConfigItem(1.00, icon: Symbols.brand_awareness_rounded),
    ],
    defaultValue: 1.00,
    valueFormatter: (dynamic value) => '{value}%'.replaceAll('{value}', (value * 100).toStringAsFixed(0).padLeft(3, '0')),
    sliderValues: ConfigSliderValues(0, 1, 100),
  );

  static final SliderConfigCollection trackPlaybackBalance = SliderConfigCollection(
    [
      ConfigItem(-1.0, name: 'LL', icon: Icons.join_left_rounded, translation: (trans) => trans.balanceLeft100),
      ConfigItem(-0.5, name: 'CL', icon: Icons.join_left_rounded, translation: (trans) => trans.balanceLeft50),
      ConfigItem(0.0, name: 'CC', icon: Icons.join_full_rounded, translation: (trans) => trans.balanceCenter),
      ConfigItem(0.5, name: 'CR', icon: Icons.join_right_outlined, translation: (trans) => trans.balanceRight50),
      ConfigItem(1.0, name: 'RR', icon: Icons.join_right_outlined, translation: (trans) => trans.balanceRight100),
    ],
    defaultValue: 0.0,
    sliderValues: ConfigSliderValues(-1, 1, 4),
  );

  static final ConfigCollection recordingAudioEncoder = ConfigCollection(
    [
      ConfigItem(AudioEncoder.aacHe.index.toDouble(), translation: (trans) => trans.audioRecorderAacLc),
      ConfigItem(AudioEncoder.aacEld.index.toDouble(), translation: (trans) => trans.audioRecorderAacEld),
      ConfigItem(AudioEncoder.aacLc.index.toDouble(), translation: (trans) => trans.audioRecorderAacHe),
      ConfigItem(AudioEncoder.wav.index.toDouble(), translation: (trans) => trans.audioRecorderWav),
      ConfigItem(AudioEncoder.flac.index.toDouble(), translation: (trans) => trans.audioRecorderFlac),
    ],
    defaultValue: AudioEncoder.wav.index.toDouble(),
    valueFormatter: (dynamic value) => AudioEncoder.values[value.toInt()].toString().replaceAll('AudioEncoder.', ''),
    valueDecoder: (dynamic value) => AudioEncoder.values[value.toInt()],
  );

  static final ConfigCollection recordingSampleRate = ConfigCollection(
    [
      ConfigItem(44100),
      ConfigItem(48000),
      ConfigItem(96000),
    ],
    defaultValue: 48000,
    valueFormatter: (dynamic value) => '{value} kHz'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
    valueDecoder: (dynamic value) => value.toInt(),
  );

  static final ConfigCollection recordingBitRate = ConfigCollection(
    [
      ConfigItem(32000),
      ConfigItem(64000),
      ConfigItem(128000),
      ConfigItem(192000),
      ConfigItem(320000),
    ],
    defaultValue: 192000,
    valueFormatter: (dynamic value) => '{value} kbps'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
    valueDecoder: (dynamic value) => value.toInt(),
  );

  static final ConfigCollection languages = ConfigCollection(
    [
      ConfigItem(Locale('en', 'US'), name: 'English'),
      ConfigItem(Locale('pl', 'PL'), name: 'Polski'),
    ],
    defaultValue: Locale('en', 'US'),
  );

  static final ConfigCollection userInterfaceColor = ConfigCollection(
    [
      ConfigItem(Colors.red, translation: (trans) => trans.red),
      ConfigItem(Colors.green, translation: (trans) => trans.green),
      ConfigItem(Colors.blue, translation: (trans) => trans.blue),
      ConfigItem(Colors.yellow, translation: (trans) => trans.yellow),
      ConfigItem(Colors.purple, translation: (trans) => trans.purple),
      ConfigItem(Colors.orange, translation: (trans) => trans.orange),
      ConfigItem(Colors.cyan, translation: (trans) => trans.cyan),
      ConfigItem(Colors.pink, translation: (trans) => trans.pink),
    ],
    defaultValue: Colors.red,
  );

  static final ConfigCollection trackState = ConfigCollection(
    [
      ConfigItem(TrackState.empty, icon: Icons.cancel_outlined),
      ConfigItem(TrackState.recording, icon: Icons.radio_button_checked_outlined),
      ConfigItem(TrackState.ready, icon: Icons.task_alt_outlined),
      ConfigItem(TrackState.stopped, icon: Icons.task_alt_outlined),
      ConfigItem(TrackState.playing, icon: Icons.play_circle_outline),
      ConfigItem(TrackState.paused, icon: Icons.pause_circle_outline),
    ],
  );

  static final ConfigCollection trackStateForegroundColor = ConfigCollection(
    [
      ConfigItem(TrackState.empty, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .inversePrimary),
      ConfigItem(TrackState.recording, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .error),
      ConfigItem(TrackState.ready, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .secondary),
      ConfigItem(TrackState.stopped, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .secondary),
      ConfigItem(TrackState.playing, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .primary),
      ConfigItem(TrackState.paused, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .tertiary),
    ],
  );

  static final ConfigCollection trackStateBackgroundColor = ConfigCollection(
    [
      ConfigItem(TrackState.empty, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .surfaceContainer),
      ConfigItem(TrackState.recording, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .errorContainer),
      ConfigItem(TrackState.ready, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .secondaryContainer),
      ConfigItem(TrackState.stopped, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .secondaryContainer),
      ConfigItem(TrackState.playing, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .primaryContainer),
      ConfigItem(TrackState.paused, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .tertiaryContainer),
    ],
  );

  static final ConfigCollection trackStateProgressColor = ConfigCollection(
    [
      ConfigItem(TrackState.empty, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .inversePrimary),
      ConfigItem(TrackState.recording, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .surfaceContainerHighest),
      ConfigItem(TrackState.ready, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .surfaceContainer),
      ConfigItem(TrackState.stopped, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .surfaceContainer),
      ConfigItem(TrackState.playing, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .inversePrimary),
      ConfigItem(TrackState.paused, color: (context) =>
      Theme
          .of(context)
          .colorScheme
          .surfaceContainer),
    ],
  );

  static ConfigCollection readerEncoderExtension = ConfigCollection(
    [
      ConfigItem(AudioEncoder.aacLc, name: 'm4a'),
      ConfigItem(AudioEncoder.aacEld, name: 'm4a'),
      ConfigItem(AudioEncoder.aacHe, name: 'm4a'),
      ConfigItem(AudioEncoder.amrNb, name: '3gp'),
      ConfigItem(AudioEncoder.amrWb, name: '3gp'),
      ConfigItem(AudioEncoder.opus, name: 'opus'),
      ConfigItem(AudioEncoder.flac, name: 'flac'),
      ConfigItem(AudioEncoder.wav, name: 'wav'),
      ConfigItem(AudioEncoder.pcm16bits, name: 'pcm'),
    ],
  );
}
