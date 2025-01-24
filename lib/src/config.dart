import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'track.dart';

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

final class GlobalConfig {
  static const Map<dynamic, String> names = <dynamic, String>{
    GlobalConfigKey.locale: 'locale',
    GlobalConfigKey.themeMode: 'theme_mode',
    GlobalConfigKey.themeSeedColor: 'theme_color',
    GlobalConfigKey.wakelockEnabled: 'keep_screen_on_enabled',
    GlobalConfigKey.recordingProbingModeHigh: 'recording_probing_mode_high',
    GlobalConfigKey.recordingAudioModeStereo: 'recording_audio_mode_stereo',
    GlobalConfigKey.emojis: 'title_emojis',
    GlobalConfigKey.gridRowsAmount: 'grid_rows_amount',
    GlobalConfigKey.gridColsAmount: 'grid_cols_amount',
  };

  static const Map<dynamic, dynamic> defaults = <dynamic, dynamic>{
    GlobalConfigKey.locale: Locale('en', 'US'),
    GlobalConfigKey.themeMode: ThemeMode.light,
    GlobalConfigKey.themeSeedColor: Colors.blue,
    GlobalConfigKey.wakelockEnabled: false,
    GlobalConfigKey.recordingProbingModeHigh: true,
    GlobalConfigKey.recordingAudioModeStereo: true,
    GlobalConfigKey.emojis: "❤️⭐️🎸🪕🎻🪘🥁🎷🎺🎹🪗🎤🎂🎉🎄😻😸😹😺😼😾😿🙀️",
    GlobalConfigKey.gridRowsAmount: 6,
    GlobalConfigKey.gridColsAmount: 4,
  };

  static name(dynamic key) => names[key] ?? Exception('Key $key not recognized');

  static defaultValue(dynamic key) => defaults[key] ?? Exception('Key $key not recognized');
}

final class Config {
  static double gridRowsMin = 2;
  static double gridRowsMax = 8;
  static double gridColsMin = 2;
  static double gridColsMax = 9;

  static const Map<String, Set<String>> keyboardKeysRows = {
    'A': {'1', '2', '3', '4', '5', '6', '7', '8', '9'},
    'B': {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o'},
    'C': {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'},
    'D': {'z', 'x', 'c', 'v', 'b', 'n', 'm', '.', '/'},
    'E': {'!', '@', '#', '\$', '%', '^', '&', '*', '('},
    'F': {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O'},
    'G': {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'},
    'H': {'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>'},
  };

  static Iterable<String> rowNames() => keyboardKeysRows.keys;

  static Iterable<String> keyboardKeys() {
    var keyboardKeys = <String>[];
    keyboardKeysRows.forEach((row, keys) => keyboardKeys.addAll(keys));
    return keyboardKeys;
  }

  static const Map<String, Locale> languages = {
    'English': Locale('en', 'US'),
    'Polski': Locale('pl', 'PL'),
  };

  static Iterable<String> languageNames() => languages.keys;

  static Iterable<Locale> languageValues() => languages.values;

  static const Map<String, Color> colors = {
    "red": Colors.red,
    "green": Colors.green,
    "blue": Colors.blue,
    "yellow": Colors.yellow,
    "purple": Colors.purple,
    "orange": Colors.orange,
    "cyan": Colors.cyan,
    "pink": Colors.pink,
  };

  static Iterable<String> colorNames() => colors.keys;

  static Iterable<Color> colorValues() => colors.values;

  static Map<double, IconData> playbackSpeeds = {
    0.2: Symbols.speed_0_2x_rounded,
    0.5: Symbols.speed_0_5x_rounded,
    0.7: Symbols.speed_0_7x_rounded,
    1.0: Symbols.one_x_mobiledata,
    1.2: Symbols.speed_1_2x_rounded,
    1.5: Symbols.speed_1_5x_rounded,
    1.7: Symbols.speed_1_7x_rounded,
    2.0: Symbols.speed_2x_rounded,
  };

  static Iterable<IconData> playbackSpeedNames() => playbackSpeeds.values;

  static Iterable<double> playbackSpeedValues() => playbackSpeeds.keys;

  static const Map<int, String> playbackVolumes = {
    0: "0",
    10: "10",
    20: "20",
    30: "30",
    40: "40",
    50: "50",
    60: "60",
    70: "70",
    80: "80",
    90: "90",
    100: "100",
  };

  static Iterable<String> playbackVolumeNames() => playbackVolumes.values;

  static Iterable<int> playbackVolumeValues() => playbackVolumes.keys;

  static Map<TrackState, IconData> trackStateIcon(context) => {
        TrackState.empty: Icons.cancel_outlined,
        TrackState.recording: Icons.radio_button_checked_outlined,
        TrackState.stopped: Icons.task_alt_outlined,
        TrackState.playing: Icons.play_circle_outline,
        TrackState.paused: Icons.pause_circle_outline,
      };

  static Map<TrackState, Color> trackStateForegroundColor(context) => {
        TrackState.empty: Theme.of(context).colorScheme.inversePrimary,
        TrackState.recording: Theme.of(context).colorScheme.error,
        TrackState.stopped: Theme.of(context).colorScheme.secondary,
        TrackState.playing: Theme.of(context).colorScheme.primary,
        TrackState.paused: Theme.of(context).colorScheme.tertiary,
      };

  static Map<TrackState, Color> trackStateBackgroundColor(context) => {
        TrackState.empty: Theme.of(context).colorScheme.surfaceContainer,
        TrackState.recording: Theme.of(context).colorScheme.errorContainer,
        TrackState.stopped: Theme.of(context).colorScheme.secondaryContainer,
        TrackState.playing: Theme.of(context).colorScheme.primaryContainer,
        TrackState.paused: Theme.of(context).colorScheme.tertiaryContainer,
      };

  static Map<TrackState, Color> trackStateProgressColor(context) => {
        TrackState.empty: Theme.of(context).colorScheme.inversePrimary,
        TrackState.recording: Theme.of(context).colorScheme.surfaceContainerHighest,
        TrackState.stopped: Theme.of(context).colorScheme.surfaceContainer,
        TrackState.playing: Theme.of(context).colorScheme.inversePrimary,
        TrackState.paused: Theme.of(context).colorScheme.surfaceContainer,
      };
}
