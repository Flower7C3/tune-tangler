import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path/path.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/app_global_config.dart';

import '../adapter/track_adapter_key.dart';
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

  String get keyboardKey => AppKeyboardKeyMap.trackKeyboardKeyName(
      TrackRow.name(_rowIndex), _colIndex);
}

class Track {
  ///*************************************************************************************************************************************************
  /// INDEX

  late final TrackId id;

  Track(this.id) {
    setName(id.toString());
    resetKeyboardKey;
    _player = AudioPlayer();
    // Użyj normalnego trybu ale z konfiguracją audio pozwalającą na mieszanie
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _player.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
          // Kluczowe dla jednoczesnego odtwarzania
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus:
            AndroidAudioFocus.none, // Kluczowe - nie przejmuj audio focus
      ),
    ));
  }

  ///*************************************************************************************************************************************************
  /// STREAMS

  bool _streamsInitialized = false;

  bool get streamsInitialized => _streamsInitialized;

  StreamSubscription? durationSubscription;

  StreamSubscription? positionSubscription;

  StreamSubscription? playerCompleteSubscription;

  StreamSubscription? playerStateChangeSubscription;

  // Throttling mechanism for performance
  Timer? _throttleTimer;
  Duration? _lastPositionUpdate;
  Duration? _lastDurationUpdate;
  PlayerState? _lastPlayerStateUpdate;

  static const Duration _throttleInterval =
      Duration(milliseconds: 16); // 60 FPS

  void setStreamsInitialized() {
    durationSubscription = player.onDurationChanged.listen((Duration value) {
      _throttledDurationUpdate(value);
    });

    positionSubscription = player.onPositionChanged.listen((Duration position) {
      _throttledPositionUpdate(position);
    });

    playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((PlayerState state) {
      _throttledPlayerStateUpdate(state);
    });

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      stopPlaying();
    });

    _streamsInitialized = true;
  }

  void _throttledPositionUpdate(Duration position) {
    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

    if (_lastPositionUpdate == null ||
        now.inMilliseconds - _lastPositionUpdate!.inMilliseconds >=
            _throttleInterval.inMilliseconds) {
      _lastPositionUpdate = now;
      
      if (position >= playbackEndAtPosition.value) {
        if (isPlaybackReleaseModeSingle(playbackReleaseMode.value)) {
          stopPlaying();
        } else {
          setPosition(playbackStartAtPosition.value);
          player.seek(playbackStartAtPosition.value);
        }
        return; // ✅ Nie ustawiaj pozycji ponownie
      }
      setPosition(position);
    }
  }

  void _throttledDurationUpdate(Duration value) {
    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

    if (_lastDurationUpdate == null ||
        now.inMilliseconds - _lastDurationUpdate!.inMilliseconds >=
            _throttleInterval.inMilliseconds) {
      _lastDurationUpdate = now;
      setDuration(value);
    }
  }

  void _throttledPlayerStateUpdate(PlayerState state) {
    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

    if (_lastPlayerStateUpdate == null ||
        now.inMilliseconds -
                (_lastPlayerStateUpdate == null
                    ? 0
                    : _lastPlayerStateUpdate!.index * 16) >=
            _throttleInterval.inMilliseconds) {
      _lastPlayerStateUpdate = state;
      setPlayerState(state);
    }
  }

  void dispose() {
    _throttleTimer?.cancel();
    _throttleTimer = null;

    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateChangeSubscription?.cancel();

    player.dispose().then((status) {
      // Cleanup completed
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
  Timer? _timer;

  void startTimer() {
    clock.value = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.value == TrackState.recording) {
        clock.value = clock.value + 100; // milliseconds
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
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
    progress.value = (durationAfterCut.value.inMilliseconds == 0)
        ? 0
        : positionAfterCut.value.inMilliseconds /
            durationAfterCut.value.inMilliseconds;
  }

  void _updatePositionCut() {
    positionAfterCut.value = Duration(
        milliseconds: position.value.inMilliseconds -
            playbackStartAtPosition.value.inMilliseconds);
    _updateProgress();
  }

  void _updateDurationCut() {
    durationAfterCut.value = Duration(
        milliseconds: playbackEndAtPosition.value.inMilliseconds -
            playbackStartAtPosition.value.inMilliseconds);
    _updateProgress();
  }

  ///*************************************************************************************************************************************************
  /// POSITION START AT

  IconData? get playbackStartAtPositionIcon =>
      (playbackStartAtPosition.value.inMilliseconds > 0)
          ? AppIcon.trackPlaybackStartAtPosition
          : null;

  final ValueNotifier<Duration> playbackStartAtPosition =
      ValueNotifier(Duration());

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
      (playbackEndAtPosition.value.inMilliseconds !=
              duration.value.inMilliseconds)
          ? AppIcon.trackPlaybackEndAtPosition
          : null;

  final ValueNotifier<Duration> playbackEndAtPosition =
      ValueNotifier(Duration());

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
    if (p != null &&
        (state.value == TrackState.idle || state.value == TrackState.paused)) {
      player
          .seek(playbackStartAtPosition.value)
          .then((status) => player.resume());
    }
  }

  void pausePlaying() {
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
      player.stop().then((status) {
        setPosition(playbackStartAtPosition.value); // Ustaw pozycję po zatrzymaniu
      });
    }
  }

  ///*************************************************************************************************************************************************
  /// PATH

  String? _path;

  String? get path => _path;

  void setPath(String? newPath,
      {Duration? playbackStartAtPosition,
      Duration? playbackEndAtPosition,
      bool preserveDuration = false,
      bool preservePlaybackPositions = false}) {
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
    player.setVolume(playbackVolume.value);
    player.setBalance(playbackBalance.value);
    player.setReleaseMode(playbackReleaseMode.value);
    player.setPlaybackRate(playbackSpeed.value);
    _path = newPath;
    player.setSourceDeviceFile(newPath).then((value) async {
      Duration trackDuration = await player.getDuration() ?? Duration();
      if (!preserveDuration) {
        setDuration(trackDuration);
      }
      if (!preservePlaybackPositions) {
        setPosition(Duration());
        setPlaybackStartAtPosition(playbackStartAtPosition ?? Duration());
        setPlaybackEndAtPosition(playbackEndAtPosition ?? trackDuration);
      } else {
        // Gdy preservePlaybackPositions=true, ustaw pozycję na Duration()
        // Pozycje odtwarzania będą ustawione po wywołaniu setPath
        setPosition(Duration());
      }
      setRecorderState(RecorderState.ready);
    }).onError((error, stack) {
      debugPrint('Error in setPath: $error');
      _clearPath();
    });
  }

  void _clearPath() {
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

  final ValueNotifier<RecorderState> recorderState =
      ValueNotifier(RecorderState.empty);

  void setRecorderState(RecorderState state) {
    recorderState.value = state;
    updateState();
  }

  final ValueNotifier<TrackState> state =
      ValueNotifier(AppGlobalConfig.trackState.defaultValue);

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
      AppGlobalConfig.trackState.color(state.value,
          context: context, domain: ConfigItemPropertyDomain.foregroundColor);

  Color stateBackgroundColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value,
          context: context, domain: ConfigItemPropertyDomain.backgroundColor);

  Color stateProgressColor(BuildContext context) =>
      AppGlobalConfig.trackState.color(state.value,
          context: context, domain: ConfigItemPropertyDomain.progressColor);

  ///*************************************************************************************************************************************************
  /// PLAYBACK VOLUME

  final ValueNotifier<double> playbackVolume =
      ValueNotifier(AppGlobalConfig.trackPlaybackVolume.defaultValue);

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

  final ValueNotifier<double> playbackBalance =
      ValueNotifier(AppGlobalConfig.trackPlaybackBalance.defaultValue);

  void setPlaybackBalance(double value) {
    player.setBalance(value);
    playbackBalance.value = value;
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK MODE

  final ValueNotifier<ReleaseMode> playbackReleaseMode =
      ValueNotifier(AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);

  static bool isPlaybackReleaseModeSingle(ReleaseMode mode) =>
      mode == ReleaseMode.stop;

  void setPlaybackReleaseMode(ReleaseMode value) {
    player.setReleaseMode(value);
    playbackReleaseMode.value = value;
  }

  void togglePlaybackMode() {
    setPlaybackReleaseMode(
        isPlaybackReleaseModeSingle(playbackReleaseMode.value)
            ? ReleaseMode.loop
            : ReleaseMode.stop);
  }

  ///*************************************************************************************************************************************************
  /// PLAYBACK SPEED

  final ValueNotifier<double> playbackSpeed =
      ValueNotifier(AppGlobalConfig.trackPlaybackSpeed.defaultValue);

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

  Future<void> fromTrack(Track track) async {
    if (track.id.toString() == track.name.value) {
      setName(id.toString());
    } else {
      setName(track.name.value);
    }
    setPlaybackReleaseMode(track.playbackReleaseMode.value);
    setPlaybackVolume(track.playbackVolume.value);
    setPlaybackBalance(track.playbackBalance.value);
    setPlaybackSpeed(track.playbackSpeed.value);
    setDuration(track.duration.value);

    try {
      if (track.path == null) {
        throw Exception();
      }
      File oldFile = File(track.path!);
      if (!oldFile.existsSync()) {
        throw Exception();
      }
      Directory appDir = await getApplicationDocumentsDirectory();
      String newFileName = path_provider
          .basename(track.path!)
          .replaceFirst(RegExp(r'^[^.]+'), id.toString());
      String newFilePath = "${appDir.path}/$newFileName";
      File newFile = oldFile.renameSync(newFilePath);
      setPath(newFile.path,
          preserveDuration: true, preservePlaybackPositions: true);
    } catch (e) {
      _path = null;
      setRecorderState(RecorderState.empty);
      updateState();
    }

    setAudioSource(track.audioSource);
    setAudioEncoder(track.audioEncoder);
    setSampleRate(track.sampleRate);
    setBitRate(track.bitRate);

    // Ustaw pozycje odtwarzania po przeniesieniu ścieżki
    setPlaybackStartAtPosition(track.playbackStartAtPosition.value);
    setPlaybackEndAtPosition(track.playbackEndAtPosition.value);

    // Ustaw pozycję po przeniesieniu ścieżki
    setPosition(track.position.value);

    // Aktualizuj progress po ustawieniu wszystkich wartości
    _updateProgress();
  }

  static Track fromMap(Map data) {
    TrackId trackId = data[TrackAdapterKey.trackId];
    Track track = Track(trackId);
    track.setName(data[TrackAdapterKey.name]);
    track.setPlaybackReleaseMode(
        ReleaseMode.values[data[TrackAdapterKey.playbackReleaseMode]]);
    track.setPlaybackVolume(data[TrackAdapterKey.playbackVolume] ??
        AppGlobalConfig.trackPlaybackVolume.defaultValue);
    track.setPlaybackBalance(data[TrackAdapterKey.playbackBalance] ??
        AppGlobalConfig.trackPlaybackBalance.defaultValue);
    track.setPlaybackSpeed(data[TrackAdapterKey.playbackSpeed] ??
        AppGlobalConfig.trackPlaybackSpeed.defaultValue);
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey] ?? '');
    track.setAudioSource(data[TrackAdapterKey.audioSource] != null
        ? TrackAudioSource.values[data[TrackAdapterKey.audioSource]]
        : null);
    track.setAudioEncoder(data[TrackAdapterKey.audioEncoder] != null
        ? AudioEncoder.values[data[TrackAdapterKey.audioEncoder]]
        : null);
    track.setSampleRate(data[TrackAdapterKey.sampleRate]);
    track.setBitRate(data[TrackAdapterKey.bitRate]);
    track.setPath(data[TrackAdapterKey.path],
        playbackStartAtPosition: data[TrackAdapterKey.playbackStartAtPosition],
        playbackEndAtPosition: data[TrackAdapterKey.playbackEndAtPosition]);
    track.updateState();
    return track;
  }

  Map toMap() => {
        TrackAdapterKey.trackId: id,
        TrackAdapterKey.name: name.value,
        TrackAdapterKey.path: path,
        TrackAdapterKey.playbackReleaseMode: playbackReleaseMode.value.index,
        TrackAdapterKey.playbackVolume: playbackVolume.value,
        TrackAdapterKey.playbackBalance: playbackBalance.value,
        TrackAdapterKey.playbackSpeed: playbackSpeed.value,
        TrackAdapterKey.playbackStartAtPosition: playbackStartAtPosition.value,
        TrackAdapterKey.playbackEndAtPosition: playbackEndAtPosition.value,
        TrackAdapterKey.keyboardKey: keyboardKey.value,
        TrackAdapterKey.audioSource: audioSource?.index,
        TrackAdapterKey.audioEncoder: audioEncoder?.index,
        TrackAdapterKey.sampleRate: sampleRate,
        TrackAdapterKey.bitRate: bitRate,
      };
}
