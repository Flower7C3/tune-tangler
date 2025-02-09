import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/config.dart';

import '../config/app_icon.dart';
import '../config/config_collection.dart';
import '../config/keyboard.dart';
import 'track_row.dart';

enum RecorderState {
  empty,
  recording,
  ready,
}

enum TrackState {
  empty,
  recording,
  idle,
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

  StreamSubscription? durationSubscription;

  StreamSubscription? positionSubscription;

  StreamSubscription? playerCompleteSubscription;

  StreamSubscription? playerStateChangeSubscription;

  void setStreamsInitialized() {
    durationSubscription = player.onDurationChanged.listen((Duration value) {
      setDuration(value);
    });

    positionSubscription = player.onPositionChanged.listen((Duration position) {
      if (playbackStartAtPosition.value != null && playbackEndAtPosition.value != null && position >= playbackEndAtPosition.value!) {
        if (isPlaybackReleaseModeSingle(playbackReleaseMode.value)) {
          stopPlaying();
        }
        position = playbackStartAtPosition.value!;
        player.seek(position);
      }
      setPosition(position);
    });

    playerStateChangeSubscription = player.onPlayerStateChanged.listen((PlayerState state) {
      setPlayerState(state);
    });

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      stopPlaying();
      player.seek(playbackStartAtPosition.value ?? Duration());
    });

    _streamsInitialized = true;
  }

  void dispose() {
    player.dispose();
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
  /// TIMER

  final ValueNotifier<double> clock = ValueNotifier(0);
  Timer? timer;

  void startTimer() {
    clock.value = 0;
    timer = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
      clock.value += 10;
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  ///*************************************************************************************************************************************************
  /// POSITION
  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<Duration?> position = ValueNotifier(null);
  final ValueNotifier<Duration> positionAfterCut = ValueNotifier(Duration());
  final ValueNotifier<Duration?> duration = ValueNotifier(null);
  final ValueNotifier<Duration> durationAfterCut = ValueNotifier(Duration());

  void setPosition(Duration value) {
    position.value = value;
    _updatePositionCut();
  }

  void setDuration(Duration value) {
    duration.value = value;
  }

  void _updateProgress() {
    progress.value = (durationAfterCut.value.inMilliseconds == 0) ? 0 : positionAfterCut.value.inMilliseconds / durationAfterCut.value.inMilliseconds;
  }

  void _updatePositionCut() {
    positionAfterCut.value = Duration(
        milliseconds: (position.value == null ? 0 : position.value!.inMilliseconds) -
            (playbackStartAtPosition.value == null ? 0 : playbackStartAtPosition.value!.inMilliseconds));
    _updateProgress();
  }

  void _updateDurationCut() {
    durationAfterCut.value = Duration(
        milliseconds: (playbackEndAtPosition.value == null ? 0 : playbackEndAtPosition.value!.inMilliseconds) -
            (playbackStartAtPosition.value == null ? 0 : playbackStartAtPosition.value!.inMilliseconds));
    _updateProgress();
  }

  ///*************************************************************************************************************************************************
  /// POSITION START AT

  final ValueNotifier<Duration?> playbackStartAtPosition = ValueNotifier(Duration());

  IconData? get playbackStartAtPositionIcon =>
      (playbackStartAtPosition.value != null && playbackStartAtPosition.value!.inMilliseconds > 0) ? AppIcon.trackPlaybackStartAtPosition : null;

  void setPlaybackStartAtPosition(Duration? value) {
    playbackStartAtPosition.value = (playbackEndAtPosition.value != null && value == null) ? Duration() : value;
    _updatePositionCut();
    _updateDurationCut();
    if (value != null) {
      if (position.value != null && position.value! < playbackStartAtPosition.value!) {
        player.seek(playbackStartAtPosition.value!);
      }
    }
  }

  void changePlaybackStartAtPosition(int value) {
    Duration zero = Duration();
    Duration startAt = playbackStartAtPosition.value ??= zero;
    Duration endAt = playbackEndAtPosition.value ??= zero;
    Duration newValue = Duration(milliseconds: startAt.inMilliseconds + value);
    if (newValue < zero) {
      newValue = zero;
    }
    if (newValue > endAt) {
      newValue = endAt;
    }
    setPlaybackStartAtPosition(newValue);
  }

  ///*************************************************************************************************************************************************
  /// POSITION END AT

  final ValueNotifier<Duration?> playbackEndAtPosition = ValueNotifier(Duration());

  IconData? get playbackEndAtPositionIcon =>
      (playbackEndAtPosition.value != null && duration.value != null && playbackEndAtPosition.value!.inMilliseconds != duration.value!.inMilliseconds)
          ? AppIcon.trackPlaybackEndAtPosition
          : null;

  void setPlaybackEndAtPosition(Duration? value) {
    playbackEndAtPosition.value = (value == null) ? duration.value : value;
    _updateDurationCut();
    if (value != null) {
      if (position.value != null && position.value! > playbackEndAtPosition.value!) {
        player.seek(playbackEndAtPosition.value!);
      }
    }
  }

  void changePlaybackEndAtPosition(int value) {
    Duration zero = Duration();
    Duration startAt = playbackStartAtPosition.value ??= zero;
    Duration endAt = playbackEndAtPosition.value ??= zero;
    Duration trackDuration = duration.value ??= zero;
    Duration newValue = Duration(milliseconds: endAt.inMilliseconds + value);
    if (newValue < startAt) {
      newValue = startAt;
    }
    if (newValue > trackDuration) {
      newValue = trackDuration;
    }
    setPlaybackEndAtPosition(newValue);
  }

  ///*************************************************************************************************************************************************
  /// PLAYER

  late AudioPlayer _player;

  AudioPlayer get player => _player;

  void startPlaying() {
    String? p = path;
    if (p != null && (state.value == TrackState.idle || state.value == TrackState.paused)) {
      if (playbackStartAtPosition.value != null) {
        player.seek(playbackStartAtPosition.value!);
      }
      player.resume();
    }
  }

  void pausePLaying() {
    if (path != null) {
      player.pause();
    }
  }

  void resumePlaying() {
    if (path != null) {
      player.resume();
    }
  }

  Future<void> stopPlaying() async {
    if (path != null) {
      await player.stop();
      player.seek(playbackStartAtPosition.value ?? Duration());
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
    await player.setSourceDeviceFile(newPath).then((value) async {
      await player.getDuration().then((value) => (duration.value == value) ? null : setDuration(value ?? Duration()));
      setRecorderState(RecorderState.ready);
      setPlayerState(PlayerState.completed);
      setPosition(Duration());
      setPlaybackStartAtPosition(Duration());
      setPlaybackEndAtPosition(duration.value);
      player.setVolume(playbackVolume.value);
      player.setBalance(playbackBalance.value);
      player.setReleaseMode(playbackReleaseMode.value);
      player.setPlaybackRate(playbackSpeed.value);
    });
  }

  _clearPath() {
    player.setSourceUrl('');
    setRecorderState(RecorderState.empty);
    setAudioEncoder(null);
    setSampleRate(null);
    setBitRate(null);
    setPlayerState(null);
    setPosition(Duration());
    setDuration(Duration());
    setPlaybackStartAtPosition(null);
    setPlaybackEndAtPosition(null);
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

  void setRecorderState(RecorderState state) {
    recorderState.value = state;
    updateState();
  }

  final ValueNotifier<TrackState> state = ValueNotifier(AppGlobalConfig.trackState.defaultValue);

  IconData get stateIcon => AppGlobalConfig.trackState.icon(state.value);

  void updateState() {
    state.value = switch (recorderState.value) {
      RecorderState.empty => TrackState.empty,
      RecorderState.recording => TrackState.recording,
      RecorderState.ready => switch (_playerState) {
          PlayerState.stopped => TrackState.idle,
          PlayerState.playing => TrackState.playing,
          PlayerState.paused => TrackState.paused,
          PlayerState.disposed => TrackState.idle,
          PlayerState.completed => TrackState.idle,
          _ => TrackState.empty,
        },
    };
  }

  Color stateForegroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.foregroundColor);

  Color stateBackgroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.backgroundColor);

  Color stateProgressColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.progressColor);

  ///*************************************************************************************************************************************************
  /// PLAYBACK VOLUME

  final ValueNotifier<double> playbackVolume = ValueNotifier(AppGlobalConfig.trackPlaybackVolume.defaultValue);

  Future<void> setPlaybackVolume(double value) async {
    await player.setVolume(value);
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

  final ValueNotifier<double> playbackBalance = ValueNotifier(AppGlobalConfig.trackPlaybackBalance.defaultValue);

  Future<void> setPlaybackBalance(double value) async {
    await player.setBalance(value);
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

  final ValueNotifier<ReleaseMode> playbackReleaseMode = ValueNotifier(AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);

  static isPlaybackReleaseModeSingle(ReleaseMode mode) => mode == ReleaseMode.stop;

  Future<void> setPlaybackReleaseMode(ReleaseMode value) async {
    await player.setReleaseMode(value);
    playbackReleaseMode.value = value;
  }

  IconData get playbackModeIcon => AppGlobalConfig.trackPlaybackReleaseMode.icon(playbackReleaseMode.value);

  void togglePlaybackMode() {
    setPlaybackReleaseMode(isPlaybackReleaseModeSingle(playbackReleaseMode.value) ? ReleaseMode.loop : ReleaseMode.stop);
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK SPEED

  final ValueNotifier<double> playbackSpeed = ValueNotifier(AppGlobalConfig.trackPlaybackSpeed.defaultValue);

  Future<void> setPlaybackSpeed(double value) async {
    await player.setPlaybackRate(value);
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
