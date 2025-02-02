import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:record/record.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';
import 'screen.dart';

class HomeScreen extends StatefulWidget implements ScreenInterface {
  const HomeScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
    required this.audioRecorder,
    required this.tracksList,
  });

  @override
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;
  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;
  @override
  final AudioRecorder audioRecorder;
  @override
  final TracksCollection tracksList;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool loading = false;

  late AppLocalizations _trans;
  late UIWrapper _uiWrapper;
  late TrackWrapper _trackWrapper;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Utrzymuje fokus po starcie aplikacji
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _trackWrapper.stopTracksPlaying(widget.tracksList.all());
    }
  }

  @override
  void dispose() {
    _trackWrapper.dispose(widget.tracksList.all());
    _trackWrapper.stopTracksPlaying(widget.tracksList.all());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        _trans = AppLocalizations.of(context)!;
        _uiWrapper = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _uiWrapper);

        Widget body;
        if (loading == true) {
          body = Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(strokeWidth: 8)]));
        } else {
          body = Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (node, KeyEvent event) {
                _trackWrapper.onKeyEvent(event);
                return KeyEventResult.handled;
              },
              child: Column(children: [
                Expanded(child: _buildTracksGrid()),
              ]));
        }

        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              leading: IconButton(
                  icon:
                      Icon(widget.settingsGet(GlobalConfigKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
                  onPressed: () {
                    _uiWrapper.recordConfigDialog(_trans.recordingSettings,
                        recordConfig: widget.settingsGet(GlobalConfigKey.recording), trans: _trans);
                  }),
              title: Text(_trans.appTitle),
              actions: _buildTopMenu(),
            ),
            body: body,
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(child: Text(_trans.legalNote, style: TextStyle(fontSize: _uiWrapper.footerFontSize))),
            ]));
      });

  /// *************************************************************************
  /// TOP MENU
  List<Widget> _buildTopMenu() {
    var items = <Widget>[];
    items.add(IconButton(
      icon: Icon(AppIcon.trackPlayingStart),
      tooltip: _trans.allTracksPlayingStart,
      onPressed: () {
        setState(() {
          _trackWrapper.startTracksPlaying(widget.tracksList.all());
        });
      },
    ));
    items.add(IconButton(
      icon: Icon(AppIcon.trackPlayingStop),
      tooltip: _trans.allTracksPlayingStop,
      onPressed: () {
        setState(() {
          _trackWrapper.stopTracksPlaying(widget.tracksList.all());
        });
      },
    ));
    items.add(PopupMenuButton<String>(
      icon: Icon(AppIcon.moreMenu),
      itemBuilder: (BuildContext context) => _topMenuItems(),
      onSelected: (String selection) {
        _topMenuItemSelected(TopMenuItem.values.byName(selection.replaceAll('TopMenuItem.', '')));
      },
    ));
    return items.toList();
  }

  List<PopupMenuEntry<String>> _topMenuItems() {
    List<PopupMenuEntry<String>> menuItems = [];
    menuItems.add(_uiWrapper.topPopupMenuItem(TopMenuItem.changeLanguage, AppIcon.language, _trans.changeLanguage));
    if (widget.settingsGet(GlobalConfigKey.isThemeModeDark)) {
      menuItems.add(_uiWrapper.topPopupMenuItem(TopMenuItem.themeModeLight, AppIcon.screenLightThemeMode, _trans.menuLightMode));
    } else {
      menuItems.add(_uiWrapper.topPopupMenuItem(TopMenuItem.themeModeDark, AppIcon.screenDarkThemeMode, _trans.menuDarkMode));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      menuItems
          .add(_uiWrapper.topPopupMenuItem(TopMenuItem.keepScreenOnDisable, AppIcon.keepScreenOnEnabled, _trans.menuKeepScreenOn, checked: true));
    } else {
      menuItems
          .add(_uiWrapper.topPopupMenuItem(TopMenuItem.keepScreenOnEnable, AppIcon.keepScreenOnDisabled, _trans.menuKeepScreenOn, checked: false));
    }
    menuItems.add(_uiWrapper.topPopupMenuItem(TopMenuItem.settings, AppIcon.settings, _trans.settings));
    menuItems.add(_uiWrapper.topPopupMenuItem(TopMenuItem.help, AppIcon.help, _trans.help));
    return menuItems;
  }

  void _topMenuItemSelected(TopMenuItem selection) async {
    switch (selection) {
      case TopMenuItem.changeLanguage:
        var options = <Widget>[];
        AppGlobalConfig.languages.values<Locale>().forEach((Locale locale) {
          var name = AppGlobalConfig.languages.name(locale);
          var code = locale.toLanguageTag();
          options.add(SimpleDialogOption(
            padding: EdgeInsets.all(16),
            onPressed: () {
              widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
              Navigator.pop(context, locale);
            },
            child: Text('$name ($code)'),
          ));
        });
        _uiWrapper.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
        break;
      case TopMenuItem.keepScreenOnEnable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, true, updateState: true);
        break;
      case TopMenuItem.keepScreenOnDisable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, false, updateState: true);
        break;
      case TopMenuItem.themeModeLight:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.light, updateState: true);
        break;
      case TopMenuItem.themeModeDark:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.dark, updateState: true);
        break;
      case TopMenuItem.settings:
        setState(() {
          loading = true;
        });
        await Navigator.pushNamed(context, '/settings');
        setState(() {
          widget.tracksList.reset();
          loading = false;
        });
        break;
      case TopMenuItem.help:
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        _uiWrapper.aboutDialog(
          packageInfo,
          [
            _uiWrapper.helpSection(_trans.helpScreenMessageAboutTitle, [
              Text(_trans.helpScreenMessageAboutContent),
            ]),
            _uiWrapper.helpSection(_trans.helpScreenMessageUsageTitle, [
              Text(_trans.helpScreenMessageUsageContent),
            ]),
            _uiWrapper.helpSection(_trans.helpScreenMessageTrackActions, [
              _uiWrapper.helpTrackState(TrackState.empty, _trans.helpScreenMessageTrackActions_state_empty),
              _uiWrapper.helpTrackState(TrackState.recording, _trans.helpScreenMessageTrackActions_state_recording),
              _uiWrapper.helpTrackState(TrackState.stopped, _trans.helpScreenMessageTrackActions_state_stopped),
              _uiWrapper.helpTrackState(TrackState.playing, _trans.helpScreenMessageTrackActions_state_playing),
              _uiWrapper.helpTrackState(TrackState.paused, _trans.helpScreenMessageTrackActions_state_paused),
            ]),
            _uiWrapper.helpSection(_trans.helpScreenRecordingCodecsInfoTitle, [
              Text(_trans.helpScreenRecordingCodecsInfoContent),
            ]),
            _uiWrapper.helpSection(_trans.helpScreenRecordingCodecsChooseTitle, [
              Text(_trans.helpScreenRecordingCodecsChooseContent),
            ]),
          ],
          applicationIcon:
              Icon(widget.settingsGet(GlobalConfigKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
          applicationLegalese: _trans.legalNote,
        );
        break;
    }
  }

  /// *************************************************************************
  /// TRACKS GRID
  dynamic _buildTracksGrid() => ListView.builder(
        itemCount: widget.settingsGet(GlobalConfigKey.gridRowsAmount),
        itemBuilder: (context, rowIndex) => Row(children: [
          _trackWrapper.buildRowButtons(rowIndex, TrackRow.name(rowIndex)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  widget.settingsGet(GlobalConfigKey.gridColsAmount),
                  (columnIndex) {
                    String trackId = Track.buildId(rowIndex, columnIndex);
                    Track track = widget.settingsGet(trackId, space: ConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));
                    widget.tracksList.addAll(track);
                    widget.tracksList.addRow(rowIndex, track);
                    _trackWrapper.initStreams(track);
                    return Container(
                        margin: EdgeInsets.all(_uiWrapper.trackItemMargin),
                        width: _uiWrapper.trackItemWidth,
                        child: ValueListenableBuilder(
                          valueListenable: track.state,
                          builder: (context, state, child) => ElevatedButton(
                            onPressed: () {
                              _trackWrapper.trackPressed(track);
                            },
                            onLongPress: () {
                              _trackWrapper.trackDetails(track);
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(_uiWrapper.trackPadding),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_uiWrapper.trackBorderRadius)),
                                backgroundColor: track.stateBackgroundColor(context),
                                foregroundColor: track.stateForegroundColor(context)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _trackWrapper.trackButton(track),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
          )
        ]),
      );
}
