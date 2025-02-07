import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../entity/track.dart';
import 'app_icon.dart';
import 'config_collection.dart';

enum ToastType {
  success,
  error,
}

final class AppGlobalConfig {
  static final SliderConfigCollection gridRows = SliderConfigCollection(
    [],
    sliderValues: ConfigSliderValues(min: 2, max: 8, divisions: 6),
    defaultValue: 6,
    format: (dynamic value) => value.toStringAsFixed(0),
  );

  static final SliderConfigCollection gridCols = SliderConfigCollection(
    [],
    sliderValues: ConfigSliderValues(min: 2, max: 10, divisions: 8),
    defaultValue: 4,
    format: (dynamic value) => value.toStringAsFixed(0),
  );

  static final ConfigCollection permissions = ConfigCollection(
    [
      ConfigItem<Permission>(Permission.microphone, properties: [
        ConfigItemIconProperty(Icons.mic_rounded),
        ConfigItemTranslatableProperty((trans) => trans.microphonePermission),
      ]),
      ConfigItem<Permission>(Permission.notification, properties: [
        ConfigItemIconProperty(Icons.notifications_on_rounded),
        ConfigItemTranslatableProperty((trans) => trans.notificationPermission),
      ]),
      ConfigItem<Permission>(Permission.audio, properties: [
        ConfigItemIconProperty(Icons.speaker_rounded),
        ConfigItemTranslatableProperty((trans) => trans.audioPermission),
      ]),
    ],
  );

  static final ConfigCollection permissionsStatus = ConfigCollection(
    [
      ConfigItem<PermissionStatus>(PermissionStatus.granted, properties: [
        ConfigItemTranslatableProperty((trans) => trans.permissionStatusGranted),
      ]),
      ConfigItem<PermissionStatus>(PermissionStatus.denied, properties: [
        ConfigItemTranslatableProperty((trans) => trans.permissionStatusDenied),
      ]),
      ConfigItem<PermissionStatus>(PermissionStatus.permanentlyDenied, properties: [
        ConfigItemTranslatableProperty((trans) => trans.permissionStatusPermanentlyDenied),
      ]),
      ConfigItem<PermissionStatus>(PermissionStatus.restricted, properties: [
        ConfigItemTranslatableProperty((trans) => trans.permissionStatusRestricted),
      ]),
    ],
  );

  static final ConfigCollection trackPlaybackReleaseMode = ConfigCollection(
    [
      ConfigItem<ReleaseMode>(ReleaseMode.stop, properties: [
        ConfigItemIconProperty(AppIcon.trackSinglePlaybackMode),
      ]),
      ConfigItem<ReleaseMode>(ReleaseMode.loop, properties: [
        ConfigItemIconProperty(AppIcon.trackRepeatPlaybackMode),
      ]),
    ],
    defaultValue: ReleaseMode.stop,
  );

  static final SliderConfigCollection trackPlaybackSpeed = SliderConfigCollection(
    [
      ConfigItem<double>(0.5, properties: [
        ConfigItemIconProperty(Symbols.speed_0_5x_rounded),
      ]),
      ConfigItem<double>(1.0, properties: [
        ConfigItemIconProperty(Symbols.one_x_mobiledata_rounded),
      ]),
      ConfigItem<double>(1.5, properties: [
        ConfigItemIconProperty(Symbols.speed_1_5x_rounded),
      ]),
      ConfigItem<double>(2.0, properties: [
        ConfigItemIconProperty(Symbols.speed_2x_rounded),
      ]),
    ],
    defaultValue: 1.0,
    format: (dynamic value) => '{value}x'.replaceAll('{value}', value.toStringAsFixed(1)),
    sliderValues: ConfigSliderValues(min: 0.1, max: 2.0, divisions: 19),
  );

