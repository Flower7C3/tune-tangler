import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/src/settings_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
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
  final Function(dynamic key, {AppConfigSpace space, dynamic defaultValue}) settingsGet;
  @override
  final void Function(dynamic key, dynamic value, {AppConfigSpace space, bool updateState}) settingsSet;
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
  late SettingsWrapper _settingsWrapper;

  final FocusNode _focusNode = FocusNode();

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  void _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions.values<Permission>()) {
      statuses[permission] = await permission.status;
    }
    _permissionStatuses = statuses;
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
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
        _settingsWrapper = SettingsWrapper(_trans, _uiWrapper, _trackWrapper, context, widget, _permissionStatuses);

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

        Map<String, TextStyle?> sizes = {
          'displayLarge': Theme.of(context).textTheme.displayLarge,
          'displayMedium': Theme.of(context).textTheme.displayMedium,
          'displaySmall': Theme.of(context).textTheme.displaySmall,
          'headlineLarge': Theme.of(context).textTheme.headlineLarge,
          'headlineMedium': Theme.of(context).textTheme.headlineMedium,
          'headlineSmall': Theme.of(context).textTheme.headlineSmall,
          'titleLarge': Theme.of(context).textTheme.titleLarge,
          'titleMedium': Theme.of(context).textTheme.titleMedium,
          'titleSmall': Theme.of(context).textTheme.titleSmall,
          'bodyLarge': Theme.of(context).textTheme.bodyLarge,
          'bodyMedium': Theme.of(context).textTheme.bodyMedium,
          'bodySmall': Theme.of(context).textTheme.bodySmall,
          'labelLarge': Theme.of(context).textTheme.labelLarge,
          'labelMedium': Theme.of(context).textTheme.labelMedium,
          'labelSmall': Theme.of(context).textTheme.labelSmall,
        };
        List<Widget> rows = [];
        sizes.forEach((String name, TextStyle? style) {
          rows.add(Text(
            name,
            style: style,
          ));
        });

        // body = Column(children: rows.toList());

        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                      widget.settingsGet(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              // leading: IconButton(
              //     icon: Icon(widget.settingsGet(AppGlobalConfigFieldKey.wakelockEnabled)
              //         ? AppIcon.logoKeepScreenOnEnabled
              //         : AppIcon.logoKeepScreenOnDisabled),
              //     onPressed: () {
              //       Scaffold.of(context).openDrawer();
              //       // _uiWrapper.recordConfigDialog(_trans.recordingSettings,
              //       //     recordConfig: widget.settingsGet(AppGlobalConfigFieldKey.recording), trans: _trans);
              //     }),
              title: Text(_trans.appTitle),
              actions: _buildTopMenu(),
            ),
            drawer: _settingsWrapper.drawer,
            body: body,
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(child: Text(_trans.legalNote, style: Theme.of(context).textTheme.labelSmall)),
            ]));
      });

  /// *************************************************************************
  /// TOP MENU
  List<Widget> _buildTopMenu() => [
        IconButton(
          icon: Icon(AppIcon.trackPlayingStart),
          tooltip: _trans.allTracksPlayingStart,
          onPressed: () {
            _trackWrapper.startTracksPlaying(widget.tracksList.all());
          },
        ),
        IconButton(
          icon: Icon(AppIcon.trackPlayingStop),
          tooltip: _trans.allTracksPlayingStop,
          onPressed: () {
            _trackWrapper.stopTracksPlaying(widget.tracksList.all());
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _settingsWrapper.trackSettingsMenu,
          onSelected: (String selection) {
            _settingsWrapper.trackSettingsMenuItemSelected(AllTracksMenuItem.values.byName(selection.replaceAll('AllTracksMenuItem.', '')));
            // _topMenuItemSelected(TopMenuItem.values.byName(selection.replaceAll('TopMenuItem.', '')));
          },
        ),
      ];

  List<PopupMenuEntry<String>> _topMenuItems() => [
        // _uiWrapper.topPopupMenuItem(TopMenuItem.changeLanguage, AppIcon.language, _trans.changeLanguage),
        // if (widget.settingsGet(AppGlobalConfigFieldKey.isThemeModeDark))
        //   _uiWrapper.topPopupMenuItem(TopMenuItem.themeModeLight, AppIcon.screenLightThemeMode, _trans.menuLightMode)
        // else
        //   _uiWrapper.topPopupMenuItem(TopMenuItem.themeModeDark, AppIcon.screenDarkThemeMode, _trans.menuDarkMode),
        // if (widget.settingsGet(AppGlobalConfigFieldKey.wakelockEnabled))
        //   _uiWrapper.topPopupMenuItem(TopMenuItem.keepScreenOnDisable, AppIcon.keepScreenOnEnabled, _trans.menuKeepScreenOn, checked: true)
        // else
        //   _uiWrapper.topPopupMenuItem(TopMenuItem.keepScreenOnEnable, AppIcon.keepScreenOnDisabled, _trans.menuKeepScreenOn, checked: false),
        // _uiWrapper.topPopupMenuItem(TopMenuItem.settings, AppIcon.settings, _trans.settings),
        // _uiWrapper.topPopupMenuItem(TopMenuItem.help, AppIcon.help, _trans.help),
      ];

  void _topMenuItemSelected(TopMenuItem selection) async {
    switch (selection) {
      case TopMenuItem.changeLanguage:
        var options = <Widget>[];
        AppGlobalConfig.languages.values<Locale>().forEach((Locale locale) {
          var name = AppGlobalConfig.languages.text(locale);
          var code = locale.toLanguageTag();
          options.add(SimpleDialogOption(
            padding: EdgeInsets.all(16),
            onPressed: () {
              widget.settingsSet(AppConfigFieldKey.locale, locale, updateState: true);
              Navigator.pop(context, locale);
            },
            child: Text('$name ($code)'),
          ));
        });
        _uiWrapper.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
        break;
      case TopMenuItem.keepScreenOnEnable:
        widget.settingsSet(AppConfigFieldKey.wakelockEnabled, true, updateState: true);
        break;
      case TopMenuItem.keepScreenOnDisable:
        widget.settingsSet(AppConfigFieldKey.wakelockEnabled, false, updateState: true);
        break;
      case TopMenuItem.themeModeLight:
        widget.settingsSet(AppConfigFieldKey.themeMode, ThemeMode.light, updateState: true);
        break;
      case TopMenuItem.themeModeDark:
        widget.settingsSet(AppConfigFieldKey.themeMode, ThemeMode.dark, updateState: true);
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
        _settingsWrapper.helpDialog();
        break;
    }
  }

  final PageController _controller = PageController(viewportFraction: 0.85);

  /// *************************************************************************
  /// TRACKS GRID
  dynamic _buildTracksGrid() => ListView.builder(
        controller: _controller,
        itemCount: widget.settingsGet(AppConfigFieldKey.gridRowsAmount),
        itemBuilder: (context, rowIndex) => Row(children: [
          _trackWrapper.buildRowButtons(rowIndex, TrackRow.name(rowIndex)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // physics: PageScrollPhysics(),
              child: Row(
                children: List.generate(
                  widget.settingsGet(AppConfigFieldKey.gridColsAmount),
                  (columnIndex) {
                    String trackId = Track.buildId(rowIndex, columnIndex);
                    Track track = widget.settingsGet(trackId, space: AppConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));
                    widget.tracksList.add(rowIndex, track);
                    _trackWrapper.initStreams(track);
                    return Container(
                      margin: EdgeInsets.all(_uiWrapper.gridGap),
                      width: Theme.of(context).textTheme.displaySmall!.fontSize! * 2,
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
                              padding: EdgeInsets.all(_uiWrapper.gridGap),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_uiWrapper.gridGap * 2)),
                              backgroundColor: track.stateBackgroundColor(context),
                              foregroundColor: track.stateForegroundColor(context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _trackWrapper.trackButton(track),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ]),
      );

  List<Widget> _buildDrawerMenu() => [
        _uiWrapper.drawerTitle(AppIcon.recordingSettings, _trans.recordingSettings),
        ListTile(
            leading: Icon(AppIcon.recordingInputDevice),
            title: Text(_trans.recordingInputDevice),
            subtitle: Text(
              widget.settingsGet(AppConfigFieldKey.recordingInputDevice) != null
                  ? widget.settingsGet(AppConfigFieldKey.recordingInputDevice).label
                  : _trans.defaultDevice,
            ),
            onTap: () async {
              var options = <Widget>[];
              options.add(SimpleDialogOption(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    Navigator.pop(context, 'recordingInputDevice');
                    widget.settingsSet(AppConfigFieldKey.recordingInputDevice, null, updateState: true);
                  },
                  child: Text(_trans.defaultDevice)));
              await widget.audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
                for (var inputDevice in inputDevices) {
                  options.add(SimpleDialogOption(
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        setState(() {
                          widget.settingsSet(AppConfigFieldKey.recordingInputDevice, inputDevice, updateState: true);
                        });
                        Navigator.pop(context, 'recordingInputDevice');
                      },
                      child: Text(_trans.recordingInputDeviceValue(inputDevice.label))));
                }
              });
              _uiWrapper.listDialog(AppIcon.recordingInputDevice, _trans.recordingInputDeviceTitle,
                  contentText: _trans.recordingInputDeviceInfo, actions: options.toList());
            }),
        _uiWrapper.listTileButtons(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          widget.settingsGet(AppConfigFieldKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoder.values().toList(),
          configCollection: AppGlobalConfig.recordingAudioEncoder,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(
              AppConfigFieldKey.recordingAudioEncoder,
              value,
              updateState: true,
            );
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileButtons(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          widget.settingsGet(AppConfigFieldKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRate.values().toList(),
          configCollection: AppGlobalConfig.recordingSampleRate,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileButtons(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          widget.settingsGet(AppConfigFieldKey.recordingBitRate),
          AppGlobalConfig.recordingBitRate.values().toList(),
          configCollection: AppGlobalConfig.recordingBitRate,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          disabledIcon: AppIcon.recordingAudioModeMono,
          // disabledLabel: _trans.recordingAudioModeOptionMono,
          enabledIcon: AppIcon.recordingAudioModeStereo,
          // enabledLabel: _trans.recordingAudioModeOptionStereo,
          switchValue: widget.settingsGet(AppConfigFieldKey.recordingAudioModeStereo),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.recordingAudioModeStereo, value, updateState: true);
            return _trans.recordingAudioModeSuccess(value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingAudioGain,
          _trans.recordingAutoGain,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          // enabledLabel: _trans.recordingAutoGainInfo,
          switchValue: widget.settingsGet(AppConfigFieldKey.recordingAutoGain),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.recordingAutoGain, value, updateState: true);
            return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingEchoCancel,
          _trans.recordingEchoCancel,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          // enabledLabel: _trans.recordingEchoCancelInfo,
          switchValue: widget.settingsGet(AppConfigFieldKey.recordingEchoCancel),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.recordingEchoCancel, value, updateState: true);
            return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingNoiseSuppress,
          _trans.recordingNoiseSuppress,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          // enabledLabel: _trans.recordingNoiseSuppressInfo,
          switchValue: widget.settingsGet(AppConfigFieldKey.recordingNoiseSuppress),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.recordingNoiseSuppress, value, updateState: true);
            return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.drawerTitle(AppIcon.displaySettings, _trans.displaySettings),
        ListTile(
            leading: Icon(AppIcon.language),
            title: Text(_trans.languageVersion),
            trailing: _uiWrapper.trailingLabel(widget.settingsGet(AppConfigFieldKey.locale).toLanguageTag()),
            onTap: () {
              var options = <Widget>[];
              AppGlobalConfig.languages.values<Locale>().forEach((Locale locale) {
                var name = AppGlobalConfig.languages.text(locale);
                var code = locale.toLanguageTag();
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      Navigator.pop(context, locale);
                      widget.settingsSet(AppConfigFieldKey.locale, locale, updateState: true);
                    },
                    child: Text('$name ($code)')));
              });
              _uiWrapper.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
            }),
        _uiWrapper.listTileSwitch(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          disabledIcon: AppIcon.screenLightThemeMode,
          // disabledLabel: _trans.lightMode,
          enabledIcon: AppIcon.screenDarkThemeMode,
          // enabledLabel: _trans.darkMode,
          switchValue: widget.settingsGet(AppConfigFieldKey.isThemeModeDark),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
            return null;
          },
        ),
        _uiWrapper.listTileColorPicker(
          AppIcon.screenThemeColor,
          _trans.screenThemeColor,
          null,
          _trans.screenThemeColorTitle,
          _trans.screenThemeColorInfo,
          widget.settingsGet(AppConfigFieldKey.themeSeedColor),
          AppGlobalConfig.userInterfaceColor.values<Color>().toList(),
          configCollection: AppGlobalConfig.userInterfaceColor,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.themeSeedColor, value, updateState: true);
            return _trans.screenThemeColorSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.keepScreenOn,
          _trans.keepScreenOn,
          disabledIcon: AppIcon.keepScreenOnDisabled,
          // disabledLabel: _trans.disabled,
          enabledIcon: AppIcon.keepScreenOnEnabled,
          // enabledLabel: _trans.enabled,
          switchValue: widget.settingsGet(AppConfigFieldKey.wakelockEnabled),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.wakelockEnabled, value, updateState: true);
            return value ? _trans.keepScreenOnIsDisabledSuccess : _trans.keepScreenOnIsEnabledSuccess;
          },
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            Navigator.pop(context);
            await Navigator.pushNamed(context, '/settings');
            setState(() {
              widget.tracksList.reset();
              loading = false;
            });
          },
          child: Text(_trans.moreSettings),
        ),
      ];
}
