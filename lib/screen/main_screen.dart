import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/repository/track_repository.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../helper/ui_helper.dart';
import '../manager/drawer_manager.dart';
import '../manager/navigation_bar_manager.dart';
import '../manager/recording_manager.dart';
import '../manager/row_menu_manager.dart';
import '../wrapper/settings_wrapper.dart';
import '../wrapper/track_wrapper.dart';

class MainScreenApp extends StatefulWidget {
  final Box globalSettingsBox;
  final Box trackSettingsBox;

  const MainScreenApp({super.key, required this.globalSettingsBox, required this.trackSettingsBox});

  @override
  State<MainScreenApp> createState() => _MainScreenAppState();
}

class _MainScreenAppState extends State<MainScreenApp> with WidgetsBindingObserver {
  late final AudioRecorder _audioRecorder;
  final FocusNode _focusNode = FocusNode();
  late SettingsWrapper _settings;
  late TrackRepository _trackRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioRecorder = AudioRecorder();
    _focusNode.requestFocus(); // Utrzymuje fokus po starcie aplikacji
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioRecorder.dispose();
    widget.globalSettingsBox.close();
    widget.trackSettingsBox.close();
    _trackRepository.stopTracksPlaying(_trackRepository.allTracks());
    _trackRepository.dispose(_trackRepository.allTracks());
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
    _settings = SettingsWrapper(setState, widget.globalSettingsBox, widget.trackSettingsBox);
    _settings.checkPermissions();
    return _buildApp();
  }

  MaterialApp _buildApp() => MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppGlobalConfig.languages.values<Locale>(),
        locale: _settings.get(AppConfigFieldKey.locale),
        themeAnimationDuration: Duration(seconds: 0),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settings.get(AppConfigFieldKey.themeSeedColor),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _settings.get(AppConfigFieldKey.themeSeedColor),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: _settings.get(AppConfigFieldKey.themeMode),
        home: _buildContent(),
        // initialRoute: '/',
        // routes: {
        //   '/': (context) =>
        //       HomeScreen(
        //         settingsGet: _settings.get,
        //         settingsSet: _settingsSet,
        //         audioRecorder: _audioRecorder,
        // },
      );

  Builder _buildContent() => Builder(builder: (context) {
        AppLocalizations trans = AppLocalizations.of(context)!;
        UIHelper uiWrapper = UIHelper(context);
        _trackRepository = TrackRepository(_settings);
        RecordingManager recordingManager = RecordingManager(_settings, trans, uiWrapper, _trackRepository, _audioRecorder);
        TrackWrapper trackWrapper = TrackWrapper(context, _settings, trans, uiWrapper, _trackRepository, recordingManager);
        NavigationBarManager navigationBarManager = NavigationBarManager(context, _settings, trans, uiWrapper, _trackRepository);
        RowMenuManager rowMenuManager = RowMenuManager(context, trans, uiWrapper, _trackRepository);
        DrawerManager drawerManager = DrawerManager(context, _settings, trans, uiWrapper, _trackRepository, _audioRecorder);

        return Scaffold(
          appBar: navigationBarManager.buildAppBar,
          drawer: drawerManager.build,
          body: Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (node, KeyEvent event) {
                trackWrapper.onKeyEvent(event);
                return KeyEventResult.handled;
              },
              child: ListView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: _settings.get(AppConfigFieldKey.gridRowsAmount),
                  itemBuilder: (context, rowIndex) => Row(children: [
                        rowMenuManager.buildRowButtons(rowIndex),
                        trackWrapper.buildRowTracks(rowIndex),
                      ]))),
          bottomNavigationBar: navigationBarManager.buildFooter,
        );
      });
}
