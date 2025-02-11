import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/config_collection.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';
import 'package:tune_tangler/wrapper/settings_wrapper.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../entity/track.dart';

class DrawerManager {
  final BuildContext _context;
  final SettingsWrapper _settings;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  final AudioRecorder _audioRecorder;

  DrawerManager(
    this._context,
    this._settings,
    this._trans,
    this._uiHelper,
    this._trackRepository,
    this._audioRecorder,
  );

  Widget get build => StatefulBuilder(
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
                  _settings.get(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled,
                  size: Theme.of(context).textTheme.displayLarge!.fontSize! * _uiHelper.iconSizeMultiplier,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.recordingSettings),
              title: Text(_trans.recording),
              initiallyExpanded: true,
              childrenPadding: EdgeInsets.only(left: _uiHelper.gridGap * 3),
              children: _recordingSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.screenSettings),
              title: Text(_trans.screen),
              childrenPadding: EdgeInsets.only(left: _uiHelper.gridGap * 3),
              children: _screenSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.permissions),
              title: Text(_trans.permissions),
              childrenPadding: EdgeInsets.only(left: _uiHelper.gridGap * 3),
              children: _permissionsList(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.dangerZone),
              title: Text(_trans.dangerZone),
              childrenPadding: EdgeInsets.only(left: _uiHelper.gridGap * 3),
              children: _dangerZone,
            ),
            ListTile(
              leading: Icon(AppIcon.help),
              title: Text(_trans.help),
              onTap: _helpDialog,
            ),
          ])));

  List<Widget> _recordingSettings(StateSetter setDrawerState) => [
        ListTile(
          leading: Icon(AppIcon.recordingInputDevice),
          title: Text(_trans.recordingInputDevice),
          subtitle: Text(
            _settings.get(AppConfigFieldKey.recordingInputDevice) != null
                ? _settings.get(AppConfigFieldKey.recordingInputDevice).label
                : _trans.defaultDevice,
          ),
          onTap: () async {
            var options = <Widget>[];
            options.add(SimpleDialogOption(
                padding: EdgeInsets.all(16),
                onPressed: () {
                  Navigator.pop(_context, 'recordingInputDevice');
                  _settings.set(AppConfigFieldKey.recordingInputDevice, null, updateState: true);
                },
                child: Text(_trans.defaultDevice)));
            await _audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
              for (var inputDevice in inputDevices) {
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      _settings.set(AppConfigFieldKey.recordingInputDevice, inputDevice, updateState: true);
                      Navigator.pop(_context, 'recordingInputDevice');
                    },
                    child: Text(_trans.recordingInputDeviceValue(inputDevice.label))));
              }
            });
            _uiHelper.listDialog(AppIcon.recordingInputDevice, _trans.recordingInputDeviceTitle,
                contentText: _trans.recordingInputDeviceInfo, actions: options.toList());
          },
        ),
        _uiHelper.listTileButtons(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          _settings.get(AppConfigFieldKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoder.values().toList(),
          helpWidgets: AppGlobalConfig.recordingAudioEncoder
              .values()
              .map((value) => Text(
                    '${AppGlobalConfig.recordingAudioEncoder.format(value)}: ${AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.info)}',
                    style: Theme.of(_context).textTheme.labelMedium,
                  ))
              .toList(),
          configCollection: AppGlobalConfig.recordingAudioEncoder,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _settings.set(
              AppConfigFieldKey.recordingAudioEncoder,
              value,
              updateState: true,
            );
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileButtons(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          _settings.get(AppConfigFieldKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRate.values().toList(),
          helpMessage: _trans.recordingSampleRateInfo,
          configCollection: AppGlobalConfig.recordingSampleRate,
          successAction: (dynamic value, String formattedValue) {
            _settings.set(AppConfigFieldKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileButtons(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _settings.get(AppConfigFieldKey.recordingBitRate),
          AppGlobalConfig.recordingBitRate.values().toList(),
          helpMessage: _trans.recordingBitRateInfo,
          configCollection: AppGlobalConfig.recordingBitRate,
          successAction: (dynamic value, String formattedValue) {
            _settings.set(AppConfigFieldKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          disabledIcon: AppIcon.recordingAudioModeMono,
          enabledIcon: AppIcon.recordingAudioModeStereo,
          switchValue: _settings.get(AppConfigFieldKey.recordingAudioModeStereo),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.recordingAudioModeStereo, value, updateState: true);
            return _trans.recordingAudioModeSuccess(value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingAudioGain,
          _trans.recordingAutoGain,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.get(AppConfigFieldKey.recordingAutoGain),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.recordingAutoGain, value, updateState: true);
            return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingEchoCancel,
          _trans.recordingEchoCancel,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.get(AppConfigFieldKey.recordingEchoCancel),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.recordingEchoCancel, value, updateState: true);
            return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingNoiseSuppress,
          _trans.recordingNoiseSuppress,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.get(AppConfigFieldKey.recordingNoiseSuppress),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.recordingNoiseSuppress, value, updateState: true);
            return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
          },
        ),
      ];

  List<Widget> _screenSettings(StateSetter setDrawerState) => [
        _uiHelper.listTileListDialog(
          AppIcon.language,
          _trans.languageVersion,
          listSubtitle: AppGlobalConfig.languages.text(_settings.get(AppConfigFieldKey.locale)),
          dialogTitle: _trans.changeLanguage,
          currentValue: _settings.get(AppConfigFieldKey.locale).toLanguageTag(),
          options: AppGlobalConfig.languages
              .values<Locale>()
              .map((Locale locale) => SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    child: _uiHelper.statusTextTile(
                        locale.toLanguageTag(),
                        AppGlobalConfig.languages.text(
                          locale,
                        ),
                        iconColor: Theme.of(_context).colorScheme.inversePrimary),
                    onPressed: () {
                      Navigator.pop(_context, locale);
                      _settings.set(AppConfigFieldKey.locale, locale, updateState: true);
                    },
                  ))
              .toList(),
        ),
        _uiHelper.listTileSwitch(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          disabledIcon: AppIcon.screenLightThemeMode,
          enabledIcon: AppIcon.screenDarkThemeMode,
          switchValue: _settings.get(AppConfigFieldKey.isThemeModeDark),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
            return null;
          },
        ),
        _uiHelper.listTileColorPicker(
          AppIcon.screenThemeColor,
          _trans.screenThemeColor,
          listSubtitle: AppGlobalConfig.userInterfaceColor.translate(_settings.get(AppConfigFieldKey.themeSeedColor), trans: _trans),
          dialogTitle: _trans.screenThemeColorTitle,
          dialogInfo: _trans.screenThemeColorInfo,
          currentValue: _settings.get(AppConfigFieldKey.themeSeedColor),
          values: AppGlobalConfig.userInterfaceColor.values<Color>().toList(),
          configCollection: AppGlobalConfig.userInterfaceColor,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _settings.set(AppConfigFieldKey.themeSeedColor, value, updateState: true);
            return _trans.screenThemeColorSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.keepScreenOn,
          _trans.keepScreenOn,
          disabledIcon: AppIcon.keepScreenOnDisabled,
          enabledIcon: AppIcon.keepScreenOnEnabled,
          switchValue: _settings.get(AppConfigFieldKey.wakelockEnabled),
          successAction: (bool value) {
            _settings.set(AppConfigFieldKey.wakelockEnabled, value, updateState: true);
            return value ? _trans.keepScreenOnIsDisabledSuccess : _trans.keepScreenOnIsEnabledSuccess;
          },
        ),
        _uiHelper.listTileSlider(
          AppIcon.gridRowsAmount,
          _trans.gridRowsAmount,
          _trans.gridRowsAmountTitle,
          _trans.gridRowsAmountInfo,
          double.parse(_settings.get(AppConfigFieldKey.gridRowsAmount).toString()),
          AppGlobalConfig.gridRows.sliderValues.min,
          AppGlobalConfig.gridRows.sliderValues.max,
          AppGlobalConfig.gridRows.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _settings.set(AppConfigFieldKey.gridRowsAmount, value.toInt(), updateState: true);
            _trackRepository.resetTracksCollection();
            return _trans.gridRowsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridRows,
        ),
        _uiHelper.listTileSlider(
          AppIcon.gridColsAmount,
          _trans.gridColsAmount,
          _trans.gridColsAmountTitle,
          _trans.gridColsAmountInfo,
          double.parse(_settings.get(AppConfigFieldKey.gridColsAmount).toString()),
          AppGlobalConfig.gridCols.sliderValues.min,
          AppGlobalConfig.gridCols.sliderValues.max,
          AppGlobalConfig.gridCols.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _settings.set(AppConfigFieldKey.gridColsAmount, value.toInt(), updateState: true);
            _trackRepository.resetTracksCollection();
            return _trans.gridColsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridCols,
        ),
      ];

  List<Widget> _permissionsList(StateSetter setDrawerState) => [
        ...AppGlobalConfig.permissions.values<Permission>().map(
          (Permission permission) {
            final status = _settings.permissions[permission] ?? PermissionStatus.denied;
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
                          _settings.permissions[permission] = status;
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

  Future<void> _helpDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _uiHelper.aboutDialog(
      packageInfo,
      [
        ExpansionTile(
          title: Text(_trans.helpScreenMessageAboutTitle),
          children: [
            Text(_trans.helpScreenMessageAboutContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenMessageUsageTitle),
          children: [
            Text(_trans.helpScreenMessageUsageContent),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.helpScreenMessageTrackActions),
          children: [
            _uiHelper.helpTrackState(TrackState.empty, _trans.stateEmpty),
            _uiHelper.helpTrackState(TrackState.recording, _trans.stateRecording),
            _uiHelper.helpTrackState(TrackState.processing, _trans.stateProcessing),
            _uiHelper.helpTrackState(TrackState.idle, _trans.stateIdle),
            _uiHelper.helpTrackState(TrackState.playing, _trans.statePlaying),
            _uiHelper.helpTrackState(TrackState.paused, _trans.statePaused),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackVolume, _trans.thePlaybackVolume.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackSinglePlaybackMode, _trans.singlePlaybackMode.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackRepeatPlaybackMode, _trans.repeatPlaybackMode.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceLeft, _trans.thePlaybackBalanceAt(_trans.balanceLeft).toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceCenter, _trans.thePlaybackBalanceAt(_trans.balanceCenter).toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceRight, _trans.thePlaybackBalanceAt(_trans.balanceRight).toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackAudioSourceRecorded, _trans.theAudioSourceRecorded.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackAudioSourceImported, _trans.theAudioSourceImported.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackStartAtPosition, _trans.thePlaybackStartAtPosition.toLowerCase()),
            _uiHelper.statusIconTile(AppIcon.trackPlaybackEndAtPosition, _trans.thePlaybackEndAtPosition.toLowerCase()),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.recordingSettings),
          children: [
            ListTile(
              leading: Icon(AppIcon.recordingAudioGain),
              title: Text(_trans.recordingAutoGain),
              subtitle: Text(_trans.recordingAutoGainInfo),
            ),
            ListTile(
              leading: Icon(AppIcon.recordingEchoCancel),
              title: Text(_trans.recordingEchoCancel),
              subtitle: Text(_trans.recordingEchoCancelInfo),
            ),
            ListTile(
              leading: Icon(AppIcon.recordingNoiseSuppress),
              title: Text(_trans.recordingNoiseSuppress),
              subtitle: Text(_trans.recordingNoiseSuppressInfo),
            ),
          ],
        ),
        ExpansionTile(
          title: Text(_trans.recordingAudioEncoders),
          children: AppGlobalConfig.recordingAudioEncoder
              .values()
              .map((value) => ExpansionTile(
                    leading: Text(AppGlobalConfig.recordingAudioEncoder.text(value, domain: ConfigItemPropertyDomain.icon)),
                    title: Text(AppGlobalConfig.recordingAudioEncoder.format(value)),
                    subtitle: Text(AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.info)),
                    children: [
                      ListTile(
                        title: Text(
                            AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.defaultProperty)),
                        subtitle:
                            Text(AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.details)),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
      applicationIcon: Icon(_settings.get(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
      applicationLegalese: _trans.legalNote,
    );
  }

  List<Widget> get _dangerZone => [
        _uiHelper.listTileReset(
          AppIcon.recordingSettings,
          _trans.recordingSettingsReset,
          _trans.recordingSettingsResetTitle,
          _trans.recordingSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            for (AppRecordingConfigField field in AppGlobalConfigFieldsCollection.listRecording) {
              _settings.set(field.key, field.defaultValue, updateState: true);
            }
            return _trans.recordingSettingsResetSuccess;
          },
        ),
        _uiHelper.listTileReset(
          AppIcon.screenSettings,
          _trans.screenSettingsReset,
          _trans.screenSettingsResetTitle,
          _trans.screenSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            for (AppGlobalConfigField field in AppGlobalConfigFieldsCollection.listGlobal) {
              _settings.set(field.key, field.defaultValue, updateState: true);
            }
            return _trans.screenSettingsResetSuccess;
          },
        ),
        _uiHelper.listTileReset(
          AppIcon.trackSettings,
          _trans.allTracksSettingsReset,
          _trans.allTracksSettingsResetTitle,
          _trans.allTracksSettingsResetInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.resetTracksSettings(_trackRepository.allTracks());
            return _trans.allTracksSettingsResetSuccess;
          },
        ),
        _uiHelper.listTileReset(
          AppIcon.deleteForever,
          _trans.allTracksRecordingsDelete,
          _trans.allTracksRecordingsDeleteTitle,
          _trans.allTracksRecordingsDeleteInfo,
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.removeTracksRecordings(_trackRepository.allTracks());
            return _trans.allTracksRecordingsDeleteSuccess;
          },
        ),
      ];
}
