import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/repository/track_repository.dart';
import 'package:tune_tangler/src/audio_isolate_service.dart';
import 'package:tune_tangler/screen/home_screen.dart';
import 'package:tune_tangler/wrapper/app.dart';
import 'package:tune_tangler/wrapper/hive_service.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../provider/permission_provider.dart';
import '../src/generated/app_localizations.dart';


class MainScreenApp extends StatefulWidget {
  const MainScreenApp({super.key});

  @override
  State<MainScreenApp> createState() => _MainScreenAppState();
}

class _MainScreenAppState extends State<MainScreenApp> with WidgetsBindingObserver {
  late final AudioRecorder _audioRecorder;
  final FocusNode _focusNode = FocusNode();
  late HiveSettingsProvider _settings;
  late TrackRepository _trackRepository;
  final PermissionProvider _permissionProvider = PermissionProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioRecorder = AudioRecorder();
    _focusNode.requestFocus();
    _permissionProvider.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioRecorder.dispose();
    HiveService.dispose();
    _trackRepository.stopTracksPlaying(_trackRepository.allTracks());
    _trackRepository.dispose(_trackRepository.allTracks());
    AudioIsolateService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _trackRepository.stopTracksPlaying(_trackRepository.allTracks());
    }
  }

  @override
  Widget build(BuildContext context) {
    _settings = Provider.of<HiveSettingsProvider>(context);
    _trackRepository = TrackRepository(_settings);
    WakelockPlus.toggle(enable: _settings.getConfig(AppConfigFieldKey.wakelockEnabled));

    AppWrapper appWrapper = AppWrapper(
      settings: _settings,
      permissionProvider: _permissionProvider,
      audioRecorder: _audioRecorder,
      trackRepository: _trackRepository,
      focusNode: _focusNode,
    );

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppGlobalConfig.languages.values<Locale>(),
      localeResolutionCallback: (locale, supportedLocales) => _settings.getConfig(AppConfigFieldKey.locale, defaultValue: locale),
      locale: _settings.getConfig(AppConfigFieldKey.locale),
      themeAnimationDuration: Duration(seconds: 0),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settings.getConfig(AppConfigFieldKey.themeSeedColor),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settings.getConfig(AppConfigFieldKey.themeSeedColor),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _settings.getConfig(AppConfigFieldKey.themeMode),
      home: HomeScreen(appWrapper: appWrapper),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) =>
      //       HomeScreen(
      //         settingsGet: _settings.get,
      //         settingsSet: _settingsSet,
      //         audioRecorder: _audioRecorder,
      // },
    );
  }
}
