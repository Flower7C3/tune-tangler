import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/screen/screen.dart';

import '../config/config.dart';
import '../entity/track.dart';
import 'ui_wrapper.dart';

class TrackWrapper {
  final BuildContext context;
  final ScreenInterface widget;
  final AppLocalizations _trans;
  final UIWrapper _ui;

  final Set<String> _allTracksIds;
  final AudioRecorder _audioRecorder;

  TrackWrapper(this.context, this.widget, this._trans, this._ui, this._audioRecorder, this._allTracksIds);

  void initStreams(Track track) {
    if (track.streamsInitialized) {
      return;
    }
    track.setStreamsInitialized();
    save(track);
  }

  void save(Track track, {bool updateState = false}) {
    widget.settingsSet(track.id, track, space: ConfigSpace.track, updateState: updateState);
  }

  List<Track> _tracksListByName(Set<String> tracksIds) {
    var tracks = <Track>[];
    for (var trackId in tracksIds) {
      Track? track = widget.settingsGet(trackId, space: ConfigSpace.track);
      if (track != null) {
        tracks.add(track);
      }
    }
    return tracks.toList();
  }

  String _extensionName(AudioEncoder encoder) => switch (encoder) {
        AudioEncoder.aacLc => 'm4a',
        AudioEncoder.aacEld => 'm4a',
        AudioEncoder.aacHe => 'm4a',
        AudioEncoder.amrNb => '3gp',
        AudioEncoder.amrWb => '3gp',
        AudioEncoder.opus => 'opus',
        AudioEncoder.flac => 'flac',
        AudioEncoder.wav => 'wav',
        AudioEncoder.pcm16bits => 'pcm',
      };

  Future<void> startRecording(Track track) async {
    // try {
    if (await _audioRecorder.hasPermission()) {
      // stopTracksPlaying(_allTracksIds);
      var decoder = AppGlobalConfig.recordingAudioEncoderValues.codec.valueDecoder;
      AudioEncoder audioEncoder = decoder(widget.settingsGet(GlobalConfigKey.recordingAudioEncoder));
      int sampleRate = AppGlobalConfig.recordingSampleRateValues.codec.valueDecoder(widget.settingsGet(GlobalConfigKey.recordingSampleRate));
      int bitRate = AppGlobalConfig.recordingBitRateValues.codec.valueDecoder(widget.settingsGet(GlobalConfigKey.recordingBitRate));
      int channels = (widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo) == true) ? 2 : 1;
      bool autoGain = widget.settingsGet(GlobalConfigKey.recordingAutoGain);
      bool echoCancel = widget.settingsGet(GlobalConfigKey.recordingEchoCancel);
      bool noiseSuppress = widget.settingsGet(GlobalConfigKey.recordingNoiseSuppress);
      String fileExtension = _extensionName(audioEncoder);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = await getApplicationDocumentsDirectory().then((value) => '${value.path}/${track.id}.$timestamp.$fileExtension');
      await _audioRecorder.start(
        RecordConfig(
          encoder: audioEncoder,
          sampleRate: sampleRate,
          bitRate: bitRate,
          numChannels: channels,
          autoGain: autoGain,
          echoCancel: echoCancel,
          noiseSuppress: noiseSuppress,
        ),
        path: filePath,
      );
      _ui.recordingDialog(
        _trans.trackRecordingInfo(track.name),
        audioEncoderText: AppGlobalConfig.recordingAudioEncoderValues.codec.valueTranslator(audioEncoder.index.toDouble(), _trans),
        sampleRateText: _trans.recordingSampleRateValue(AppGlobalConfig.recordingSampleRateValues.codec.valueFormatter(sampleRate.toDouble())),
        bitRateText: _trans.recordingBitRateValue(AppGlobalConfig.recordingBitRateValues.codec.valueFormatter(bitRate.toDouble())),
        autoGainText: _trans.recordingAutoGainValue(autoGain ? _trans.yes : _trans.no),
        echoCancelText: _trans.recordingEchoCancelValue(echoCancel ? _trans.yes : _trans.no),
        noiseSuppressText: _trans.recordingNoiseSuppressValue(noiseSuppress ? _trans.yes : _trans.no),
        cancelLabel: _trans.trackRecordingCancel,
        onCancel: () {
          _cancelRecording(track);
        },
        saveLabel: _trans.trackRecordingStop,
        onSave: () {
          _stopAndSaveRecording(track);
        },
        onDismiss: () {
          _stopAndSaveRecording(track);
        },
      );

      track.setAudioEncoder(audioEncoder);
      track.setSampleRate(sampleRate);
      track.setBitRate(bitRate);
      // track.setChannels(channels);

      track.setRecordingState(RecorderState.recording);
      save(track);
    }
    // } catch (e) {
    //   _ui.toast(_trans.trackRecordingStartError(track.name, e), icon: Icons.error_outline_rounded, type: ToastType.error);
    // }
  }

  Future<void> _cancelRecording(Track track) async {
    await _audioRecorder.cancel();
    track.setPath(null);
    save(track, updateState: true);
    _ui.toast(_trans.trackRecordingCancelled(track.name), icon: Icons.block_rounded);
  }

  Future<void> _stopAndSaveRecording(Track track) async {
    try {
      String? path = await _audioRecorder.stop();
      track.setPath(path);
      _ui.toast(_trans.trackRecordingStopSuccess(track.name), icon: Icons.check_circle_rounded);
    } catch (e) {
      track.setRecordingState(RecorderState.empty);
      _ui.toast(_trans.trackRecordingStopError(track.name, e), icon: Icons.error_outline_rounded, type: ToastType.error);
    }
    save(track, updateState: true);
  }

  Future<void> removeTrackRecording(Track track) async {
    track.setPath(null);
    save(track);
  }

  void removeTracksRecordings(Set<String> tracksIds) async {
    for (Track track in _tracksListByName(tracksIds)) {
      removeTrackRecording(track);
    }
  }

  void startTracksPlaying(Set<String> tracksIds) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.startPlaying();
      save(track);
    }
  }

  void stopTracksPlaying(Set<String> tracksIds) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.stopPlaying();
      save(track);
    }
  }

  void setTracksPlaybackMode(Set<String> tracksIds, bool value) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setPlaybackMode(value);
    }
  }

  void setTracksPlaybackVolume(Set<String> allTracksIds, double value) async {
    for (Track track in _tracksListByName(allTracksIds)) {
      track.setPlaybackVolume(value);
    }
  }

  void setTracksPlaybackBalance(Set<String> tracksIds, double value) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setPlaybackBalance(value);
    }
  }

  void setTracksPlaybackSpeed(Set<String> tracksIds, double value) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setPlaybackSpeed(value);
    }
  }

  void resetTracksName(Set<String> tracksIds) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.setName(track.id);
    }
  }

  void resetTracksKeyboardKey(Set<String> tracksIds) async {
    for (Track track in _tracksListByName(tracksIds)) {
      track.resetKeyboardKey;
    }
  }

  void dispose(Set<String> tracksIds) {
    for (Track track in _tracksListByName(tracksIds)) {
      track.dispose();
    }
  }
}
