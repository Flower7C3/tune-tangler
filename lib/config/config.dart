import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../entity/track.dart';
import 'app_icon.dart';

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

final class ConfigDataCodec {
  final dynamic Function(dynamic value) valueFormatter;
  final dynamic Function(dynamic value) valueDecoder;
  final String Function(dynamic value, AppLocalizations trans) valueTranslator;
  late Map<double, IconData> _valueIcons;

  Map<double, IconData> get valueIcons => _valueIcons;

  IconData valueIcon(double index) => _valueIcons[index] ?? Icons.add;

  static dynamic _defaultValueFormatter(dynamic value) => value;

  static dynamic _defaultValueDecoder(dynamic value) => value;

  static String _defaultValueTrans(dynamic value, AppLocalizations trans) => '';

  ConfigDataCodec({
    this.valueFormatter = _defaultValueFormatter,
    this.valueDecoder = _defaultValueDecoder,
    this.valueTranslator = _defaultValueTrans,
    Map<double, IconData>? valueIcons,
  }) {
    _valueIcons = valueIcons ?? <double, IconData>{};
  }
}

final class ConfigDataSliderValues {
  final double minValue;
  final double maxValue;
  final int divisions;
  double? defaultValue;
  ConfigDataCodec codec;

  ConfigDataSliderValues({
    required this.minValue,
    required this.maxValue,
    required this.divisions,
    required this.codec,
    this.defaultValue,
  });
}

final class ConfigDataRadioValues {
  final List<dynamic> values;
  dynamic defaultValue;
  ConfigDataCodec codec;

  ConfigDataRadioValues({
    required this.values,
    required this.defaultValue,
    required this.codec,
  });
}

final class ConfigDataIcon {
  final double value;
  final IconData icon;

  ConfigDataIcon(this.value, this.icon);
}

