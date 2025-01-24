import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:tune_tangler/src/config.dart';
import 'package:tune_tangler/src/track_row_wrapper.dart';

enum TrackState {
  empty,
  recording,
  stopped,
  playing,
  paused,
}

enum TrackPlaybackMode {
  once,
  single,
  repeat,
}

class Track {
  BuildContext context;
  final int _rowIndex;
  final int _colIndex;

  Track(this.context, this._rowIndex, this._colIndex) {
    switch (Random().nextInt(5)) {
      case 1:
        _state = TrackState.recording;
        break;
      case 2:
        _state = TrackState.stopped;
        break;
      case 3:
        _state = TrackState.playing;
        break;
      case 4:
        _state = TrackState.paused;
        break;
      default:
        _state = TrackState.empty;
        break;
    }
  }

  // int _id;
  TrackState _state = TrackState.empty;

  String getName() => (TrackRowWrapper.name(_rowIndex)) + (_colIndex + 1).toString();

  TrackState getState() => _state;

  IconData getSpeedIcon() {
    switch (Random().nextInt(8)) {
      case 1:
        return Symbols.speed_0_2x_rounded;
      case 2:
        return Symbols.speed_0_5x_rounded;
      case 3:
        return Symbols.speed_0_7x_rounded;
      case 5:
        return Symbols.speed_1_2x_rounded;
      case 6:
        return Symbols.speed_1_5x_rounded;
      case 7:
        return Symbols.speed_1_7x_rounded;
      case 8:
        return Symbols.speed_2x_rounded;
      default:
        return Symbols.one_x_mobiledata;
    }
  }

  String getKeyboardKey() {
    var rowName = TrackRowWrapper.name(_rowIndex);
    return Config.keyboardKeysRows[rowName]?.elementAt(_colIndex) ?? '';
  }

  IconData getStateIcon() => Config.trackStateIcon(context)[_state] ?? Icons.square;

  Color getStateFgColor() => Config.trackStateForegroundColor(context)[_state] ?? Theme.of(context).colorScheme.primary;

  Color getStateBgColor() => Config.trackStateBackgroundColor(context)[_state] ?? Theme.of(context).colorScheme.primaryFixedDim;

  Color getStateProgressColor() => Config.trackStateProgressColor(context)[_state] ?? Theme.of(context).colorScheme.primaryContainer;

  double _playbackVolume = 100;

  double playbackVolume() => _playbackVolume;

  void setPlaybackVolume(double value) {
    _playbackVolume = value;
  }

  IconData volumeIcon() => playbackVolume() == 0
      ? Symbols.volume_off_rounded
      : playbackVolume() <= 33
          ? Symbols.volume_mute_rounded
          : playbackVolume() <= 66
              ? Symbols.volume_down_rounded
              : Symbols.volume_up_rounded;

  var _playbackMode = TrackPlaybackMode.single;

  playbackMode() => _playbackMode;

  IconData playbackModeIcon() => (Random().nextBool()) ? Symbols.repeat_rounded : Symbols.repeat_one_rounded;

  void togglePlaybackMode() {
    var temp = (_playbackMode == TrackPlaybackMode.single) ? TrackPlaybackMode.repeat : TrackPlaybackMode.single;
    _playbackMode = temp;
  }
}