  static final SliderConfigCollection trackPlaybackVolume = SliderConfigCollection(
    [
      ConfigItem<double>(0.00, properties: [
        ConfigItemIconProperty(Icons.volume_off_rounded),
      ]),
      ConfigItem<double>(0.25, properties: [
        ConfigItemIconProperty(Icons.volume_mute_rounded),
      ]),
      ConfigItem<double>(0.50, properties: [
        ConfigItemIconProperty(Icons.volume_down_rounded),
      ]),
      ConfigItem<double>(0.75, properties: [
        ConfigItemIconProperty(Icons.volume_up_rounded),
      ]),
      ConfigItem<double>(1.00, properties: [
        ConfigItemIconProperty(Symbols.brand_awareness_rounded),
      ]),
    ],
    defaultValue: 1.00,
    format: (dynamic value) => '{value}%'.replaceAll('{value}', (value * 100).toStringAsFixed(0).padLeft(3, '0')),
    sliderValues: ConfigSliderValues(min: 0, max: 1, divisions: 100),
  );

  static final SliderConfigCollection trackPlaybackBalance = SliderConfigCollection(
    [
      ConfigItem<double>(-1.0, properties: [
        ConfigItemIconProperty(Icons.join_left_rounded),
        ConfigItemTextProperty('LL'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft100),
      ]),
      ConfigItem<double>(-0.5, properties: [
        ConfigItemIconProperty(Icons.join_left_rounded),
        ConfigItemTextProperty('CL'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft50),
      ]),
      ConfigItem<double>(0.0, properties: [
        ConfigItemIconProperty(Icons.join_full_rounded),
        ConfigItemTextProperty('CC'),
        ConfigItemTranslatableProperty((trans) => trans.balanceCenter),
      ]),
      ConfigItem<double>(0.5, properties: [
        ConfigItemIconProperty(Icons.join_right_outlined),
        ConfigItemTextProperty('CR'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight50),
      ]),
      ConfigItem<double>(1.0, properties: [
        ConfigItemIconProperty(Icons.join_right_outlined),
        ConfigItemTextProperty('RR'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight100),
      ]),
    ],
    defaultValue: 0.0,
    format: (dynamic value) => trackPlaybackBalance.text(value),
    sliderValues: ConfigSliderValues(min: -1, max: 1, divisions: 4),
  );

