import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/config.dart';
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
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    _audioRecorder.dispose();
    WidgetsBinding.instance.removeObserver(this);
    widget.globalSettingsBox.close();
    widget.trackSettingsBox.close();
    super.dispose();
  }

  dynamic _settingsGet(key, {space = ConfigSpace.global, dynamic defaultValue}) => switch (key) {
        GlobalConfigKey.isThemeModeDark => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.dark,
        GlobalConfigKey.isThemeModeLight => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.light,
        GlobalConfigKey.isThemeModeSystem => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.system,
        GlobalConfigKey.recording => _recordConfig(),
        _ => switch (space) {
            ConfigSpace.global => widget.globalSettingsBox
                .get(AppGlobalConfig.settingField(key).boxFieldName, defaultValue: AppGlobalConfig.settingField(key).defaultValue),
            ConfigSpace.track => widget.trackSettingsBox.get(key, defaultValue: defaultValue),
            Object() => throw UnimplementedError(),
            null => throw UnimplementedError(),
          },
      };

  void _settingsSet(key, value, {space = ConfigSpace.global, bool updateState = false}) {
    if (updateState == true) {
      setState(() {
        _settingsSetStateLess(key, value, space: space);
      });
    } else {
      _settingsSetStateLess(key, value, space: space);
    }
  }

  Future<void> _settingsSetStateLess(key, value, {space = ConfigSpace.global}) async {
    switch (space) {
      case ConfigSpace.global:
        await widget.globalSettingsBox.put(AppGlobalConfig.settingField(key).boxFieldName, value);
        switch (key) {
          case GlobalConfigKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
        }
        break;
      case ConfigSpace.track:
        await widget.trackSettingsBox.put(key, value);
        break;
    }
  }

  RecordConfig _recordConfig() {
    InputDevice? inputDevice = _settingsGet(GlobalConfigKey.recordingInputDevice);
    AudioEncoder audioEncoder = AppGlobalConfig.recordingAudioEncoder.valueDecoder(_settingsGet(GlobalConfigKey.recordingAudioEncoder));
    int sampleRate = AppGlobalConfig.recordingSampleRate.valueDecoder(_settingsGet(GlobalConfigKey.recordingSampleRate));
    int bitRate = AppGlobalConfig.recordingBitRate.valueDecoder(_settingsGet(GlobalConfigKey.recordingBitRate));
    int channels = (_settingsGet(GlobalConfigKey.recordingAudioModeStereo) == true) ? 2 : 1;
    bool autoGain = _settingsGet(GlobalConfigKey.recordingAutoGain);
    bool echoCancel = _settingsGet(GlobalConfigKey.recordingEchoCancel);
    bool noiseSuppress = _settingsGet(GlobalConfigKey.recordingNoiseSuppress);
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
        locale: _settingsGet(GlobalConfigKey.locale),
        themeAnimationDuration: Duration(seconds: 0),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settingsGet(GlobalConfigKey.themeSeedColor),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settingsGet(GlobalConfigKey.themeSeedColor),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: _settingsGet(GlobalConfigKey.themeMode),
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
