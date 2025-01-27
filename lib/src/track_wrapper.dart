import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screen/screen.dart';
import '../config/config.dart';
import 'ui_wrapper.dart';
import '../entity/track.dart';

class TrackWrapper {
  final BuildContext context;
  final ScreenInterface widget;
  final AppLocalizations _trans;
  final UIWrapper _ui;

  final List<String> _allTracksIds;

  const TrackWrapper(this.context, this.widget, this._trans, this._ui, this._allTracksIds);

  void save(Track track) {
    widget.settingsSet(track.id(), track, space: ConfigSpace.track);
  }

  List<Track> _tracksListByName(List<String> tracksIds) {
    var tracks = <Track>[];
    for (var trackId in tracksIds) {
      Track? track = widget.settingsGet(trackId, space: ConfigSpace.track);
      if (track != null) {
        tracks.add(track);
      }
    }
    return tracks.toList();
  }

  void startRecording(Track track) {
    for (Track track in _tracksListByName(_allTracksIds)) {
      stopTrackPlaying(track);
    }
    track.setState(TrackState.recording);
    save(track);
  }

  void stopRecordingAndSave(Track track) {
    _ui.toast(_trans.stop_recording_track_success(track.name()), icon: Icons.check_circle_rounded);
    track.setState(TrackState.stopped);
    save(track);
  }

  void removeRecordingAndSave(Track track) {
    if (track.state() != TrackState.empty) {
      track.setState(TrackState.empty);
      save(track);
    }
  }

  void removeTracksRecordings(List<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      removeRecordingAndSave(track);
    }
  }

  void startTrackPlaying(Track track) {
    if (track.state() != TrackState.empty) {
      track.setState(TrackState.playing);
      save(track);
    }
  }

  void pauseTrackPlaying(Track track) {
    if (track.state() != TrackState.empty) {
      track.setState(TrackState.paused);
      save(track);
    }
  }

  void resumeTrackPlaying(Track track) {
    if (track.state() != TrackState.empty) {
      track.setState(TrackState.playing);
      save(track);
    }
  }

  void stopTrackPlaying(Track track) {
    if (track.state() != TrackState.empty) {
      track.setState(TrackState.stopped);
      save(track);
    }
  }

  void startTracksPlaying(List<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      startTrackPlaying(track);
    }
  }

  void stopTracksPlaying(List<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      stopTrackPlaying(track);
    }
  }

  void setTracksPlaybackMode(List<String> tracksIds, bool value) {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setPlaybackMode(value);
    }
  }

  void setTracksPlaybackSpeed(List<String> tracksIds, double value) {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setPlaybackSpeed(value);
    }
  }

  void setTracksPlaybackVolume(List<String> allTracksIds, double value) {
    for (Track track in _tracksListByName(allTracksIds)) {
      track.setPlaybackVolume(value);
    }
  }

  void resetTracksName(List<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setName(track.id());
    }
  }

  void resetTracksKeyboardKey(List<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      track.resetKeyboardKey();
    }
  }
}
