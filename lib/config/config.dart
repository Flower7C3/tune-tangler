import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../entity/track.dart';

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
  recordingProbingModeHigh,
  recordingAudioModeStereo,
  gridRowsAmount,
  gridColsAmount,
}

final class GlobalConfigKeyNameDefaults {
  final GlobalConfigKey key;
  final String boxFieldName;
  final dynamic defaultValue;

  GlobalConfigKeyNameDefaults(this.key, this.boxFieldName, this.defaultValue);
}

final class ConfigSliderValues {
  final double minValue;
  final double maxValue;
  final int divisions;
  final String Function(double value) valueFormatter;
  double? defaultValue;
  List<ConfigValueIcon>? valueIcons = <ConfigValueIcon>[];

  ConfigSliderValues(this.minValue, this.maxValue, this.divisions, this.valueFormatter, {this.defaultValue, this.valueIcons});
}

final class ConfigValueIcon {
  final double value;
  final IconData icon;

  ConfigValueIcon(this.value, this.icon);
}

final class Config {
  static final List<GlobalConfigKeyNameDefaults> _fields = <GlobalConfigKeyNameDefaults>[
    GlobalConfigKeyNameDefaults(GlobalConfigKey.locale, 'locale', Locale('en', 'US')),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeMode, 'theme_mode', ThemeMode.dark),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.themeSeedColor, 'theme_color', Colors.purple),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.wakelockEnabled, 'keep_screen_on_enabled', false),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingProbingModeHigh, 'recording_probing_mode_high', true),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.recordingAudioModeStereo, 'recording_audio_mode_stereo', true),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.emojis, 'title_emojis', "❤️⭐️🎸🪕🎻🪘🥁🎷🎺🎹🪗🎤🎂🎉🎄😻😸😹😺😼😾😿🙀️"),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridRowsAmount, 'grid_rows_amount', 6),
    GlobalConfigKeyNameDefaults(GlobalConfigKey.gridColsAmount, 'grid_cols_amount', 4),
  ];

  static List<GlobalConfigKeyNameDefaults> settingsFields() => _fields;

  static GlobalConfigKeyNameDefaults settingField(dynamic key) => settingsFields().firstWhere((item) => item.key == key);

  static ConfigSliderValues gridRows = ConfigSliderValues(2, 8, 6, (double value) => value.toStringAsFixed(0));
  static ConfigSliderValues gridCols = ConfigSliderValues(2, 10, 9, (double value) => value.toStringAsFixed(0));
  static List<ConfigValueIcon> trackPlaybackModeValueIcons = [
    ConfigValueIcon(1, Icons.repeat_one_rounded),
    ConfigValueIcon(0, Icons.repeat_rounded),
  ];
  static ConfigSliderValues trackPlaybackSpeedSliderValues =
      ConfigSliderValues(0.1, 2, 19, (double value) => '{value}x'.replaceAll('{value}', value.toStringAsFixed(1)), defaultValue: 1);
  static List<ConfigValueIcon> trackPlaybackSpeedValueIcons = [
    ConfigValueIcon(0.5, Symbols.speed_0_5x_rounded),
    ConfigValueIcon(1.0, Symbols.one_x_mobiledata_rounded),
    ConfigValueIcon(1.5, Symbols.speed_1_5x_rounded),
    ConfigValueIcon(2.0, Symbols.speed_2x_rounded),
  ];
  static ConfigSliderValues trackPlaybackVolumeSliderValues = ConfigSliderValues(0, 100, 100, (double value) => value.toStringAsFixed(0), defaultValue: 100);
  static List<ConfigValueIcon> trackPlaybackVolumeValueIcons = [
    ConfigValueIcon(0, Icons.volume_off_rounded),
    ConfigValueIcon(25, Icons.volume_mute_rounded),
    ConfigValueIcon(50, Icons.volume_down_rounded),
    ConfigValueIcon(75, Icons.volume_up_rounded),
    ConfigValueIcon(100, Symbols.brand_awareness_rounded),
  ];

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

  static Map<TrackState, IconData> trackStateIcons(context) => {
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
