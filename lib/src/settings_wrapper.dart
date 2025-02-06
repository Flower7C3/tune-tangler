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
  final AppLocalizations _trans;
  final UIWrapper _uiWrapper;
  final TrackWrapper _trackWrapper;
  BuildContext context;
  final HomeScreen widget;
  Map<Permission, PermissionStatus> permissionStatuses;

  SettingsWrapper(this._trans, this._uiWrapper, this._trackWrapper, this.context, this.widget, this.permissionStatuses);

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
                  widget.settingsGet(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled,
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
            // ExpansionTile(
            //   leading: Icon(AppIcon.trackSettings),
            //   title: Text(_trans.track),
            //   childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
            //   children: trackSettings(setDrawerState),
            // ),
            ExpansionTile(
              leading: Icon(AppIcon.displaySettings),
              title: Text(_trans.screen),
              childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
              children: displaySettings(setDrawerState),
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
                      widget.settingsSet(AppConfigFieldKey.recordingInputDevice, inputDevice, updateState: true);
                      Navigator.pop(context, 'recordingInputDevice');
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
        _uiWrapper.settingsTileDivider(),
        _uiWrapper.listTileReset(
          AppIcon.resetAllSettings,
          _trans.recordingSettingsReset,
          _trans.recordingSettingsResetTitle,
          _trans.recordingSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            for (AppRecordingConfigField field in AppGlobalConfigFieldsCollection.listRecording) {
              widget.settingsSet(field.key, field.defaultValue, updateState: true);
            }
            return _trans.recordingSettingsResetSuccess;
          },
        ),
        ExpansionTile(
          leading: Icon(AppIcon.permissions),
          title: Text(_trans.permissions),
          childrenPadding: EdgeInsets.only(left: _uiWrapper.gridGap * 3),
          children: permissions(setDrawerState),
        ),
      ];

  List<PopupMenuEntry<String>> get trackSettingsMenu => [
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackModeSet, AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackVolumeSet, AppIcon.trackPlaybackVolume, _trans.allTracksPlaybackVolumeSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackBalanceSet, AppIcon.trackPlaybackBalance, _trans.allTracksPlaybackBalanceSet),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.playbackSpeedSet, AppIcon.trackPlaybackSpeed, _trans.allTracksPlaybackSpeedSet),
        const PopupMenuDivider(),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.titleReset, AppIcon.trackTitle, _trans.allTracksTitleReset),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.shortcutKeyReset, AppIcon.trackKeyboardKey, _trans.allTracksShortcutKeyReset),
        const PopupMenuDivider(),
        _uiWrapper.topTrackMenuItem(AllTracksMenuItem.recordingsDelete, AppIcon.deleteForever, _trans.allTracksRecordingsDelete),
      ];

  void trackSettingsMenuItemSelected(AllTracksMenuItem selection) async {
    switch (selection) {
      case AllTracksMenuItem.playbackModeSet:
        _uiWrapper
            .listDialog(AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeTitleSet, contentText: _trans.allTracksPlaybackModeInfoSet, actions: [
          SimpleDialogOption(
              padding: EdgeInsets.zero,
              child: _uiWrapper.statusIconTile(AppIcon.trackSinglePlaybackMode, _trans.singlePlaybackMode),
              onPressed: () {
                _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), true);
                _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.singlePlaybackMode), icon: AppIcon.trackSinglePlaybackMode);
                Navigator.pop(context, _trans.singlePlaybackMode);
              }),
          SimpleDialogOption(
              padding: EdgeInsets.zero,
              child: _uiWrapper.statusIconTile(AppIcon.trackRepeatPlaybackMode, _trans.repeatPlaybackMode),
              onPressed: () {
                _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), false);
                _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.repeatPlaybackMode), icon: AppIcon.trackRepeatPlaybackMode);
                Navigator.pop(context, _trans.repeatPlaybackMode);
              }),
        ]);
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
            _trackWrapper.setTracksPlaybackBalance(widget.tracksList.all(), value);
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
            _trackWrapper.setTracksPlaybackVolume(widget.tracksList.all(), value);
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
            _trackWrapper.setTracksPlaybackSpeed(widget.tracksList.all(), value);
            return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
          },
          configCollection: AppGlobalConfig.trackPlaybackSpeed,
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
            _trackWrapper.resetTracksName(widget.tracksList.all());
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
            _trackWrapper.resetTracksKeyboardKey(widget.tracksList.all());
            return _trans.allTracksShortcutKeyResetSuccess;
          },
        );
        break;
      case AllTracksMenuItem.recordingsDelete:
        _uiWrapper.alertDialogReset(
          AppIcon.deleteForever,
          _trans.allTracksRecordingsDeleteTitle,
          _trans.allTracksRecordingsDeleteInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackWrapper.removeTracksRecordings(widget.tracksList.all());
            return _trans.allTracksRecordingsDeleteSuccess;
          },
        );
        break;
    }
  }

  // List<Widget> trackSettings(StateSetter setDrawerState) => [
  //       _uiWrapper.listTileReset(
  //         AppIcon.trackTitle,
  //         _trans.allTracksTitleReset,
  //         _trans.allTracksTitleResetTitle,
  //         _trans.allTracksTitleResetInfo,
  //         _trans.buttonNo,
  //         _trans.buttonYes,
  //         () {
  //           _trackWrapper.resetTracksName(widget.tracksList.all());
  //           return _trans.allTracksTitleResetSuccess;
  //         },
  //       ),
  //       _uiWrapper.listTileReset(
  //         AppIcon.trackKeyboardKey,
  //         _trans.allTracksShortcutKeyReset,
  //         _trans.allTracksShortcutKeyResetTitle,
  //         _trans.allTracksShortcutKeyResetInfo,
  //         _trans.buttonNo,
  //         _trans.buttonYes,
  //         () {
  //           _trackWrapper.resetTracksKeyboardKey(widget.tracksList.all());
  //           return _trans.allTracksShortcutKeyResetSuccess;
  //         },
  //       ),
  //       ListTile(
  //           leading: Icon(AppIcon.trackPlaybackMode),
  //           title: Text(_trans.allTracksPlaybackModeSet),
  //           onTap: () {
  //             var options = <Widget>[];
  //             options.add(SimpleDialogOption(
  //                 padding: EdgeInsets.all(16),
  //                 child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [Icon(AppIcon.trackSinglePlaybackMode, size: 16), Text(' '), Text(_trans.singlePlaybackMode)]),
  //                 onPressed: () {
  //                   _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), true);
  //                   // _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.singlePlaybackMode), icon: AppIcon.trackSinglePlaybackMode);
  //                   Navigator.pop(context, _trans.singlePlaybackMode);
  //                 }));
  //             options.add(SimpleDialogOption(
  //                 padding: EdgeInsets.all(16),
  //                 child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [Icon(AppIcon.trackRepeatPlaybackMode, size: 16), Text(' '), Text(_trans.repeatPlaybackMode)]),
  //                 onPressed: () {
  //                   _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), false);
  //                   // _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.repeatPlaybackMode), icon: AppIcon.trackRepeatPlaybackMode);
  //                   Navigator.pop(context, _trans.repeatPlaybackMode);
  //                 }));
  //             _uiWrapper.listDialog(AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeTitleSet,
  //                 contentText: _trans.allTracksPlaybackModeInfoSet, actions: options.toList());
  //           }),
  //       _uiWrapper.listTileSlider(
  //         AppIcon.trackPlaybackVolume,
  //         _trans.allTracksPlaybackVolumeSet,
  //         _trans.allTracksPlaybackVolumeTitleSet,
  //         _trans.allTracksPlaybackVolumeInfoSet,
  //         AppGlobalConfig.trackPlaybackVolume.defaultValue,
  //         AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
  //         AppGlobalConfig.trackPlaybackVolume.sliderValues.max,
  //         AppGlobalConfig.trackPlaybackVolume.sliderValues.divisions,
  //         _trans.buttonCancel,
  //         _trans.buttonSave,
  //         withTrailing: false,
  //         successAction: (double value, String formattedValue) {
  //           _trackWrapper.setTracksPlaybackVolume(widget.tracksList.all(), value);
  //           return _trans.allTracksPlaybackVolumeSuccessSet(formattedValue);
  //         },
  //         // configCollection: AppGlobalConfig.trackPlaybackVolumeSliderValues,
  //       ),
  //       _uiWrapper.listTileSlider(
  //         AppIcon.trackPlaybackBalance,
  //         _trans.allTracksPlaybackBalanceSet,
  //         _trans.allTracksPlaybackBalanceTitleSet,
  //         _trans.allTracksPlaybackBalanceInfoSet,
  //         AppGlobalConfig.trackPlaybackBalance.defaultValue,
  //         AppGlobalConfig.trackPlaybackBalance.sliderValues.min,
  //         AppGlobalConfig.trackPlaybackBalance.sliderValues.max,
  //         AppGlobalConfig.trackPlaybackBalance.sliderValues.divisions,
  //         _trans.buttonCancel,
  //         _trans.buttonSave,
  //         successAction: (double value, String formattedValue) {
  //           _trackWrapper.setTracksPlaybackBalance(widget.tracksList.all(), value);
  //           return _trans.allTracksPlaybackBalanceSuccessSet(AppGlobalConfig.trackPlaybackBalance.translate(value, trans: _trans));
  //         },
  //         withTrailing: false,
  //         // configCollection: AppGlobalConfig.trackPlaybackBalanceSliderValues,
  //         trans: _trans,
  //       ),
  //       _uiWrapper.listTileSlider(
  //         AppIcon.trackPlaybackSpeed,
  //         _trans.allTracksPlaybackSpeedSet,
  //         _trans.allTracksPlaybackSpeedTitleSet,
  //         _trans.allTracksPlaybackSpeedInfoSet,
  //         AppGlobalConfig.trackPlaybackSpeed.defaultValue,
  //         AppGlobalConfig.trackPlaybackSpeed.sliderValues.min,
  //         AppGlobalConfig.trackPlaybackSpeed.sliderValues.max,
  //         AppGlobalConfig.trackPlaybackSpeed.sliderValues.divisions,
  //         _trans.buttonCancel,
  //         _trans.buttonSave,
  //         withTrailing: false,
  //         successAction: (double value, String formattedValue) {
  //           _trackWrapper.setTracksPlaybackSpeed(widget.tracksList.all(), value);
  //           return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
  //         },
  //         // configCollection: AppGlobalConfig.trackPlaybackSpeedSliderValues,
  //       ),
  //       _uiWrapper.settingsTileDivider(),
  //       _uiWrapper.listTileReset(AppIcon.deleteForever, _trans.allTracksRecordingsDelete, _trans.allTracksRecordingsDeleteTitle,
  //           _trans.allTracksRecordingsDeleteInfo, _trans.buttonNo, _trans.buttonYes, () {
  //         _trackWrapper.removeTracksRecordings(widget.tracksList.all());
  //         return _trans.allTracksRecordingsDeleteSuccess;
  //       }),
  //     ];

  List<Widget> displaySettings(StateSetter setDrawerState) => [
        _uiWrapper.listTileListDialog(
          AppIcon.language,
          _trans.languageVersion,
          dialogTitle: _trans.changeLanguage,
          currentValue: widget.settingsGet(AppConfigFieldKey.locale).toLanguageTag(),
          options: AppGlobalConfig.languages
              .values<Locale>()
              .map((Locale locale) => SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    child: _uiWrapper.statusTextTile(
                        locale.toLanguageTag(),
                        AppGlobalConfig.languages.text(
                          locale,
                        ),
                        iconColor: Theme.of(context).colorScheme.inversePrimary),
                    onPressed: () {
                      Navigator.pop(context, locale);
                      widget.settingsSet(AppConfigFieldKey.locale, locale, updateState: true);
                    },
                  ))
              .toList(),
        ),
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
          //_trans.screenThemeColorInfo,
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
        _uiWrapper.listTileSlider(
          AppIcon.gridRowsAmount,
          _trans.gridRowsAmount,
          _trans.gridRowsAmountTitle,
          _trans.gridRowsAmountInfo,
          double.parse(widget.settingsGet(AppConfigFieldKey.gridRowsAmount).toString()),
          AppGlobalConfig.gridRows.sliderValues.min,
          AppGlobalConfig.gridRows.sliderValues.max,
          AppGlobalConfig.gridRows.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.gridRowsAmount, value.toInt(), updateState: true);
            return _trans.gridRowsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridRows,
        ),
        _uiWrapper.listTileSlider(
          AppIcon.gridColsAmount,
          _trans.gridColsAmount,
          _trans.gridColsAmountTitle,
          _trans.gridColsAmountInfo,
          double.parse(widget.settingsGet(AppConfigFieldKey.gridColsAmount).toString()),
          AppGlobalConfig.gridCols.sliderValues.min,
          AppGlobalConfig.gridCols.sliderValues.max,
          AppGlobalConfig.gridCols.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.gridColsAmount, value.toInt(), updateState: true);
            return _trans.gridColsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridCols,
        ),
        _uiWrapper.settingsTileDivider(),
        _uiWrapper.listTileReset(AppIcon.resetAllSettings, _trans.screenSettingsReset, _trans.screenSettingsResetTitle,
            _trans.screenSettingsResetInfo, _trans.buttonNo, _trans.buttonYes, () {
          for (AppGlobalConfigField field in AppGlobalConfigFieldsCollection.listGlobal) {
            widget.settingsSet(field.key, field.defaultValue, updateState: true);
          }
          return _trans.screenSettingsResetSuccess;
        }),
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
                  ? Icon(AppIcon.yes, color: Theme.of(context).colorScheme.primary)
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
    double fontSize = Theme.of(context).textTheme.titleMedium!.fontSize!;
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
          title: Text(_trans.recordingAudioEncoder),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.helpScreenRecordingCodecsInfoContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenRecordingCodecsChooseTitle),
          childrenPadding: EdgeInsets.all(_uiWrapper.gridGap),
          children: [
            Text(_trans.helpScreenRecordingCodecsChooseContent),
          ],
        ),
      ],
      applicationIcon:
          Icon(widget.settingsGet(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
      applicationLegalese: _trans.legalNote,
    );
  }
}
