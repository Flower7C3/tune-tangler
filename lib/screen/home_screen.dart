import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/src/settings_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
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
  final dynamic Function(dynamic key, {AppConfigSpace space, dynamic defaultValue}) settingsGet;
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
  late AppLocalizations _trans;
  late UIWrapper _uiWrapper;
  late TrackWrapper _trackWrapper;
  late SettingsWrapper _settingsWrapper;

  final FocusNode _focusNode = FocusNode();

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _focusNode.requestFocus(); // Utrzymuje fokus po starcie aplikacji
    WidgetsBinding.instance.addObserver(this);
  }

  void _checkPermissions() {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions.values<Permission>()) {
      permission.status.then((status) => statuses[permission] = status);
    }
    _permissionStatuses = statuses;
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
        _settingsWrapper = SettingsWrapper(context, widget, _trans, _uiWrapper, _trackWrapper, _permissionStatuses);

        _trackWrapper.initTracks();

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
              title: Text(_trans.appTitle),
              actions: _settingsWrapper.appBarActions,
            ),
            drawer: _settingsWrapper.drawer,
            body: Focus(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: (node, KeyEvent event) {
                  _trackWrapper.onKeyEvent(event);
                  return KeyEventResult.handled;
                },
                child: ListView.builder(
                    controller: PageController(viewportFraction: 0.85),
                    itemCount: widget.settingsGet(AppConfigFieldKey.gridRowsAmount),
                    itemBuilder: (context, rowIndex) => Row(children: [
                          _settingsWrapper.buildRowButtons(rowIndex, TrackRow.name(rowIndex)),
                          _trackWrapper.buildRowTracks(rowIndex),
                        ]))),
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(child: Text(_trans.legalNote, style: Theme.of(context).textTheme.labelSmall)),
            ]));
      });
}
