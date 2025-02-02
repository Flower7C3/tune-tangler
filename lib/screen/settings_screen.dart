import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/screen/screen.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../entity/track.dart';
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
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;
  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;
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
                Tab(icon: Icon(AppIcon.recordSettings), text: _trans.recording),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(_trans.settings),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(AppIcon.resetAllSettings),
                  tooltip: _trans.allSettingsResetTitle,
                  onPressed: () {
                    _uiWrapper.alertDialog(
                      AppIcon.resetAllSettings,
                      _trans.allSettingsResetTitle,
                      contentText: _trans.allSettingsResetInfo,
                      actions: <Widget>[
                        _uiWrapper.simpleButton(_trans.buttonNo, () {
                          Navigator.pop(context, 'No');
                        }),
                        _uiWrapper.errorButton(_trans.buttonYes, () {
                          setState(() {
                            _trackWrapper.resetTracksName(widget.tracksList.all());
                            _trackWrapper.resetTracksKeyboardKey(widget.tracksList.all());
                            _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), Track.defaultPlaybackModeSingle);
                            _trackWrapper.setTracksPlaybackVolume(widget.tracksList.all(), Track.defaultPlaybackVolume);
                            _trackWrapper.setTracksPlaybackBalance(widget.tracksList.all(), Track.defaultPlaybackBalance);
                            _trackWrapper.setTracksPlaybackSpeed(widget.tracksList.all(), Track.defaultPlaybackSpeed);
                            AppGlobalConfig.settingsFields().forEach((GlobalConfigKeyNameDefaults field) {
                              widget.settingsSet(field.key, field.defaultValue, updateState: true);
                            });
                            _uiWrapper.toast(_trans.allSettingsResetSuccess, icon: AppIcon.resetAllSettings);
                            Navigator.pop(context, 'Yes');
                          });
                        }),
                      ],
                    );
                  }),
            ],
          ),
          body: TabBarView(controller: _tabController, children: [
            ListView(children: _bodyScreen()),
            ListView(children: _bodyTrack()),
            ListView(children: _bodyRecording()),
          ]),
        );
      });

  Map<Permission, PermissionStatus> _permissionStatuses = {};

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in AppGlobalConfig.permissions) {
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
        _uiWrapper.settingsTileTitle(_trans.screenSettings),
        ListTile(
            leading: Icon(AppIcon.language),
            title: Text(_trans.languageVersion),
            trailing: _uiWrapper.trailingLabel(widget.settingsGet(GlobalConfigKey.locale).toLanguageTag()),
            onTap: () {
              var options = <Widget>[];
              AppGlobalConfig.languages.forEach((String name, Locale locale) {
                var code = locale.toLanguageTag();
                options.add(SimpleDialogOption(
                    padding: EdgeInsets.all(16),
                    onPressed: () {
                      Navigator.pop(context, locale);
                      widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
                    },
                    child: Text('$name ($code)')));
              });
              _uiWrapper.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
            }),
        _uiWrapper.listTileSwitch(AppIcon.screenThemeMode, _trans.screenThemeMode, AppIcon.screenLightThemeMode, _trans.lightMode,
            AppIcon.screenDarkThemeMode, _trans.darkMode, widget.settingsGet(GlobalConfigKey.isThemeModeDark), (bool value) {
          widget.settingsSet(GlobalConfigKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
          return null;
        }),
        ListTile(
            leading: Icon(AppIcon.screenThemeColor),
            title: Text(_trans.screenThemeColor),
            trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.settingsGet(GlobalConfigKey.themeSeedColor),
                  borderRadius: BorderRadius.circular(24),
                )),
            onTap: () {
              _uiWrapper.alertDialog(AppIcon.screenThemeColor, _trans.screenThemeColorTitle,
                  contentText: _trans.screenThemeColorInfo,
                  contentWidget: _uiWrapper.gridBuilder(
                      itemCount: AppGlobalConfig.userInterfaceColors.values.length,
                      itemBuilder: (context, index) {
                        Color color = AppGlobalConfig.userInterfaceColors.values.elementAt(index);
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                            onPressed: () {
                              widget.settingsSet(GlobalConfigKey.themeSeedColor, color, updateState: true);
                              Navigator.pop(context, color.toString());
                              _uiWrapper.toast(_trans.screenThemeColorSuccess(
                                      // double.tryParse(index.toString())??-1
                                      AppGlobalConfig.userInterfaceColors.codec.valueTranslator(double.tryParse(index.toString()) ?? -1, _trans)),
                                  icon: AppIcon.screenThemeColor);
                            },
                            child: null);
                      }));
            }),
        _uiWrapper.listTileSwitch(AppIcon.keepScreenOn, _trans.keepScreenOn, AppIcon.keepScreenOnDisabled, _trans.disabled,
            AppIcon.keepScreenOnEnabled, _trans.enabled, widget.settingsGet(GlobalConfigKey.wakelockEnabled), (bool value) {
          widget.settingsSet(GlobalConfigKey.wakelockEnabled, value, updateState: true);
          return value ? _trans.keepScreenOnIsDisabledSuccess : _trans.keepScreenOnIsEnabledSuccess;
        }),
        _uiWrapper.listTileSlider(
          AppIcon.gridRowsAmount,
          _trans.gridRowsAmount,
          _trans.gridRowsAmountTitle,
          _trans.gridRowsAmountInfo,
          double.parse(widget.settingsGet(GlobalConfigKey.gridRowsAmount).toString()),
          AppGlobalConfig.gridRows.minValue,
          AppGlobalConfig.gridRows.maxValue,
          AppGlobalConfig.gridRows.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.gridRowsAmount, value.toInt(), updateState: true);
            return _trans.gridRowsAmountSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.gridRows.codec.valueFormatter,
        ),
        _uiWrapper.listTileSlider(
          AppIcon.gridColsAmount,
          _trans.gridColsAmount,
          _trans.gridColsAmountTitle,
          _trans.gridColsAmountInfo,
          double.parse(widget.settingsGet(GlobalConfigKey.gridColsAmount).toString()),
          AppGlobalConfig.gridCols.minValue,
          AppGlobalConfig.gridCols.maxValue,
          AppGlobalConfig.gridCols.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.gridColsAmount, value.toInt(), updateState: true);
            return _trans.gridColsAmountSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.gridCols.codec.valueFormatter,
        ),
      ];

  List<Widget> _bodyTrack() => [
        _uiWrapper.settingsTileTitle(_trans.trackSettings),
        _uiWrapper.listTileReset(AppIcon.trackTitle, _trans.allTracksTitleReset, _trans.allTracksTitleResetTitle, _trans.allTracksTitleResetInfo,
            _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.resetTracksName(widget.tracksList.all());
          return _trans.allTracksTitleResetSuccess;
        }),
        _uiWrapper.listTileReset(AppIcon.trackKeyboardKey, _trans.allTracksShortcutKeyReset, _trans.allTracksShortcutKeyResetTitle,
            _trans.allTracksShortcutKeyResetInfo, _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.resetTracksKeyboardKey(widget.tracksList.all());
          return _trans.allTracksShortcutKeyResetSuccess;
        }),
        ListTile(
            leading: Icon(AppIcon.trackPlaybackMode),
            title: Text(_trans.allTracksPlaybackModeSet),
            onTap: () {
              var options = <Widget>[];
              options.add(SimpleDialogOption(
                  padding: EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(AppIcon.trackSinglePlaybackMode, size: 16), Text(' '), Text(_trans.singlePlaybackMode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), true);
                      _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.singlePlaybackMode), icon: AppIcon.trackSinglePlaybackMode);
                      Navigator.pop(context, _trans.singlePlaybackMode);
                    });
                  }));
              options.add(SimpleDialogOption(
                  padding: EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(AppIcon.trackRepeatPlaybackMode, size: 16), Text(' '), Text(_trans.repeatPlaybackMode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(widget.tracksList.all(), false);
                      _uiWrapper.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.repeatPlaybackMode), icon: AppIcon.trackRepeatPlaybackMode);
                      Navigator.pop(context, _trans.repeatPlaybackMode);
                    });
                  }));
              _uiWrapper.listDialog(AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeTitleSet,
                  contentText: _trans.allTracksPlaybackModeInfoSet, actions: options.toList());
            }),
        _uiWrapper.listTileSlider(
          AppIcon.trackPlaybackVolume,
          _trans.allTracksPlaybackVolumeSet,
          _trans.allTracksPlaybackVolumeTitleSet,
          _trans.allTracksPlaybackVolumeInfoSet,
          AppGlobalConfig.trackPlaybackVolumeSliderValues.defaultValue!,
          AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue,
          AppGlobalConfig.trackPlaybackVolumeSliderValues.maxValue,
          AppGlobalConfig.trackPlaybackVolumeSliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          withTrailing: false,
          successAction: (double value, String formattedValue) {
            _trackWrapper.setTracksPlaybackVolume(widget.tracksList.all(), value);
            return _trans.allTracksPlaybackVolumeSuccessSet(formattedValue);
          },
          valueFormatter: AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter,
        ),
        _uiWrapper.listTileSlider(
          AppIcon.trackPlaybackBalance,
          _trans.allTracksPlaybackBalanceSet,
          _trans.allTracksPlaybackBalanceTitleSet,
          _trans.allTracksPlaybackBalanceInfoSet,
          AppGlobalConfig.trackPlaybackBalanceSliderValues.defaultValue!,
          AppGlobalConfig.trackPlaybackBalanceSliderValues.minValue,
          AppGlobalConfig.trackPlaybackBalanceSliderValues.maxValue,
          AppGlobalConfig.trackPlaybackBalanceSliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            _trackWrapper.setTracksPlaybackBalance(widget.tracksList.all(), value);
            return _trans.allTracksPlaybackBalanceSuccessSet(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(value, _trans));
          },
          valueFormatter: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter,
          valueTranslator: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator,
          trans: _trans,
          withTrailing: false,
        ),
        _uiWrapper.listTileSlider(
          AppIcon.trackPlaybackSpeed,
          _trans.allTracksPlaybackSpeedSet,
          _trans.allTracksPlaybackSpeedTitleSet,
          _trans.allTracksPlaybackSpeedInfoSet,
          AppGlobalConfig.trackPlaybackSpeedSliderValues.defaultValue!,
          AppGlobalConfig.trackPlaybackSpeedSliderValues.minValue,
          AppGlobalConfig.trackPlaybackSpeedSliderValues.maxValue,
          AppGlobalConfig.trackPlaybackSpeedSliderValues.divisions,
          _trans.buttonCancel,
          _trans.buttonSave,
          withTrailing: false,
          successAction: (double value, String formattedValue) {
            _trackWrapper.setTracksPlaybackSpeed(widget.tracksList.all(), value);
            return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
          },
          valueFormatter: AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter,
        ),
        _uiWrapper.settingsTileDivider(),
        _uiWrapper.listTileReset(AppIcon.deleteForever, _trans.allTracksRecordingsDelete, _trans.allTracksRecordingsDeleteTitle,
            _trans.allTracksRecordingsDeleteInfo, _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.removeTracksRecordings(widget.tracksList.all());
          return _trans.allTracksRecordingsDeleteSuccess;
        }),
      ];

  List<Widget> _bodyRecording() => [
        _uiWrapper.settingsTileTitle(_trans.recordingSettings),
        ListTile(
            leading: Icon(AppIcon.recordingInputDevice),
            title: Text(_trans.recordingInputDevice),
            subtitle: Text(
              widget.settingsGet(GlobalConfigKey.recordingInputDevice) != null
                  ? widget.settingsGet(GlobalConfigKey.recordingInputDevice).label
                  : _trans.defaultDevice,
            ),
            trailing: _uiWrapper.trailingLabel(
              widget.settingsGet(GlobalConfigKey.recordingInputDevice) != null
                  ? widget.settingsGet(GlobalConfigKey.recordingInputDevice).id.toString()
                  : '0',
            ),
            onTap: () async {
              var options = <Widget>[];
              options.add(SimpleDialogOption(
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    Navigator.pop(context, 'recordingInputDevice');
                    widget.settingsSet(GlobalConfigKey.recordingInputDevice, null, updateState: true);
                  },
                  child: Text(_trans.defaultDevice)));
              await widget.audioRecorder.listInputDevices().then((List<InputDevice> inputDevices) {
                for (var inputDevice in inputDevices) {
                  options.add(SimpleDialogOption(
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        setState(() {
                          widget.settingsSet(GlobalConfigKey.recordingInputDevice, inputDevice, updateState: true);
                        });
                        Navigator.pop(context, 'recordingInputDevice');
                      },
                      child: Text(_trans.recordingInputDeviceValue(inputDevice.label))));
                }
              });
              _uiWrapper.listDialog(AppIcon.recordingInputDevice, _trans.recordingInputDeviceTitle,
                  contentText: _trans.recordingInputDeviceInfo, actions: options.toList());
            }),
        _uiWrapper.listTileRadio(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          null,
          _trans.recordingAudioEncoderTitle,
          _trans.recordingAudioEncoderInfo,
          widget.settingsGet(GlobalConfigKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoderValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(
              GlobalConfigKey.recordingAudioEncoder,
              value,
              updateState: true,
            );
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.recordingAudioEncoderValues.codec.valueFormatter,
          valueTranslator: AppGlobalConfig.recordingAudioEncoderValues.codec.valueTranslator,
          trans: _trans,
        ),
        _uiWrapper.listTileRadio(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          _trans.recordingSampleRateInfo,
          _trans.recordingSampleRateTitle,
          _trans.recordingSampleRateInfo,
          widget.settingsGet(GlobalConfigKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRateValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.recordingSampleRateValues.codec.valueFormatter,
        ),
        _uiWrapper.listTileRadio(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _trans.recordingBitRateInfo,
          _trans.recordingBitRateTitle,
          _trans.recordingBitRateInfo,
          widget.settingsGet(GlobalConfigKey.recordingBitRate),
          AppGlobalConfig.recordingBitRateValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (dynamic value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.recordingBitRateValues.codec.valueFormatter,
        ),
        _uiWrapper.listTileSwitch(
            AppIcon.recordingAudioMode,
            _trans.recordingAudioMode,
            AppIcon.recordingAudioModeMono,
            _trans.recordingAudioModeOptionMono,
            AppIcon.recordingAudioModeStereo,
            _trans.recordingAudioModeOptionStereo,
            widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingAudioModeStereo, value, updateState: true);
          return _trans.recordingAudioModeSuccess(value ? _trans.recordingAudioModeOptionStereo : _trans.recordingAudioModeOptionMono);
        }),
        _uiWrapper.listTileSwitch(AppIcon.recordingAudioGain, _trans.recordingAutoGain, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingAutoGain),
            subtitleText: _trans.recordingAutoGainInfo, (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingAutoGain, value, updateState: true);
          return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
        }),
        _uiWrapper.listTileSwitch(AppIcon.recordingEchoCancel, _trans.recordingEchoCancel, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingEchoCancel),
            subtitleText: _trans.recordingEchoCancelInfo, (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingEchoCancel, value, updateState: true);
          return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
        }),
        _uiWrapper.listTileSwitch(AppIcon.recordingNoiseSuppress, _trans.recordingNoiseSuppress, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingNoiseSuppress),
            subtitleText: _trans.recordingNoiseSuppressInfo, (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingNoiseSuppress, value, updateState: true);
          return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
        }),
        _uiWrapper.settingsTileTitle(_trans.permissions),
        ...AppGlobalConfig.permissions.map((permission) {
          final status = _permissionStatuses[permission] ?? PermissionStatus.denied;
          return ListTile(
            leading: Icon(AppGlobalConfig.permissionsCodec.valueIcon(permission.value.toDouble())),
            title: Text(AppGlobalConfig.permissionsCodec.valueTranslator(permission, _trans)),
            subtitle: Text(AppGlobalConfig.permissionsStatusCodec.valueTranslator(status, _trans)),
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
