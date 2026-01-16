import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/config/config_collection.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';
import 'package:tune_tangler/wrapper/setting_profile_wrapper.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../entity/settings_profile.dart';
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
  late final SettingProfileWrapper _settingsProfileWrapper;

  DrawerManager(
    this._context,
    this._settings,
    this._permissionProvider,
    this._trans,
    this._uiHelper,
    this._trackRepository,
    this._audioRecorder,
  ) {
    _settingsProfileWrapper = SettingProfileWrapper(_context, _trans, _settings, _uiHelper);
  }

  bool showUserDetails = false;
  bool _hasChanges = false;
  static const Key _drawerKey = Key('drawer_key');

  Widget get build => Drawer(
    key: _drawerKey,
    child: RepaintBoundary(
      child: _DrawerContent(drawerManager: this),
    ),
  );

  Widget _buildDrawerContent() => Column(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Align(
        alignment: Alignment.topCenter,
        child: UserAccountsDrawerHeader(
          accountName: Text(
            _uiHelper.getAppTitle(_trans),
            style: TextStyle(
              fontSize: Theme.of(_context).textTheme.headlineMedium?.fontSize,
              color: Theme.of(_context).colorScheme.inversePrimary,
            ),
          ),
          accountEmail: Text(_trans.legalNote, style: TextStyle(color: Theme.of(_context).colorScheme.inversePrimary)),
          currentAccountPicture: Container(
            margin: EdgeInsets.only(bottom: 5),
            padding: EdgeInsets.zero,
            child: AppIcon.appLogo(
              Theme.of(_context).colorScheme.inversePrimary,
              Theme.of(_context).colorScheme.primary,
            ),
          ),
        ),
      ),
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ExpansionTile(
              leading: Icon(AppIcon.recordingSettings),
              title: Text(_trans.recording),
              // initiallyExpanded: true,
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              backgroundColor: Theme.of(_context).colorScheme.primaryContainer,
              textColor: Theme.of(_context).colorScheme.primary,
              iconColor: Theme.of(_context).colorScheme.primary,
              children: _recordingSettings(),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.trackSettings),
              title: Text(_trans.tracks),
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              backgroundColor: Theme.of(_context).colorScheme.primaryContainer,
              textColor: Theme.of(_context).colorScheme.primary,
              iconColor: Theme.of(_context).colorScheme.primary,
              children: _tracksSettings(),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.screenSettings),
              title: Text(_trans.screen),
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              backgroundColor: Theme.of(_context).colorScheme.primaryContainer,
              textColor: Theme.of(_context).colorScheme.primary,
              iconColor: Theme.of(_context).colorScheme.primary,
              children: _screenSettings(),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.permissions),
              title: Text(_trans.permissions),
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              backgroundColor: Theme.of(_context).colorScheme.secondaryContainer,
              textColor: Theme.of(_context).colorScheme.secondary,
              iconColor: Theme.of(_context).colorScheme.secondary,
              children: _permissionsList(),
            ),
            ExpansionTile(
              leading: Icon(AppIcon.dangerZone),
              title: Text(_trans.dangerZone),
              maintainState: true,
              childrenPadding: EdgeInsets.only(left: UIHelper.gridGap * 3),
              backgroundColor: Theme.of(_context).colorScheme.errorContainer,
              textColor: Theme.of(_context).colorScheme.error,
              iconColor: Theme.of(_context).colorScheme.error,
              children: _dangerZone,
            ),
            ListTile(leading: Icon(AppIcon.help), title: Text(_trans.help), onTap: _helpDialog),
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: ListTile(
          leading: Icon(AppIcon.settingsProfiles),
          title: Text(_trans.settingsProfiles),
          subtitle: Text(
            _settings.settingsProfilesList.isEmpty
                ? _trans.settingsProfilesEmpty
                : '${_settings.settingsProfilesList.length} ${_trans.settingsProfile.toLowerCase()}',
            style: TextStyle(fontSize: Theme.of(_context).textTheme.labelSmall!.fontSize),
          ),
          onTap: _settingsProfilesListsDialog,
          trailing: Icon(AppIcon.modalMenu),
        ),
      ),
    ],
  );

  List<Widget> _recordingSettings() => [
    ListTile(
      leading: Icon(AppIcon.recordingInputDevice),
      title: Text(_trans.recordingInputDevice),
      subtitle: Text(
        _settings.getConfig(AppConfigFieldKey.recordingInputDevice) != null
            ? _settings.getConfig(AppConfigFieldKey.recordingInputDevice).label
            : _trans.defaultDevice,
        style: TextStyle(fontSize: Theme.of(_context).textTheme.labelSmall!.fontSize),
      ),
      onTap: _recordingSettingsDialog,
      trailing: Icon(AppIcon.modalMenu),
    ),
    _uiHelper.listTileButtons(
      AppIcon.recordingAudioEncoder,
      _trans.recordingAudioEncoder,
      _settings.getConfig(AppConfigFieldKey.recordingAudioEncoder),
      AppGlobalConfig.recordingAudioEncoder.values().toList(),
      helpWidgets: AppGlobalConfig.recordingAudioEncoder
          .values()
          .map(
            (value) => Text(
              '${AppGlobalConfig.recordingAudioEncoder.format(value)}: ${AppGlobalConfig.recordingAudioEncoder.translate(value, trans: _trans, domain: ConfigItemPropertyDomain.info)}',
              style: Theme.of(_context).textTheme.labelMedium,
            ),
          )
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
      trans: _trans,
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
      trans: _trans,
      successAction: (dynamic value, String formattedValue) {
        _settings.setConfig(AppConfigFieldKey.recordingBitRate, value);
        return _trans.recordingAudioEncoderSuccess(formattedValue);
      },
    ),
    _uiHelper.listTileSwitch(
      AppIcon.recordingAudioMode,
      _trans.recordingAudioMode,
      subtitleText: AppGlobalConfig.recordingAudioMode.translate(
        _settings.getConfig(AppConfigFieldKey.recordingAudioModeStereo),
        trans: _trans,
      ),
      disabledIcon: AppIcon.recordingAudioModeMono,
      enabledIcon: AppIcon.recordingAudioModeStereo,
      switchValue: _settings.getConfig(AppConfigFieldKey.recordingAudioModeStereo),
      successAction: (bool value) {
        _settings.setConfig(AppConfigFieldKey.recordingAudioModeStereo, value);
        return _trans.recordingAudioModeSuccess(
          value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono,
        );
      },
    ),
    _uiHelper.listTileSwitch(
      AppIcon.recordingAutoGain,
      _trans.recordingAutoGain,
      subtitleText: _settings.getConfig(AppConfigFieldKey.recordingAutoGain) ? _trans.yes : _trans.no,
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
      subtitleText: _settings.getConfig(AppConfigFieldKey.recordingEchoCancel) ? _trans.yes : _trans.no,
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
      subtitleText: _settings.getConfig(AppConfigFieldKey.recordingNoiseSuppress) ? _trans.yes : _trans.no,
      disabledIcon: AppIcon.no,
      enabledIcon: AppIcon.yes,
      switchValue: _settings.getConfig(AppConfigFieldKey.recordingNoiseSuppress),
      successAction: (bool value) {
        _settings.setConfig(AppConfigFieldKey.recordingNoiseSuppress, value);
        return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
      },
    ),
  ];

  List<Widget> _tracksSettings() => [
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
        // gridRowsAmount requires full reload after drawer close
        _hasChanges = true;
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
        // gridColsAmount requires full reload after drawer close
        _hasChanges = true;
        _settings.setConfig(AppConfigFieldKey.gridColsAmount, value.toInt());
        _trackRepository.resetTracksCollection();
        return _trans.gridColsAmountSuccess(formattedValue);
      },
      configCollection: AppGlobalConfig.gridCols,
    ),
    Divider(),
    _uiHelper.listTileReset(
      AppIcon.trackName,
      _trans.allTracksTitleReset,
      _trans.allTracksTitleResetTitle,
      _trans.allTracksTitleResetInfo,
      _trans.buttonNo,
      _trans.buttonYes,
      () {
        _trackRepository.resetTracksName(_trackRepository.allTracks());
        return _trans.allTracksTitleResetSuccess;
      },
      subtitleText: '${_trackRepository.allTracks().length} ${_trans.tracks.toLowerCase()}',
    ),
    _uiHelper.listTileReset(
      AppIcon.trackKeyboardKey,
      _trans.allTracksShortcutKeyReset,
      _trans.allTracksShortcutKeyResetTitle,
      _trans.allTracksShortcutKeyResetInfo,
      _trans.buttonNo,
      _trans.buttonYes,
      () {
        _trackRepository.resetTracksKeyboardKey(_trackRepository.allTracks());
        return _trans.allTracksShortcutKeyResetSuccess;
      },
      subtitleText: '${_trackRepository.allTracks().length} ${_trans.tracks.toLowerCase()}',
    ),
  ];

  Future<void> _recordingSettingsDialog() async {
    InputDevice? currentValue = _settings.getConfig(AppConfigFieldKey.recordingInputDevice);
    var options = <Widget>[];
    options.add(
      ListTile(
        title: Text(_trans.defaultDevice),
        selected: currentValue == null,
        onTap: () {
          Navigator.pop(_context, 'recordingInputDevice');
          _settings.setConfig(AppConfigFieldKey.recordingInputDevice, null);
        },
      ),
    );
    await _audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
      for (var inputDevice in inputDevices) {
        options.add(
          ListTile(
            title: Text(_trans.recordingInputDeviceValue(inputDevice.label)),
            selected: currentValue == inputDevice,
            onTap: () {
              _settings.setConfig(AppConfigFieldKey.recordingInputDevice, inputDevice);
              _uiHelper.toast(
                _trans.recordingInputDeviceSuccess(inputDevice.label),
                icon: AppIcon.recordingInputDevice,
                duration: 4,
              );
              Navigator.pop(_context, 'recordingInputDevice');
            },
          ),
        );
      }
    });
    _uiHelper.listDialog(
      AppIcon.recordingInputDevice,
      _trans.recordingInputDeviceTitle,
      contentText: _trans.recordingInputDeviceInfo,
      actions: options.toList(),
    );
  }

  List<Widget> _screenSettings() => [
    _uiHelper.listTileListDialog(
      AppIcon.language,
      _trans.languageVersion,
      listSubtitle: AppGlobalConfig.languages.format(_settings.getConfig(AppConfigFieldKey.locale)),
      dialogTitle: _trans.changeLanguage,
      currentValue: _settings.getConfig(AppConfigFieldKey.locale).toLanguageTag(),
      options: AppGlobalConfig.languages
          .values<Locale>()
          .map(
            (Locale locale) => ListTile(
              title: Text(AppGlobalConfig.languages.format(locale)),
              trailing: Text(locale.toLanguageTag()),
              selected: locale == _settings.getConfig(AppConfigFieldKey.locale),
              onTap: () {
                Navigator.pop(_context, locale);
                _settings.setConfig(AppConfigFieldKey.locale, locale);
              },
            ),
          )
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
        // themeMode only updates drawer, MaterialApp will pick up theme change automatically
        _settings.setConfig(AppConfigFieldKey.themeMode, value);
        return '';
      },
    ),
    _uiHelper.listTileColorPicker(
      AppIcon.screenThemeColor,
      _trans.screenThemeColor,
      listSubtitle: AppGlobalConfig.userInterfaceColor.translate(
        _settings.getConfig(AppConfigFieldKey.themeSeedColor),
        trans: _trans,
      ),
      dialogTitle: _trans.screenThemeColorTitle,
      dialogInfo: _trans.screenThemeColorInfo,
      currentValue: _settings.getConfig(AppConfigFieldKey.themeSeedColor),
      values: AppGlobalConfig.userInterfaceColor.values<Color>().toList(),
      configCollection: AppGlobalConfig.userInterfaceColor,
      trans: _trans,
      successAction: (dynamic value, String formattedValue) {
        // themeSeedColor only updates drawer, MaterialApp will pick up color change automatically
        _settings.setConfig(AppConfigFieldKey.themeSeedColor, value);
        return _trans.screenThemeColorSuccess(formattedValue);
      },
    ),
    _uiHelper.listTileSwitch(
      AppIcon.keepScreenOn,
      _trans.keepScreenOn,
      subtitleText: _settings.getConfig(AppConfigFieldKey.wakelockEnabled) ? _trans.enabled : _trans.disabled,
      disabledIcon: AppIcon.keepScreenOnDisabled,
      enabledIcon: AppIcon.keepScreenOnEnabled,
      switchValue: _settings.getConfig(AppConfigFieldKey.wakelockEnabled),
      successAction: (bool value) {
        _settings.setConfig(AppConfigFieldKey.wakelockEnabled, value);
        return value ? _trans.keepScreenOnIsEnabledSuccess : _trans.keepScreenOnIsDisabledSuccess;
      },
    ),
  ];

  List<Widget> _permissionsList() => [
    ...AppGlobalConfig.permissions.values<Permission>().map((Permission permission) {
      final status = _permissionProvider.get(permission) ?? PermissionStatus.denied;
      return ListTile(
        leading: Icon(AppGlobalConfig.permissions.icon(permission)),
        title: Text(AppGlobalConfig.permissions.translate(permission, trans: _trans)),
        subtitle: Text(
          AppGlobalConfig.permissionsStatus.translate(status, trans: _trans),
          style: TextStyle(fontSize: Theme.of(_context).textTheme.labelSmall!.fontSize),
        ),
        selected: status == PermissionStatus.granted,
        trailing: switch (status) {
          PermissionStatus.granted => Icon(AppIcon.yes, color: Theme.of(_context).colorScheme.primary),
          PermissionStatus.denied => ElevatedButton(
            onPressed: () async {
              final status = await permission.request();
              _permissionProvider.set(permission, status);
            },
            child: Text(_trans.grantPermission),
          ),
          _ => ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: Text(_trans.grantPermission),
          ),
        },
      );
    }),
  ];

  Future<void> _settingsProfilesListsDialog() async {
    List<Widget> options = [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_trans.settingsProfilesInfo, style: Theme.of(_context).textTheme.bodyMedium),
      ),
      const Divider(),
    ];
    for (int index = 0; index < _settings.settingsProfilesList.length; index++) {
      var item = _settings.settingsProfilesList[index];
      options.add(
        ListTile(
          title: _settingsProfileWrapper.listTitle(item),
          subtitle: _settingsProfileWrapper.listSubtitle(item),
          trailing: Icon(AppIcon.touchLong),
          onTap: () => _settingsProfileWrapper.load(item),
          onLongPress: () => _settingsProfilesDetailDialog(index, item),
        ),
      );
    }
    if (options.length == 2) {
      // Only info and divider, no profiles
      options.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(_trans.settingsProfilesEmpty, style: TextStyle(fontSize: 14))],
        ),
      );
    }
    options.add(
      TextButton.icon(
        icon: Icon(AppIcon.create),
        label: Text(_trans.settingsProfileCreate),
        onPressed: () {
          _settingsProfileWrapper.create();
          _settingsProfilesListsDialog();
        },
      ),
    );
    _uiHelper.listDialog(AppIcon.settingsProfiles, _trans.settingsProfilesListTitle, actions: options.toList());
  }

  Future<void> _settingsProfilesDetailDialog(int index, SettingsProfile settingsProfile) async {
    _uiHelper.alertDialog(
      AppIcon.settingsProfiles,
      _trans.settingsProfile,
      contentWidget: Column(children: _settingsProfileWrapper.toList(settingsProfile)),
      actions: <Widget>[
        _uiHelper.simpleButton(_trans.buttonCancel, () {
          Navigator.pop(_context, 'Cancel');
        }),
        _uiHelper.errorButton(_trans.settingsProfileDelete, () {
          _settingsProfilesDeleteDialog(index, settingsProfile);
        }),
        _uiHelper.primaryButton(_trans.settingsProfileLoad, () {
          Navigator.pop(_context, 'Load');
          _settingsProfileWrapper.load(settingsProfile);
        }),
      ],
    );
  }

  Future<void> _settingsProfilesDeleteDialog(int index, SettingsProfile settingsProfile) async {
    _uiHelper.alertDialogReset(
      AppIcon.settingsProfiles,
      _trans.settingsProfileDeleteTitle,
      _trans.settingsProfileDeleteInfo,
      _trans.buttonNo,
      _trans.buttonYes,
      () {
        _settingsProfileWrapper.delete(index);
        _settingsProfilesListsDialog();
        return _trans.settingsProfileDeleted;
      },
    );
  }

  Future<void> _helpDialog() async {
    List<Widget> details = [
      ExpansionTile(
        title: Text(_trans.helpScreenMessageAboutTitle),
        children: [Text(_trans.helpScreenMessageAboutContent)],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageGridScreenTitle),
        children: [
          _uiHelper.buildRichText(
            _trans.helpScreenMessageGridScreenContent,
            data: {'controlKey': Icons.keyboard_control_key},
          ),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageDetailsScreenTitle),
        children: [
          _uiHelper.buildRichText(
            _trans.helpScreenMessageDetailsScreenContent,
            data: {
              'recordingClip': AppIcon.recordingClipSlider,
              'trackPlaybackMode': AppIcon.trackPlaybackMode,
              'trackPlaybackVolume': AppIcon.trackPlaybackVolume,
              'trackPlaybackBalance': AppIcon.trackPlaybackBalance,
              'trackPlaybackSpeed': AppIcon.trackPlaybackSpeed,
              'trackName': AppIcon.trackName,
              'trackKeyboardKey': AppIcon.trackKeyboardKey,
              'trackRecordingMove': AppIcon.trackRecordingMove,
              'trackRecordingImport': AppIcon.trackRecordingImport,
              'trackRecordingShare': AppIcon.trackRecordingShare,
              'deleteForever': AppIcon.deleteForever,
            },
          ),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageTrackStates),
        children: [
          _uiHelper.buildRichText(_trans.helpScreenMessageTrackStatesInfo, data: {}),
          _uiHelper.helpTrackState(TrackState.empty, _trans.stateEmpty),
          _uiHelper.helpTrackState(TrackState.recording, _trans.stateRecording),
          _uiHelper.helpTrackState(TrackState.processing, _trans.stateProcessing),
          _uiHelper.helpTrackState(TrackState.idle, _trans.stateIdle),
          _uiHelper.helpTrackState(TrackState.playing, _trans.statePlaying),
          _uiHelper.helpTrackState(TrackState.paused, _trans.statePaused),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageTrackIcons),
        children: [
          _uiHelper.buildRichText(_trans.helpScreenMessageTrackIconsInfo, data: {}),
          _uiHelper.statusWidgetTile(
            AppIcon.trackKeyboardKeyBox(
              'x',
              size: Theme.of(_context).textTheme.titleMedium!.fontSize!,
              backgroundColor: Theme.of(_context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(_context).colorScheme.primary,
            ),
            _trans.theKeyboardKey.toLowerCase(),
          ),
          _uiHelper.statusIconTile(AppIcon.trackAudioSourceRecorded, _trans.theAudioSourceRecorded.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackAudioSourceImported, _trans.theAudioSourceImported.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackVolume, _trans.thePlaybackVolume.toLowerCase()),
          _uiHelper.statusIconTile(
            AppIcon.trackPlaybackBalanceLeft,
            _trans.thePlaybackBalanceAt(_trans.balanceLeft).toLowerCase(),
          ),
          _uiHelper.statusIconTile(
            AppIcon.trackPlaybackBalanceCenter,
            _trans.thePlaybackBalanceAt(_trans.balanceCenter).toLowerCase(),
          ),
          _uiHelper.statusIconTile(
            AppIcon.trackPlaybackBalanceRight,
            _trans.thePlaybackBalanceAt(_trans.balanceRight).toLowerCase(),
          ),
          _uiHelper.statusIconTile(
            AppIcon.trackPlaybackStartAtPosition,
            _trans.thePlaybackStartAtPosition.toLowerCase(),
          ),
          _uiHelper.statusIconTile(AppIcon.trackPlaybackEndAtPosition, _trans.thePlaybackEndAtPosition.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackSinglePlaybackMode, _trans.singlePlaybackMode.toLowerCase()),
          _uiHelper.statusIconTile(AppIcon.trackRepeatPlaybackMode, _trans.repeatPlaybackMode.toLowerCase()),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageProjectExportImportTitle),
        children: [
          _uiHelper.buildRichText(
            _trans.helpScreenMessageProjectExportImportContent,
            data: {'projectExport': AppIcon.projectExport, 'projectImport': AppIcon.projectImport},
          ),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.helpScreenMessageSettingsProfilesTitle),
        children: [
          _uiHelper.buildRichText(
            _trans.helpScreenMessageSettingsProfilesContent,
            data: {
              'settingsProfiles': AppIcon.settingsProfiles,
              'recordingAudioEncoder': AppIcon.recordingAudioEncoder,
              'recordingInputDevice': AppIcon.recordingInputDevice,
              'recordingSampleRate': AppIcon.recordingSampleRate,
              'recordingBitRate': AppIcon.recordingBitRate,
              'recordingAudioMode': AppIcon.recordingAudioMode,
              'recordingAutoGain': AppIcon.recordingAutoGain,
              'recordingEchoCancel': AppIcon.recordingEchoCancel,
              'recordingNoiseSuppress': AppIcon.recordingNoiseSuppress,
              'language': AppIcon.language,
              'screenThemeMode': AppIcon.screenThemeMode,
              'screenThemeColor': AppIcon.screenThemeColor,
              'keepScreenOn': AppIcon.keepScreenOn,
              'touchLong': AppIcon.touchLong,
              'create': AppIcon.create,
              'deleteForever': AppIcon.deleteForever,
            },
          ),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.recordingSettings),
        children: [
          _uiHelper.buildRichText(
            _trans.helpScreenMessageSettingsInfo,
            data: {
              'recordingAudioEncoder': AppIcon.recordingAudioEncoder,
              'recordingSampleRate': AppIcon.recordingSampleRate,
              'recordingBitRate': AppIcon.recordingBitRate,
              'recordingAudioMode': AppIcon.recordingAudioMode,
              'recordingAutoGain': AppIcon.recordingAutoGain,
              'recordingEchoCancel': AppIcon.recordingEchoCancel,
              'recordingNoiseSuppress': AppIcon.recordingNoiseSuppress,
            },
          ),
          ListTile(leading: Icon(AppIcon.recordingAutoGain), title: Text(_trans.recordingAutoGain)),
          Text(_trans.recordingAutoGainInfo),
          ListTile(leading: Icon(AppIcon.recordingEchoCancel), title: Text(_trans.recordingEchoCancel)),
          Text(_trans.recordingEchoCancelInfo),
          ListTile(leading: Icon(AppIcon.recordingNoiseSuppress), title: Text(_trans.recordingNoiseSuppress)),
          Text(_trans.recordingNoiseSuppressInfo),
        ],
      ),
      ExpansionTile(
        title: Text(_trans.recordingAudioEncoders),
        children: AppGlobalConfig.recordingAudioEncoder
            .values()
            .map(
              (value) => ExpansionTile(
                leading: Text(AppGlobalConfig.recordingAudioEncoder.text(value, domain: ConfigItemPropertyDomain.icon)),
                title: Text(AppGlobalConfig.recordingAudioEncoder.format(value)),
                subtitle: Text(
                  AppGlobalConfig.recordingAudioEncoder.translate(
                    value,
                    trans: _trans,
                    domain: ConfigItemPropertyDomain.info,
                  ),
                ),
                children: [
                  ListTile(
                    title: Text(
                      AppGlobalConfig.recordingAudioEncoder.translate(
                        value,
                        trans: _trans,
                        domain: ConfigItemPropertyDomain.defaultProperty,
                      ),
                    ),
                    subtitle: Text(
                      AppGlobalConfig.recordingAudioEncoder.translate(
                        value,
                        trans: _trans,
                        domain: ConfigItemPropertyDomain.details,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ];
    Widget icon = SizedBox(
      width: Theme.of(_context).textTheme.displayLarge!.fontSize,
      height: Theme.of(_context).textTheme.displayLarge!.fontSize,
      child: AppIcon.appLogo(
        Theme.of(_context).colorScheme.primary,
        Theme.of(_context).colorScheme.surfaceContainerHigh,
      ),
    );
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _uiHelper.aboutDialog(packageInfo, details, applicationIcon: icon, applicationLegalese: _trans.legalNote);
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
        for (AppRecordingConfigField field in AppConfigFieldsCollection.recordingList) {
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
        for (AppScreenConfigField field in AppConfigFieldsCollection.screenList) {
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
        for (AppProjectConfigField field in AppConfigFieldsCollection.projectList) {
          _settings.setConfig(field.key, field.defaultValue);
        }
        return _trans.allTracksSettingsResetSuccess;
      },
    ),
    _uiHelper.listTileReset(
      AppIcon.deleteRecordings,
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

class _DrawerContent extends StatefulWidget {
  final DrawerManager drawerManager;

  const _DrawerContent({required this.drawerManager});

  @override
  State<_DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<_DrawerContent> {
  bool _wasDrawerOpen = true;

  @override
  void initState() {
    super.initState();
    // Add listener to update drawer when settings change
    widget.drawerManager._settings.addListener(_onSettingsChanged);
    // Monitor drawer state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitorDrawerState();
    });
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.drawerManager._settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _monitorDrawerState() {
    if (!mounted) return;
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null) {
      final isDrawerOpen = scaffoldState.isDrawerOpen;
      if (_wasDrawerOpen && !isDrawerOpen && widget.drawerManager._hasChanges) {
        // Drawer was closed, trigger reload if there were changes
        widget.drawerManager._hasChanges = false;
        widget.drawerManager._settings.reload();
      }
      _wasDrawerOpen = isDrawerOpen;
      // Continue monitoring
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _monitorDrawerState();
        }
      });
    }
  }

  void _onSettingsChanged() {
    if (mounted) {
      // Check if drawer is still open before rebuilding
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null && scaffoldState.isDrawerOpen) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild drawer when locale changes by using Localizations.localeOf
    // This ensures drawer updates when language changes
    Localizations.localeOf(context);
    return widget.drawerManager._buildDrawerContent();
  }
}
