import 'package:flutter/material.dart';
import 'package:tune_tangler/wrapper/app.dart';
import 'package:tune_tangler/src/lazy_loading_manager.dart';


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

  Widget get body => Focus(focusNode: _appWrapper.focusNode, autofocus: true, onKeyEvent: keyEvent, child: tracksList);

  Widget get bottomNavigationBar => _navigationBarManager.buildFooter;

  Widget get tracksList => ListView.builder(
      controller: PageController(viewportFraction: 0.85),
      itemCount: _appWrapper.settings.getConfig(AppConfigFieldKey.gridRowsAmount),
      itemBuilder: (context, rowIndex) => _lazyLoadingManager.lazyLoadWidget(
        key: 'row_$rowIndex',
        builder: () => RepaintBoundary(
          child: Row(children: [
            _rowMenuManager.buildRowButtons(rowIndex),
            _trackManager.buildRowTracks(rowIndex),
          ]),
        ),
        placeholder: const SizedBox(height: 100),
      ));

  KeyEventResult keyEvent(FocusNode node, KeyEvent event) {
    _trackManager.onKeyEvent(event);
    return KeyEventResult.handled;
  }
}
