import 'package:audioplayers/audioplayers.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import '../wrapper/settings_wrapper.dart';

class TrackRepository {
  final SettingsWrapper _settings;

  TrackRepository(this._settings) {
    resetTracksCollection();
  }

  late Map<String, Set<Track>> _tracksCollection;

  void resetTracksCollection() => _tracksCollection = {};

  Set<Track> allTracks() => _lazyLoadCollection(-1);

  Set<Track> rowTracks(int rowIndex) => _lazyLoadCollection(rowIndex);

  Set<Track> _lazyLoadCollection(int rowIndex) {
    String name = rowIndex < 0 ? 'all' : TrackRow.name(rowIndex);
    if (!_tracksCollection.containsKey(name) || _tracksCollection[name]!.isEmpty) {
      int colsAmount = _settings.get(AppConfigFieldKey.gridColsAmount);
      if (rowIndex < 0) {
        int rowsAmount = _settings.get(AppConfigFieldKey.gridRowsAmount);
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
    String trackId = Track.buildId(rowIndex, columnIndex);
    Track track = _settings.get(trackId, space: AppConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));

    if (!_tracksCollection.containsKey(name)) {
      _tracksCollection[name] = {};
    }
    _tracksCollection[name]!.add(track);
  }

  void save(Track track) {
    _settings.set(track.id, track, space: AppConfigSpace.track);
  }

  Future<void> removeTrackRecording(Track track) async {
    track.setPath(null);
    save(track);
  }

  void removeTracksRecordings(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      removeTrackRecording(track);
      save(track);
    }
  }

  void startTracksPlaying(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.startPlaying();
      save(track);
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
      track.setName(track.id);
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
    setTracksPlaybackMode(tracksList, AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);
    setTracksPlaybackBalance(tracksList, AppGlobalConfig.trackPlaybackBalance.defaultValue);
    setTracksPlaybackVolume(tracksList, AppGlobalConfig.trackPlaybackVolume.defaultValue);
    setTracksPlaybackSpeed(tracksList, AppGlobalConfig.trackPlaybackSpeed.defaultValue);
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
}
