import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/config.dart';
import '../config/fields.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import 'home_screen.dart';

class MainScreenApp extends StatefulWidget {
  final Box globalSettingsBox;
  final Box trackSettingsBox;

  const MainScreenApp({super.key, required this.globalSettingsBox, required this.trackSettingsBox});

  @override
  State<MainScreenApp> createState() => _MainScreenAppState();
}

class _MainScreenAppState extends State<MainScreenApp> with WidgetsBindingObserver {
  _MainScreenAppState();

  late final AudioRecorder _audioRecorder;
  late final TracksCollection _tracksList = TracksCollection(_settingsGet);

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    WidgetsBinding.instance.removeObserver(this);
    widget.globalSettingsBox.close();
    widget.trackSettingsBox.close();
    super.dispose();
  }

  dynamic _settingsGet(dynamic key, {AppConfigSpace space = AppConfigSpace.global, dynamic defaultValue}) => switch (key) {
        AppConfigFieldKey.isThemeModeDark => _settingsGet(AppConfigFieldKey.themeMode) == ThemeMode.dark,
        AppConfigFieldKey.isThemeModeLight => _settingsGet(AppConfigFieldKey.themeMode) == ThemeMode.light,
        AppConfigFieldKey.isThemeModeSystem => _settingsGet(AppConfigFieldKey.themeMode) == ThemeMode.system,
        AppConfigFieldKey.recording => _recordConfig(),
        _ => switch (space) {
            AppConfigSpace.global => widget.globalSettingsBox
                .get(AppGlobalConfigFieldsCollection.field(key).boxFieldName, defaultValue: AppGlobalConfigFieldsCollection.field(key).defaultValue),
            AppConfigSpace.track => _loadTrack(key, defaultValue),
          },
      };

  Track _loadTrack(dynamic key, dynamic defaultValue) {
    Track track = widget.trackSettingsBox.get(key, defaultValue: defaultValue);
    if (!track.streamsInitialized) {
      track.setStreamsInitialized();
      _settingsSet(key, track, space: AppConfigSpace.track);
    }
    return track;
  }

  void _settingsSet(dynamic key, dynamic value, {AppConfigSpace space = AppConfigSpace.global, bool updateState = false}) {
    if (updateState == true) {
      setState(() {
        _settingsSetStateLess(key, value, space: space);
      });
    } else {
      _settingsSetStateLess(key, value, space: space);
    }
  }

  void _settingsSetStateLess(dynamic key, dynamic value, {AppConfigSpace space = AppConfigSpace.global}) {
    switch (space) {
      case AppConfigSpace.global:
        widget.globalSettingsBox.put(AppGlobalConfigFieldsCollection.field(key).boxFieldName, value);
        switch (key) {
          case AppConfigFieldKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
        }
        break;
      case AppConfigSpace.track:
        widget.trackSettingsBox.put(key, value);
        break;
    }
  }

  RecordConfig _recordConfig() {
    InputDevice? inputDevice = _settingsGet(AppConfigFieldKey.recordingInputDevice);
    AudioEncoder audioEncoder = _settingsGet(AppConfigFieldKey.recordingAudioEncoder);
    int sampleRate = _settingsGet(AppConfigFieldKey.recordingSampleRate);
    int bitRate = _settingsGet(AppConfigFieldKey.recordingBitRate);
    int channels = AppGlobalConfig.recordingAudioMode.decode(_settingsGet(AppConfigFieldKey.recordingAudioModeStereo));
    bool autoGain = _settingsGet(AppConfigFieldKey.recordingAutoGain);
    bool echoCancel = _settingsGet(AppConfigFieldKey.recordingEchoCancel);
    bool noiseSuppress = _settingsGet(AppConfigFieldKey.recordingNoiseSuppress);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppGlobalConfig.languages.values<Locale>(),
      locale: _settingsGet(AppConfigFieldKey.locale),
      themeAnimationDuration: Duration(seconds: 0),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settingsGet(AppConfigFieldKey.themeSeedColor),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settingsGet(AppConfigFieldKey.themeSeedColor),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _settingsGet(AppConfigFieldKey.themeMode),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(
              settingsGet: _settingsGet,
              settingsSet: _settingsSet,
              audioRecorder: _audioRecorder,
              tracksList: _tracksList,
            ),
      },
    );
  }
}
