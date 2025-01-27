import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'adapter/locale_adapter.dart';
import 'adapter/theme_mode_adapter.dart';
import 'adapter/track_adapter.dart';
import 'screen/home_screen.dart';
import 'screen/settings_screen.dart';
import 'config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //************************************
  // Set loading screen
  runApp(const SplashScreenApp());

  //************************************
  // Initialize
  await Hive.initFlutter();
  Hive.registerAdapter(LocaleAdapter());
  Hive.registerAdapter(ThemeModeAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(ColorAdapter());
  Box globalSettingsBox = await Hive.openBox('settings');
  Box trackSettingsBox = await Hive.openBox('tracks');

  //************************************
  // Set main screen
  runApp(MainScreenApp(globalSettingsBox: globalSettingsBox, trackSettingsBox: trackSettingsBox));
}

class SplashScreenApp extends StatelessWidget {
  const SplashScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_customize_rounded, size: 48),
                Text('Tune Tangler', style: TextStyle(fontSize: 48)),
              ],
            ),
            CircularProgressIndicator(strokeWidth: 8),
          ]),
        ),
      ),
    );
  }
}

class MainScreenApp extends StatefulWidget {
  final Box globalSettingsBox;
  final Box trackSettingsBox;

  const MainScreenApp({super.key, required this.globalSettingsBox, required this.trackSettingsBox});

  @override
  State<MainScreenApp> createState() => _MainScreenAppState();
}

class _MainScreenAppState extends State<MainScreenApp> {
  _MainScreenAppState();

  _settingsGet(key, {space = ConfigSpace.global, dynamic defaultValue}) => switch (key) {
        GlobalConfigKey.isThemeModeDark => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.dark,
        GlobalConfigKey.isThemeModeLight => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.light,
        GlobalConfigKey.isThemeModeSystem => _settingsGet(GlobalConfigKey.themeMode) == ThemeMode.system,
        _ => switch (space) {
            ConfigSpace.global =>
              widget.globalSettingsBox.get(Config.settingField(key).boxFieldName, defaultValue: Config.settingField(key).defaultValue),
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

  void _settingsSetStateLess(key, value, {space = ConfigSpace.global}) {
    switch (space) {
      case ConfigSpace.global:
        widget.globalSettingsBox.put(Config.settingField(key).boxFieldName, value);
        switch (key) {
          case GlobalConfigKey.wakelockEnabled:
            WakelockPlus.toggle(enable: value);
            break;
        }
        break;
      case ConfigSpace.track:
        widget.trackSettingsBox.put(key, value);
        break;
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
      supportedLocales: Config.languages.values,
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
        '/': (context) => HomeScreen(settingsGet: _settingsGet, settingsSet: _settingsSet),
        '/settings': (context) => SettingsScreen(settingsGet: _settingsGet, settingsSet: _settingsSet),
      });
}
