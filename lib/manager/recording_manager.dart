import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/adapter/track_audio_source.dart';
import 'package:tune_tangler/config/app_config_fields.dart';
import 'package:tune_tangler/config/app_global_config.dart';
import 'package:tune_tangler/config/app_icon.dart';
import 'package:tune_tangler/config/config_collection.dart';
import 'package:tune_tangler/entity/track.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/main.dart';
import 'package:tune_tangler/repository/track_repository.dart';
import 'package:tune_tangler/src/generated/app_localizations.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

class RecordingManager {
  final HiveSettingsProvider _settings;
  final UIHelper _uiHelper;
  final AppLocalizations _trans;
  final TrackRepository _trackRepository;
  final AudioRecorder _audioRecorder;

  RecordingManager(this._settings, this._trans, this._uiHelper, this._trackRepository, this._audioRecorder);

  Future<void> importRecording(Track track) async {
    if (await Permission.audio.request().isGranted == false) {
      _uiHelper.toast(
        _trans.trackRecordingImportNoPermissions(track.name.value),
        icon: AppIcon.trackRecordingImport,
        type: ToastType.error,
        duration: 4,
      );
      return;
    }
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.audio);

    if (result == null) {
      _uiHelper.toast(
        _trans.trackRecordingImportCancelled(track.name.value),
        icon: AppIcon.trackRecordingImport,
        type: ToastType.error,
        duration: 4,
      );
      return;
    }
    String sourcePath = result.files.single.path!;
    String fileName = result.files.single.name;

    Directory appDir = await getApplicationDocumentsDirectory();
    String destinationPath = "${appDir.path}/${track.id}.$fileName";

    File sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);

    track.setPath(destinationPath);
    track.setAudioSource(TrackAudioSource.file);
    _trackRepository.save(track);

    _uiHelper.toast(_trans.trackRecordingImported(track.name.value), icon: AppIcon.trackRecordingImport);
  }

  RecordConfig _recordConfig() {
    InputDevice? inputDevice = _settings.getConfig(AppConfigFieldKey.recordingInputDevice);
    AudioEncoder audioEncoder = _settings.getConfig(AppConfigFieldKey.recordingAudioEncoder);
    int sampleRate = _settings.getConfig(AppConfigFieldKey.recordingSampleRate);
    int bitRate = _settings.getConfig(AppConfigFieldKey.recordingBitRate);
    int channels = AppGlobalConfig.recordingAudioMode.decode(
      _settings.getConfig(AppConfigFieldKey.recordingAudioModeStereo),
    );
    bool autoGain = _settings.getConfig(AppConfigFieldKey.recordingAutoGain);
    bool echoCancel = _settings.getConfig(AppConfigFieldKey.recordingEchoCancel);
    bool noiseSuppress = _settings.getConfig(AppConfigFieldKey.recordingNoiseSuppress);
    if (inputDevice == null) {
      return RecordConfig(
        encoder: audioEncoder,
        sampleRate: sampleRate,
        bitRate: bitRate,
        numChannels: channels,
        autoGain: autoGain,
        echoCancel: echoCancel,
        noiseSuppress: noiseSuppress,
      );
    } else {
      return RecordConfig(
        device: inputDevice,
        encoder: audioEncoder,
        sampleRate: sampleRate,
        bitRate: bitRate,
        numChannels: channels,
        autoGain: autoGain,
        echoCancel: echoCancel,
        noiseSuppress: noiseSuppress,
      );
    }
  }

  Future<void> startRecording(Track track) async {
    try {
      if (await _audioRecorder.isRecording()) {
        throw Exception(_trans.trackRecordingAlreadyStarted);
      }
      // Request permissions sequentially to avoid overlapping dialogs
      final micGranted = await Permission.microphone.request().isGranted;
      if (!micGranted) {
        throw Exception(_trans.trackRecordingStartNoAudioPermission);
      }

      final notifGranted = await Permission.notification.request().isGranted;
      if (!notifGranted) {
        throw Exception(_trans.trackRecordingStartNoNotificationPermission);
      }

      // Double-check via record plugin (should be fast now and not prompt again)
      if (!await _audioRecorder.hasPermission()) {
        throw Exception(_trans.trackRecordingStartNoAudioPermission);
      }

      RecordConfig recordConfig = _recordConfig();
      String fileExtension = AppGlobalConfig.recordingAudioEncoder.text(
        recordConfig.encoder,
        domain: ConfigItemPropertyDomain.extension,
      );
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = await getApplicationDocumentsDirectory().then(
        (value) => '${value.path}/${track.id}.$timestamp.$fileExtension',
      );

      _audioRecorder.start(recordConfig, path: filePath);

      track.startTimer();

      track.setAudioSource(TrackAudioSource.recording);
      track.setAudioEncoder(recordConfig.encoder);
      track.setSampleRate(recordConfig.sampleRate);
      track.setBitRate(recordConfig.bitRate);
      track.setRecorderState(RecorderState.recording);
      _trackRepository.save(track);

      _showRecordingNotification(track);
    } catch (e) {
      _uiHelper.toast(
        _trans.trackRecordingStartError(e.toString(), track.name.value),
        icon: AppIcon.exception,
        type: ToastType.error,
        duration: 4,
      );
    }
  }

  Future<void> _showRecordingNotification(Track track) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'recording_channel',
      _trans.trackRecording,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      silent: true,
      onlyAlertOnce: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      id: 0,
      title: _trans.trackRecordingInfo(track.name.value),
      body: _trans.clickToOpenApp,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> cancelRecording(Track track) async {
    _audioRecorder.cancel();
    flutterLocalNotificationsPlugin.cancel(id: 0);
    track.stopTimer();
    track.setPath(null);
    _trackRepository.save(track);
    _uiHelper.toast(
      _trans.trackRecordingCancelled(track.name.value),
      icon: AppGlobalConfig.trackState.icon(TrackState.empty),
    );
  }

  Future<void> stopAndSaveRecording(Track track) async {
    try {
      String? path = await _audioRecorder.stop();
      track.setRecorderState(RecorderState.ready);
      track.setPath(path);
      _uiHelper.toast(
        _trans.trackRecordingStopSuccess(track.name.value),
        icon: AppGlobalConfig.trackState.icon(TrackState.idle),
      );
      _trackRepository.save(track);
    } catch (e) {
      track.setRecorderState(RecorderState.empty);
      track.setAudioSource(null);
      track.setAudioEncoder(null);
      track.setSampleRate(null);
      track.setBitRate(null);
      track.setPath(null);
      _trackRepository.save(track);
      _uiHelper.toast(
        _trans.trackRecordingStopError(e.toString(), track.name.value),
        icon: AppIcon.exception,
        type: ToastType.error,
        duration: 4,
      );
    }
    flutterLocalNotificationsPlugin.cancel(id: 0);
    track.stopTimer();
    _trackRepository.save(track);
  }
}
