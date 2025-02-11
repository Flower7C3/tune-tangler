import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../entity/track.dart';

class SettingsWrapper {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  void Function(VoidCallback fn) setState;
  final Box _globalSettingsBox;
  final Box _trackSettingsBox;

  SettingsWrapper(this.setState, this._globalSettingsBox, this._trackSettingsBox);

  dynamic get(dynamic key, {AppConfigSpace space = AppConfigSpace.global, dynamic defaultValue}) => switch (key) {
        AppConfigFieldKey.isThemeModeDark => get(AppConfigFieldKey.themeMode) == ThemeMode.dark,
        AppConfigFieldKey.isThemeModeLight => get(AppConfigFieldKey.themeMode) == ThemeMode.light,
        AppConfigFieldKey.isThemeModeSystem => get(AppConfigFieldKey.themeMode) == ThemeMode.system,
        AppConfigFieldKey.recording => _recordConfig(),
        _ => switch (space) {
            AppConfigSpace.global => _globalSettingsBox.get(AppGlobalConfigFieldsCollection.field(key).boxFieldName,
                defaultValue: AppGlobalConfigFieldsCollection.field(key).defaultValue),
            AppConfigSpace.track => _loadTrack(key, defaultValue),
          },
      };

  Track _loadTrack(dynamic key, dynamic defaultValue) {
    Track track = _trackSettingsBox.get(key, defaultValue: defaultValue);
    if (!track.streamsInitialized) {
      track.setStreamsInitialized();
      set(key, track, space: AppConfigSpace.track);
    }
    return track;
  }

  void set(dynamic key, dynamic value, {AppConfigSpace space = AppConfigSpace.global, bool updateState = false}) {
    if (updateState == true) {
      setState(() {
        _setStateLess(key, value, space: space);
      });
    } else {
      _setStateLess(key, value, space: space);
    }
  }

  void _setStateLess(dynamic key, dynamic value, {AppConfigSpace space = AppConfigSpace.global}) {
    switch (space) {
      case AppConfigSpace.global:
        _globalSettingsBox.put(AppGlobalConfigFieldsCollection.field(key).boxFieldName, value);
        switch (key) {
          case AppConfigFieldKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
        }
        break;
      case AppConfigSpace.track:
        _trackSettingsBox.put(key, value);
        break;
    }
  }

  RecordConfig _recordConfig() {
    InputDevice? inputDevice = get(AppConfigFieldKey.recordingInputDevice);
    AudioEncoder audioEncoder = get(AppConfigFieldKey.recordingAudioEncoder);
    int sampleRate = get(AppConfigFieldKey.recordingSampleRate);
    int bitRate = get(AppConfigFieldKey.recordingBitRate);
    int channels = AppGlobalConfig.recordingAudioMode.decode(get(AppConfigFieldKey.recordingAudioModeStereo));
    bool autoGain = get(AppConfigFieldKey.recordingAutoGain);
    bool echoCancel = get(AppConfigFieldKey.recordingEchoCancel);
    bool noiseSuppress = get(AppConfigFieldKey.recordingNoiseSuppress);
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

  void checkPermissions() {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions.values<Permission>()) {
      permission.status.then((status) => statuses[permission] = status);
    }
    _permissionStatuses = statuses;
  }

  Map<Permission, PermissionStatus> get permissions => _permissionStatuses;
}
