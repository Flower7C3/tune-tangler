import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/screen/home_screen.dart';
import 'package:tune_tangler/src/track_wrapper.dart';
import 'package:tune_tangler/src/ui_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';

class SettingsWrapper {
  final BuildContext _context;
  final HomeScreen _widget;
  final AppLocalizations _trans;
  final UIWrapper _uiWrapper;
  final TrackWrapper _trackWrapper;
  Map<Permission, PermissionStatus> permissionStatuses;

  SettingsWrapper(this._context, this._widget, this._trans, this._uiWrapper, this._trackWrapper, this.permissionStatuses);

  Widget get drawer => StatefulBuilder(
      builder: (BuildContext context, StateSetter setDrawerState) => Drawer(
              child: ListView(padding: EdgeInsets.zero, children: [
            UserAccountsDrawerHeader(
              accountName: Text(_trans.appTitle,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )),
              accountEmail: Text(
                _trans.legalNote,
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              ),
              currentAccountPicture: Icon(
                  _widget.settingsGet(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled,
                  size: Theme.of(context).textTheme.displayLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.recordingSettings),
              title: Text(_trans.recording),
              initiallyExpanded: true,
              childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
              children: _recordingSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.screenSettings),
              title: Text(_trans.screen),
              childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
              children: screenSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.permissions),
              title: Text(_trans.permissions),
              childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
              children: permissions(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.dangerZone),
              title: Text(_trans.dangerZone),
              childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
              children: _dangerZone,
            ),
            ListTile(
              leading: Icon(AppIcon.help),
              title: Text(_trans.help),
              onTap: helpDialog,
            ),
          ])));

  List<Widget> _recordingSettings(StateSetter setDrawerState) => [
        ListTile(
          leading: Icon(AppIcon.recordingInputDevice),
          title: Text(_trans.recordingInputDevice),
          subtitle: Text(
            _widget.settingsGet(AppConfigFieldKey.recordingInputDevice) != null
                ? _widget.settingsGet(AppConfigFieldKey.recordingInputDevice).label
                : _trans.defaultDevice,
          ),
          onTap: () async {
            var options = <Widget>[];
            options.add(SimpleDialogOption(
                padding: EdgeInsets.all(16),
                onPressed: () {
                  Navigator.pop(_context, 'recordingInputDevice');
                  _widget.settingsSet(AppConfigFieldKey.recordingInputDevice, null, updateState: true);
                },
                child: Text(_trans.defaultDevice)));
            await _widget.audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
              for (var inputDevice in inputDevices) {
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      _widget.settingsSet(AppConfigFieldKey.recordingInputDevice, inputDevice, updateState: true);
                      Navigator.pop(_context, 'recordingInputDevice');
                    },
                    child: Text(_trans.recordingInputDeviceValue(inputDevice.label))));
              }
            });
            _uiWrapper.listDialog(AppIcon.recordingInputDevice, _trans.recordingInputDeviceTitle,
                contentText: _trans.recordingInputDeviceInfo, actions: options.toList());
          },
        ),
        _uiWrapper.listTileButtons(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          _widget.settingsGet(AppConfigFieldKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoder.values().toList(),
          helpMessage: _trans.recordingAudioEncoderInfo,
          configCollection: AppGlobalConfig.recordingAudioEncoder,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _widget.settingsSet(
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
          _widget.settingsGet(AppConfigFieldKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRate.values().toList(),
          helpMessage: _trans.recordingSampleRateInfo,
          configCollection: AppGlobalConfig.recordingSampleRate,
          successAction: (dynamic value, String formattedValue) {
            _widget.settingsSet(AppConfigFieldKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileButtons(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _widget.settingsGet(AppConfigFieldKey.recordingBitRate),
          AppGlobalConfig.recordingBitRate.values().toList(),
          helpMessage: _trans.recordingBitRateInfo,
          configCollection: AppGlobalConfig.recordingBitRate,
          successAction: (dynamic value, String formattedValue) {
            _widget.settingsSet(AppConfigFieldKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          disabledIcon: AppIcon.recordingAudioModeMono,
          enabledIcon: AppIcon.recordingAudioModeStereo,
          switchValue: _widget.settingsGet(AppConfigFieldKey.recordingAudioModeStereo),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.recordingAudioModeStereo, value, updateState: true);
            return _trans.recordingAudioModeSuccess(value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingAudioGain,
          _trans.recordingAutoGain,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _widget.settingsGet(AppConfigFieldKey.recordingAutoGain),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.recordingAutoGain, value, updateState: true);
            return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingEchoCancel,
          _trans.recordingEchoCancel,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _widget.settingsGet(AppConfigFieldKey.recordingEchoCancel),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.recordingEchoCancel, value, updateState: true);
            return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingNoiseSuppress,
          _trans.recordingNoiseSuppress,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _widget.settingsGet(AppConfigFieldKey.recordingNoiseSuppress),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.recordingNoiseSuppress, value, updateState: true);
            return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
          },
        ),
      ];

  List<Widget> screenSettings(StateSetter setDrawerState) => [
        _uiWrapper.listTileListDialog(
          AppIcon.language,
          _trans.languageVersion,
          dialogTitle: _trans.changeLanguage,
          currentValue: _widget.settingsGet(AppConfigFieldKey.locale).toLanguageTag(),
          options: AppGlobalConfig.languages
              .values<Locale>()
              .map((Locale locale) => SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    child: _uiWrapper.statusTextTile(
                        locale.toLanguageTag(),
                        AppGlobalConfig.languages.text(
                          locale,
                        ),
                        iconColor: Theme.of(_context).colorScheme.inversePrimary),
                    onPressed: () {
                      Navigator.pop(_context, locale);
                      _widget.settingsSet(AppConfigFieldKey.locale, locale, updateState: true);
                    },
                  ))
              .toList(),
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          disabledIcon: AppIcon.screenLightThemeMode,
          enabledIcon: AppIcon.screenDarkThemeMode,
          switchValue: _widget.settingsGet(AppConfigFieldKey.isThemeModeDark),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
            return null;
          },
        ),
        _uiWrapper.listTileColorPicker(
          AppIcon.screenThemeColor,
          _trans.screenThemeColor,
          null,
          _trans.screenThemeColorTitle,
          _trans.screenThemeColorInfo,
          _widget.settingsGet(AppConfigFieldKey.themeSeedColor),
          AppGlobalConfig.userInterfaceColor.values<Color>().toList(),
          configCollection: AppGlobalConfig.userInterfaceColor,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _widget.settingsSet(AppConfigFieldKey.themeSeedColor, value, updateState: true);
            return _trans.screenThemeColorSuccess(formattedValue);
          },
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.keepScreenOn,
          _trans.keepScreenOn,
          disabledIcon: AppIcon.keepScreenOnDisabled,
          enabledIcon: AppIcon.keepScreenOnEnabled,
          switchValue: _widget.settingsGet(AppConfigFieldKey.wakelockEnabled),
          successAction: (bool value) {
            _widget.settingsSet(AppConfigFieldKey.wakelockEnabled, value, updateState: true);
            return value ? _trans.keepScreenOnIsDisabledSuccess : _trans.keepScreenOnIsEnabledSuccess;
          },
        ),
        _uiWrapper.listTileSlider(
          AppIcon.gridRowsAmount,
          _trans.gridRowsAmount,
          _trans.gridRowsAmountTitle,
          _trans.gridRowsAmountInfo,
          double.parse(_widget.settingsGet(AppConfigFieldKey.gridRowsAmount).toString()),
          AppGlobalConfig.gridRows.sliderValues.min,
          AppGlobalConfig.gridRows.sliderValues.max,
          AppGlobalConfig.gridRows.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _widget.settingsSet(AppConfigFieldKey.gridRowsAmount, value.toInt(), updateState: true);
            return _trans.gridRowsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridRows,
        ),
        _uiWrapper.listTileSlider(
          AppIcon.gridColsAmount,
          _trans.gridColsAmount,
          _trans.gridColsAmountTitle,
          _trans.gridColsAmountInfo,
          double.parse(_widget.settingsGet(AppConfigFieldKey.gridColsAmount).toString()),
          AppGlobalConfig.gridCols.sliderValues.min,
          AppGlobalConfig.gridCols.sliderValues.max,
          AppGlobalConfig.gridCols.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _widget.settingsSet(AppConfigFieldKey.gridColsAmount, value.toInt(), updateState: true);
            return _trans.gridColsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridCols,
        ),
      ];

  List<Widget> permissions(StateSetter setDrawerState) => [
        ...AppGlobalConfig.permissions.values<Permission>().map(
          (Permission permission) {
            final status = permissionStatuses[permission] ?? PermissionStatus.denied;
            return ListTile(
              leading: Icon(AppGlobalConfig.permissions.icon(permission)),
              title: Text(AppGlobalConfig.permissions.translate(permission, trans: _trans)),
              subtitle: Text(AppGlobalConfig.permissionsStatus.translate(status, trans: _trans)),
              trailing: status.isGranted
                  ? Icon(AppIcon.yes, color: Theme.of(_context).colorScheme.primary)
                  : ElevatedButton(
                      onPressed: () async {
                        if (status.isDenied) {
                          final status = await permission.request();
                          permissionStatuses[permission] = status;
                          setDrawerState(() {});
                        } else {
                          await openAppSettings();
                          setDrawerState(() {});
                        }
                      },
                      child: Text(_trans.grantPermission),
                    ),
            );
          },
        )
      ];

  Future<void> helpDialog() async {
    double fontSize = Theme.of(_context).textTheme.titleMedium!.fontSize!;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _uiWrapper.aboutDialog(
      packageInfo,
      [
        ExpansionTile(
          title: Text(_trans.helpScreenMessageAboutTitle),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.helpScreenMessageAboutContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenMessageUsageTitle),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.helpScreenMessageUsageContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenMessageTrackActions),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            _uiWrapper.helpTrackState(TrackState.empty, _trans.stateEmpty),
            _uiWrapper.helpTrackState(TrackState.recording, _trans.stateRecording),
            _uiWrapper.helpTrackState(TrackState.idle, _trans.stateIdle),
            _uiWrapper.helpTrackState(TrackState.playing, _trans.statePlaying),
            _uiWrapper.helpTrackState(TrackState.paused, _trans.statePaused),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.recordingSettings),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            _uiWrapper.statusIconRow(AppIcon.recordingAudioGain, _trans.recordingAutoGain, fontSize: fontSize),
            Text(_trans.recordingAutoGainInfo),
            _uiWrapper.statusIconRow(AppIcon.recordingEchoCancel, _trans.recordingEchoCancel, fontSize: fontSize),
            Text(_trans.recordingEchoCancelInfo),
            _uiWrapper.statusIconRow(AppIcon.recordingNoiseSuppress, _trans.recordingNoiseSuppress, fontSize: fontSize),
            Text(_trans.recordingNoiseSuppressInfo),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.recordingAudioEncoders),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.helpScreenRecordingCodecsInfoContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenRecordingCodecsChooseTitle),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.recordingAudioEncoderInfo),
          ],
        ),
      ],
      applicationIcon:
          Icon(_widget.settingsGet(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
      applicationLegalese: _trans.legalNote,
    );
  }

  /// *************************************************************************
  /// TOP MENU
  List<Widget> get appBarActions => [
        IconButton(
          icon: Icon(AppIcon.trackPlayingStart),
          tooltip: _trans.allTracksPlayingStart,
          onPressed: () {
            _trackWrapper.startTracksPlaying(_widget.tracksList.all());
          },
        ),
        IconButton(
          icon: Icon(AppIcon.trackPlayingStop),
          tooltip: _trans.allTracksPlayingStop,
          onPressed: () {
            _trackWrapper.stopTracksPlaying(_widget.tracksList.all());
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _trackSettingsMenu,
          onSelected: (String selection) {
            _trackSettingsMenuItemSelected(AllTracksMenuItem.values.byName(selection.replaceAll('AllTracksMenuItem.', '')));
          },
        ),
      ];

  List<PopupMenuEntry<String>> get _trackSettingsMenu => [
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackModeSet, AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackVolumeSet, AppIcon.trackPlaybackVolume, _trans.allTracksPlaybackVolumeSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackBalanceSet, AppIcon.trackPlaybackBalance, _trans.allTracksPlaybackBalanceSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackSpeedSet, AppIcon.trackPlaybackSpeed, _trans.allTracksPlaybackSpeedSet),
        const PopupMenuDivider(),
        _uiWrapper.topTrackMenuItem(
            AllTracksMenuItem.playbackStartAtPositionReset, AppIcon.trackPlaybackStartAtPosition, _trans.allTracksPlaybackStartAtPositionReset),
        _uiWrapper.topTrackMenuItem(
            AllTracksMenuItem.playbackEndAtPositionReset, AppIcon.trackPlaybackEndAtPosition, _trans.allTracksPlaybackEndAtPositionReset),
        const PopupMenuDivider(),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.titleReset, AppIcon.trackTitle, _trans.allTracksTitleReset),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.shortcutKeyReset, AppIcon.trackKeyboardKey, _trans.allTracksShortcutKeyReset),
      ];

  void _trackSettingsMenuItemSelected(AllTracksMenuItem selection) async {
    switch (selection) {
      case AllTracksMenuItem.playbackModeSet:
        _uiWrapper.listDialog(
          AppIcon.trackPlaybackMode,
          _trans.allTracksPlaybackModeTitleSet,
          contentText: _trans.allTracksPlaybackModeInfoSet,
          actions: [
            ...AppGlobalConfig.trackPlaybackReleaseMode.values<ReleaseMode>().map(
                  (ReleaseMode value) => SimpleDialogOption(
                      padding: EdgeInsets.zero,
                      child: _uiWrapper.statusIconTile(
                        AppGlobalConfig.trackPlaybackReleaseMode.icon(value),
                        AppGlobalConfig.trackPlaybackReleaseMode.translate(value, trans: _trans),
                      ),
                      onPressed: () {
                        _trackWrapper.setTracksPlaybackMode(_widget.tracksList.all(), value);
                        _uiWrapper.toast(
                            _trans.allTracksPlaybackModeSuccessSet(
                              AppGlobalConfig.trackPlaybackReleaseMode
                                  .translate(AppGlobalConfig.trackPlaybackReleaseMode.values().toList().indexOf(0), trans: _trans),
                            ),
                            icon: AppIcon.trackSinglePlaybackMode);
                        Navigator.pop(_context);
                      }),
                )
          ],
        );
        break;
      case AllTracksMenuItem.playbackBalanceSet:
        _uiWrapper.alertDialogSlider(
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
            _trackWrapper.setTracksPlaybackBalance(_widget.tracksList.all(), value);
            return _trans.allTracksPlaybackBalanceSuccessSet(AppGlobalConfig.trackPlaybackBalance.translate(value, trans: _trans));
          },
          withTrailing: false,
          configCollection: AppGlobalConfig.trackPlaybackBalance,
          trans: _trans,
        );
        break;
      case AllTracksMenuItem.playbackVolumeSet:
        _uiWrapper.alertDialogSlider(
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
            _trackWrapper.setTracksPlaybackVolume(_widget.tracksList.all(), value);
            return _trans.allTracksPlaybackVolumeSuccessSet(formattedValue);
          },
          configCollection: AppGlobalConfig.trackPlaybackVolume,
        );
        break;
      case AllTracksMenuItem.playbackSpeedSet:
        _uiWrapper.alertDialogSlider(
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
            _trackWrapper.setTracksPlaybackSpeed(_widget.tracksList.all(), value);
            return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
          },
          configCollection: AppGlobalConfig.trackPlaybackSpeed,
        );
        break;
      case AllTracksMenuItem.playbackStartAtPositionReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackPlaybackStartAtPosition,
          _trans.allTracksPlaybackStartAtPositionReset,
          _trans.allTracksPlaybackStartAtPositionResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksPlaybackStartAtPosition(_widget.tracksList.all());
            return _trans.allTracksPlaybackStartAtPositionResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.playbackEndAtPositionReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackPlaybackEndAtPosition,
          _trans.allTracksPlaybackEndAtPositionResetTitle,
          _trans.allTracksPlaybackEndAtPositionResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksPlaybackEndAtPosition(_widget.tracksList.all());
            return _trans.allTracksPlaybackEndAtPositionResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.titleReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackTitle,
          _trans.allTracksTitleResetTitle,
          _trans.allTracksTitleResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksName(_widget.tracksList.all());
            return _trans.allTracksTitleResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.shortcutKeyReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackKeyboardKey,
          _trans.allTracksShortcutKeyResetTitle,
          _trans.allTracksShortcutKeyResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksKeyboardKey(_widget.tracksList.all());
            return _trans.allTracksShortcutKeyResetSuccess;
          },
        );
        break;
    }
  }

  List<Widget> get _dangerZone => [
        _uiWrapper.listTileReset(
          AppIcon.recordingSettings,
          _trans.recordingSettingsReset,
          _trans.recordingSettingsResetTitle,
          _trans.recordingSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            for (AppRecordingConfigField field in AppGlobalConfigFieldsCollection.listRecording) {
              _widget.settingsSet(field.key, field.defaultValue, updateState: true);
            }
            return _trans.recordingSettingsResetSuccess;
          },
        ),
        _uiWrapper.listTileReset(
          AppIcon.screenSettings,
          _trans.screenSettingsReset,
          _trans.screenSettingsResetTitle,
          _trans.screenSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            for (AppGlobalConfigField field in AppGlobalConfigFieldsCollection.listGlobal) {
              _widget.settingsSet(field.key, field.defaultValue, updateState: true);
            }
            return _trans.screenSettingsResetSuccess;
          },
        ),
        _uiWrapper.listTileReset(
          AppIcon.trackSettings,
          _trans.allTracksSettingsReset,
          _trans.allTracksSettingsResetTitle,
          _trans.allTracksSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksSettings(_widget.tracksList.all());
            return _trans.allTracksSettingsResetSuccess;
          },
        ),
        _uiWrapper.listTileReset(
          AppIcon.deleteForever,
          _trans.allTracksRecordingsDelete,
          _trans.allTracksRecordingsDeleteTitle,
          _trans.allTracksRecordingsDeleteInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.removeTracksRecordings(_widget.tracksList.all());
            return _trans.allTracksRecordingsDeleteSuccess;
          },
        ),
      ];

  /// *************************************************************************
  /// ROW
  Container buildRowButtons(
    int rowIndex,
    String rowName,
  ) =>
      Container(
          width: Theme.of(_context).textTheme.displaySmall!.fontSize,
          padding: EdgeInsets.zero,
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlayingStart,
              _trans.rowTracksPlayingStart(rowName),
              boxSize: Theme.of(_context).textTheme.displaySmall!.fontSize! * 0.9,
              onPressed: () {
                _trackWrapper.startTracksPlaying(_widget.tracksList.row(rowIndex));
              },
            ),
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlayingStop,
              _trans.rowTracksPlayingStop(rowName),
              boxSize: Theme.of(_context).textTheme.displaySmall!.fontSize! * 0.9,
              onPressed: () {
                _trackWrapper.stopTracksPlaying(_widget.tracksList.row(rowIndex));
              },
            ),
            _uiWrapper.rowButton(_rowMenuActions(rowName, _widget.tracksList.row(rowIndex))),
          ]));

  PopupMenuButton _rowMenuActions(
    String rowName,
    Set<Track> tracksList,
  ) =>
      PopupMenuButton<dynamic>(
          style: _uiWrapper.circledButtonStyle(),
          icon: Icon(AppIcon.moreMenu, color: Theme.of(_context).colorScheme.secondary),
          itemBuilder: (BuildContext context) => _rowMenuItems(rowName, tracksList),
          onSelected: (dynamic selection) => _rowMenuItemSelected(selection, rowName, tracksList));

  List<PopupMenuEntry<dynamic>> _rowMenuItems(
    String rowName,
    Set<Track> tracksList,
  ) =>
      <PopupMenuEntry<dynamic>>[
        _uiWrapper.rowMenuButton(RowMenuItem.playbackMode, AppIcon.trackPlaybackMode, _trans.rowTracksPlaybackModeSet,
            itemBuilder: () => [
                  ...AppGlobalConfig.trackPlaybackReleaseMode.values<ReleaseMode>().map((ReleaseMode value) => _uiWrapper.rowPopupMenuItem(
                        value,
                        AppGlobalConfig.trackPlaybackReleaseMode.icon(value),
                        AppGlobalConfig.trackPlaybackReleaseMode.translate(value, trans: _trans),
                      ))
                ],
            onSelected: (selection) {
              _trackWrapper.setTracksPlaybackMode(tracksList, selection);
              _uiWrapper.toast(
                  _trans.rowTracksPlaybackModeSetSuccess(
                      rowName, Track.isPlaybackReleaseModeSingle(selection) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
                  icon: AppIcon.trackPlaybackMode);
              Navigator.pop(_context);
            }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackVolume, AppIcon.trackPlaybackVolume, _trans.rowTracksPlaybackVolumeSet,
            itemBuilder: () => [
                  ...AppGlobalConfig.trackPlaybackVolume.values<double>().map((double value) => _uiWrapper.rowPopupMenuItem(
                        value,
                        AppGlobalConfig.trackPlaybackVolume.icon(value),
                        _trans.rowTracksPlaybackVolumeTitleSet(AppGlobalConfig.trackPlaybackVolume.format(value)),
                      ))
                ],
            onSelected: (selection) {
              _trackWrapper.setTracksPlaybackVolume(tracksList, selection);
              _uiWrapper.toast(_trans.rowTracksPlaybackVolumeSuccessSet(rowName, AppGlobalConfig.trackPlaybackVolume.format(selection)),
                  icon: AppIcon.trackPlaybackSpeed);
              Navigator.pop(_context);
            }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackBalance, AppIcon.trackPlaybackBalance, _trans.rowTracksPlaybackBalanceSet,
            itemBuilder: () => [
                  ...AppGlobalConfig.trackPlaybackBalance.values<double>().map((double value) => _uiWrapper.rowPopupMenuItem(
                        value,
                        AppGlobalConfig.trackPlaybackBalance.icon(value),
                        _trans.rowTracksPlaybackBalanceTitleSet(AppGlobalConfig.trackPlaybackBalance.translate(value, trans: _trans)),
                      ))
                ],
            onSelected: (selection) {
              _trackWrapper.setTracksPlaybackBalance(tracksList, selection);
              _uiWrapper.toast(
                  _trans.rowTracksPlaybackBalanceSuccessSet(rowName, AppGlobalConfig.trackPlaybackBalance.translate(selection, trans: _trans)),
                  icon: AppIcon.trackPlaybackBalance);
              Navigator.pop(_context);
            }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackSpeed, AppIcon.trackPlaybackSpeed, _trans.rowTracksPlaybackSpeedSet,
            itemBuilder: () => [
                  ...AppGlobalConfig.trackPlaybackSpeed.values<double>().map((double value) => _uiWrapper.rowPopupMenuItem(
                        value,
                        AppGlobalConfig.trackPlaybackSpeed.icon(value),
                        _trans.rowTracksPlaybackSpeedTitleSet(AppGlobalConfig.trackPlaybackSpeed.format(value)),
                      ))
                ],
            onSelected: (selection) {
              _trackWrapper.setTracksPlaybackSpeed(tracksList, selection);
              _uiWrapper.toast(_trans.rowTracksPlaybackSpeedSuccessSet(rowName, AppGlobalConfig.trackPlaybackSpeed.format(selection)),
                  icon: AppIcon.trackPlaybackSpeed);
              Navigator.pop(_context);
            }),
        const PopupMenuDivider(),
        _uiWrapper.rowPopupMenuItem(
            RowMenuItem.playbackStartAtPositionReset, AppIcon.trackPlaybackStartAtPosition, _trans.rowTracksPlaybackStartAtPositionReset),
        _uiWrapper.rowPopupMenuItem(
            RowMenuItem.playbackEndAtPositionReset, AppIcon.trackPlaybackEndAtPosition, _trans.rowTracksPlaybackEndAtPositionReset),
        const PopupMenuDivider(),
        _uiWrapper.rowPopupMenuItem(RowMenuItem.recordingsDelete, AppIcon.deleteForever, _trans.rowTracksRecordingsDelete),
      ];

  void _rowMenuItemSelected(
    RowMenuItem selection,
    String rowName,
    Set<Track> tracksList,
  ) {
    switch (selection) {
      case RowMenuItem.playbackStartAtPositionReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackPlaybackStartAtPosition,
          _trans.rowTracksPlaybackStartAtPositionResetTitle,
          _trans.rowTracksPlaybackStartAtPositionResetInfo(rowName),
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksPlaybackStartAtPosition(tracksList);
            return _trans.rowTracksPlaybackStartAtPositionResetSuccess(rowName);
          },
        );
        break;
      case RowMenuItem.playbackEndAtPositionReset:
        _uiWrapper.alertDialogReset(
          AppIcon.trackPlaybackEndAtPosition,
          _trans.rowTracksPlaybackEndAtPositionResetTitle,
          _trans.rowTracksPlaybackEndAtPositionResetInfo(rowName),
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.resetTracksPlaybackEndAtPosition(tracksList);
            return _trans.rowTracksPlaybackEndAtPositionResetSuccess(rowName);
          },
        );
        break;
      case RowMenuItem.recordingsDelete:
        _uiWrapper.alertDialog(AppIcon.deleteForever, _trans.rowTracksRecordingsDeleteTitle,
            contentText: _trans.rowTracksRecordingsDeleteInfo(rowName),
            actions: <Widget>[
              _uiWrapper.simpleButton(_trans.buttonNo, () {
                Navigator.pop(_context, 'No');
              }),
              _uiWrapper.errorButton(_trans.buttonYes, () {
                _trackWrapper.removeTracksRecordings(tracksList);
                Navigator.pop(_context, 'Yes');
                _uiWrapper.toast(_trans.rowTracksRecordingsDeleteSuccess(rowName), icon: AppIcon.deleteForever);
              }),
            ]);
        break;
      default:
    }
  }
}
