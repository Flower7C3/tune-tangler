import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';
import 'screen.dart';

class HomeScreen extends StatefulWidget implements ScreenInterface {
  const HomeScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  @override
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;

  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLocalizations _trans;
  late UIWrapper _ui;
  late TrackWrapper _trackWrapper;
  final Set<String> _allTracksIds = {};

  bool loading = false;

  late final AudioRecorder _audioRecorder;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.dispose();
    _trackWrapper.dispose(_allTracksIds);
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        _trans = AppLocalizations.of(context)!;
        _ui = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _ui, _audioRecorder, _allTracksIds);

        Widget body;
        if (loading == true) {
          body = Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(strokeWidth: 8)]));
        } else {
          body = Column(children: [Expanded(child: _buildTracksGrid())]);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: Icon(widget.settingsGet(GlobalConfigKey.wakelockEnabled) ? AppIcon.logoKeepScreenOnEnabled : AppIcon.logoKeepScreenOnDisabled),
            title: Text(_trans.appTitle),
            actions: _buildTopMenu(),
          ),
          body: body,
          // bottomNavigationBar: Column(
          //   mainAxisSize: MainAxisSize.min,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: _buildFooter(),
          // ),
        );
      });

  /// *************************************************************************
  /// TOP MENU
  List<Widget> _buildTopMenu() {
    var items = <Widget>[];
    items.add(IconButton(
      icon: Icon(AppIcon.trackPlayingStart),
      tooltip: _trans.allTracksPlayingStart,
      onPressed: () {
        setState(() {
          _trackWrapper.startTracksPlaying(_allTracksIds);
        });
      },
    ));
    items.add(IconButton(
      icon: Icon(AppIcon.trackPlayingStop),
      tooltip: _trans.allTracksPlayingStop,
      onPressed: () {
        setState(() {
          _trackWrapper.stopTracksPlaying(_allTracksIds);
        });
      },
    ));
    items.add(PopupMenuButton<String>(
      icon: Icon(AppIcon.moreMenu),
      itemBuilder: (BuildContext context) => _topMenuItems(),
      onSelected: (String selection) {
        _topMenuItemSelected(TopMenuItem.values.byName(selection.replaceAll('TopMenuItem.', '')));
      },
    ));
    return items.toList();
  }

  List<PopupMenuEntry<String>> _topMenuItems() {
    List<PopupMenuEntry<String>> menuItems = [];
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.changeLanguage, AppIcon.language, _trans.changeLanguage));
    if (widget.settingsGet(GlobalConfigKey.isThemeModeDark)) {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.themeModeLight, AppIcon.screenLightThemeMode, _trans.menuLightMode));
    } else {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.themeModeDark, AppIcon.screenDarkThemeMode, _trans.menuDarkMode));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.keepScreenOnDisable, AppIcon.keepScreenOnEnabled, _trans.menuKeepScreenOn, checked: true));
    } else {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.keepScreenOnEnable, AppIcon.keepScreenOnDisabled, _trans.menuKeepScreenOn, checked: false));
    }
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.settings, AppIcon.settings, _trans.settings));
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.help, AppIcon.help, _trans.help));
    return menuItems;
  }

  void _topMenuItemSelected(TopMenuItem selection) async {
    switch (selection) {
      case TopMenuItem.changeLanguage:
        var options = <Widget>[];
        AppGlobalConfig.languages.forEach((String name, Locale locale) {
          var code = locale.toLanguageTag();
          options.add(SimpleDialogOption(
            onPressed: () {
              widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
              Navigator.pop(context, locale);
            },
            child: Text('$name ($code)'),
          ));
        });
        _ui.listDialog(AppIcon.language, _trans.changeLanguage, actions: options.toList());
        break;
      case TopMenuItem.keepScreenOnEnable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, true, updateState: true);
        break;
      case TopMenuItem.keepScreenOnDisable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, false, updateState: true);
        break;
      case TopMenuItem.themeModeLight:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.light, updateState: true);
        break;
      case TopMenuItem.themeModeDark:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.dark, updateState: true);
        break;
      case TopMenuItem.settings:
        setState(() {
          loading = true;
        });
        await Navigator.pushNamed(context, '/settings', arguments: {'allTracksIds': _allTracksIds});
        setState(() {
          _allTracksIds.clear();
          loading = false;
        });
        break;
      case TopMenuItem.help:
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        _ui.aboutDialog(
            packageInfo,
            [
              _ui.helpSection(_trans.helpScreenMessageAboutTitle, [
                Text(_trans.helpScreenMessageAboutContent),
              ]),
              _ui.helpSection(_trans.helpScreenMessageUsageTitle, [
                Text(_trans.helpScreenMessageUsageContent_1),
                _ui.helpTrackState(TrackState.empty, _trans.helpScreenMessageUsageContent_1_state_empty),
                _ui.helpTrackState(TrackState.recording, _trans.helpScreenMessageUsageContent_1_state_recording),
                _ui.helpTrackState(TrackState.stopped, _trans.helpScreenMessageUsageContent_1_state_stopped),
                _ui.helpTrackState(TrackState.playing, _trans.helpScreenMessageUsageContent_1_state_playing),
                _ui.helpTrackState(TrackState.paused, _trans.helpScreenMessageUsageContent_1_state_paused),
                SizedBox(height: 6),
                Text(_trans.helpScreenMessageUsageContent_2),
                // SizedBox(height: 6),
                // Text(_trans.helpScreenMessageShortcutKeysContent),
              ]),
              _ui.helpSection(_trans.helpScreenRecordingCodecsInfoTitle, [
                Text(_trans.helpScreenRecordingCodecsInfoContent),
              ]),
              _ui.helpSection(_trans.helpScreenRecordingCodecsChooseTitle, [
                Text(_trans.helpScreenRecordingCodecsChooseContent),
              ]),
            ],
            applicationLegalese: _trans.legalNote);
        break;
    }
  }

  /// *************************************************************************
  /// TRACKS GRID
  dynamic _buildTracksGrid() => ListView.builder(
      itemCount: widget.settingsGet(GlobalConfigKey.gridRowsAmount),
      itemBuilder: (context, rowIndex) {
        return Row(children: [
          _buildRow(rowIndex),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  widget.settingsGet(GlobalConfigKey.gridColsAmount),
                  (columnIndex) {
                    String trackId = Track.buildId(rowIndex, columnIndex);
                    _allTracksIds.add(trackId);
                    Track track = widget.settingsGet(trackId, space: ConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));
                    _trackWrapper.initStreams(track);
                    return Container(
                      margin: EdgeInsets.all(_ui.trackItemMargin),
                      width: _ui.trackItemWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          _trackPressed(track);
                        },
                        onLongPress: () {
                          _trackDetails(track);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(_ui.trackPadding),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_ui.trackBorderRadius)),
                            backgroundColor: track.stateBackgroundColor(context),
                            foregroundColor: track.stateForegroundColor(context)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _trackButton(track),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ]);
      });

  /// *************************************************************************
  /// ROW
  Container _buildRow(rowIndex) {
    var rowName = TrackRow.name(rowIndex);
    Set<String> rowTrackIds = {};
    int columns = widget.settingsGet(GlobalConfigKey.gridColsAmount);
    for (int colIndex = 0; colIndex < columns; colIndex++) {
      rowTrackIds.add(Track.buildId(rowIndex, colIndex));
    }

    var buttons = <Widget>[];
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _ui.mediaPlayerButton(AppIcon.trackPlayingStart, _trans.rowTracksPlayingStart(rowName), onPressed: () {
          setState(() {
            _trackWrapper.startTracksPlaying(rowTrackIds);
          });
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _ui.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.rowTracksPlayingStop(rowName), onPressed: () {
          setState(() {
            _trackWrapper.stopTracksPlaying(rowTrackIds);
          });
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _rowMenu(rowName, rowTrackIds)));
    return Container(
        width: _ui.gridFirstColumnWidth,
        padding: EdgeInsets.zero,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: buttons.toList()));
  }

  PopupMenuButton _rowMenu(String rowName, Set<String> tracks) => PopupMenuButton<dynamic>(
        style: _ui.circledButtonStyle(),
        icon: Icon(AppIcon.moreMenu, size: _ui.rowButtonIconSize, color: Theme.of(context).colorScheme.secondary),
        itemBuilder: (BuildContext context) => _rowMenuItems(rowName, tracks),
        onSelected: (dynamic selection) {
          _rowMenuItemSelected(selection, rowName, tracks);
        },
      );

  List<PopupMenuEntry<dynamic>> _rowMenuItems(String rowName, Set<String> tracks) => <PopupMenuEntry<dynamic>>[
        _ui.rowMenuButton(RowMenuItem.playbackMode, AppIcon.trackPlaybackMode, _trans.rowTracksPlaybackModeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in AppGlobalConfig.trackPlaybackModeValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.rowTracksPlaybackModeSetTitle((data.value == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
            ));
          }
          return items.toList();
        }, onSelected: (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackMode(tracks, (selection == 1) ? true : false);
            _ui.toast(_trans.rowTracksPlaybackModeSetSuccess(rowName, (selection == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
                icon: AppIcon.trackPlaybackMode);
          });
        }),
        _ui.rowMenuButton(RowMenuItem.playbackVolume, AppIcon.trackPlaybackVolume, _trans.rowTracksPlaybackVolumeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in AppGlobalConfig.trackPlaybackVolumeValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.rowTracksPlaybackVolumeTitleSet(AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(data.value)),
            ));
          }
          return items.toList();
        }, onSelected: (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackVolume(tracks, selection);
            _ui.toast(
                _trans.rowTracksPlaybackVolumeSuccessSet(rowName, AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(selection)),
                icon: AppIcon.trackPlaybackSpeed);
          });
        }),
        _ui.rowMenuButton(RowMenuItem.playbackBalance, AppIcon.trackPlaybackBalance, _trans.rowTracksPlaybackBalanceSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in AppGlobalConfig.trackPlaybackBalanceValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.rowTracksPlaybackBalanceTitleSet(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(data.value, _trans)),
            ));
          }
          return items.toList();
        }, onSelected: (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackBalance(tracks, selection);
            _ui.toast(
                _trans.rowTracksPlaybackBalanceSuccessSet(
                    rowName, AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(selection, _trans)),
                icon: AppIcon.trackPlaybackBalance);
          });
        }),
        _ui.rowMenuButton(RowMenuItem.playbackSpeed, AppIcon.trackPlaybackSpeed, _trans.rowTracksPlaybackSpeedSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in AppGlobalConfig.trackPlaybackSpeedValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.rowTracksPlaybackSpeedTitleSet(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(data.value)),
            ));
          }
          return items.toList();
        }, onSelected: (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackSpeed(tracks, selection);
            _ui.toast(
                _trans.rowTracksPlaybackSpeedSuccessSet(rowName, AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(selection)),
                icon: AppIcon.trackPlaybackSpeed);
          });
        }),
        const PopupMenuDivider(),
        _ui.rowPopupMenuItem(RowMenuItem.delete, AppIcon.deleteForever, _trans.rowTracksRecordingsDelete),
      ];

  void _rowMenuItemSelected(RowMenuItem selection, String rowName, Set<String> tracks) {
    if (selection == RowMenuItem.delete) {
      _ui.alertDialog(AppIcon.deleteForever, _trans.rowTracksRecordingsDeleteTitle,
          contentText: _trans.rowTracksRecordingsDeleteInfo(rowName),
          actions: <Widget>[
            _ui.simpleButton(_trans.buttonNo, () {
              Navigator.pop(context, 'No');
            }),
            _ui.errorButton(_trans.buttonYes, () {
              setState(() {
                _trackWrapper.removeTracksRecordings(tracks);
                Navigator.pop(context, 'Yes');
                _ui.toast(_trans.rowTracksRecordingsDeleteSuccess(rowName), icon: AppIcon.deleteForever);
              });
            }),
          ]);
    }
  }

  /// *************************************************************************
  /// TRACK PRESSED
  void _trackPressed(Track track) {
    setState(() {
      switch (track.state.value) {
        case TrackState.empty:
          _trackWrapper.startRecording(track);
          break;
        case TrackState.stopped:
          track.startPlaying();
          _trackWrapper.save(track);
          break;
        case TrackState.playing:
          track.stopPlaying();
          _trackWrapper.save(track);
          break;
        case TrackState.paused:
          track.resumePlaying();
          _trackWrapper.save(track);
          break;
        default:
          break;
      }
    });
  }

  List<Widget> _trackButton(Track track) {
    Color foregroundColor = track.stateForegroundColor(context);
    var items = <Widget>[];
    items.add(SizedBox(
        height: _ui.trackItemWidth - _ui.trackPadding,
        child: Stack(fit: StackFit.expand, children: [
          Align(alignment: Alignment.topLeft, child: Icon(track.stateIcon.value, size: _ui.trackButtonIconSize, color: foregroundColor)),
          Align(
              alignment: Alignment.topRight, child: AppIcon.trackKeyboardKeyBox(track, ui: _ui, context: context, foregroundColor: foregroundColor)),
          Align(
              alignment: Alignment.bottomLeft,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackVolume,
                  builder: (context, playbackVolume, child) {
                    return Icon(track.playbackVolumeIcon, size: _ui.trackButtonIconSize, color: foregroundColor);
                  })),
          Align(
              alignment: Alignment.bottomRight,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackBalance,
                  builder: (context, playbackBalance, child) {
                    return Icon(track.playbackBalanceIcon, size: _ui.trackButtonIconSize, color: foregroundColor);
                  })),
          Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackBalance,
                  builder: (context, playbackBalance, child) {
                    return Text(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(playbackBalance),
                        style: TextStyle(fontSize: _ui.trackInfoBalanceFontSize, color: foregroundColor));
                  })),
          Align(
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackSpeed,
                  builder: (context, playbackSpeed, child) {
                    return Text(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed),
                        style: TextStyle(fontSize: _ui.trackInfoSpeedFontSize, color: foregroundColor));
                  })),
          Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackModeSingle,
                  builder: (context, playbackModeSingle, child) {
                    return Icon(track.playbackModeIcon, size: _ui.trackButtonIconSize, color: foregroundColor);
                  })),
          Align(
              alignment: Alignment.center,
              child: Text(_trans.cell(track.name), style: TextStyle(fontSize: _ui.trackButtonTitleFontSize, fontWeight: FontWeight.bold))),
        ])));
    items.add(ValueListenableBuilder<double>(
        valueListenable: track.progress,
        builder: (context, progress, child) {
          return LinearProgressIndicator(value: progress, color: foregroundColor, backgroundColor: track.stateProgressColor(context));
        }));

    items.add(ValueListenableBuilder<Duration?>(
        valueListenable: track.duration,
        builder: (context, duration, child) {
          return _ui.trackInfoLine(AppIcon.trackDuration, _ui.formatTime((duration == null) ? 0 : duration.inMilliseconds), foregroundColor);
        }));
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK DETAILS
  void _trackDetails(Track track) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => LayoutBuilder(builder: (context, constraints) {
          double contentHeight = 500;
          double screenHeight = constraints.maxHeight;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: (contentHeight / screenHeight).clamp(0.3, 0.9),
            minChildSize: (contentHeight / screenHeight).clamp(0.3, 0.9),
            maxChildSize: (contentHeight / screenHeight).clamp(0.3, 0.9),
            builder: (context, scrollController) => Padding(
              padding: EdgeInsets.all(_ui.trackDetailsPadding1x),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  ValueListenableBuilder(valueListenable: track.stateIcon, builder: (context, icon, child) => Icon(icon)),
                  Text(_trans.trackTitle(track.name), style: TextStyle(fontSize: _ui.trackDetailsTitleFontSize, fontWeight: FontWeight.bold)),
                  AppIcon.trackKeyboardKeyBox(track, ui: _ui, context: context, foregroundColor: track.stateForegroundColor(context)),
                ]),
                SizedBox(height: _ui.trackDetailsPadding1x),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      SizedBox(height: _ui.trackDetailsPadding1x),
                      track.path == null ? SizedBox() : _ui.trackDetailsInfo(AppIcon.recordingFile, path.basename(track.path.toString())),
                      track.audioEncoder == null
                          ? SizedBox()
                          : _ui.trackDetailsInfo(AppIcon.recordingAudioEncoder,
                              AppGlobalConfig.recordingAudioEncoderValues.codec.valueTranslator(track.audioEncoder!.index.toDouble(), _trans)),
                      track.sampleRate == null
                          ? SizedBox()
                          : _ui.trackDetailsInfo(
                              AppIcon.recordingSampleRate,
                              _trans.recordingSampleRateValue(
                                  AppGlobalConfig.recordingSampleRateValues.codec.valueFormatter(track.sampleRate!.toDouble()))),
                      track.bitRate == null
                          ? SizedBox()
                          : _ui.trackDetailsInfo(
                              AppIcon.recordingBitRate,
                              _trans.recordingBitRateValue(AppGlobalConfig.recordingBitRateValues.codec.valueFormatter(track.bitRate!.toDouble())),
                            ),
                      _ui.trackDetailsLine(_trackDetailsCurrentStateIndicator(track, setModalState)),
                      _ui.trackDetailsLine(_trackDetailsSeek(track, setModalState)),
                      _ui.trackDetailsLine(_trackDetailsProgress(track, setModalState), mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      SizedBox(height: _ui.trackDetailsPadding1x),
                      _ui.trackDetailsLine(_trackDetailsPlaybackSpeedControl(track, setModalState),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      _ui.trackDetailsLine(_trackDetailsPlaybackVolumeControl(track, setModalState),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      _ui.trackDetailsLine(_trackDetailsPlaybackBalanceControl(track, setModalState),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      SizedBox(height: _ui.trackDetailsPadding1x),
                    ]),
                  ),
                ),
                const Divider(height: 1),
                SizedBox(height: _ui.trackDetailsPadding1x),
                _ui.trackDetailsLine(_trackDetailsPlayerIcons(track, setModalState)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  List<Widget> _trackDetailsSeek(Track track, StateSetter setModalState) => (track.recorderState != RecorderState.ready)
      ? []
      : [
          ValueListenableBuilder<Duration?>(
              valueListenable: track.duration,
              builder: (context, duration, child) {
                return ValueListenableBuilder<Duration?>(
                    valueListenable: track.position,
                    builder: (context, position, child) {
                      if (duration == null) {
                        return Text('');
                      }
                      return Expanded(
                        child: Slider(
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          divisions: duration.inMilliseconds.toInt(),
                          value: position!.inMilliseconds.toDouble(),
                          onChanged: (value) async {
                            await track.player.seek(Duration(milliseconds: (value).toInt()));
                          },
                        ),
                      );
                    });
              })
        ];

  List<Widget> _trackDetailsProgress(Track track, StateSetter setModalState) => (track.recorderState != RecorderState.ready)
      ? []
      : [
          ValueListenableBuilder<Duration?>(
              valueListenable: track.position,
              builder: (context, position, child) {
                return Text(_ui.formatTime(position?.inMilliseconds ?? 0));
              }),
          ValueListenableBuilder<Duration?>(
              valueListenable: track.duration,
              builder: (context, duration, child) {
                return Text(_ui.formatTime(duration?.inMilliseconds ?? 0));
              }),
        ];

  List<Widget> _trackDetailsCurrentStateIndicator(Track track, StateSetter setModalState) => (track.recorderState != RecorderState.empty)
      ? []
      : [
          _ui.mediaPlayerButton(AppIcon.trackRecordingStart, _trans.trackRecordingStart(track.name), onPressed: () {
            Navigator.pop(context);
            setState(() {
              _trackWrapper.startRecording(track);
            });
          }),
          _ui.mediaPlayerButton(AppIcon.trackRecordingImport, _trans.trackRecordingImport(track.name), onPressed: () async {
            if (await Permission.storage.request().isGranted == false && await Permission.audio.request().isGranted == false) {
              _ui.toast(_trans.trackRecordingImportNoPermissions(track.name), icon: AppIcon.trackRecordingImport, type: ToastType.error);
              return;
            }
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.audio,
            );

            if (result == null) {
              _ui.toast(_trans.trackRecordingImportCancelled(track.name), icon: AppIcon.trackRecordingImport, type: ToastType.error);
              return;
            }
            String sourcePath = result.files.single.path!;
            String fileName = result.files.single.name;

            Directory appDir = await getApplicationDocumentsDirectory();
            String destinationPath = "${appDir.path}/${track.id}.$fileName";

            File sourceFile = File(sourcePath);
            await sourceFile.copy(destinationPath);

            track.setPath(destinationPath);
            _trackWrapper.save(track, updateState: true);

            _ui.toast(_trans.trackRecordingImported(track.name), icon: AppIcon.trackRecordingImport);
          }),
        ];

  List<Widget> _trackDetailsPlayerIcons(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) {
              return _ui.mediaPlayerButton(AppIcon.trackRecordingShare, _trans.trackRecordingShare(track.name),
                  onPressed: (state != TrackState.empty && state != TrackState.recording)
                      ? () async {
                          if (track.path == null) {
                            _ui.toast(_trans.trackRecordingShareNoFile(track.name), icon: AppIcon.trackRecordingShare, type: ToastType.error);
                            return;
                          }
                          File file = File(track.path!);
                          if (await file.exists() == false) {
                            _ui.toast(_trans.trackRecordingShareNoFile(track.name), icon: AppIcon.trackRecordingShare, type: ToastType.error);
                            return;
                          }
                          await Share.shareXFiles([XFile(track.path!)], text: _trans.trackRecordingShareMessage(track.name));
                        }
                      : null);
            }),
        _ui.mediaPlayerButton(track.playbackModeIcon, _trans.trackPlaybackModeToggle(track.name), onPressed: () {
          setModalState(() {
            track.togglePlaybackMode();
            _trackWrapper.save(track);
          });
        }),
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) {
              return _ui.mediaPlayerButton(
                  (state == TrackState.paused)
                      ? AppIcon.trackPlayingResume
                      : ((state == TrackState.playing) ? AppIcon.trackPlayingPause : AppIcon.trackPlayingStart),
                  (state == TrackState.paused)
                      ? _trans.trackPlayingResume(track.name)
                      : ((state == TrackState.playing) ? _trans.trackPlayingPause(track.name) : _trans.trackPlayingStart(track.name)),
                  onPressed: (state == TrackState.paused)
                      ? () {
                          setModalState(() {
                            setState(() {
                              track.resumePlaying();
                              _trackWrapper.save(track);
                            });
                          });
                        }
                      : ((state == TrackState.playing)
                          ? () {
                              setModalState(() {
                                setState(() {
                                  track.pausePLaying();
                                  _trackWrapper.save(track);
                                });
                              });
                            }
                          : ((state == TrackState.stopped)
                              ? () {
                                  setModalState(() {
                                    setState(() {
                                      track.startPlaying();
                                      _trackWrapper.save(track);
                                    });
                                  });
                                }
                              : null)),
                  iconSize: _ui.mediaPlayerIconSize2x);
            }),
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) {
              return _ui.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.trackPlayingStop(track.name),
                  onPressed: (track.state.value == TrackState.playing || track.state.value == TrackState.paused)
                      ? () {
                          setModalState(() {
                            setState(() {
                              track.stopPlaying();
                              _trackWrapper.save(track);
                            });
                          });
                        }
                      : null);
            }),
        PopupMenuButton<TrackMenuItem>(
          style: _ui.circledButtonStyle(),
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _trackMenuItems(track),
          onSelected: (TrackMenuItem selection) => _trackMenuItemSelected(track, selection, setModalState),
        ),
      ];

  List<Widget> _trackDetailsPlaybackSpeedControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) {
              return _ui.mediaPlayerButton(AppIcon.trackPlaybackSpeed, _trans.trackPlaybackSpeedSet(track.name), onPressed: () {
                setModalState(() {
                  setState(() {
                    track.setPlaybackSpeed(1);
                    _trackWrapper.save(track);
                  });
                });
              });
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) {
              return Expanded(
                  child: Slider(
                value: playbackSpeed,
                min: AppGlobalConfig.trackPlaybackSpeedSliderValues.minValue,
                max: AppGlobalConfig.trackPlaybackSpeedSliderValues.maxValue,
                divisions: AppGlobalConfig.trackPlaybackSpeedSliderValues.divisions,
                label: AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed),
                onChanged: (double value) {
                  setModalState(() {
                    track.setPlaybackSpeed(value);
                    _trackWrapper.save(track);
                  });
                },
              ));
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) {
              return _ui.trailingLabel(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed));
            }),
      ];

  List<Widget> _trackDetailsPlaybackVolumeControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) {
              return _ui.mediaPlayerButton(track.playbackVolumeIcon, _trans.trackPlaybackVolumeSet(track.name), onPressed: () {
                setModalState(() {
                  // setState(() {
                  track.setPlaybackVolume((playbackVolume == AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue)
                      ? AppGlobalConfig.trackPlaybackVolumeSliderValues.maxValue
                      : AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue);
                  _trackWrapper.save(track);
                  // });
                });
              });
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) {
              return Expanded(
                  child: Slider(
                value: playbackVolume,
                min: AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue,
                max: AppGlobalConfig.trackPlaybackVolumeSliderValues.maxValue,
                divisions: AppGlobalConfig.trackPlaybackVolumeSliderValues.divisions,
                label: AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(playbackVolume),
                onChanged: (double value) {
                  setModalState(() {
                    // setState(() {
                    track.setPlaybackVolume(value);
                    _trackWrapper.save(track);
                    // });
                  });
                },
              ));
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) {
              return _ui.trailingLabel(AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(playbackVolume));
            }),
      ];

  List<Widget> _trackDetailsPlaybackBalanceControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) {
              return _ui.mediaPlayerButton(track.playbackBalanceIcon, _trans.trackPlaybackBalanceSet(track.name), onPressed: () {
                setModalState(() {
                  track.setPlaybackBalance(0);
                  _trackWrapper.save(track);
                });
              });
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) {
              return Expanded(
                  child: Slider(
                value: playbackBalance,
                min: AppGlobalConfig.trackPlaybackBalanceSliderValues.minValue,
                max: AppGlobalConfig.trackPlaybackBalanceSliderValues.maxValue,
                divisions: AppGlobalConfig.trackPlaybackBalanceSliderValues.divisions,
                label: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(playbackBalance, _trans),
                onChanged: (double value) {
                  setModalState(() {
                    track.setPlaybackBalance(value);
                    _trackWrapper.save(track);
                  });
                },
              ));
            }),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) {
              return _ui.trailingLabel(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(playbackBalance));
            }),
      ];

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(Track track) {
    var items = <PopupMenuEntry<TrackMenuItem>>[];
    items.add(_ui.trackMenuItem(TrackMenuItem.changeName, AppIcon.trackTitle, _trans.trackNameChange));
    items.add(_ui.trackMenuItem(TrackMenuItem.changeKeyboardKey, AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChange));
    if (track.state.value != TrackState.empty && track.state.value != TrackState.recording) {
      items.add(_ui.trackMenuItem(TrackMenuItem.delete, AppIcon.deleteForever, _trans.trackRecordingDelete));
    }
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection, StateSetter setModalState) async {
    switch (selection) {
      case TrackMenuItem.changeName:
        String emojiString = widget.settingsGet(GlobalConfigKey.emojis);
        List<String> emojiList = [track.id];
        emojiList.addAll(emojiString.characters.toList());
        _ui.alertDialog(AppIcon.trackTitle, _trans.trackNameChangeTitle(track.name),
            contentText: _trans.trackNameChangeInfo(track.name),
            contentWidget: _ui.gridBuilder(
                columnsCount: 6,
                itemCount: emojiList.length,
                itemBuilder: (context, index) {
                  String emoji = emojiList[index];
                  ButtonStyle style = OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  );
                  TextStyle textStyle = TextStyle();
                  if (emoji == track.name) {
                    style = OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                    textStyle = TextStyle(color: Theme.of(context).colorScheme.inversePrimary);
                  }
                  return OutlinedButton(
                      style: style,
                      onPressed: () {
                        setModalState(() {
                          setState(() {
                            Navigator.pop(context, emoji);
                            track.setName(emoji);
                            _ui.toast(_trans.trackNameChangeSuccess(emoji), icon: AppIcon.trackTitle);
                          });
                        });
                      },
                      child: Text(emoji, style: textStyle));
                }));
        break;
      case TrackMenuItem.changeKeyboardKey:
        _ui.alertDialog(AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChangeTitle(track.name),
            contentText: _trans.trackKeyboardKeyChangeInfo(track.name),
            contentWidget: _ui.gridBuilder(
                columnsCount: 6,
                itemCount: AppGlobalConfig.keyboardKeys().length,
                itemBuilder: (context, index) {
                  String key = AppGlobalConfig.keyboardKeys().elementAt(index);
                  ButtonStyle buttonStyle = OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  );
                  TextStyle textStyle = TextStyle();
                  if (key == track.keyboardKey) {
                    buttonStyle = OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                    textStyle = TextStyle(color: Theme.of(context).colorScheme.inversePrimary);
                  }
                  return OutlinedButton(
                      style: buttonStyle,
                      onPressed: () {
                        setModalState(() {
                          setState(() {
                            Navigator.pop(context, key);
                            track.setKeyboardKey(key);
                            _ui.toast(_trans.trackKeyboardKeyChangeSuccess(key), icon: AppIcon.trackKeyboardKey);
                          });
                        });
                      },
                      child: Text(key, style: textStyle));
                }));
        break;
      case TrackMenuItem.delete:
        _ui.alertDialog(AppIcon.deleteForever, _trans.trackRecordingDeleteTitle(track.name),
            contentText: _trans.trackRecordingDeleteInfo(track.name),
            actions: <Widget>[
              _ui.simpleButton(_trans.buttonNo, () {
                Navigator.pop(context, _trans.buttonNo);
              }),
              _ui.errorButton(_trans.buttonYes, () {
                setModalState(() {
                  setState(() {
                    _trackWrapper.removeTrackRecording(track);
                    Navigator.pop(context, _trans.buttonYes);
                    _ui.toast(_trans.trackRecordingDeleteSuccess(track.name), icon: AppIcon.deleteForever);
                  });
                });
              }),
            ]);
        break;
    }
  }
}