  static final ConfigCollection recordingAudioEncoder = ConfigCollection(
    [
      ConfigItem<double>(AudioEncoder.aacHe.index.toDouble(), properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacLc),
      ]),
      ConfigItem<double>(AudioEncoder.aacEld.index.toDouble(), properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacEld),
      ]),
      ConfigItem<double>(AudioEncoder.aacLc.index.toDouble(), properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacHe),
      ]),
      ConfigItem<double>(AudioEncoder.wav.index.toDouble(), properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderWav),
      ]),
      ConfigItem<double>(AudioEncoder.flac.index.toDouble(), properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderFlac),
      ]),
    ],
    defaultValue: AudioEncoder.wav.index.toDouble(),
    format: (dynamic value) => AudioEncoder.values[value.toInt()].toString().replaceAll('AudioEncoder.', ''),
    decode: (dynamic value) => AudioEncoder.values[value.toInt()],
  );

  static final ConfigCollection recordingSampleRate = ConfigCollection(
    [
      ConfigItem<int>(44100, properties: []),
      ConfigItem<int>(48000, properties: []),
      ConfigItem<int>(96000, properties: []),
    ],
    defaultValue: 48000,
    format: (dynamic value) => '{value} kHz'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
    decode: (dynamic value) => value.toInt(),
  );

  static final ConfigCollection recordingBitRate = ConfigCollection(
    [
      ConfigItem<int>(32000, properties: []),
      ConfigItem<int>(64000, properties: []),
      ConfigItem<int>(128000, properties: []),
      ConfigItem<int>(192000, properties: []),
      ConfigItem<int>(320000, properties: []),
    ],
    defaultValue: 192000,
    format: (dynamic value) => '{value} kbps'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
    decode: (dynamic value) => value.toInt(),
  );

  static final ConfigCollection languages = ConfigCollection(
    [
      ConfigItem<Locale>(Locale('en', 'US'), properties: [
        ConfigItemTextProperty('English'),
      ]),
      ConfigItem<Locale>(Locale('pl', 'PL'), properties: [
        ConfigItemTextProperty('Polski'),
      ]),
    ],
    defaultValue: Locale('en', 'US'),
  );

  static final ConfigCollection userInterfaceColor = ConfigCollection(
    [
      ConfigItem<Color>(Colors.red, properties: [
        ConfigItemTranslatableProperty((trans) => trans.red),
      ]),
      ConfigItem<Color>(Colors.green, properties: [
        ConfigItemTranslatableProperty((trans) => trans.green),
      ]),
      ConfigItem<Color>(Colors.blue, properties: [
        ConfigItemTranslatableProperty((trans) => trans.blue),
      ]),
      ConfigItem<Color>(Colors.yellow, properties: [
        ConfigItemTranslatableProperty((trans) => trans.yellow),
      ]),
      ConfigItem<Color>(Colors.purple, properties: [
        ConfigItemTranslatableProperty((trans) => trans.purple),
      ]),
      ConfigItem<Color>(Colors.orange, properties: [
        ConfigItemTranslatableProperty((trans) => trans.orange),
      ]),
      ConfigItem<Color>(Colors.cyan, properties: [
        ConfigItemTranslatableProperty((trans) => trans.cyan),
      ]),
      ConfigItem<Color>(Colors.pink, properties: [
        ConfigItemTranslatableProperty((trans) => trans.pink),
      ]),
    ],
    defaultValue: Colors.purple,
  );

  static final ConfigCollection trackState = ConfigCollection(
    [
      ConfigItem<TrackState>(TrackState.empty, properties: [
        ConfigItemIconProperty(Icons.cancel_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, name: ConfigItemPropertyName.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, name: ConfigItemPropertyName.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, name: ConfigItemPropertyName.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateEmpty),
      ]),
      ConfigItem<TrackState>(TrackState.recording, properties: [
        ConfigItemIconProperty(Icons.radio_button_checked_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.error, name: ConfigItemPropertyName.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.errorContainer, name: ConfigItemPropertyName.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainerHighest, name: ConfigItemPropertyName.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateRecording),
      ]),
      ConfigItem<TrackState>(TrackState.idle, properties: [
        ConfigItemIconProperty(Icons.task_alt_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.secondary, name: ConfigItemPropertyName.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.secondaryContainer, name: ConfigItemPropertyName.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, name: ConfigItemPropertyName.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateIdle),
      ]),
      ConfigItem<TrackState>(TrackState.playing, properties: [
        ConfigItemIconProperty(Icons.play_circle_outline),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.primary, name: ConfigItemPropertyName.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.primaryContainer, name: ConfigItemPropertyName.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, name: ConfigItemPropertyName.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.statePlaying),
      ]),
      ConfigItem<TrackState>(TrackState.paused, properties: [
        ConfigItemIconProperty(Icons.pause_circle_outline),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.tertiary, name: ConfigItemPropertyName.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.tertiaryContainer, name: ConfigItemPropertyName.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, name: ConfigItemPropertyName.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.statePaused),
      ]),
    ],
  );

  static ConfigCollection readerEncoderExtension = ConfigCollection(
    [
      ConfigItem<AudioEncoder>(AudioEncoder.aacLc, properties: [
        ConfigItemTextProperty('m4a'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.aacEld, properties: [
        ConfigItemTextProperty('m4a'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.aacHe, properties: [
        ConfigItemTextProperty('m4a'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.amrNb, properties: [
        ConfigItemTextProperty('3gp'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.amrWb, properties: [
        ConfigItemTextProperty('3gp'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.opus, properties: [
        ConfigItemTextProperty('opus'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.flac, properties: [
        ConfigItemTextProperty('flac'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.wav, properties: [
        ConfigItemTextProperty('wav'),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.pcm16bits, properties: [
        ConfigItemTextProperty('pcm'),
      ]),
    ],
  );
}
