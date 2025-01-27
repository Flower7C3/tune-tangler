import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:tune_tangler/config/config.dart';

import 'track_row.dart';

enum TrackState {
  empty,
  recording,
  stopped,
  playing,
  paused,
}

class Track {
  ///*************************************************************************************************************************************************
  /// INDEX

  final int _rowIndex;
  final int _colIndex;

  Track(this._rowIndex, this._colIndex) {
    setName(buildId(_rowIndex, _colIndex));
    resetKeyboardKey();
  }

  String id() => buildId(_rowIndex, _colIndex);

  int rowIndex() => _rowIndex;

  int colIndex() => _colIndex;

  static String buildId(int rowIndex, int colIndex) => (TrackRow.name(rowIndex)) + (colIndex + 1).toString();

  ///*************************************************************************************************************************************************
  /// NAME

  String _name = '';

  String name() => _name;

  void setName(String name) {
    _name = name;
  }

  ///*************************************************************************************************************************************************
  /// STATE

  TrackState _state = TrackState.empty;

  TrackState state() => _state;

  void setState(state) {
    _state = state;
  }

  IconData stateIcon(BuildContext context) => Config.trackStateIcons(context)[state()] ?? Icons.square;

  Color stateForegroundColor(BuildContext context) => Config.trackStateForegroundColors(context)[state()] ?? Theme.of(context).colorScheme.primary;

  Color stateBackgroundColor(BuildContext context) =>
      Config.trackStateBackgroundColors(context)[state()] ?? Theme.of(context).colorScheme.primaryFixedDim;

  Color stateProgressColor(BuildContext context) =>
      Config.trackStateProgressColors(context)[state()] ?? Theme.of(context).colorScheme.primaryContainer;

  ///*************************************************************************************************************************************************
  /// PLAYBACK VOLUME

  double _playbackVolume = 100;

  double playbackVolume() => _playbackVolume;

  void setPlaybackVolume(double value) {
    _playbackVolume = value;
  }

  IconData volumeIcon() {
    double trackValue = playbackVolume();
    if (trackValue <= 0) {
      return Symbols.volume_off_rounded;
    } else if (trackValue <= 33) {
      return Symbols.volume_mute_rounded;
    } else if (trackValue <= 66) {
      return Symbols.volume_down_rounded;
    } else if (trackValue <= 99) {
      return Symbols.volume_up_rounded;
    } else {
      return Symbols.brand_awareness_rounded;
    }
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK MODE

  bool _playbackModeSingle = true;

  bool isPlaybackModeSingle() => _playbackModeSingle;

  IconData playbackModeIcon() => (_playbackModeSingle) ? Symbols.repeat_one_rounded : Symbols.repeat_rounded;

  void togglePlaybackMode() {
    _playbackModeSingle = !_playbackModeSingle;
  }

  void setPlaybackMode(bool mode) {
    _playbackModeSingle = mode;
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK SPEED

  double _playbackSpeed = 1;

  double playbackSpeed() => _playbackSpeed;

  void setPlaybackSpeed(double value) {
    _playbackSpeed = value;
  }

  ///*************************************************************************************************************************************************
  /// KEYBOARD KEY

  String _keyboardKey = '';

  String keyboardKey() => _keyboardKey;

  void setKeyboardKey(String key) {
    _keyboardKey = key;
  }

  void resetKeyboardKey() {
    setKeyboardKey(Config.keyboardKeysRows[TrackRow.name(_rowIndex)]?.elementAt(_colIndex) ?? '');
  }
}
