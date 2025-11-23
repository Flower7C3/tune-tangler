import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path_provider;
import 'package:path_provider/path_provider.dart';

import '../adapter/track_adapter_key.dart';
import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class TrackRepository {
  final HiveSettingsProvider _settings;

  TrackRepository(this._settings) {
    resetTracksCollection();
  }

  late Map<String, Set<Track>> _tracksCollection;

  void resetTracksCollection() => _tracksCollection = {};

  Set<Track> allTracks() => _lazyLoadCollection(-1);

  Set<Track> rowTracks(int rowIndex) => _lazyLoadCollection(rowIndex);

  Set<Track> _lazyLoadCollection(int rowIndex) {
    String name = rowIndex < 0 ? 'all' : TrackRow.name(rowIndex);
    if (!_tracksCollection.containsKey(name) ||
        _tracksCollection[name]!.isEmpty) {
      int colsAmount = _settings.getConfig(AppConfigFieldKey.gridColsAmount);
      if (rowIndex < 0) {
        int rowsAmount = _settings.getConfig(AppConfigFieldKey.gridRowsAmount);
        for (int rowIndex = 0; rowIndex < rowsAmount; rowIndex++) {
          _lazyLoadRowTracks(name, rowIndex, colsAmount);
        }
      } else {
        _lazyLoadRowTracks(name, rowIndex, colsAmount);
      }
    }
    return _tracksCollection[name]!;
  }

  void _lazyLoadRowTracks(String name, int rowIndex, int colsAmount) {
    for (int columnIndex = 0; columnIndex < colsAmount; columnIndex++) {
      _lazyLoadTrack(name, rowIndex, columnIndex);
    }
  }

  void _lazyLoadTrack(String name, int rowIndex, int columnIndex) {
    Track track = _settings.getTrack(rowIndex, columnIndex);

    if (!_tracksCollection.containsKey(name)) {
      _tracksCollection[name] = {};
    }
    _tracksCollection[name]!.add(track);
  }

  void save(Track track) {
    _settings.saveTrack(track);
  }

  void trackRecordingDelete(Track track) {
    track.setPath(null);
    save(track);
  }

  void togglePlaybackMode(Track track) {
    track.togglePlaybackMode();
    save(track);
  }

  void deleteTracksRecordings(Set<Track> tracksList) {
    for (Track track in tracksList) {
      trackRecordingDelete(track);
      save(track);
    }
  }

  void startTracksPlaying(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      // Sprawdź czy ścieżka ma nagranie i jest gotowa do odtwarzania
      if (track.path != null &&
          track.recorderState.value == RecorderState.ready) {
        track.startPlaying();
        save(track);
      }
    }
  }

  void stopTracksPlaying(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.stopPlaying();
      save(track);
    }
  }

  void setTracksPlaybackMode(Set<Track> tracksList, ReleaseMode value) async {
    for (Track track in tracksList) {
      track.setPlaybackReleaseMode(value);
      save(track);
    }
  }

  void setTracksPlaybackVolume(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackVolume(value);
      save(track);
    }
  }

  void setTracksPlaybackBalance(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackBalance(value);
      save(track);
    }
  }

  void setTracksPlaybackSpeed(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackSpeed(value);
      save(track);
    }
  }

  void resetTracksPlaybackStartAtPosition(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetPlaybackStartAtPosition();
      save(track);
    }
  }

  void resetTracksPlaybackEndAtPosition(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetPlaybackEndAtPosition();
      save(track);
    }
  }

  void resetTracksName(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.setName(track.id.toString());
      save(track);
    }
  }

  void resetTracksKeyboardKey(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetKeyboardKey;
      save(track);
    }
  }

  void resetTracksSettings(Set<Track> tracksList) {
    setTracksPlaybackMode(
      tracksList,
      AppGlobalConfig.trackPlaybackReleaseMode.defaultValue,
    );
    setTracksPlaybackBalance(
      tracksList,
      AppGlobalConfig.trackPlaybackBalance.defaultValue,
    );
    setTracksPlaybackVolume(
      tracksList,
      AppGlobalConfig.trackPlaybackVolume.defaultValue,
    );
    setTracksPlaybackSpeed(
      tracksList,
      AppGlobalConfig.trackPlaybackSpeed.defaultValue,
    );
    resetTracksPlaybackStartAtPosition(tracksList);
    resetTracksPlaybackEndAtPosition(tracksList);
    resetTracksName(tracksList);
    resetTracksKeyboardKey(tracksList);
  }

  void dispose(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.dispose();
    }
  }

  bool _isSwapping = false;

  /// Bezpieczna zamiana z walidacją
  Future<void> safeSwapTracks(Track track1, Track track2, AppLocalizations trans) async {
    if (_isSwapping) {
      throw Exception(trans.trackRecordingMoveInProgress);
    }
    if (!canSwapTracks(track1, track2)) {
      throw Exception(trans.trackRecordingMoveNotAllowed);
    }

    _isSwapping = true;

    // Zapisujemy WSZYSTKIE właściwości używając istniejących metod
    final tempTrack1Data = track1.toMap();
    final tempTrack2Data = track2.toMap();

    try {
      // 1. Tymczasowo zmieniamy nazwy plików aby uniknąć konfliktów
      final tempPath1 = await _createTempPathForSwap(
        track1.path,
        track1.id,
        'temp_swap_1',
      );
      final tempPath2 = await _createTempPathForSwap(
        track2.path,
        track2.id,
        'temp_swap_2',
      );

      if (track1.path != null && File(track1.path!).existsSync()) {
        try {
          await File(track1.path!).rename(tempPath1);
        } catch (_) {
          await File(track1.path!).copy(tempPath1);
          await File(track1.path!).delete();
        }
      }
      if (track2.path != null && File(track2.path!).existsSync()) {
        try {
          await File(track2.path!).rename(tempPath2);
        } catch (_) {
          await File(track2.path!).copy(tempPath2);
          await File(track2.path!).delete();
        }
      }

      // 2. Zamiana właściwości track2 -> track1 (zachowaj klawisz skrótu)
      await track1.applyTrackPropertiesFromMap(tempTrack2Data, tempPath2, preserveKeyboardKey: true);

      // 3. Zamiana właściwości track1 -> track2 (zachowaj klawisz skrótu)
      await track2.applyTrackPropertiesFromMap(tempTrack1Data, tempPath1, preserveKeyboardKey: true);
    } catch (e) {
      debugPrint('Error while swapping tracks: $e');

      // W przypadku błędu próbujemy przywrócić oryginalne pliki
      try {
        await _restoreFilesAfterError(
          track1,
          track2,
          tempTrack1Data,
          tempTrack2Data,
        );
      } catch (restoreError) {
        debugPrint('Error restoring files after swap failure: $restoreError');
      }

      throw Exception(trans.trackRecordingMoveFailed);
    } finally {
      resetTracksCollection();
      _isSwapping = false;
    }
  }

  /// Sprawdza czy tracki mogą być bezpiecznie zamienione
  bool canSwapTracks(Track track1, Track track2) {
    return track1.state.value != TrackState.recording &&
        track2.state.value != TrackState.recording &&
        track1.state.value != TrackState.playing &&
        track2.state.value != TrackState.playing &&
        track1.state.value != TrackState.processing &&
        track2.state.value != TrackState.processing;
  }

  /// Tworzy tymczasową ścieżkę dla zamiany
  Future<String> _createTempPathForSwap(
    String? originalPath,
    TrackId trackId,
    String tempPrefix,
  ) async {
    if (originalPath == null || !File(originalPath).existsSync()) {
      return ''; // Brak pliku do przeniesienia
    }

    final appDir = await getApplicationDocumentsDirectory();
    final originalExtension = path_provider.extension(originalPath);
    final tempFileName =
        '${tempPrefix}_${trackId.toString()}_${DateTime.now().millisecondsSinceEpoch}$originalExtension';
    return "${appDir.path}/$tempFileName";
  }

  /// Przywraca pliki w przypadku błędu (z użyciem map)
  Future<void> _restoreFilesAfterError(
    Track track1,
    Track track2,
    Map<dynamic, dynamic> properties1,
    Map<dynamic, dynamic> properties2,
  ) async {
    try {
      // Przywracanie pliku dla track1
      if (properties1[TrackAdapterKey.path] != null) {
        final originalPath = properties1[TrackAdapterKey.path]!;
        final appDir = await getApplicationDocumentsDirectory();
        final originalExtension = path_provider.extension(originalPath);
        final restoredPath1 =
            "${appDir.path}/${track1.id.toString()}$originalExtension";

        if (File(originalPath).existsSync()) {
          if (File(restoredPath1).existsSync()) {
            await File(restoredPath1).delete();
          }
          await File(originalPath).rename(restoredPath1);
        }
      }

      // Przywracanie pliku dla track2
      if (properties2[TrackAdapterKey.path] != null) {
        final originalPath = properties2[TrackAdapterKey.path]!;
        final appDir = await getApplicationDocumentsDirectory();
        final originalExtension = path_provider.extension(originalPath);
        final restoredPath2 =
            "${appDir.path}/${track2.id.toString()}$originalExtension";

        if (File(originalPath).existsSync()) {
          if (File(restoredPath2).existsSync()) {
            await File(restoredPath2).delete();
          }
          await File(originalPath).rename(restoredPath2);
        }
      }
    } catch (e) {
      debugPrint('Critical error while restoring files: $e');
    }
  }
}
