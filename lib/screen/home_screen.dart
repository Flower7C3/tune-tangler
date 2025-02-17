import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../config/app_config_fields.dart';
import '../helper/ui_helper.dart';
import '../manager/drawer_manager.dart';
import '../manager/navigation_bar_manager.dart';
import '../manager/row_menu_manager.dart';
import '../manager/track_manager.dart';
import '../provider/permission_provider.dart';
import '../repository/track_repository.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class HomeScreen extends StatelessWidget {
  late HiveSettingsProvider settings;
  late PermissionProvider permissionProvider;
  late FocusNode focusNode;
  late AudioRecorder audioRecorder;
  late TrackRepository trackRepository;

  HomeScreen({
    super.key,
    required this.settings,
    required this.permissionProvider,
    required this.focusNode,
    required this.audioRecorder,
    required this.trackRepository,
  });

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        AppLocalizations trans = AppLocalizations.of(context)!;
        UIHelper uiHelper = UIHelper(context);
        trackRepository = TrackRepository(settings);
        NavigationBarManager navigationBarManager = NavigationBarManager(context, settings, trans, uiHelper, trackRepository);
        RowMenuManager rowMenuManager = RowMenuManager(context, trans, uiHelper, trackRepository);
        DrawerManager drawerManager = DrawerManager(context, settings,permissionProvider, trans, uiHelper, trackRepository, audioRecorder);
        TrackManager trackManager = TrackManager(context, settings, trans, uiHelper, trackRepository, audioRecorder);

        return Scaffold(
          appBar: navigationBarManager.buildAppBar,
          drawer: drawerManager.build,
          body: Focus(
              focusNode: focusNode,
              autofocus: true,
              onKeyEvent: (node, KeyEvent event) {
                trackManager.onKeyEvent(event);
                return KeyEventResult.handled;
              },
              child: ListView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: settings.getConfig(AppConfigFieldKey.gridRowsAmount),
                  itemBuilder: (context, rowIndex) => Row(children: [
                        rowMenuManager.buildRowButtons(rowIndex),
                        trackManager.buildRowTracks(rowIndex),
                      ]))),
          bottomNavigationBar: navigationBarManager.buildFooter,
        );
      });
}