final class AppGlobalConfig {
  static final List<GlobalConfigKeyNameDefaults> _fields = <GlobalConfigKeyNameDefaults>[
    GlobalConfigKeyNameDefaults(GlobalConfigKey.locale, 'locale', Locale('en', 'US')),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeMode, 'theme_mode', ThemeMode.dark),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeSeedColor, 'theme_color', AppGlobalConfig.userInterfaceColors.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.wakelockEnabled, 'keepScreenOnEnabled', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingInputDevice, 'recordingInputDevice', null),
    GlobalConfigKeyNameDefaults(
        GlobalConfigKey.recordingAudioEncoder, 'recordingAudioEncoder', AppGlobalConfig.recordingAudioEncoderValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingSampleRate, 'recordingSampleRate', AppGlobalConfig.recordingSampleRateValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingBitRate, 'recordingBitRate', AppGlobalConfig.recordingBitRateValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAudioModeStereo, 'recordingAudioModeStereo', true),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAutoGain, 'recordingAudioAutoGain', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingEchoCancel, 'recordingAudioEchoCancel', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingNoiseSuppress, 'recordingAudioNoiseSuppress', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridRowsAmount, 'grid_rows_amount', 6),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridColsAmount, 'grid_cols_amount', 4),
  ];

  static List<GlobalConfigKeyNameDefaults> settingsFields() => _fields;

  static GlobalConfigKeyNameDefaults settingField(dynamic key) => settingsFields().firstWhere((item) => item.key == key);

  static final ConfigDataSliderValues gridRows = ConfigDataSliderValues(
    minValue: 2,
    maxValue: 8,
    divisions: 6,
    codec: ConfigDataCodec(valueFormatter: (dynamic value) => value.toStringAsFixed(0)),
  );

  static final ConfigDataSliderValues gridCols = ConfigDataSliderValues(
    minValue: 2,
    maxValue: 10,
    divisions: 9,
    codec: ConfigDataCodec(valueFormatter: (dynamic value) => value.toStringAsFixed(0)),
  );

  static final List<Permission> permissions = [
    Permission.microphone,
    Permission.notification,
    Permission.audio,
  ];

  static final ConfigDataCodec permissionsStatusCodec = ConfigDataCodec(
      valueTranslator: (dynamic status, AppLocalizations trans) => switch (status) {
            PermissionStatus.granted => trans.permissionStatusGranted,
            PermissionStatus.denied => trans.permissionStatusDenied,
            PermissionStatus.permanentlyDenied => trans.permissionStatusPermanentlyDenied,
            PermissionStatus.restricted => trans.permissionStatusRestricted,
            _ => trans.permissionStatusUndefined,
          });

  static final ConfigDataCodec permissionsCodec = ConfigDataCodec(
      valueIcons: {
        Permission.audio.value.toDouble(): Icons.speaker_rounded,
        Permission.microphone.value.toDouble(): Icons.mic_rounded,
        Permission.notification.value.toDouble(): Icons.notifications_on_rounded,
      },
      valueTranslator: (dynamic value, AppLocalizations trans) => switch (value) {
            Permission.audio => trans.audioPermission,
            Permission.microphone => trans.microphonePermission,
            Permission.notification => trans.notificationPermission,
            _ => value.toString(),
          });

  static final ConfigDataCodec trackPlaybackModeCodec = ConfigDataCodec(valueIcons: {
    1: AppIcon.trackSinglePlaybackMode,
    0: AppIcon.trackRepeatPlaybackMode,
  });

  static final ConfigDataSliderValues trackPlaybackSpeedSliderValues = ConfigDataSliderValues(
    minValue: 0.1,
    maxValue: 2.0,
    divisions: 19,
    defaultValue: 1.0,
    codec: ConfigDataCodec(
      valueIcons: {
        0.5: Symbols.speed_0_5x_rounded,
        1.0: Symbols.one_x_mobiledata_rounded,
        1.5: Symbols.speed_1_5x_rounded,
        2.0: Symbols.speed_2x_rounded,
      },
      valueFormatter: (dynamic value) => '{value}x'.replaceAll('{value}', value.toStringAsFixed(1)),
    ),
  );

  static final ConfigDataSliderValues trackPlaybackVolumeSliderValues = ConfigDataSliderValues(
    minValue: 0,
    maxValue: 1,
    divisions: 100,
    defaultValue: 1,
    codec: ConfigDataCodec(
      valueIcons: {
        0.00: Icons.volume_off_rounded,
        0.25: Icons.volume_mute_rounded,
        0.50: Icons.volume_down_rounded,
        0.75: Icons.volume_up_rounded,
        1.00: Symbols.brand_awareness_rounded,
      },
      valueFormatter: (dynamic value) => '{value}%'.replaceAll('{value}', (value * 100).toStringAsFixed(0).padLeft(3, '0')),
    ),
  );

  static final ConfigDataSliderValues trackPlaybackBalanceSliderValues = ConfigDataSliderValues(
    minValue: -1,
    maxValue: 1,
    divisions: 4,
    defaultValue: 0.0,
    codec: ConfigDataCodec(
        valueIcons: {
          -1.0: Icons.join_left_rounded,
          -0.5: Icons.join_left_rounded,
          0.0: Icons.join_full_rounded,
          0.5: Icons.join_right_outlined,
          1.0: Icons.join_right_outlined,
        },
        valueFormatter: (dynamic value) => switch (value) {
              -1.00 => 'LL',
              -0.75 => 'L',
              -0.50 => 'CL',
              -0.25 => 'CCL',
              0.00 => 'CC',
              0.25 => 'CCR',
              0.50 => 'CR',
              0.75 => 'R',
              1.00 => 'RR',
              _ => '??',
            },
        valueTranslator: (dynamic value, AppLocalizations trans) => switch (value) {
              -1.00 => trans.balanceLeft100,
              -0.75 => trans.balanceLeft75,
              -0.50 => trans.balanceLeft50,
              -0.25 => trans.balanceLeft25,
              0.00 => trans.balanceCenter,
              0.25 => trans.balanceRight25,
              0.50 => trans.balanceRight50,
              0.75 => trans.balanceRight75,
              1.00 => trans.balanceRight100,
              _ => AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(value),
            }),
  );

  static final ConfigDataRadioValues recordingAudioEncoderValues = ConfigDataRadioValues(
    values: [
      AudioEncoder.aacHe.index.toDouble(),
      AudioEncoder.aacEld.index.toDouble(),
      AudioEncoder.aacLc.index.toDouble(),
      AudioEncoder.wav.index.toDouble(),
      AudioEncoder.flac.index.toDouble(),
    ],
    defaultValue: AudioEncoder.wav.index.toDouble(),
    codec: ConfigDataCodec(
        valueFormatter: (dynamic value) => AudioEncoder.values[value.toInt()].toString().replaceAll('AudioEncoder.', ''),
        valueDecoder: (dynamic value) => AudioEncoder.values[value.toInt()],
        valueTranslator: (dynamic value, AppLocalizations trans) => switch (AudioEncoder.values[value.toInt()]) {
              AudioEncoder.aacLc => trans.audioRecorderAacLc,
              AudioEncoder.aacEld => trans.audioRecorderAacEld,
              AudioEncoder.aacHe => trans.audioRecorderAacHe,
              AudioEncoder.wav => trans.audioRecorderWav,
              AudioEncoder.flac => trans.audioRecorderFlac,
              _ => throw UnimplementedError(),
            }),
  );

  static final ConfigDataRadioValues recordingSampleRateValues = ConfigDataRadioValues(
    values: [44100, 48000, 96000],
    defaultValue: 48000,
    codec: ConfigDataCodec(
      valueFormatter: (dynamic value) => '{value} kHz'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
      valueDecoder: (dynamic value) => value.toInt(),
    ),
  );

  static final ConfigDataRadioValues recordingBitRateValues = ConfigDataRadioValues(
    values: [32000, 64000, 128000, 192000, 320000],
    defaultValue: 192000,
    codec: ConfigDataCodec(
      valueFormatter: (dynamic value) => '{value} kbps'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
      valueDecoder: (dynamic value) => value.toInt(),
    ),
  );

  static final Map<String, Locale> languages = {
    'English': Locale('en', 'US'),
    'Polski': Locale('pl', 'PL'),
  };

  static final ConfigDataRadioValues userInterfaceColors = ConfigDataRadioValues(
    values: [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ],
    defaultValue: Colors.purple,
    codec: ConfigDataCodec(
        valueFormatter: (value) => value.toString(),
        valueTranslator: (value, AppLocalizations trans) => switch (userInterfaceColors.values[value.toInt()]) {
              Colors.red => trans.red,
              Colors.green => trans.green,
              Colors.blue => trans.blue,
              Colors.yellow => trans.yellow,
              Colors.purple => trans.purple,
              Colors.orange => trans.orange,
              Colors.cyan => trans.cyan,
              Colors.pink => trans.pink,
              _ => throw UnimplementedError(),
            }),
  );

  static Map<TrackState, IconData> trackStateIcons() => {
        TrackState.empty: Icons.cancel_outlined,
        TrackState.recording: Icons.radio_button_checked_outlined,
        TrackState.stopped: Icons.task_alt_outlined,
        TrackState.playing: Icons.play_circle_outline,
        TrackState.paused: Icons.pause_circle_outline,
      };

  static Map<TrackState, Color> trackStateForegroundColors(context) => {
        TrackState.empty: Theme.of(context).colorScheme.inversePrimary,
        TrackState.recording: Theme.of(context).colorScheme.error,
        TrackState.stopped: Theme.of(context).colorScheme.secondary,
        TrackState.playing: Theme.of(context).colorScheme.primary,
        TrackState.paused: Theme.of(context).colorScheme.tertiary,
      };

  static Map<TrackState, Color> trackStateBackgroundColors(context) => {
        TrackState.empty: Theme.of(context).colorScheme.surfaceContainer,
        TrackState.recording: Theme.of(context).colorScheme.errorContainer,
        TrackState.stopped: Theme.of(context).colorScheme.secondaryContainer,
        TrackState.playing: Theme.of(context).colorScheme.primaryContainer,
        TrackState.paused: Theme.of(context).colorScheme.tertiaryContainer,
      };

  static Map<TrackState, Color> trackStateProgressColors(context) => {
        TrackState.empty: Theme.of(context).colorScheme.inversePrimary,
        TrackState.recording: Theme.of(context).colorScheme.surfaceContainerHighest,
        TrackState.stopped: Theme.of(context).colorScheme.surfaceContainer,
        TrackState.playing: Theme.of(context).colorScheme.inversePrimary,
        TrackState.paused: Theme.of(context).colorScheme.surfaceContainer,
      };
}
