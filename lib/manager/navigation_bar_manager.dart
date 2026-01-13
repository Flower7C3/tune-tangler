import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/config_collection.dart';
import '../config/menu_item_enums.dart';
import '../manager/project_export_import_manager.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class NavigationBarManager {
  final BuildContext _context;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final HiveSettingsProvider _settings;
  late final ProjectExportImportManager _projectManager;

  NavigationBarManager(
    this._context,
    this._trans,
    this._uiHelper,
    this._trackRepository,
    this._scaffoldKey,
    this._settings,
  ) {
    _projectManager = ProjectExportImportManager(
      _context,
      _settings,
      _trackRepository,
      _trans,
      _uiHelper,
    );
  }

  AppBar get buildAppBar => AppBar(
    backgroundColor: Theme.of(_context).colorScheme.inversePrimary,
    leading: Builder(
      builder: (context) => IconButton(
        icon: AppIcon.appLogo(
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.inversePrimary,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    title: Text(_uiHelper.getAppTitle(_trans)),
    actions: [
      RepaintBoundary(
        child: IconButton(
          icon: Icon(AppIcon.trackPlayingStart),
          tooltip: _trans.allTracksPlayingStart,
          onPressed: () =>
              _trackRepository.startTracksPlaying(_trackRepository.allTracks()),
        ),
      ),
      RepaintBoundary(
        child: IconButton(
          icon: Icon(AppIcon.trackPlayingStop),
          tooltip: _trans.allTracksPlayingStop,
          onPressed: () =>
              _trackRepository.stopTracksPlaying(_trackRepository.allTracks()),
        ),
      ),
      RepaintBoundary(
        child: PopupMenuButton<String>(
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _trackSettingsMenu,
          onSelected: (String selection) => _trackSettingsMenuItemSelected(
            AllTracksMenuItem.values.byName(
              selection.replaceAll('AllTracksMenuItem.', ''),
            ),
          ),
        ),
      ),
    ],
  );

  Widget get buildFooter => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Text(
          _trans.legalNote,
          style: Theme.of(_context).textTheme.labelSmall,
        ),
      ),
    ],
  );

  List<PopupMenuEntry<String>> get _trackSettingsMenu => [
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackModeSet,
      AppIcon.trackPlaybackMode,
      _trans.allTracksPlaybackModeSet,
    ),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackVolumeSet,
      AppIcon.trackPlaybackVolume,
      _trans.allTracksPlaybackVolumeSet,
    ),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackBalanceSet,
      AppIcon.trackPlaybackBalance,
      _trans.allTracksPlaybackBalanceSet,
    ),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackSpeedSet,
      AppIcon.trackPlaybackSpeed,
      _trans.allTracksPlaybackSpeedSet,
    ),
    const PopupMenuDivider(),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackStartAtPositionReset,
      AppIcon.trackPlaybackStartAtPosition,
      _trans.allTracksPlaybackStartAtPositionReset,
    ),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.playbackEndAtPositionReset,
      AppIcon.trackPlaybackEndAtPosition,
      _trans.allTracksPlaybackEndAtPositionReset,
    ),
    const PopupMenuDivider(),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.projectExport,
      AppIcon.projectExport,
      _trans.projectExport,
    ),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.projectImport,
      AppIcon.projectImport,
      _trans.projectImport,
    ),
    const PopupMenuDivider(),
    _uiHelper.topTrackMenuItem(
      AllTracksMenuItem.moreSettings,
      AppIcon.moreSettings,
      _trans.moreSettings,
    ),
  ];

  void _trackSettingsMenuItemSelected(AllTracksMenuItem selection) async {
    switch (selection) {
      case AllTracksMenuItem.playbackModeSet:
        _uiHelper.listDialog(
          AppIcon.trackPlaybackMode,
          _trans.allTracksPlaybackModeTitleSet,
          contentText: _trans.allTracksPlaybackModeInfoSet,
          actions: [
            ...AppGlobalConfig.trackPlaybackReleaseMode
                .values<ReleaseMode>()
                .map(
                  (ReleaseMode value) => SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    child: _uiHelper.statusIconTile(
                      AppGlobalConfig.trackPlaybackReleaseMode.icon(value),
                      AppGlobalConfig.trackPlaybackReleaseMode.translate(
                        value,
                        trans: _trans,
                      ),
                    ),
                    onPressed: () {
                      _trackRepository.setTracksPlaybackMode(
                        _trackRepository.allTracks(),
                        value,
                      );
                      _uiHelper.toast(
                        _trans.allTracksPlaybackModeSuccessSet(
                          AppGlobalConfig.trackPlaybackReleaseMode.translate(
                            value,
                            trans: _trans,
                          ),
                        ),
                        icon: AppIcon.trackSinglePlaybackMode,
                      );
                      Navigator.pop(_context);
                    },
                  ),
                ),
          ],
        );
        break;
      case AllTracksMenuItem.playbackBalanceSet:
        _uiHelper.alertDialogSlider(
          AppIcon.trackPlaybackBalance,
          _trans.allTracksPlaybackBalanceTitleSet,
          _trans.allTracksPlaybackBalanceInfoSet,
          AppGlobalConfig.trackPlaybackBalance.defaultValue,
          AppGlobalConfig.trackPlaybackBalance.sliderValues.min,
          AppGlobalConfig.trackPlaybackBalance.sliderValues.max,
          AppGlobalConfig.trackPlaybackBalance.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _trackRepository.setTracksPlaybackBalance(
              _trackRepository.allTracks(),
              value,
            );
            return _trans.allTracksPlaybackBalanceSuccessSet(
              AppGlobalConfig.trackPlaybackBalance.translate(
                value,
                trans: _trans,
              ),
            );
          },
          withTrailing: false,
          configCollection: AppGlobalConfig.trackPlaybackBalance,
          trans: _trans,
          sliderTheme: _uiHelper.balanceSliderThemeData(_context),
          tileLeading: ConfigItemPropertyDomain.balanceLeft,
          tileTrailing: ConfigItemPropertyDomain.balanceRight,
        );
        break;
      case AllTracksMenuItem.playbackVolumeSet:
        _uiHelper.alertDialogSlider(
          AppIcon.trackPlaybackVolume,
          _trans.allTracksPlaybackVolumeTitleSet,
          _trans.allTracksPlaybackVolumeInfoSet,
          AppGlobalConfig.trackPlaybackVolume.defaultValue,
          AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
          AppGlobalConfig.trackPlaybackVolume.sliderValues.max,
          AppGlobalConfig.trackPlaybackVolume.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          withTrailing: false,
          successAction: (double value, String formattedValue) {
            _trackRepository.setTracksPlaybackVolume(
              _trackRepository.allTracks(),
              value,
            );
            return _trans.allTracksPlaybackVolumeSuccessSet(formattedValue);
          },
          configCollection: AppGlobalConfig.trackPlaybackVolume,
        );
        break;
      case AllTracksMenuItem.playbackSpeedSet:
        _uiHelper.alertDialogSlider(
          AppIcon.trackPlaybackSpeed,
          _trans.allTracksPlaybackSpeedTitleSet,
          _trans.allTracksPlaybackSpeedInfoSet,
          AppGlobalConfig.trackPlaybackSpeed.defaultValue,
          AppGlobalConfig.trackPlaybackSpeed.sliderValues.min,
          AppGlobalConfig.trackPlaybackSpeed.sliderValues.max,
          AppGlobalConfig.trackPlaybackSpeed.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          withTrailing: false,
          successAction: (double value, String formattedValue) {
            _trackRepository.setTracksPlaybackSpeed(
              _trackRepository.allTracks(),
              value,
            );
            return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
          },
          configCollection: AppGlobalConfig.trackPlaybackSpeed,
        );
        break;
      case AllTracksMenuItem.playbackStartAtPositionReset:
        _uiHelper.alertDialogReset(
          AppIcon.trackPlaybackStartAtPosition,
          _trans.allTracksPlaybackStartAtPositionReset,
          _trans.allTracksPlaybackStartAtPositionResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.resetTracksPlaybackStartAtPosition(
              _trackRepository.allTracks(),
            );
            return _trans.allTracksPlaybackStartAtPositionResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.playbackEndAtPositionReset:
        _uiHelper.alertDialogReset(
          AppIcon.trackPlaybackEndAtPosition,
          _trans.allTracksPlaybackEndAtPositionResetTitle,
          _trans.allTracksPlaybackEndAtPositionResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.resetTracksPlaybackEndAtPosition(
              _trackRepository.allTracks(),
            );
            return _trans.allTracksPlaybackEndAtPositionResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.projectExport:
        _projectManager.exportProject();
        break;
      case AllTracksMenuItem.projectImport:
        _projectManager.importProject();
        break;
      case AllTracksMenuItem.moreSettings:
        _scaffoldKey.currentState?.openDrawer();
        break;
    }
  }
}
