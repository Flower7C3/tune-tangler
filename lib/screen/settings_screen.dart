import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/screen/screen.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
import '../entity/track_row.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';

class SettingsScreen extends StatefulWidget implements ScreenInterface {
  const SettingsScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
    required this.audioRecorder,
    required this.tracksList,
  });

  @override
  final Function(dynamic key, {AppConfigSpace space, dynamic defaultValue}) settingsGet;
  @override
  final void Function(dynamic key, dynamic value, {AppConfigSpace space, bool updateState}) settingsSet;
  @override
  final AudioRecorder audioRecorder;
  @override
  final TracksCollection tracksList;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AppLocalizations _trans;
  late UIWrapper _uiWrapper;
  late TrackWrapper _trackWrapper;

  late TabController _tabController;
  int? selectedTab;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    if (args != null && selectedTab == null) {
      selectedTab = args;
      _tabController.animateTo(args);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        _trans = AppLocalizations.of(context)!;
        _uiWrapper = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _uiWrapper);

        return Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(AppIcon.displaySettings), text: _trans.screen),
                Tab(icon: Icon(AppIcon.trackSettings), text: _trans.track),
                Tab(icon: Icon(AppIcon.recordingSettings), text: _trans.recording),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(_trans.settings),
            centerTitle: true,
            // actions: [
            //   IconButton(
            //       icon: Icon(AppIcon.resetAllSettings),
            //       tooltip: _trans.allSettingsResetTitle,
            //       onPressed: () {
            //         _uiWrapper.alertDialog(
            //           AppIcon.resetAllSettings,
            //           _trans.allSettingsResetTitle,
            //           contentText: _trans.allSettingsResetInfo,
            //           actions: <Widget>[
            //             _uiWrapper.simpleButton(_trans.buttonNo, () {
            //               Navigator.pop(context, 'No');
            //             }),
            //             _uiWrapper.errorButton(_trans.buttonYes, () {
            //               setState(() {
            //                 _trackWrapper.resetTracksName(widget.tracksList.all());
            //                 _trackWrapper.resetTracksKeyboardKey(widget.tracksList.all());
            //                 _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), Track.defaultPlaybackModeSingle);
            //                 _trackWrapper.setTracksPlaybackVolume(widget.tracksList.all(), Track.defaultPlaybackVolume);
            //                 _trackWrapper.setTracksPlaybackBalance(widget.tracksList.all(), Track.defaultPlaybackBalance);
            //                 _trackWrapper.setTracksPlaybackSpeed(widget.tracksList.all(), Track.defaultPlaybackSpeed);
            //                 for (AppGlobalConfigField field in AppGlobalConfigFieldsCollection.list) {
            //                   widget.settingsSet(field.key, field.defaultValue, updateState: true);
            //                 }
            //                 _uiWrapper.toast(_trans.allSettingsResetSuccess, icon: AppIcon.resetAllSettings);
            //                 Navigator.pop(context, 'Yes');
            //               });
            //             }),
            //           ],
            //         );
            //       }),
            // ],
          ),
          body: TabBarView(controller: _tabController, children: [
            ListView(children: _bodyScreen()),
            // ListView(children: _bodyTrack()),
            ListView(children: _bodyRecording()),
          ]),
        );
      });

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions.values<Permission>()) {
      statuses[permission] = await permission.status;
    }
    setState(() {
      _permissionStatuses = statuses;
    });
  }

  /// Poproszenie o uprawnienia
  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionStatuses[permission] = status;
    });
  }

  List<Widget> _bodyScreen() => [
        _uiWrapper.settingsTileTitle(_trans.displaySettings),
        ListTile(
            leading: Icon(AppIcon.language),
            title: Text(_trans.languageVersion),
            trailing: _uiWrapper.trailingLabel(widget.settingsGet(AppConfigFieldKey.locale).toLanguageTag()),
            onTap: () {
              var options = <Widget>[];
              AppGlobalConfig.languages.values<Locale>().forEach((Locale locale) {
                var name = AppGlobalConfig.languages.text(locale);
                var code = locale.toLanguageTag();
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      Navigator.pop(context, locale);
                      widget.settingsSet(AppConfigFieldKey.locale, locale, updateState: true);
                    },
                    child: Text('$name ($code)')));
              });
              _uiWrapper.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
            }),
        _uiWrapper.listTileSwitch(
          AppIcon.screenThemeMode,
          _trans.screenThemeMode,
          disabledIcon: AppIcon.screenLightThemeMode,
          disabledLabel: _trans.lightMode,
          enabledIcon: AppIcon.screenDarkThemeMode,
          enabledLabel: _trans.darkMode,
          switchValue: widget.settingsGet(AppConfigFieldKey.isThemeModeDark),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
            return null;
          },
        ),
        _uiWrapper.listTileColorPicker(
          AppIcon.screenThemeColor,
          _trans.screenThemeColor,
          _trans.screenThemeColorInfo,
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
          disabledLabel: _trans.disabled,
          enabledIcon: AppIcon.keepScreenOnEnabled,
          enabledLabel: _trans.enabled,
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


  List<Widget> _bodyRecording() => [
        _uiWrapper.settingsTileTitle(_trans.recordingSettings),
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
                        setState(() {
                          widget.settingsSet(AppConfigFieldKey.recordingInputDevice, inputDevice, updateState: true);
                        });
                        Navigator.pop(context, 'recordingInputDevice');
                      },
                      child: Text(_trans.recordingInputDeviceValue(inputDevice.label))));
                }
              });
              _uiWrapper.listDialog(AppIcon.recordingInputDevice, _trans.recordingInputDeviceTitle,
                  contentText: _trans.recordingInputDeviceInfo, actions: options.toList());
            }),
        _uiWrapper.listTileRadioDialog(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          null,
          _trans.recordingAudioEncoderTitle,
          _trans.recordingAudioEncoderInfo,
          widget.settingsGet(AppConfigFieldKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoder.values().toList(),
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(
              AppConfigFieldKey.recordingAudioEncoder,
              value,
              updateState: true,
            );
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.recordingAudioEncoder,
          trans: _trans,
        ),
        _uiWrapper.listTileRadioDialog(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          _trans.recordingSampleRateInfo,
          _trans.recordingSampleRateTitle,
          _trans.recordingSampleRateInfo,
          widget.settingsGet(AppConfigFieldKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRate.values().toList(),
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.recordingSampleRate,
        ),
        _uiWrapper.listTileRadioDialog(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _trans.recordingBitRateInfo,
          _trans.recordingBitRateTitle,
          _trans.recordingBitRateInfo,
          widget.settingsGet(AppConfigFieldKey.recordingBitRate),
          AppGlobalConfig.recordingBitRate.values().toList(),
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(AppConfigFieldKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          configCollection: AppGlobalConfig.recordingBitRate,
        ),
        _uiWrapper.listTileSwitch(
          AppIcon.recordingAudioMode,
          _trans.recordingAudioMode,
          disabledIcon: AppIcon.recordingAudioModeMono,
          disabledLabel: _trans.recordingAudioModeOptionMono,
          enabledIcon: AppIcon.recordingAudioModeStereo,
          enabledLabel: _trans.recordingAudioModeOptionStereo,
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
          enabledLabel: _trans.recordingAutoGainInfo,
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
          enabledLabel: _trans.recordingEchoCancelInfo,
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
          enabledLabel: _trans.recordingNoiseSuppressInfo,
          switchValue: widget.settingsGet(AppConfigFieldKey.recordingNoiseSuppress),
          successAction: (bool value) {
            widget.settingsSet(AppConfigFieldKey.recordingNoiseSuppress, value, updateState: true);
            return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
          },
        ),
        _uiWrapper.settingsTileDivider(),
        _uiWrapper.listTileReset(AppIcon.resetAllSettings, _trans.recordingSettingsReset, _trans.recordingSettingsResetTitle,
            _trans.recordingSettingsResetInfo, _trans.buttonNo, _trans.buttonYes, () {
          for (AppRecordingConfigField field in AppGlobalConfigFieldsCollection.listRecording) {
            widget.settingsSet(field.key, field.defaultValue, updateState: true);
          }
          return _trans.recordingSettingsResetSuccess;
        }),
        _uiWrapper.settingsTileDivider(),
        _uiWrapper.settingsTileTitle(_trans.permissions),
        ...AppGlobalConfig.permissions.values<Permission>().map((Permission permission) {
          final status = _permissionStatuses[permission] ?? PermissionStatus.denied;
          return ListTile(
            leading: Icon(AppGlobalConfig.permissions.icon(permission)),
            title: Text(AppGlobalConfig.permissions.translate(permission, trans: _trans)),
            subtitle: Text(AppGlobalConfig.permissionsStatus.translate(status, trans: _trans)),
            trailing: status.isGranted
                ? Icon(AppIcon.yes, color: Theme.of(context).colorScheme.primary)
                : ElevatedButton(
                    onPressed: () async {
                      if (status.isDenied) {
                        setState(() {
                          _requestPermission(permission);
                        });
                      } else {
                        await openAppSettings();
                        setState(() {});
                      }
                    },
                    child: Text(_trans.grantPermission),
                  ),
          );
        }),
      ];
}
