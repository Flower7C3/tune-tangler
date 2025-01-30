import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
  emojis,
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
  final String Function(double value) valueFormatter;
  final dynamic Function(double value) valueDecoder;
  String Function(double value, AppLocalizations trans) valueTranslator;

  static dynamic _defaultValueDecoder(double value) => value;

  static String _defaultValueTrans(double value, AppLocalizations trans) => '';

  ConfigDataCodec({required this.valueFormatter, this.valueDecoder = _defaultValueDecoder, this.valueTranslator = _defaultValueTrans});
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
  final List<double> values;
  double defaultValue;
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
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeSeedColor, 'theme_color', Colors.purple),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.wakelockEnabled, 'keepScreenOnEnabled', false),
    GlobalConfigKeyNameDefaults(
        GlobalConfigKey.recordingAudioEncoder, 'recordingAudioEncoder', AppGlobalConfig.recordingAudioEncoderValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingSampleRate, 'recordingSampleRate', AppGlobalConfig.recordingSampleRateValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingBitRate, 'recordingBitRate', AppGlobalConfig.recordingBitRateValues.defaultValue),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAudioModeStereo, 'recordingAudioModeStereo', true),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAutoGain, 'recordingAudioAutoGain', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingEchoCancel, 'recordingAudioEchoCancel', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingNoiseSuppress, 'recordingAudioNoiseSuppress', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.emojis, 'title_emojis', "❤️⭐️🎸🪕🎻🪘🥁🎷🎺🎹🪗🎤🎂🎉🎄😻😸😹😺😼😾😿🙀️"),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridRowsAmount, 'grid_rows_amount', 6),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridColsAmount, 'grid_cols_amount', 4),
  ];

  static List<GlobalConfigKeyNameDefaults> settingsFields() => _fields;

  static GlobalConfigKeyNameDefaults settingField(dynamic key) => settingsFields().firstWhere((item) => item.key == key);

  static ConfigDataSliderValues gridRows = ConfigDataSliderValues(
    minValue: 2,
    maxValue: 8,
    divisions: 6,
    codec: ConfigDataCodec(valueFormatter: (double value) => value.toStringAsFixed(0)),
  );
  static ConfigDataSliderValues gridCols = ConfigDataSliderValues(
    minValue: 2,
    maxValue: 10,
    divisions: 9,
    codec: ConfigDataCodec(valueFormatter: (double value) => value.toStringAsFixed(0)),
  );
  static List<ConfigDataIcon> trackPlaybackModeValueIcons = [
    ConfigDataIcon(1, AppIcon.trackSinglePlaybackMode),
    ConfigDataIcon(0, AppIcon.trackRepeatPlaybackMode),
  ];
  static ConfigDataSliderValues trackPlaybackSpeedSliderValues = ConfigDataSliderValues(
    minValue: 0.1,
    maxValue: 2.0,
    divisions: 19,
    defaultValue: 1.0,
    codec: ConfigDataCodec(valueFormatter: (double value) => '{value}x'.replaceAll('{value}', value.toStringAsFixed(1))),
  );
  static List<ConfigDataIcon> trackPlaybackSpeedValueIcons = [
    ConfigDataIcon(0.5, Symbols.speed_0_5x_rounded),
    ConfigDataIcon(1.0, Symbols.one_x_mobiledata_rounded),
    ConfigDataIcon(1.5, Symbols.speed_1_5x_rounded),
    ConfigDataIcon(2.0, Symbols.speed_2x_rounded),
  ];
  static ConfigDataSliderValues trackPlaybackVolumeSliderValues = ConfigDataSliderValues(
    minValue: 0,
    maxValue: 1,
    divisions: 100,
    defaultValue: 1,
    codec: ConfigDataCodec(valueFormatter: (double value) => '{value}%'.replaceAll('{value}', (value * 100).toStringAsFixed(0).padLeft(3, '0'))),
  );
  static List<ConfigDataIcon> trackPlaybackVolumeValueIcons = [
    ConfigDataIcon(0.00, Icons.volume_off_rounded),
    ConfigDataIcon(0.25, Icons.volume_mute_rounded),
    ConfigDataIcon(0.50, Icons.volume_down_rounded),
    ConfigDataIcon(0.75, Icons.volume_up_rounded),
    ConfigDataIcon(1.00, Symbols.brand_awareness_rounded),
  ];
  static ConfigDataSliderValues trackPlaybackBalanceSliderValues = ConfigDataSliderValues(
    minValue: -1,
    maxValue: 1,
    divisions: 4,
    defaultValue: 0.0,
    codec: ConfigDataCodec(
        valueFormatter: (double value) => switch (value) {
              -1.00 => 'L100',
              -0.75 => 'L75',
              -0.50 => 'L50',
              -0.25 => 'L25',
              0.00 => 'C',
              0.25 => 'R1',
              0.50 => 'R2',
              0.75 => 'R3',
              1.00 => 'R4',
              _ => '??',
            },
        valueTranslator: (double value, AppLocalizations trans) => switch (value) {
              -1.00 => trans.balanceLeft100,
              -0.75 => trans.balanceLeft75,
              -0.50 => trans.balanceLeft50,
              -0.25 => trans.balanceLeft25,
              0.0 => trans.balanceCenter,
              0.25 => trans.balanceRight25,
              0.50 => trans.balanceRight50,
              0.75 => trans.balanceRight75,
              1.00 => trans.balanceRight100,
              _ => AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(value),
            }),
  );
  static List<ConfigDataIcon> trackPlaybackBalanceValueIcons = [
    ConfigDataIcon(-1.0, Icons.join_left_rounded),
    ConfigDataIcon(-0.5, Icons.join_left_rounded),
    ConfigDataIcon(0.0, Icons.join_full_rounded),
    ConfigDataIcon(0.5, Icons.join_right_outlined),
    ConfigDataIcon(1.0, Icons.join_right_outlined),
  ];
  static ConfigDataRadioValues recordingAudioEncoderValues = ConfigDataRadioValues(
    values: [
      AudioEncoder.aacHe.index.toDouble(),
      AudioEncoder.aacEld.index.toDouble(),
      AudioEncoder.aacLc.index.toDouble(),
      AudioEncoder.wav.index.toDouble(),
      AudioEncoder.flac.index.toDouble(),
    ],
    defaultValue: AudioEncoder.wav.index.toDouble(),
    codec: ConfigDataCodec(
        valueFormatter: (double value) => AudioEncoder.values[value.toInt()].toString().replaceAll('AudioEncoder.', ''),
        valueDecoder: (double value) => AudioEncoder.values[value.toInt()],
        valueTranslator: (double value, AppLocalizations trans) => switch (AudioEncoder.values[value.toInt()]) {
              AudioEncoder.aacLc => trans.audioRecorderAacLc,
              AudioEncoder.aacEld => trans.audioRecorderAacEld,
              AudioEncoder.aacHe => trans.audioRecorderAacHe,
              AudioEncoder.wav => trans.audioRecorderWav,
              AudioEncoder.flac => trans.audioRecorderFlac,
              _ => throw UnimplementedError(),
            }),
  );
  static ConfigDataRadioValues recordingSampleRateValues = ConfigDataRadioValues(
    values: [44100, 48000, 96000],
    defaultValue: 48000,
    codec: ConfigDataCodec(
      valueFormatter: (double value) => '{value} kHz'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
      valueDecoder: (double value) => value.toInt(),
    ),
  );
  static ConfigDataRadioValues recordingBitRateValues = ConfigDataRadioValues(
    values: [32000, 64000, 128000, 192000, 320000],
    defaultValue: 192000,
    codec: ConfigDataCodec(
      valueFormatter: (double value) => '{value} kbps'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
      valueDecoder: (double value) => value.toInt(),
    ),
  );

  static const Map<String, Set<String>> keyboardKeysRows = {
    'A': {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'},
    'B': {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'},
    'C': {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'},
    'D': {'z', 'x', 'c', 'v', 'b', 'n', 'm', '.', ',', '/'},
    'E': {'!', '@', '#', '\$', '%', '^', '&', '*', '(', ')'},
    'F': {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'},
    'G': {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':'},
    'H': {'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?'},
  };

  static Iterable<String> gridRowNames() => keyboardKeysRows.keys;

  static Iterable<String> keyboardKeys() {
    var keyboardKeys = <String>[];
    keyboardKeysRows.forEach((row, keys) => keyboardKeys.addAll(keys));
    return keyboardKeys;
  }

  static const Map<String, Locale> languages = {
    'English': Locale('en', 'US'),
    'Polski': Locale('pl', 'PL'),
  };

  static const Map<String, Color> userInterfaceColors = {
    "red": Colors.red,
    "green": Colors.green,
    "blue": Colors.blue,
    "yellow": Colors.yellow,
    "purple": Colors.purple,
    "orange": Colors.orange,
    "cyan": Colors.cyan,
    "pink": Colors.pink,
  };

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
