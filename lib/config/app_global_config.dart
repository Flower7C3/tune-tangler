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
        ConfigItemIconProperty(Icons.perm_camera_mic_rounded),
        ConfigItemTranslatableProperty((trans) => trans.microphonePermission),
      ]),
      ConfigItem<Permission>(Permission.notification, properties: [
        ConfigItemIconProperty(Icons.notifications_on_rounded),
        ConfigItemTranslatableProperty((trans) => trans.notificationPermission),
      ]),
      ConfigItem<Permission>(Permission.audio, properties: [
        ConfigItemIconProperty(Icons.perm_media_rounded),
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
        ConfigItemTranslatableProperty((trans) => trans.singlePlaybackMode),
      ]),
      ConfigItem<ReleaseMode>(ReleaseMode.loop, properties: [
        ConfigItemIconProperty(AppIcon.trackRepeatPlaybackMode),
        ConfigItemTranslatableProperty((trans) => trans.repeatPlaybackMode),
      ]),
    ],
    defaultValue: ReleaseMode.stop,
  );

  static final ConfigCollection screenThemeMode = ConfigCollection(
    [
      ConfigItem<ThemeMode>(ThemeMode.system, properties: [
        ConfigItemIconProperty(AppIcon.screenSystemThemeMode),
        ConfigItemTranslatableProperty((trans) => trans.screenSystemThemeMode),
      ]),
      ConfigItem<ThemeMode>(ThemeMode.light, properties: [
        ConfigItemIconProperty(AppIcon.screenLightThemeMode),
        ConfigItemTranslatableProperty((trans) => trans.screenLightThemeMode),
      ]),
      ConfigItem<ThemeMode>(ThemeMode.dark, properties: [
        ConfigItemIconProperty(AppIcon.screenDarkThemeMode),
        ConfigItemTranslatableProperty((trans) => trans.screenDarkThemeMode),
      ]),
    ],
    // format: (dynamic value) => trackPlaybackBalance.text(value),
    defaultValue: ThemeMode.system,
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
    format: (dynamic value) => '{value}%'.replaceAll('{value}', (value * 100).toStringAsFixed(0)),
    sliderValues: ConfigSliderValues(min: 0, max: 1, divisions: 100),
  );

  static final SliderConfigCollection trackPlaybackBalance = SliderConfigCollection(
    [
      ConfigItem<double>(-1.0, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceLeft),
        ConfigItemTextProperty('L'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft100),
      ]),
      ConfigItem<double>(-0.75, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceLeft),
        ConfigItemTextProperty('L³'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft75),
      ]),
      ConfigItem<double>(-0.5, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceLeft),
        ConfigItemTextProperty('L²'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft50),
      ]),
      ConfigItem<double>(-0.25, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceLeft),
        ConfigItemTextProperty('L¹'),
        ConfigItemTranslatableProperty((trans) => trans.balanceLeft25),
      ]),
      ConfigItem<double>(0.0, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceCenter),
        ConfigItemTextProperty('C'),
        ConfigItemTranslatableProperty((trans) => trans.balanceCenter),
      ]),
      ConfigItem<double>(0.25, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceRight),
        ConfigItemTextProperty('R¹'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight25),
      ]),
      ConfigItem<double>(0.5, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceRight),
        ConfigItemTextProperty('R²'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight50),
      ]),
      ConfigItem<double>(0.75, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceRight),
        ConfigItemTextProperty('R³'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight75),
      ]),
      ConfigItem<double>(1.0, properties: [
        ConfigItemIconProperty(AppIcon.trackPlaybackBalanceRight),
        ConfigItemTextProperty('R'),
        ConfigItemTranslatableProperty((trans) => trans.balanceRight100),
      ]),
    ],
    defaultValue: 0.0,
    format: (dynamic value) => trackPlaybackBalance.text(value),
    sliderValues: ConfigSliderValues(min: -1, max: 1, divisions: 8),
  );

  static final ConfigCollection recordingAudioEncoder = ConfigCollection(
    [
      ConfigItem<AudioEncoder>(AudioEncoder.aacHe, properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacLcName),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacLcInfo, domain: ConfigItemPropertyDomain.info),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacLcDetails, domain: ConfigItemPropertyDomain.details),
        ConfigItemTextProperty('📡', domain: ConfigItemPropertyDomain.icon),
        ConfigItemTextProperty('m4a', domain: ConfigItemPropertyDomain.extension),
        ConfigItemTextProperty('AAC HE', domain: ConfigItemPropertyDomain.shortName),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.aacEld, properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacEldName),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacEldInfo, domain: ConfigItemPropertyDomain.info),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacEldDetails, domain: ConfigItemPropertyDomain.details),
        ConfigItemTextProperty('📞', domain: ConfigItemPropertyDomain.icon),
        ConfigItemTextProperty('m4a', domain: ConfigItemPropertyDomain.extension),
        ConfigItemTextProperty('AAC ELD', domain: ConfigItemPropertyDomain.shortName),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.aacLc, properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacHeName),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacHeInfo, domain: ConfigItemPropertyDomain.info),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderAacHeDetails, domain: ConfigItemPropertyDomain.details),
        ConfigItemTextProperty('🎵', domain: ConfigItemPropertyDomain.icon),
        ConfigItemTextProperty('m4a', domain: ConfigItemPropertyDomain.extension),
        ConfigItemTextProperty('AAC LC', domain: ConfigItemPropertyDomain.shortName),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.wav, properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderWavName),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderWavInfo, domain: ConfigItemPropertyDomain.info),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderWavDetails, domain: ConfigItemPropertyDomain.details),
        ConfigItemTextProperty('🎤', domain: ConfigItemPropertyDomain.icon),
        ConfigItemTextProperty('wav', domain: ConfigItemPropertyDomain.extension),
        ConfigItemTextProperty('WAV', domain: ConfigItemPropertyDomain.shortName),
      ]),
      ConfigItem<AudioEncoder>(AudioEncoder.flac, properties: [
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderFlacName),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderFlacInfo, domain: ConfigItemPropertyDomain.info),
        ConfigItemTranslatableProperty((trans) => trans.audioRecorderFlacDetails, domain: ConfigItemPropertyDomain.details),
        ConfigItemTextProperty('🎧', domain: ConfigItemPropertyDomain.icon),
        ConfigItemTextProperty('flac', domain: ConfigItemPropertyDomain.extension),
        ConfigItemTextProperty('FLAC', domain: ConfigItemPropertyDomain.shortName),
      ]),
      // ConfigItem<AudioEncoder>(AudioEncoder.amrNb, properties: [
      //   ConfigItemTextProperty('3gp', name: ConfigItemPropertyName.extension),
      // ]),
      // ConfigItem<AudioEncoder>(AudioEncoder.amrWb, properties: [
      //   ConfigItemTextProperty('3gp', name: ConfigItemPropertyName.extension),
      // ]),
      // ConfigItem<AudioEncoder>(AudioEncoder.opus, properties: [
      //   ConfigItemTextProperty('opus', name: ConfigItemPropertyName.extension),
      // ]),
      // ConfigItem<AudioEncoder>(AudioEncoder.pcm16bits, properties: [
      //   ConfigItemTextProperty('pcm', name: ConfigItemPropertyName.extension),
      // ]),
    ],
    defaultValue: AudioEncoder.wav,
    format: (dynamic value) => recordingAudioEncoder.text(value, domain: ConfigItemPropertyDomain.shortName),
    decode: (dynamic value) => value,
  );

  static final ConfigCollection recordingAudioMode = ConfigCollection(
    [],
    decode: (value) => (value == true) ? 2 : 1,
  );

  static final ConfigCollection recordingSampleRate = ConfigCollection(
    [
      ConfigItem<int>(44100, properties: []),
      ConfigItem<int>(48000, properties: []),
      ConfigItem<int>(96000, properties: []),
    ],
    defaultValue: 48000,
    format: (dynamic value) => '{value} kHz'.replaceAll('{value}', (value / 1000).toStringAsFixed(0)),
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
    format: (dynamic value) => languages.text(value),
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
      ConfigItem<Color>(Colors.indigo, properties: [
        ConfigItemTranslatableProperty((trans) => trans.indigo),
      ]),
      ConfigItem<Color>(Colors.brown, properties: [
        ConfigItemTranslatableProperty((trans) => trans.brown),
      ]),
      ConfigItem<Color>(Colors.teal, properties: [
        ConfigItemTranslatableProperty((trans) => trans.teal),
      ]),
      ConfigItem<Color>(Colors.black, properties: [
        ConfigItemTranslatableProperty((trans) => trans.black),
      ]),
    ],
    defaultValue: Colors.purple,
  );

  static final ConfigCollection trackState = ConfigCollection(
    [
      ConfigItem<TrackState>(TrackState.processing, properties: [
        ConfigItemIconProperty(Icons.hourglass_empty),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainerHighest, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateProcessing),
      ]),
      ConfigItem<TrackState>(TrackState.empty, properties: [
        ConfigItemIconProperty(Icons.cancel_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainerHighest, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateEmpty),
      ]),
      ConfigItem<TrackState>(TrackState.recording, properties: [
        ConfigItemIconProperty(Icons.radio_button_checked_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.error, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.errorContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainerHigh, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateRecording),
      ]),
      ConfigItem<TrackState>(TrackState.idle, properties: [
        ConfigItemIconProperty(Icons.task_alt_outlined),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.secondary, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.secondaryContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainerHighest, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.stateIdle),
      ]),
      ConfigItem<TrackState>(TrackState.playing, properties: [
        ConfigItemIconProperty(Icons.play_circle_outline),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.primary, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.primaryContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.inversePrimary, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.statePlaying),
      ]),
      ConfigItem<TrackState>(TrackState.paused, properties: [
        ConfigItemIconProperty(Icons.pause_circle_outline),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.tertiary, domain: ConfigItemPropertyDomain.foregroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.tertiaryContainer, domain: ConfigItemPropertyDomain.backgroundColor),
        ConfigItemColorProperty((context) => Theme.of(context).colorScheme.surfaceContainer, domain: ConfigItemPropertyDomain.progressColor),
        ConfigItemTranslatableProperty((trans) => trans.statePaused),
      ]),
    ],
    defaultValue: TrackState.empty,
  );
}
