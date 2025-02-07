import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/src/settings_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
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
        _settingsWrapper = SettingsWrapper(context, widget, _trans, _uiWrapper, _trackWrapper, _permissionStatuses);

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
            body: body,
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(child: Text(_trans.legalNote, style: Theme.of(context).textTheme.labelSmall)),
            ]));
      });

  final PageController _controller = PageController(viewportFraction: 0.85);

  /// *************************************************************************
  /// TRACKS GRID
  dynamic _buildTracksGrid() => ListView.builder(
        controller: _controller,
        itemCount: widget.settingsGet(AppConfigFieldKey.gridRowsAmount),
        itemBuilder: (context, rowIndex) => Row(children: [
          _settingsWrapper.buildRowButtons(rowIndex, TrackRow.name(rowIndex)),
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
                      width: Theme.of(context).textTheme.displaySmall!.fontSize! * 2.1,
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
                            children: _trackWrapper.trackButton(track, state),
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
}
