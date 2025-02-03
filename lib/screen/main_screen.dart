import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/config.dart';
import '../config/fields.dart';
import '../entity/track_row.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

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
  late final TracksCollection _tracksList = TracksCollection();

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

  dynamic _settingsGet(key, {space = AppConfigSpace.global, dynamic defaultValue}) => switch (key) {
        AppGlobalConfigFieldKey.isThemeModeDark => _settingsGet(AppGlobalConfigFieldKey.themeMode) == ThemeMode.dark,
        AppGlobalConfigFieldKey.isThemeModeLight => _settingsGet(AppGlobalConfigFieldKey.themeMode) == ThemeMode.light,
        AppGlobalConfigFieldKey.isThemeModeSystem => _settingsGet(AppGlobalConfigFieldKey.themeMode) == ThemeMode.system,
        AppGlobalConfigFieldKey.recording => _recordConfig(),
        _ => switch (space) {
          AppConfigSpace.global => widget.globalSettingsBox
                .get(AppGlobalConfigFieldsCollection.field(key).boxFieldName, defaultValue: AppGlobalConfigFieldsCollection.field(key).defaultValue),
          AppConfigSpace.track => widget.trackSettingsBox.get(key, defaultValue: defaultValue),
            Object() => throw UnimplementedError(),
            null => throw UnimplementedError(),
          },
      };

  void _settingsSet(key, value, {space = AppConfigSpace.global, bool updateState = false}) {
    if (updateState == true) {
      setState(() {
        _settingsSetStateLess(key, value, space: space);
      });
    } else {
      _settingsSetStateLess(key, value, space: space);
    }
  }

  Future<void> _settingsSetStateLess(key, value, {space = AppConfigSpace.global}) async {
    switch (space) {
      case AppConfigSpace.global:
        await widget.globalSettingsBox.put(AppGlobalConfigFieldsCollection.field(key).boxFieldName, value);
        switch (key) {
          case AppGlobalConfigFieldKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
        }
        break;
      case AppConfigSpace.track:
        await widget.trackSettingsBox.put(key, value);
        break;
    }
  }

  RecordConfig _recordConfig() {
    InputDevice? inputDevice = _settingsGet(AppGlobalConfigFieldKey.recordingInputDevice);
    AudioEncoder audioEncoder = AppGlobalConfig.recordingAudioEncoder.decode(_settingsGet(AppGlobalConfigFieldKey.recordingAudioEncoder));
    int sampleRate = AppGlobalConfig.recordingSampleRate.decode(_settingsGet(AppGlobalConfigFieldKey.recordingSampleRate));
    int bitRate = AppGlobalConfig.recordingBitRate.decode(_settingsGet(AppGlobalConfigFieldKey.recordingBitRate));
    int channels = (_settingsGet(AppGlobalConfigFieldKey.recordingAudioModeStereo) == true) ? 2 : 1;
    bool autoGain = _settingsGet(AppGlobalConfigFieldKey.recordingAutoGain);
    bool echoCancel = _settingsGet(AppGlobalConfigFieldKey.recordingEchoCancel);
    bool noiseSuppress = _settingsGet(AppGlobalConfigFieldKey.recordingNoiseSuppress);
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
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppGlobalConfig.languages.values<Locale>(),
        locale: _settingsGet(AppGlobalConfigFieldKey.locale),
        themeAnimationDuration: Duration(seconds: 0),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settingsGet(AppGlobalConfigFieldKey.themeSeedColor),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settingsGet(AppGlobalConfigFieldKey.themeSeedColor),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: _settingsGet(AppGlobalConfigFieldKey.themeMode),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(
                settingsGet: _settingsGet,
                settingsSet: _settingsSet,
                audioRecorder: _audioRecorder,
                tracksList: _tracksList,
              ),
          '/settings': (context) => SettingsScreen(
                settingsGet: _settingsGet,
                settingsSet: _settingsSet,
                audioRecorder: _audioRecorder,
                tracksList: _tracksList,
              ),
        },
      );
}
