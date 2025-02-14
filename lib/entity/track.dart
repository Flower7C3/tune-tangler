import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/app_global_config.dart';

import '../adapter/track_audio_source.dart';
import '../config/app_icon.dart';
import '../config/config_collection.dart';
import '../config/keyboard.dart';
import 'track_row.dart';

enum RecorderState {
  empty,
  recording,
  processing,
  ready,
}

enum TrackState {
  empty,
  recording,
  processing,
  idle,
  playing,
  paused,
}

class TrackId {
  final int _rowIndex;
  final int _colIndex;

  TrackId(this._rowIndex, this._colIndex);

  @override
  String toString() => (TrackRow.name(_rowIndex)) + (_colIndex + 1).toString();

  List<int> toList() => [_rowIndex, _colIndex];

  String get keyboardKey => AppKeyboardKeyMap.trackKeyboardKeyName(TrackRow.name(_rowIndex), _colIndex);
}

class Track {
  ///*************************************************************************************************************************************************
  /// INDEX

  late final TrackId id;

  Track(this.id) {
    setName(id.toString());
    resetKeyboardKey;
    _player = AudioPlayer();
  }

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
      if (position >= playbackEndAtPosition.value) {
        if (isPlaybackReleaseModeSingle(playbackReleaseMode.value)) {
          stopPlaying();
        }
        position = playbackStartAtPosition.value;
        player.seek(position);
      }
      setPosition(position);
    });

    playerStateChangeSubscription = player.onPlayerStateChanged.listen((PlayerState state) {
      setPlayerState(state);
    });

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      stopPlaying();
    });

    _streamsInitialized = true;
  }

  void dispose() {
    player.dispose().then((status) {
      durationSubscription?.cancel();
      positionSubscription?.cancel();
      playerCompleteSubscription?.cancel();
      playerStateChangeSubscription?.cancel();
    });
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
  final ValueNotifier<Duration> position = ValueNotifier(Duration());
  final ValueNotifier<Duration> positionAfterCut = ValueNotifier(Duration());
  final ValueNotifier<Duration> duration = ValueNotifier(Duration());
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
    positionAfterCut.value = Duration(milliseconds: position.value.inMilliseconds - playbackStartAtPosition.value.inMilliseconds);
    _updateProgress();
  }

  void _updateDurationCut() {
    durationAfterCut.value = Duration(milliseconds: playbackEndAtPosition.value.inMilliseconds - playbackStartAtPosition.value.inMilliseconds);
    _updateProgress();
  }

  ///*************************************************************************************************************************************************
  /// POSITION START AT

  IconData? get playbackStartAtPositionIcon => (playbackStartAtPosition.value.inMilliseconds > 0) ? AppIcon.trackPlaybackStartAtPosition : null;

  final ValueNotifier<Duration> playbackStartAtPosition = ValueNotifier(Duration());

  void resetPlaybackStartAtPosition() => setPlaybackStartAtPosition(Duration());

  void setPlaybackStartAtPosition(Duration value) {
    playbackStartAtPosition.value = value;
    _updatePositionCut();
    _updateDurationCut();
    if (position.value < playbackStartAtPosition.value) {
      player.seek(playbackStartAtPosition.value);
    }
  }

  void changePlaybackStartAtPosition(int value) {
    Duration zero = Duration();
    Duration startAt = playbackStartAtPosition.value;
    Duration endAt = playbackEndAtPosition.value;
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

  IconData? get playbackEndAtPositionIcon =>
      (playbackEndAtPosition.value.inMilliseconds != duration.value.inMilliseconds) ? AppIcon.trackPlaybackEndAtPosition : null;

  final ValueNotifier<Duration> playbackEndAtPosition = ValueNotifier(Duration());

  void resetPlaybackEndAtPosition() => setPlaybackEndAtPosition(duration.value);

  void setPlaybackEndAtPosition(Duration value) {
    playbackEndAtPosition.value = value;
    _updateDurationCut();
    if (position.value > playbackEndAtPosition.value) {
      player.seek(playbackEndAtPosition.value);
    }
  }

  void changePlaybackEndAtPosition(int value) {
    Duration startAt = playbackStartAtPosition.value;
    Duration endAt = playbackEndAtPosition.value;
    Duration trackDuration = duration.value;
    Duration newValue = Duration(milliseconds: endAt.inMilliseconds + value);
    if (newValue < startAt) {
      newValue = startAt;
    }
    if (newValue > trackDuration) {
      newValue = trackDuration;
    }
    setPlaybackEndAtPosition(newValue);
  }

  void setPlaybackStartEndAtPosition(RangeValues value) {
    setPlaybackStartAtPosition(Duration(milliseconds: value.start.toInt()));
    setPlaybackEndAtPosition(Duration(milliseconds: value.end.toInt()));
  }

  ///*************************************************************************************************************************************************
  /// PLAYER

  late AudioPlayer _player;

  AudioPlayer get player => _player;

  void startPlaying() {
    String? p = path;
    if (p != null && (state.value == TrackState.idle || state.value == TrackState.paused)) {
      player.seek(playbackStartAtPosition.value).then((status) => player.resume());
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

  void stopPlaying() {
    if (path != null) {
      player.stop().then((status) => player.seek(playbackStartAtPosition.value));
    }
  }

  ///*************************************************************************************************************************************************
  /// PATH

  String? _path;

  String? get path => _path;

  void setPath(String? newPath, {Duration? playbackStartAtPosition, Duration? playbackEndAtPosition}) async {
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

    setRecorderState(RecorderState.processing);
    player.setSourceDeviceFile(newPath).then((value) async {
      setDuration(await player.getDuration() ?? Duration());
      setPosition(Duration());
      setPlaybackStartAtPosition(playbackStartAtPosition ?? Duration());
      setPlaybackEndAtPosition(playbackEndAtPosition ?? duration.value);
      player.setVolume(playbackVolume.value);
      player.setBalance(playbackBalance.value);
      player.setReleaseMode(playbackReleaseMode.value);
      player.setPlaybackRate(playbackSpeed.value);
      setRecorderState(RecorderState.ready);
      _path = newPath;
    }).onError((error, stack) {});
  }

  _clearPath() {
    setRecorderState(RecorderState.processing);
    setAudioSource(null);
    setAudioEncoder(null);
    setSampleRate(null);
    setBitRate(null);
    setPosition(Duration());
    setDuration(Duration());
    setPlaybackStartAtPosition(Duration());
    setPlaybackEndAtPosition(Duration());
    setRecorderState(RecorderState.empty);
    _path = null;
  }

  ///*************************************************************************************************************************************************

  TrackAudioSource? _audioSource;

  TrackAudioSource? get audioSource => _audioSource;

  void setAudioSource(TrackAudioSource? value) {
    _audioSource = value;
  }

  IconData? get audioSourceIcon => switch (audioSource) {
        TrackAudioSource.recording => AppIcon.trackAudioSourceRecorded,
        TrackAudioSource.file => AppIcon.trackAudioSourceImported,
        _ => null
      };

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

  void setPlayerState(PlayerState state) {
    _playerState = state;
    updateState();
  }

  final ValueNotifier<RecorderState> recorderState = ValueNotifier(RecorderState.empty);

  void setRecorderState(RecorderState state) {
    recorderState.value = state;
    updateState();
  }

  final ValueNotifier<TrackState> state = ValueNotifier(AppGlobalConfig.trackState.defaultValue);

  void updateState() {
    state.value = switch (recorderState.value) {
      RecorderState.empty => TrackState.empty,
      RecorderState.recording => TrackState.recording,
      RecorderState.processing => TrackState.processing,
      RecorderState.ready => switch (_playerState) {
          PlayerState.playing => TrackState.playing,
          PlayerState.paused => TrackState.paused,
          _ => TrackState.idle,
        },
    };
  }

  IconData get stateIcon => AppGlobalConfig.trackState.icon(state.value);

  Color stateForegroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.foregroundColor);

  Color stateBackgroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.backgroundColor);

  Color stateProgressColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value, context: context, domain: ConfigItemPropertyDomain.progressColor);

  ///*************************************************************************************************************************************************
  /// PLAYBACK VOLUME

  final ValueNotifier<double> playbackVolume = ValueNotifier(AppGlobalConfig.trackPlaybackVolume.defaultValue);

  void setPlaybackVolume(double value) {
    player.setVolume(value);
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

  void setPlaybackBalance(double value) {
    player.setBalance(value);
    playbackBalance.value = value;
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK MODE

  final ValueNotifier<ReleaseMode> playbackReleaseMode = ValueNotifier(AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);

  static isPlaybackReleaseModeSingle(ReleaseMode mode) => mode == ReleaseMode.stop;

  void setPlaybackReleaseMode(ReleaseMode value) {
    player.setReleaseMode(value);
    playbackReleaseMode.value = value;
  }

  void togglePlaybackMode() {
    setPlaybackReleaseMode(isPlaybackReleaseModeSingle(playbackReleaseMode.value) ? ReleaseMode.loop : ReleaseMode.stop);
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK SPEED

  final ValueNotifier<double> playbackSpeed = ValueNotifier(AppGlobalConfig.trackPlaybackSpeed.defaultValue);

  void setPlaybackSpeed(double value) {
    player.setPlaybackRate(value);
    playbackSpeed.value = value;
  }

  ///*************************************************************************************************************************************************
  /// KEYBOARD KEY

  ValueNotifier<String> keyboardKey = ValueNotifier('');

  void setKeyboardKey(String key) {
    keyboardKey.value = key;
  }

  void get resetKeyboardKey {
    setKeyboardKey(id.keyboardKey);
  }
}
