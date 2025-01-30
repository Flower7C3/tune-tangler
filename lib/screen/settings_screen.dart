import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/screen/screen.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../entity/track.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';

class SettingsScreen extends StatefulWidget implements ScreenInterface {
  const SettingsScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  @override
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;

  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _trans;
  late UIWrapper _ui;
  late TrackWrapper _trackWrapper;
  late Set<String> _allTracksIds;

  late final AudioRecorder _audioRecorder;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        _allTracksIds = args['allTracksIds'];

        _trans = AppLocalizations.of(context)!;
        _ui = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _ui, _audioRecorder, _allTracksIds);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(AppIcon.displaySettings)),
                  Tab(icon: Icon(AppIcon.trackSettings)),
                  Tab(icon: Icon(AppIcon.recordSettings)),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(_trans.settings),
              centerTitle: true,
              actions: [
                IconButton(
                    icon: Icon(AppIcon.resetAllSettings),
                    onPressed: () {
                      _ui.alertDialog(
                        AppIcon.resetAllSettings,
                        _trans.allSettingsResetTitle,
                        contentText: _trans.allSettingsResetInfo,
                        actions: <Widget>[
                          _ui.simpleButton(_trans.buttonNo, () {
                            Navigator.pop(context, 'No');
                          }),
                          _ui.errorButton(_trans.buttonYes, () {
                            setState(() {
                              _trackWrapper.resetTracksName(_allTracksIds);
                              _trackWrapper.resetTracksKeyboardKey(_allTracksIds);
                              _trackWrapper.setTracksPlaybackMode(_allTracksIds, Track.defaultPlaybackModeSingle);
                              _trackWrapper.setTracksPlaybackVolume(_allTracksIds, Track.defaultPlaybackVolume);
                              _trackWrapper.setTracksPlaybackBalance(_allTracksIds, Track.defaultPlaybackBalance);
                              _trackWrapper.setTracksPlaybackSpeed(_allTracksIds, Track.defaultPlaybackSpeed);
                              AppGlobalConfig.settingsFields().forEach((GlobalConfigKeyNameDefaults field) {
                                widget.settingsSet(field.key, field.defaultValue, updateState: true);
                              });
                              _ui.toast(_trans.allSettingsResetSuccess, icon: AppIcon.resetAllSettings);
                              Navigator.pop(context, 'Yes');
                            });
                          }),
                        ],
                      );
                    })
              ],
            ),
            body: TabBarView(children: [
              ListView(children: _bodyScreen()),
              ListView(children: _bodyTrack()),
              ListView(children: _bodyRecording()),
            ]),
          ),
        );
      });

  List<Widget> _bodyScreen() => [
        _ui.settingsTileTitle(_trans.screenSettings),
        ListTile(
            leading: Icon(AppIcon.language),
            title: Text(_trans.languageVersion),
            trailing: _ui.trailingLabel(widget.settingsGet(GlobalConfigKey.locale).toLanguageTag()),
            onTap: () {
              var options = <Widget>[];
              AppGlobalConfig.languages.forEach((String name, Locale locale) {
                var code = locale.toLanguageTag();
                options.add(SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, locale);
                      widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
                    },
                    child: Text('$name ($code)')));
              });
              _ui.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
            }),
        _ui.listTileSwitch(AppIcon.screenThemeMode, _trans.screenThemeMode, AppIcon.screenLightThemeMode, _trans.lightMode,
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
              _ui.alertDialog(AppIcon.screenThemeColor, _trans.screenThemeColorTitle,
                  contentText: _trans.screenThemeColorInfo,
                  contentWidget: _ui.gridBuilder(
                      itemCount: AppGlobalConfig.userInterfaceColors.length,
                      itemBuilder: (context, index) {
                        Color color = AppGlobalConfig.userInterfaceColors.values.elementAt(index);
                        String name = AppGlobalConfig.userInterfaceColors.keys.elementAt(index);
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                            onPressed: () {
                              widget.settingsSet(GlobalConfigKey.themeSeedColor, color, updateState: true);
                              Navigator.pop(context, color.toString());
                              _ui.toast(_trans.screenThemeColorSuccess(name), icon: AppIcon.screenThemeColor);
                            },
                            child: null);
                      }));
            }),
        _ui.listTileSwitch(AppIcon.keepScreenOn, _trans.keepScreenOn, AppIcon.keepScreenOnDisabled, _trans.disabled, AppIcon.keepScreenOnEnabled,
            _trans.enabled, widget.settingsGet(GlobalConfigKey.wakelockEnabled), (bool value) {
          widget.settingsSet(GlobalConfigKey.wakelockEnabled, value, updateState: true);
          return value ? _trans.keepScreenOnIsDisabledSuccess : _trans.keepScreenOnIsEnabledSuccess;
        }),
        _ui.listTileSlider(
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
        _ui.listTileSlider(
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
        _ui.settingsTileTitle(_trans.trackSettings),
        ListTile(
            leading: Icon(AppIcon.trackTitleEmojis),
            title: Text(_trans.trackTitleEmojis),
            subtitle: Text(widget.settingsGet(GlobalConfigKey.emojis), style: TextStyle(fontSize: _ui.settingsSubtitleFontSize)),
            onTap: () {
              final TextEditingController textController = TextEditingController(text: widget.settingsGet(GlobalConfigKey.emojis));
              _ui.alertDialog(AppIcon.trackTitleEmojis, _trans.trackTitleEmojisTitle,
                  contentText: _trans.trackTitleEmojisInfo,
                  contentWidget: Column(children: [
                    ValueListenableBuilder(
                      valueListenable: textController,
                      builder: (context, text, child) {
                        return TextField(
                            controller: textController,
                            maxLines: 4,
                            decoration: InputDecoration(hintText: _trans.trackTitleEmojisInfo, border: OutlineInputBorder()));
                      },
                    ),
                    // SizedBox(height: 16),
                    // SizedBox(
                    //   width: double.maxFinite,
                    //   height: 200,
                    //   child: EmojiPicker(
                    //     textEditingController: textController,
                    //     scrollController: ScrollController(),
                    //     config: Config(
                    //       height: 200,
                    //       checkPlatformCompatibility: true,
                    //       viewOrderConfig: const ViewOrderConfig(),
                    //       emojiViewConfig: EmojiViewConfig(
                    //         // Issue: https://github.com/flutter/flutter/issues/28894
                    //         emojiSizeMax: 20 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.2 : 1.0),
                    //       ),
                    //       locale: widget.settingsGet(GlobalConfigKey.locale),
                    //       skinToneConfig: const SkinToneConfig(),
                    //       categoryViewConfig: const CategoryViewConfig(),
                    //       bottomActionBarConfig: const BottomActionBarConfig(),
                    //       searchViewConfig: const SearchViewConfig(),
                    //     ),
                    //   ),
                    // ),
                  ]),
                  actions: <Widget>[
                    _ui.simpleButton(_trans.buttonCancel, () {
                      Navigator.pop(context, _trans.buttonCancel);
                    }),
                    _ui.primaryButton(_trans.buttonSave, () {
                      setState(() {
                        widget.settingsSet(GlobalConfigKey.emojis, textController.text.replaceAll(' ', ''), updateState: true);
                        _ui.toast(_trans.trackTitleEmojisSuccess, icon: AppIcon.trackTitleEmojis);
                        Navigator.pop(context, _trans.buttonSave);
                      });
                    }),
                  ]);
            }),
        // Expanded(
        //   child: Center(
        //     child: ValueListenableBuilder(
        //       valueListenable: _controller,
        //       builder: (context, text, child) {
        //         return Text(
        //           _controller.text,
        //         );
        //       },
        //     ),
        //   ),
        // ),
        // Material(
        //   color: Colors.transparent,
        //   child: IconButton(
        //     onPressed: () {
        //       setState(() {
        //         _emojiShowing = !_emojiShowing;
        //       });
        //     },
        //     icon: const Icon(
        //       Icons.emoji_emotions,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 8.0),
        //     child: TextField(
        //         controller: _controller,
        //         scrollController: _scrollController,
        //         style: const TextStyle(
        //           fontSize: 20.0,
        //           color: Colors.black87,
        //         ),
        //         maxLines: 1,
        //         decoration: InputDecoration(
        //           hintText: 'Type a message',
        //           filled: true,
        //           fillColor: Colors.white,
        //           contentPadding: const EdgeInsets.only(
        //             left: 16.0,
        //             bottom: 8.0,
        //             top: 8.0,
        //             right: 16.0,
        //           ),
        //           border: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(50.0),
        //           ),
        //         )),
        //   ),
        // ),

        _ui.listTileReset(AppIcon.trackTitle, _trans.allTracksTitleReset, _trans.allTracksTitleResetTitle, _trans.allTracksTitleResetInfo,
            _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.resetTracksName(_allTracksIds);
          return _trans.allTracksTitleResetSuccess;
        }),
        _ui.listTileReset(AppIcon.trackKeyboardKey, _trans.allTracksShortcutKeyReset, _trans.allTracksShortcutKeyResetTitle,
            _trans.allTracksShortcutKeyResetInfo, _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.resetTracksKeyboardKey(_allTracksIds);
          return _trans.allTracksShortcutKeyResetSuccess;
        }),
        ListTile(
            leading: Icon(AppIcon.trackPlaybackMode),
            title: Text(_trans.allTracksPlaybackModeSet),
            onTap: () {
              var options = <Widget>[];
              options.add(SimpleDialogOption(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(AppIcon.trackSinglePlaybackMode, size: 16), Text(' '), Text(_trans.singlePlaybackMode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(_allTracksIds, true);
                      _ui.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.singlePlaybackMode), icon: AppIcon.trackSinglePlaybackMode);
                      Navigator.pop(context, _trans.singlePlaybackMode);
                    });
                  }));
              options.add(SimpleDialogOption(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(AppIcon.trackRepeatPlaybackMode, size: 16), Text(' '), Text(_trans.repeatPlaybackMode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(_allTracksIds, false);
                      _ui.toast(_trans.allTracksPlaybackModeSuccessSet(_trans.repeatPlaybackMode), icon: AppIcon.trackRepeatPlaybackMode);
                      Navigator.pop(context, _trans.repeatPlaybackMode);
                    });
                  }));
              _ui.listDialog(AppIcon.trackPlaybackMode, _trans.allTracksPlaybackModeTitleSet,
                  contentText: _trans.allTracksPlaybackModeInfoSet, actions: options.toList());
            }),
        _ui.listTileSlider(
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
            _trackWrapper.setTracksPlaybackVolume(_allTracksIds, value);
            return _trans.allTracksPlaybackVolumeSuccessSet(formattedValue);
          },
          valueFormatter: AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter,
        ),
        _ui.listTileSlider(
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
            _trackWrapper.setTracksPlaybackBalance(_allTracksIds, value);
            return _trans.allTracksPlaybackBalanceSuccessSet(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(value, _trans));
          },
          valueFormatter: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter,
          valueTranslator: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator,
          trans: _trans,
          withTrailing: false,
        ),
        _ui.listTileSlider(
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
            _trackWrapper.setTracksPlaybackSpeed(_allTracksIds, value);
            return _trans.allTracksPlaybackSpeedSuccessSet(formattedValue);
          },
          valueFormatter: AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter,
        ),
        _ui.settingsTileDivider(),
        _ui.listTileReset(AppIcon.deleteForever, _trans.allTracksRecordingsDelete, _trans.allTracksRecordingsDeleteTitle,
            _trans.allTracksRecordingsDeleteInfo, _trans.buttonNo, _trans.buttonYes, () {
          _trackWrapper.removeTracksRecordings(_allTracksIds);
          return _trans.allTracksRecordingsDeleteSuccess;
        }),
      ];

  List<Widget> _bodyRecording() => [
        _ui.settingsTileTitle(_trans.recordingSettings),
        _ui.listTileRadio(
          AppIcon.recordingAudioEncoder,
          _trans.recordingAudioEncoder,
          null,
          _trans.recordingAudioEncoderTitle,
          _trans.recordingAudioEncoderInfo,
          widget.settingsGet(GlobalConfigKey.recordingAudioEncoder),
          AppGlobalConfig.recordingAudioEncoderValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
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
        _ui.listTileRadio(
          AppIcon.recordingSampleRate,
          _trans.recordingSampleRate,
          _trans.recordingSampleRateInfo,
          _trans.recordingSampleRateTitle,
          _trans.recordingSampleRateInfo,
          widget.settingsGet(GlobalConfigKey.recordingSampleRate),
          AppGlobalConfig.recordingSampleRateValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.recordingSampleRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.recordingSampleRateValues.codec.valueFormatter,
          valueTranslator: AppGlobalConfig.recordingSampleRateValues.codec.valueTranslator,
          trans: _trans,
        ),
        _ui.listTileRadio(
          AppIcon.recordingBitRate,
          _trans.recordingBitRate,
          _trans.recordingBitRateInfo,
          _trans.recordingBitRateTitle,
          _trans.recordingBitRateInfo,
          widget.settingsGet(GlobalConfigKey.recordingBitRate),
          AppGlobalConfig.recordingBitRateValues.values,
          _trans.buttonCancel,
          _trans.buttonSave,
          successAction: (double value, String formattedValue) {
            widget.settingsSet(GlobalConfigKey.recordingBitRate, value, updateState: true);
            return _trans.recordingAudioEncoderSuccess(formattedValue);
          },
          valueFormatter: AppGlobalConfig.recordingBitRateValues.codec.valueFormatter,
          valueTranslator: AppGlobalConfig.recordingBitRateValues.codec.valueTranslator,
          trans: _trans,
        ),
        _ui.listTileSwitch(
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
        _ui.listTileSwitch(AppIcon.recordingAudioGain, _trans.recordingAutoGain, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingAutoGain), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingAutoGain, value, updateState: true);
          return _trans.recordingAutoGainSuccess(value ? _trans.yes : _trans.no);
        }, subtitleText: _trans.recordingAutoGainInfo),
        _ui.listTileSwitch(AppIcon.recordingEchoCancel, _trans.recordingEchoCancel, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingEchoCancel), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingEchoCancel, value, updateState: true);
          return _trans.recordingEchoCancelSuccess(value ? _trans.yes : _trans.no);
        }, subtitleText: _trans.recordingEchoCancelInfo),
        _ui.listTileSwitch(AppIcon.recordingNoiseSuppress, _trans.recordingNoiseSuppress, AppIcon.no, _trans.no, AppIcon.yes, _trans.yes,
            widget.settingsGet(GlobalConfigKey.recordingNoiseSuppress), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingNoiseSuppress, value, updateState: true);
          return _trans.recordingNoiseSuppressSuccess(value ? _trans.yes : _trans.no);
        }, subtitleText: _trans.recordingNoiseSuppressInfo),
      ];
}
