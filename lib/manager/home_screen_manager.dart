import 'package:flutter/material.dart';
import 'package:tune_tangler/src/lazy_loading_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';

import '../config/app_config_fields.dart';
import '../manager/drawer_manager.dart';
import '../manager/navigation_bar_manager.dart';
import '../manager/row_menu_manager.dart';
import '../manager/track_manager.dart';

class HomeScreenManager {
  final AppWrapper _appWrapper;
  late NavigationBarManager _navigationBarManager;
  late DrawerManager _drawerManager;
  late RowMenuManager _rowMenuManager;
  late TrackManager _trackManager;
  final LazyLoadingManager _lazyLoadingManager = LazyLoadingManager();

  HomeScreenManager(this._appWrapper) {
    _navigationBarManager = NavigationBarManager(
      _appWrapper.context,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
      _appWrapper.scaffoldKey,
    );
    _drawerManager = DrawerManager(
      _appWrapper.context,
      _appWrapper.settings,
      _appWrapper.permissionProvider,
      _appWrapper.trans,
      _appWrapper.uiHelper,
      _appWrapper.trackRepository,
      _appWrapper.audioRecorder,
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
      child: tracksList);

  Widget get bottomNavigationBar => _navigationBarManager.buildFooter;

  Widget get tracksList {
    final rowsAmount =
        _appWrapper.settings.getConfig(AppConfigFieldKey.gridRowsAmount);
    final colsAmount =
        _appWrapper.settings.getConfig(AppConfigFieldKey.gridColsAmount);

    return ListView.builder(
      controller: PageController(viewportFraction: 0.85),
      itemCount: rowsAmount,
      itemBuilder: (context, rowIndex) => _lazyLoadingManager.lazyLoadWidget(
        // Include locale in cache key to rebuild on language change
        key:
            'row_${rowIndex}_rows${rowsAmount}_cols${colsAmount}_locale_${_appWrapper.settings.getConfig(AppConfigFieldKey.locale).toLanguageTag()}',
        builder: () => Row(children: [
          _rowMenuManager.buildRowButtons(rowIndex),
          _trackManager.buildRowTracks(rowIndex, colsAmount),
        ]),
        placeholder: const SizedBox(height: 100),
      ),
    );
  }

  KeyEventResult keyEvent(FocusNode node, KeyEvent event) {
    _trackManager.onKeyEvent(event);

    return KeyEventResult.handled;
  }
}
