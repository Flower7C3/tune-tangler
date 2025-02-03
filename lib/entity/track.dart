import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/config.dart';

import '../config/config_collection.dart';
import '../config/keyboard.dart';
import 'track_row.dart';

enum RecorderState {
  empty,
  recording,
  ready,
}

enum TrackState {
  undefined,
  empty,
  recording,
  ready,
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
    resetKeyboardKey;
    _player = AudioPlayer();
  }

  String get id => buildId(_rowIndex, _colIndex);

  int get rowIndex => _rowIndex;

  int get colIndex => _colIndex;

  static String buildId(int rowIndex, int colIndex) => (TrackRow.name(rowIndex)) + (colIndex + 1).toString();

  ///*************************************************************************************************************************************************
  /// STREAMS

  bool _streamsInitialized = false;

  bool get streamsInitialized => _streamsInitialized;

  void setStreamsInitialized() {
    durationSubscription = player.onDurationChanged.listen((value) {
      setDuration(value);
    });

    positionSubscription = player.onPositionChanged.listen(
      (value) => (position.value == value) ? null : setPosition(value),
    );

    playerStateChangeSubscription = player.onPlayerStateChanged.listen((state) {
      setPlayerState(state);
    });

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      stopPlaying();
    });

    _streamsInitialized = true;
  }

  StreamSubscription? durationSubscription;

  StreamSubscription? positionSubscription;

  StreamSubscription? playerCompleteSubscription;

  StreamSubscription? playerStateChangeSubscription;

  void dispose() {
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateChangeSubscription?.cancel();
  }

  ///*************************************************************************************************************************************************
  /// NAME

  ValueNotifier<String> name = ValueNotifier('');

  void setName(String value) {
    name.value = value;
  }

  ///*************************************************************************************************************************************************
  /// DURATION

  final ValueNotifier<double> clock = ValueNotifier(0);
  Timer? timer;

  void startTimer() {
    clock.value = 0;
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      clock.value += 100;
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  final ValueNotifier<Duration?> duration = ValueNotifier(null);

  final ValueNotifier<Duration?> position = ValueNotifier(null);

  final ValueNotifier<double> progress = ValueNotifier(0);

  void setDuration(Duration? value) {
    duration.value = value;
  }

  void setPosition(Duration? value) {
    position.value = value;
    if (position.value == null || duration.value == null || position.value?.inMilliseconds == null || duration.value?.inMilliseconds == null) {
      progress.value = 0;
    } else {
      progress.value = position.value!.inMilliseconds / duration.value!.inMilliseconds;
    }
  }

  ///*************************************************************************************************************************************************
  /// PLAYER

  late AudioPlayer _player;

  AudioPlayer get player => _player;

  void startPlaying() {
    String? p = path;
    if ((state.value == TrackState.stopped || state.value == TrackState.paused) && p != null) {
      _player.resume();
      setPlayerState(PlayerState.playing);
    }
  }

  void pausePLaying() {
    if (path != null) {
      _player.pause();
      setPlayerState(PlayerState.paused);
    }
  }

  void resumePlaying() {
    if (path != null) {
      _player.resume();
      setPlayerState(PlayerState.playing);
    }
  }

  void stopPlaying() {
    if (path != null) {
      _player.stop();
      setPlayerState(PlayerState.stopped);
      setPosition(Duration.zero);
    }
  }

  ///*************************************************************************************************************************************************
  /// PATH

  String? _path;

  String? get path => _path;

  Future<void> setPath(String? newPath) async {
    if (newPath == null) {
      if (path != null && File(path!).existsSync()) {
        File(path!).delete();
      }
      _clearPath();
      return;
    }

    if (!File(newPath).existsSync()) {
      _clearPath();
      return;
    }

    _path = newPath;
    await _player.setSourceDeviceFile(newPath).then((dynamic response) {
      setRecordingState(RecorderState.ready);
      setPlayerState(PlayerState.stopped);
      _player.getDuration().then((value) => (duration.value == value) ? null : setDuration(value));
      _player.setVolume(playbackVolume.value);
      _player.setBalance(playbackBalance.value);
      _player.setReleaseMode(playbackModeSingle.value ? ReleaseMode.release : ReleaseMode.loop);
      _player.setPlaybackRate(playbackSpeed.value);
    });
  }

  _clearPath() {
    setRecordingState(RecorderState.empty);
    setAudioEncoder(null);
    setSampleRate(null);
    setBitRate(null);
    setRecordingState(RecorderState.empty);
    setPlayerState(null);
    setPosition(null);
    setDuration(null);
    _player.setSourceUrl('');
    _path = null;
  }

  ///*************************************************************************************************************************************************
  AudioEncoder? _audioEncoder;

  AudioEncoder? get audioEncoder => _audioEncoder;

  void setAudioEncoder(AudioEncoder? audioEncoder) {
    _audioEncoder = audioEncoder;
  }

  int? _sampleRate;

  int? get sampleRate => _sampleRate;

  void setSampleRate(int? sampleRate) {
    _sampleRate = sampleRate;
  }

  int? _bitRate;

  int? get bitRate => _bitRate;

  void setBitRate(int? bitRate) {
    _bitRate = bitRate;
  }

  ///*************************************************************************************************************************************************
  /// STATE

  PlayerState? _playerState;

  PlayerState? get playerState => _playerState;

  void setPlayerState(PlayerState? state) {
    _playerState = state;
    updateState();
  }

  final ValueNotifier<RecorderState> recorderState = ValueNotifier(RecorderState.empty);

  void setRecordingState(RecorderState state) {
    recorderState.value = state;
    updateState();
  }

  final ValueNotifier<TrackState> state = ValueNotifier(TrackState.undefined);

  final ValueNotifier<IconData> stateIcon = ValueNotifier(Icons.square_rounded);

  void updateState() {
    state.value = switch (recorderState.value) {
      RecorderState.empty => TrackState.empty,
      RecorderState.recording => TrackState.recording,
      RecorderState.ready => switch (_playerState) {
          PlayerState.stopped => TrackState.stopped,
          PlayerState.playing => TrackState.playing,
          PlayerState.paused => TrackState.paused,
          PlayerState.disposed => TrackState.stopped,
          PlayerState.completed => TrackState.stopped,
          _ => TrackState.empty,
        },
    };
    stateIcon.value = AppGlobalConfig.trackState.icon(state.value);
  }

  Color stateForegroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, name: ConfigItemPropertyName.foregroundColor);

  Color stateBackgroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, name: ConfigItemPropertyName.backgroundColor);

  Color stateProgressColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, name: ConfigItemPropertyName.progressColor);

  ///*************************************************************************************************************************************************
  /// PLAYBACK VOLUME

  static double defaultPlaybackVolume = 1;

  final ValueNotifier<double> playbackVolume = ValueNotifier(defaultPlaybackVolume);

  Future<void> setPlaybackVolume(double value) async {
    await _player.setVolume(value);
    playbackVolume.value = value;
  }

  IconData get playbackVolumeIcon {
    IconData volumeIcon = Symbols.add;
    AppGlobalConfig.trackPlaybackVolume.values<double>().any((double value) {
      if (playbackVolume.value <= value) {
        volumeIcon = AppGlobalConfig.trackPlaybackVolume.icon(value);
        return true;
      }
      return false;
    });
    return volumeIcon;
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK BALANCE

  static double defaultPlaybackBalance = 0;

  final ValueNotifier<double> playbackBalance = ValueNotifier(defaultPlaybackBalance);

  Future<void> setPlaybackBalance(double value) async {
    await _player.setBalance(value);
    playbackBalance.value = value;
  }

  IconData get playbackBalanceIcon {
    if (playbackBalance.value < 0) {
      return Icons.join_left_rounded;
    }
    if (playbackBalance.value > 0) {
      return Icons.join_right_rounded;
    }
    return Icons.join_full_rounded;
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK MODE

  static bool defaultPlaybackModeSingle = true;

  final ValueNotifier<bool> playbackModeSingle = ValueNotifier(defaultPlaybackModeSingle);

  Future<void> setPlaybackMode(bool value) async {
    await _player.setReleaseMode(value ? ReleaseMode.release : ReleaseMode.loop);
    playbackModeSingle.value = value;
  }

  IconData get playbackModeIcon => (playbackModeSingle.value) ? Symbols.repeat_one_rounded : Symbols.repeat_rounded;

  void togglePlaybackMode() {
    setPlaybackMode(!playbackModeSingle.value);
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK SPEED

  static double defaultPlaybackSpeed = 1;
  final ValueNotifier<double> playbackSpeed = ValueNotifier(defaultPlaybackSpeed);

  Future<void> setPlaybackSpeed(double value) async {
    await _player.setPlaybackRate(value);
    playbackSpeed.value = value;
  }

  ///*************************************************************************************************************************************************
  /// KEYBOARD KEY

  ValueNotifier<String> keyboardKey = ValueNotifier('');

  void setKeyboardKey(String key) {
    keyboardKey.value = key;
  }

  void get resetKeyboardKey {
    setKeyboardKey(AppKeyboardKeyMap.trackKeyboardKeyName(TrackRow.name(_rowIndex), _colIndex));
  }
}
