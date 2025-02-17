import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/config_collection.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../entity/track.dart';
import '../provider/permission_provider.dart';
import '../src/generated/app_localizations.dart';

class DrawerManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final PermissionProvider _permissionProvider;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  final AudioRecorder _audioRecorder;

  DrawerManager(this._context, this._settings, this._permissionProvider, this._trans, this._uiHelper, this._trackRepository, this._audioRecorder);

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
                  _settings.getConfig(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled,
                  size: Theme.of(context).textTheme.displayLarge!.fontSize! * UIHelper.iconSizeMultiplier,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.recordingSettings),
              title: Text(_trans.recording),
              // initiallyExpanded: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              children: _recordingSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.screenSettings),
              title: Text(_trans.screen),
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              children: _screenSettings(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.permissions),
              title: Text(_trans.permissions),
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              children: _permissionsList(setDrawerState),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.dangerZone),
              title: Text(_trans.dangerZone),
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
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
            _settings.getConfig(AppConfigFieldKey.recordingInputDevice) != null
                ? _settings.getConfig(AppConfigFieldKey.recordingInputDevice).label
                : _trans.defaultDevice,
          ),
          onTap: () async {
            var options = <Widget>[];
            options.add(SimpleDialogOption(
                padding: EdgeInsets.all(16),
                onPressed: () {
                  Navigator.pop(_context, 'recordingInputDevice');
                  _settings.setConfig(AppConfigFieldKey.recordingInputDevice, null);
                },
                child: Text(_trans.defaultDevice)));
            await _audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
              for (var inputDevice in inputDevices) {
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      _settings.setConfig(AppConfigFieldKey.recordingInputDevice, inputDevice);
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
          _settings.getConfig(AppConfigFieldKey.recordingAudioEncoder),
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
            _settings.setConfig(AppConfigFieldKey.recordingAudioEncoder, value);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileButtons(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          _settings.getConfig(AppConfigFieldKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRate.values().toList(),
          helpMessage: _trans.recordingSampleRateInfo,
          configCollection: AppGlobalConfig.recordingSampleRate,
          successAction: (dynamic value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.recordingSampleRate, value);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileButtons(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _settings.getConfig(AppConfigFieldKey.recordingBitRate),
          AppGlobalConfig.recordingBitRate.values().toList(),
          helpMessage: _trans.recordingBitRateInfo,
          configCollection: AppGlobalConfig.recordingBitRate,
          successAction: (dynamic value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.recordingBitRate, value);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          disabledIcon: AppIcon.recordingAudioModeMono,
          enabledIcon: AppIcon.recordingAudioModeStereo,
          switchValue: _settings.getConfig(AppConfigFieldKey.recordingAudioModeStereo),
          successAction: (bool value) {
            _settings.setConfig(AppConfigFieldKey.recordingAudioModeStereo, value);
            return _trans.recordingAudioModeSuccess(value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingAudioGain,
          _trans.recordingAutoGain,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.getConfig(AppConfigFieldKey.recordingAutoGain),
          successAction: (bool value) {
            _settings.setConfig(AppConfigFieldKey.recordingAutoGain, value);
            return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingEchoCancel,
          _trans.recordingEchoCancel,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.getConfig(AppConfigFieldKey.recordingEchoCancel),
          successAction: (bool value) {
            _settings.setConfig(AppConfigFieldKey.recordingEchoCancel, value);
            return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.recordingNoiseSuppress,
          _trans.recordingNoiseSuppress,
          disabledIcon: AppIcon.no,
          enabledIcon: AppIcon.yes,
          switchValue: _settings.getConfig(AppConfigFieldKey.recordingNoiseSuppress),
          successAction: (bool value) {
            _settings.setConfig(AppConfigFieldKey.recordingNoiseSuppress, value);
            return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
          },
        ),
      ];

  List<Widget> _screenSettings(StateSetter setDrawerState) => [
        _uiHelper.listTileListDialog(
          AppIcon.language,
          _trans.languageVersion,
          listSubtitle: AppGlobalConfig.languages.format(_settings.getConfig(AppConfigFieldKey.locale)),
          dialogTitle: _trans.changeLanguage,
          currentValue: _settings.getConfig(AppConfigFieldKey.locale).toLanguageTag(),
          options: AppGlobalConfig.languages
              .values<Locale>()
              .map((Locale locale) => SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    child: _uiHelper.statusTextTile(locale.toLanguageTag(), AppGlobalConfig.languages.format(locale),
                        iconColor: Theme.of(_context).colorScheme.inversePrimary),
                    onPressed: () {
                      Navigator.pop(_context, locale);
                      _settings.setConfig(AppConfigFieldKey.locale, locale);
                    },
                  ))
              .toList(),
        ),
        _uiHelper.listTileButtons(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          _settings.getConfig(AppConfigFieldKey.themeMode),
          AppGlobalConfig.screenThemeMode.values().toList(),
          trailingValueIcon: true,
          useAvatar: true,
          translateChoiceChip: true,
          configCollection: AppGlobalConfig.screenThemeMode,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.themeMode, value);
            return '';
          },
        ),
        _uiHelper.listTileColorPicker(
          AppIcon.screenThemeColor,
          _trans.screenThemeColor,
          listSubtitle: AppGlobalConfig.userInterfaceColor.translate(_settings.getConfig(AppConfigFieldKey.themeSeedColor), trans: _trans),
          dialogTitle: _trans.screenThemeColorTitle,
          dialogInfo: _trans.screenThemeColorInfo,
          currentValue: _settings.getConfig(AppConfigFieldKey.themeSeedColor),
          values: AppGlobalConfig.userInterfaceColor.values<Color>().toList(),
          configCollection: AppGlobalConfig.userInterfaceColor,
          trans: _trans,
          successAction: (dynamic value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.themeSeedColor, value);
            return _trans.screenThemeColorSuccess(formattedValue);
          },
        ),
        _uiHelper.listTileSwitch(
          AppIcon.keepScreenOn,
          _trans.keepScreenOn,
          disabledIcon: AppIcon.keepScreenOnDisabled,
          enabledIcon: AppIcon.keepScreenOnEnabled,
          switchValue: _settings.getConfig(AppConfigFieldKey.wakelockEnabled),
          successAction: (bool value) {
            _settings.setConfig(AppConfigFieldKey.wakelockEnabled, value);
            return value ? _trans.keepScreenOnIsEnabledSuccess : _trans.keepScreenOnIsDisabledSuccess;
          },
        ),
        _uiHelper.listTileSlider(
          AppIcon.gridRowsAmount,
          _trans.gridRowsAmount,
          _trans.gridRowsAmountTitle,
          _trans.gridRowsAmountInfo,
          double.parse(_settings.getConfig(AppConfigFieldKey.gridRowsAmount).toString()),
          AppGlobalConfig.gridRows.sliderValues.min,
          AppGlobalConfig.gridRows.sliderValues.max,
          AppGlobalConfig.gridRows.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.gridRowsAmount, value.toInt());
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
          double.parse(_settings.getConfig(AppConfigFieldKey.gridColsAmount).toString()),
          AppGlobalConfig.gridCols.sliderValues.min,
          AppGlobalConfig.gridCols.sliderValues.max,
          AppGlobalConfig.gridCols.sliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _settings.setConfig(AppConfigFieldKey.gridColsAmount, value.toInt());
            _trackRepository.resetTracksCollection();
            return _trans.gridColsAmountSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.gridCols,
        ),
      ];

  List<Widget> _permissionsList(StateSetter setDrawerState) => [
        ...AppGlobalConfig.permissions.values<Permission>().map(
          (Permission permission) {
            final status = _permissionProvider.get(permission) ?? PermissionStatus.denied;
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
                          _permissionProvider.set(permission, status);
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
    List<Widget> details = [
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
          _uiHelper.statusWidgetTile(
              AppIcon.trackKeyboardKeyBox('x',
                  size: Theme.of(_context).textTheme.titleMedium!.fontSize!,
                  backgroundColor: Theme.of(_context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(_context).colorScheme.primary),
              _trans.theKeyboardKey.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackAudioSourceRecorded, _trans.theAudioSourceRecorded.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackAudioSourceImported, _trans.theAudioSourceImported.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackVolume, _trans.thePlaybackVolume.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceLeft, _trans.thePlaybackBalanceAt(_trans.balanceLeft).toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceCenter, _trans.thePlaybackBalanceAt(_trans.balanceCenter).toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackBalanceRight, _trans.thePlaybackBalanceAt(_trans.balanceRight).toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackStartAtPosition, _trans.thePlaybackStartAtPosition.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackEndAtPosition, _trans.thePlaybackEndAtPosition.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackSinglePlaybackMode, _trans.singlePlaybackMode.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackRepeatPlaybackMode, _trans.repeatPlaybackMode.toLowerCase()),
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
                      subtitle: Text(AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.details)),
                    ),
                  ],
                ))
            .toList(),
      ),
    ];
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _uiHelper.aboutDialog(
      packageInfo,
      details,
      applicationIcon:
          Icon(_settings.getConfig(AppConfigFieldKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
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
            for (AppRecordingConfigField field in AppConfigFieldsCollection.listRecording) {
              _settings.setConfig(field.key, field.defaultValue);
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
            for (AppScreenConfigField field in AppConfigFieldsCollection.listScreen) {
              _settings.setConfig(field.key, field.defaultValue);
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
            _trackRepository.deleteTracksRecordings(_trackRepository.allTracks());
            return _trans.allTracksRecordingsDeleteSuccess;
          },
        ),
      ];
}
