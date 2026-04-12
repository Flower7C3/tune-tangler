import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tune_tangler/manager/project_export_import_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';

import '../config/app_config_fields.dart';
import '../manager/drawer_manager.dart';
import '../manager/navigation_bar_manager.dart';
import '../manager/row_menu_manager.dart';
import '../manager/track_manager.dart';
import '../wrapper/hive_settings_provider.dart';

class HomeScreenManager {
  final AppWrapper _appWrapper;
  late NavigationBarManager _navigationBarManager;
  late DrawerManager _drawerManager;
  late RowMenuManager _rowMenuManager;
  late TrackManager _trackManager;
  late ProjectExportImportManager _projectManager;

  HomeScreenManager(this._appWrapper) {
    _projectManager = ProjectExportImportManager(
      _appWrapper.context,
      _appWrapper.settings,
      _appWrapper.trackRepository,
      _appWrapper.trans,
      _appWrapper.uiHelper,
    );

    _navigationBarManager = NavigationBarManager(
      _appWrapper.context,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
      _appWrapper.scaffoldKey,
      _projectManager,
    );
    _drawerManager = DrawerManager(
      _appWrapper.context,
      _appWrapper.settings,
      _appWrapper.permissionProvider,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
      _appWrapper.audioRecorder,
      _appWrapper.hasDynamicColor,
    );
    _rowMenuManager = RowMenuManager(
      _appWrapper.context,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
    );
    _trackManager = TrackManager(
      _appWrapper.context,
      _appWrapper.settings,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
      _appWrapper.audioRecorder,
    );
  }

  AppBar get appBar => _navigationBarManager.buildAppBar;

  Widget get drawer => _drawerManager.build;

  Widget get body => Focus(
    focusNode: _appWrapper.focusNode,
    autofocus: true,
    onKeyEvent: keyEvent,
    child: Selector<HiveSettingsProvider, (int, int, String)>(
      selector: (context, settings) => (
        settings.getConfig(AppConfigFieldKey.gridRowsAmount) as int,
        settings.getConfig(AppConfigFieldKey.gridColsAmount) as int,
        settings.getConfig(AppConfigFieldKey.keyboardLayoutPreset).toString(),
      ),
      builder: (context, dims, child) {
        final (gridRowsAmount, gridColsAmount, _) = dims;
        return ListView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: gridRowsAmount,
          itemBuilder: (context, rowIndex) => Row(
            children: [
              _rowMenuManager.buildRowButtons(rowIndex),
              _trackManager.buildRowTracks(rowIndex, gridColsAmount),
            ],
          ),
        );
      },
    ),
  );

  // Include locale and version in cache key to rebuild on language change and import
  Widget get bottomNavigationBar => _navigationBarManager.buildFooter;

  KeyEventResult keyEvent(FocusNode node, KeyEvent event) {
    _trackManager.onKeyEvent(event);

    return KeyEventResult.handled;
  }
}
