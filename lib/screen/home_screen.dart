import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../src/config.dart';
import '../src/io.dart';
import '../src/track.dart';
import '../src/track_row_wrapper.dart';
import '../src/track_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settingsGet,
    required this.settingsPut,
  });

  final Function(dynamic key) settingsGet;
  final void Function(dynamic key, dynamic value) settingsPut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLocalizations _trans;
  late IO _io;

  @override
  Widget build(BuildContext context) {
    _trans = AppLocalizations.of(context)!;
    _io = IO(context);

    return Builder(
        builder: (context) => Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(_trans.homeTitle),
                leading: Icon(Icons.dashboard_customize),
                actions: buildTopMenu()),
            body: Column(children: [Expanded(child: buildGrid())]),
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: buildFooter())));
  }

  List<Widget> buildTopMenu() {
    var items = <Widget>[];
    items.add(IconButton(
        onPressed: () => {
              // TODO
            },
        icon: Icon(Icons.play_arrow_rounded),
        tooltip: _trans.start_playing_all_tracks));
    items.add(IconButton(
        onPressed: () => {
              // TODO
            },
        icon: Icon(Icons.stop_rounded),
        tooltip: _trans.stop_playing_all_tracks));
    items.add(
        PopupMenuButton<String>(onSelected: menuItemSelected, itemBuilder: (BuildContext context) => buildMenuItems(), icon: Icon(Icons.more_vert)));
    return items.toList();
  }

  void menuItemSelected(String selection) async {
    switch (selection) {
      case 'translate':
        var options = <Widget>[];
        Config.languages.forEach((String name, Locale locale) {
          var code = locale.toLanguageTag();
          options.add(SimpleDialogOption(
            onPressed: () {
              widget.settingsPut(GlobalConfigKey.locale, locale);
              Navigator.of(context).pop(locale);
            },
            child: Text('$name ($code)'),
          ));
        });
        _io.listDialog(Icons.language_rounded, _trans.title_changeLanguage, actions: options.toList());
        break;
      case 'keep_screen_on_enable':
        widget.settingsPut(GlobalConfigKey.wakelockEnabled, true);
        break;
      case 'keep_screen_on_disable':
        widget.settingsPut(GlobalConfigKey.wakelockEnabled, false);
        break;
      case 'theme_mode_light':
        widget.settingsPut(GlobalConfigKey.themeMode, ThemeMode.light);
        break;
      case 'theme_mode_dark':
        widget.settingsPut(GlobalConfigKey.themeMode, ThemeMode.dark);
        break;
      case 'help':
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        _io.aboutDialog(
            packageInfo,
            [
              _io.helpSection(_trans.help_screen_message_about_title, [
                Text(_trans.help_screen_message_about_content),
              ]),
              _io.helpSection(_trans.help_screen_message_usage_title, [
                Text(_trans.help_screen_message_usage_content_1),
                _io.helpTrackState(TrackState.empty, _trans.help_screen_message_usage_content_1_state_empty),
                _io.helpTrackState(TrackState.recording, _trans.help_screen_message_usage_content_1_state_recording),
                _io.helpTrackState(TrackState.stopped, _trans.help_screen_message_usage_content_1_state_stopped),
                _io.helpTrackState(TrackState.playing, _trans.help_screen_message_usage_content_1_state_playing),
                _io.helpTrackState(TrackState.paused, _trans.help_screen_message_usage_content_1_state_paused),
                SizedBox(height: 6),
                Text(_trans.help_screen_message_usage_content_2),
                SizedBox(height: 6),
                Text(_trans.help_screen_message_usage_content_3),
              ]),
            ],
            applicationLegalese: _trans.footer_copy);
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      default:
    }
  }

  /// *************************************************************************
  /// MENU ACTIONS
  buildMenuActions() => [
        IconButton(onPressed: () => {}, icon: Icon(Icons.play_arrow_rounded)),
        IconButton(onPressed: () => {}, icon: Icon(Icons.stop_rounded)),
        PopupMenuButton<String>(onSelected: menuItemSelected, itemBuilder: (BuildContext context) => buildMenuItems(), icon: Icon(Icons.more_vert)),
      ];

  /// *************************************************************************
  /// MENU ITEMS
  List<PopupMenuEntry<String>> buildMenuItems() {
    List<PopupMenuEntry<String>> menuItems = [];
    menuItems.add(_io.menuItem('translate', _trans.menu_translation, Icons.language_rounded));
    if (widget.settingsGet(GlobalConfigKey.isThemeModeDark)) {
      menuItems.add(_io.menuItem('theme_mode_light', _trans.menu_light_mode, Icons.light_mode_rounded));
    } else {
      menuItems.add(_io.menuItem('theme_mode_dark', _trans.menu_dark_mode, Icons.dark_mode_rounded));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      menuItems.add(_io.menuItem('keep_screen_on_disable', _trans.menu_keep_screen_on, Icons.lightbulb_outline_rounded, checked: true));
    } else {
      menuItems.add(_io.menuItem('keep_screen_on_enable', _trans.menu_keep_screen_on, Icons.lightbulb_rounded, checked: false));
    }
    menuItems.add(_io.menuItem('settings', _trans.menu_settings, Icons.settings_rounded));
    menuItems.add(_io.menuItem('help', _trans.menu_help, Icons.help_rounded));
    return menuItems;
  }

  /// *************************************************************************
  /// GRID
  buildGrid() {
    int rowsAmount = widget.settingsGet(GlobalConfigKey.gridRowsAmount);
    int columnsAmount = widget.settingsGet(GlobalConfigKey.gridColsAmount);
    TrackWrapper trackWrapper = TrackWrapper(context, _trans, _io);
    TrackRowWrapper rowOptions = TrackRowWrapper(context, _trans, _io);

    return ListView.builder(
        itemCount: rowsAmount,
        itemBuilder: (context, rowIndex) {
          return Row(children: [
            rowOptions.build(rowIndex),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(columnsAmount, (columnIndex) {
                      Track track = Track(context, rowIndex, columnIndex);
                      return trackWrapper.build(track);
                    }))))
          ]);
        });
  }

  /// *************************************************************************
  /// INFOS
  List<Widget> buildFooter() {
    var items = <Widget>[];
    if (widget.settingsGet(GlobalConfigKey.recordingProbingModeHigh)) {
      items.add(_io.footerInfo(Icons.hotel_class, _trans.recording_probing_mode_high_info));
    } else {
      items.add(_io.footerInfo(Icons.star, _trans.recording_probing_mode_low_info));
    }
    if (widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo)) {
      items.add(_io.footerInfo(Symbols.mic_double_rounded, _trans.recording_audio_mode_stereo_info));
    } else {
      items.add(_io.footerInfo(Icons.mic_rounded, _trans.recording_audio_mode_mono_info));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      items.add(_io.footerInfo(Icons.lightbulb_rounded, _trans.keep_screen_on_enabled));
    } else {
      items.add(_io.footerInfo(Symbols.light_off_rounded, _trans.keep_screen_on_disabled));
    }
    return items.toList();
  }
}
