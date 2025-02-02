import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tune_tangler/screen/screen.dart';
import 'package:tune_tangler/src/ui_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/keyboard.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';
import '../entity/track_row.dart';
import '../main.dart';

class TrackWrapper {
  final BuildContext context;
  final ScreenInterface widget;
  final AppLocalizations _trans;
  final UIWrapper _uiWrapper;

  TrackWrapper(this.context, this.widget, this._trans, this._uiWrapper);

  void initStreams(Track track) {
    if (track.streamsInitialized) {
      return;
    }
    track.setStreamsInitialized();
    save(track);
  }

  void save(Track track, {bool updateState = false}) {
    widget.settingsSet(track.id, track, space: ConfigSpace.track, updateState: updateState);
  }

  String _extensionName(AudioEncoder encoder) => switch (encoder) {
        AudioEncoder.aacLc => 'm4a',
        AudioEncoder.aacEld => 'm4a',
        AudioEncoder.aacHe => 'm4a',
        AudioEncoder.amrNb => '3gp',
        AudioEncoder.amrWb => '3gp',
        AudioEncoder.opus => 'opus',
        AudioEncoder.flac => 'flac',
        AudioEncoder.wav => 'wav',
        AudioEncoder.pcm16bits => 'pcm',
      };

  Future<void> startRecording(Track track) async {
    try {
      if (!await widget.audioRecorder.hasPermission()) {
        throw Exception(_trans.trackRecordingStartNoAudioPermission);
      }
      if (!await Permission.notification.request().isGranted) {
        throw Exception(_trans.trackRecordingStartNoNotificationPermission);
      }

      RecordConfig recordConfig = widget.settingsGet(GlobalConfigKey.recording);
      String fileExtension = _extensionName(recordConfig.encoder);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = await getApplicationDocumentsDirectory().then((value) => '${value.path}/${track.id}.$timestamp.$fileExtension');

      await widget.audioRecorder.start(
        recordConfig,
        path: filePath,
      );
      await showRecordingNotification(track);

      _uiWrapper.recordingDialog(
        _trans.trackRecordingInfo(track.name.value),
        recordConfig: recordConfig,
        trans: _trans,
        cancelLabel: _trans.trackRecordingCancel,
        saveLabel: _trans.trackRecordingStop,
        onCancel: () {
          _cancelRecording(track);
        },
        onSave: () {
          _stopAndSaveRecording(track);
        },
        onDismiss: () {
          _stopAndSaveRecording(track);
        },
      );

      track.setAudioEncoder(recordConfig.encoder);
      track.setSampleRate(recordConfig.sampleRate);
      track.setBitRate(recordConfig.bitRate);

      track.setRecordingState(RecorderState.recording);
      save(track);
    } catch (e) {
      _uiWrapper.toast(_trans.trackRecordingStartError(e.toString(), track.name.value), icon: AppIcon.exception, type: ToastType.error, duration: 4);
    }
  }

  Future<void> showRecordingNotification(Track track) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'recording_channel',
      _trans.trackRecording,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      silent: true,
      onlyAlertOnce: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      _trans.trackRecordingInfo(track.name.value),
      _trans.clickToOpenApp,
      platformChannelSpecifics,
    );
  }

  Future<void> _cancelRecording(Track track) async {
    await widget.audioRecorder.cancel();
    await flutterLocalNotificationsPlugin.cancel(0);
    track.setPath(null);
    save(track);
    _uiWrapper.toast(_trans.trackRecordingCancelled(track.name.value), icon: AppIcon.no);
  }

  Future<void> _stopAndSaveRecording(Track track) async {
    try {
      String? path = await widget.audioRecorder.stop();
      track.setPath(path);
      _uiWrapper.toast(_trans.trackRecordingStopSuccess(track.name.value), icon: AppIcon.yes);
    } catch (e) {
      track.setRecordingState(RecorderState.empty);
      _uiWrapper.toast(_trans.trackRecordingStopError(e.toString(), track.name.value), icon: AppIcon.exception, type: ToastType.error);
    }
    await flutterLocalNotificationsPlugin.cancel(0);
    save(track);
  }

  Future<void> removeTrackRecording(Track track) async {
    track.setPath(null);
    save(track);
  }

  void removeTracksRecordings(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      removeTrackRecording(track);
      save(track, updateState: true);
    }
  }

  void startTracksPlaying(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.startPlaying();
      save(track);
    }
  }

  void stopTracksPlaying(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.stopPlaying();
      save(track);
    }
  }

  void setTracksPlaybackMode(Set<Track> tracksList, bool value) async {
    for (Track track in tracksList) {
      track.setPlaybackMode(value);
      save(track);
    }
  }

  void setTracksPlaybackVolume(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackVolume(value);
      save(track);
    }
  }

  void setTracksPlaybackBalance(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackBalance(value);
      save(track);
    }
  }

  void setTracksPlaybackSpeed(Set<Track> tracksList, double value) async {
    for (Track track in tracksList) {
      track.setPlaybackSpeed(value);
      save(track);
    }
  }

  void resetTracksName(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.setName(track.id);
      save(track);
    }
  }

  void resetTracksKeyboardKey(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetKeyboardKey;
      save(track);
    }
  }

  void dispose(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.dispose();
    }
  }

  void onKeyEvent(KeyEvent event) {
    bool withControl = (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.control));

    if (event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight) {
      return;
    }

    String? pressedKeyName = AppKeyboardKeyMap.findPressedKeyName(event);
    for (Track track in widget.tracksList.all()) {
      if (track.keyboardKey.value == pressedKeyName) {
        if (withControl) {
          trackDetails(track);
        } else {
          trackPressed(track);
        }
        break;
      }
    }
  }

  void trackPressed(Track track) {
    switch (track.state.value) {
      case TrackState.empty:
        startRecording(track);
        break;
      case TrackState.stopped:
        track.startPlaying();
        save(track);
        break;
      case TrackState.playing:
        track.stopPlaying();
        save(track);
        break;
      case TrackState.paused:
        track.resumePlaying();
        save(track);
        break;
      default:
        break;
    }
  }

  /// *************************************************************************
  /// ROW
  Container buildRowButtons(rowIndex) {
    var rowName = TrackRow.name(rowIndex);
    var buttons = <Widget>[];
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        height: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        padding: EdgeInsets.all(_uiWrapper.rowContainerPadding),
        child: _uiWrapper.mediaPlayerButton(AppIcon.trackPlayingStart, _trans.rowTracksPlayingStart(rowName), onPressed: () {
          // setState(() {
          startTracksPlaying(widget.tracksList.row(rowIndex));
          // });
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        height: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        padding: EdgeInsets.all(_uiWrapper.rowContainerPadding),
        child: _uiWrapper.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.rowTracksPlayingStop(rowName), onPressed: () {
          // setState(() {
          stopTracksPlaying(widget.tracksList.row(rowIndex));
          // });
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        height: _uiWrapper.rowButtonIconSize + _uiWrapper.rowContainerPadding * 2,
        padding: EdgeInsets.all(_uiWrapper.rowContainerPadding),
        child: _rowMenu(rowName, widget.tracksList.row(rowIndex))));
    return Container(
        width: _uiWrapper.gridFirstColumnWidth,
        padding: EdgeInsets.zero,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: buttons.toList()));
  }

  PopupMenuButton _rowMenu(String rowName, Set<Track> tracksList) => PopupMenuButton<dynamic>(
      style: _uiWrapper.circledButtonStyle(),
      icon: Icon(AppIcon.moreMenu, size: _uiWrapper.rowButtonIconSize, color: Theme.of(context).colorScheme.secondary),
      itemBuilder: (BuildContext context) => _rowMenuItems(rowName, tracksList),
      onSelected: (dynamic selection) {
        _rowMenuItemSelected(selection, rowName, tracksList);
      });

  List<PopupMenuEntry<dynamic>> _rowMenuItems(String rowName, Set<Track> tracksList) => <PopupMenuEntry<dynamic>>[
        _uiWrapper.rowMenuButton(RowMenuItem.playbackMode, AppIcon.trackPlaybackMode, _trans.rowTracksPlaybackModeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackModeCodec.valueIcons.forEach((value, icon) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              icon,
              _trans.rowTracksPlaybackModeSetTitle((value == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          // setState(() {
          setTracksPlaybackMode(tracksList, (selection == 1) ? true : false);
          _uiWrapper.toast(_trans.rowTracksPlaybackModeSetSuccess(rowName, (selection == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
              icon: AppIcon.trackPlaybackMode);
          // });
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackVolume, AppIcon.trackPlaybackVolume, _trans.rowTracksPlaybackVolumeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueIcons.forEach((value, icon) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              icon,
              _trans.rowTracksPlaybackVolumeTitleSet(AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(value)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          // setState(() {
          setTracksPlaybackVolume(tracksList, selection);
          _uiWrapper.toast(
              _trans.rowTracksPlaybackVolumeSuccessSet(rowName, AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(selection)),
              icon: AppIcon.trackPlaybackSpeed);
          // });
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackBalance, AppIcon.trackPlaybackBalance, _trans.rowTracksPlaybackBalanceSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueIcons.forEach((value, icon) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              icon,
              _trans.rowTracksPlaybackBalanceTitleSet(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(value, _trans)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          // setState(() {
          setTracksPlaybackBalance(tracksList, selection);
          _uiWrapper.toast(
              _trans.rowTracksPlaybackBalanceSuccessSet(
                  rowName, AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(selection, _trans)),
              icon: AppIcon.trackPlaybackBalance);
          // });
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackSpeed, AppIcon.trackPlaybackSpeed, _trans.rowTracksPlaybackSpeedSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueIcons.forEach((value, icon) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              icon,
              _trans.rowTracksPlaybackSpeedTitleSet(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(value)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          // setState(() {
          setTracksPlaybackSpeed(tracksList, selection);
          _uiWrapper.toast(
              _trans.rowTracksPlaybackSpeedSuccessSet(rowName, AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(selection)),
              icon: AppIcon.trackPlaybackSpeed);
          // });
          Navigator.pop(context);
        }),
        const PopupMenuDivider(),
        _uiWrapper.rowPopupMenuItem(RowMenuItem.delete, AppIcon.deleteForever, _trans.rowTracksRecordingsDelete),
      ];

  void _rowMenuItemSelected(RowMenuItem selection, String rowName, Set<Track> tracksList) {
    if (selection == RowMenuItem.delete) {
      _uiWrapper.alertDialog(AppIcon.deleteForever, _trans.rowTracksRecordingsDeleteTitle,
          contentText: _trans.rowTracksRecordingsDeleteInfo(rowName),
          actions: <Widget>[
            _uiWrapper.simpleButton(_trans.buttonNo, () {
              Navigator.pop(context, 'No');
            }),
            _uiWrapper.errorButton(_trans.buttonYes, () {
              removeTracksRecordings(tracksList);
              Navigator.pop(context, 'Yes');
              _uiWrapper.toast(_trans.rowTracksRecordingsDeleteSuccess(rowName), icon: AppIcon.deleteForever);
            }),
          ]);
    }
  }

  /// *************************************************************************
  /// TRACK PRESSED

  List<Widget> trackButton(Track track) {
    Color foregroundColor = track.stateForegroundColor(context);
    var items = <Widget>[];
    items.add(SizedBox(
        height: _uiWrapper.trackItemWidth - _uiWrapper.trackPadding,
        child: Stack(fit: StackFit.expand, children: [
          Align(
              alignment: Alignment.topLeft,
              child: ValueListenableBuilder(
                  valueListenable: track.stateIcon,
                  builder: (context, stateIcon, child) => Icon(stateIcon, size: _uiWrapper.trackButtonIconSize, color: foregroundColor))),
          Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder(
                  valueListenable: track.keyboardKey,
                  builder: (context, keyboardKey, child) =>
                      AppIcon.trackKeyboardKeyBox(track, ui: _uiWrapper, context: context, foregroundColor: foregroundColor))),
          Align(
              alignment: Alignment.bottomLeft,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackVolume,
                  builder: (context, playbackVolume, child) =>
                      Icon(track.playbackVolumeIcon, size: _uiWrapper.trackButtonIconSize, color: foregroundColor))),
          Align(
              alignment: Alignment.bottomRight,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackBalance,
                  builder: (context, playbackBalance, child) =>
                      Icon(track.playbackBalanceIcon, size: _uiWrapper.trackButtonIconSize, color: foregroundColor))),
          Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackBalance,
                  builder: (context, playbackBalance, child) => Text(
                      AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(playbackBalance),
                      style: TextStyle(fontSize: _uiWrapper.trackInfoBalanceFontSize, color: foregroundColor)))),
          Align(
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackSpeed,
                  builder: (context, playbackSpeed, child) => Text(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed),
                      style: TextStyle(fontSize: _uiWrapper.trackInfoSpeedFontSize, color: foregroundColor)))),
          Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder(
                  valueListenable: track.playbackModeSingle,
                  builder: (context, playbackModeSingle, child) =>
                      Icon(track.playbackModeIcon, size: _uiWrapper.trackButtonIconSize, color: foregroundColor))),
          Align(
              alignment: Alignment.center,
              child: ValueListenableBuilder(
                  valueListenable: track.name,
                  builder: (context, name, child) =>
                      Text(_trans.cell(name), style: TextStyle(fontSize: _uiWrapper.trackButtonTitleFontSize, fontWeight: FontWeight.bold)))),
        ])));
    items.add(ValueListenableBuilder<double>(
        valueListenable: track.progress,
        builder: (context, progress, child) =>
            LinearProgressIndicator(value: progress, color: foregroundColor, backgroundColor: track.stateProgressColor(context))));

    items.add(ValueListenableBuilder<Duration?>(
        valueListenable: track.duration,
        builder: (context, duration, child) => _uiWrapper.statusIconRow(
              AppIcon.trackDuration,
              _uiWrapper.formatTime((duration == null) ? 0 : duration.inMilliseconds),
              iconColor: foregroundColor,
              iconSize: _uiWrapper.trackInfoIconSize,
              fontSize: _uiWrapper.trackInfoFontSize,
            )));
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK DETAILS
  void trackDetails(Track track) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) => LayoutBuilder(
                builder: (context, constraints) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                    minChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                    maxChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                    builder: (context, scrollController) => Padding(
                          padding: EdgeInsets.all(_uiWrapper.trackDetailsPadding1x),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                              ValueListenableBuilder(valueListenable: track.stateIcon, builder: (context, icon, child) => Icon(icon)),
                              Text(_trans.trackTitle(track.name.value),
                                  style: TextStyle(fontSize: _uiWrapper.trackDetailsTitleFontSize, fontWeight: FontWeight.bold)),
                              AppIcon.trackKeyboardKeyBox(track,
                                  ui: _uiWrapper, context: context, foregroundColor: Theme.of(context).colorScheme.primary),
                            ]),
                            SizedBox(height: _uiWrapper.trackDetailsPadding1x),
                            const Divider(height: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  SizedBox(height: _uiWrapper.trackDetailsPadding1x),
                                  if (track.path == null)
                                    _uiWrapper.statusIconRow(
                                      AppIcon.recordingFile,
                                      path.basename(track.path.toString()),
                                      iconSize: 16,
                                      fontSize: 14,
                                      separatorSize: _uiWrapper.iconToTextOffset,
                                    ),
                                  if (track.audioEncoder != null)
                                    _uiWrapper.statusIconRow(
                                      AppIcon.recordingAudioEncoder,
                                      AppGlobalConfig.recordingAudioEncoderValues.codec.valueTranslator(track.audioEncoder!.index.toDouble(), _trans),
                                      iconSize: 16,
                                      fontSize: 14,
                                      separatorSize: _uiWrapper.iconToTextOffset,
                                    ),
                                  if (track.sampleRate != null)
                                    _uiWrapper.statusIconRow(
                                      AppIcon.recordingSampleRate,
                                      _trans.recordingSampleRateValue(
                                          AppGlobalConfig.recordingSampleRateValues.codec.valueFormatter(track.sampleRate!.toDouble())),
                                      iconSize: 16,
                                      fontSize: 14,
                                      separatorSize: _uiWrapper.iconToTextOffset,
                                    ),
                                  if (track.bitRate != null)
                                    _uiWrapper.statusIconRow(
                                      AppIcon.recordingBitRate,
                                      _trans.recordingBitRateValue(
                                          AppGlobalConfig.recordingBitRateValues.codec.valueFormatter(track.bitRate!.toDouble())),
                                      iconSize: 16,
                                      fontSize: 14,
                                      separatorSize: _uiWrapper.iconToTextOffset,
                                    ),
                                  if (track.recorderState != RecorderState.empty)
                                    _uiWrapper.trackDetailsLine(_trackDetailsCurrentStateIndicator(track, setModalState)),
                                  if (track.recorderState != RecorderState.ready)
                                    _uiWrapper.trackDetailsLine(_trackDetailsSeek(track, setModalState)),
                                  if (track.recorderState != RecorderState.ready)
                                    _uiWrapper.trackDetailsLine(_trackDetailsProgress(track, setModalState),
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween),
                                  SizedBox(height: _uiWrapper.trackDetailsPadding1x),
                                  _uiWrapper.trackDetailsLine(_trackDetailsPlaybackSpeedControl(track, setModalState),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween),
                                  _uiWrapper.trackDetailsLine(_trackDetailsPlaybackVolumeControl(track, setModalState),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween),
                                  _uiWrapper.trackDetailsLine(_trackDetailsPlaybackBalanceControl(track, setModalState),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween),
                                  SizedBox(height: _uiWrapper.trackDetailsPadding1x),
                                ]),
                              ),
                            ),
                            const Divider(height: 1),
                            SizedBox(height: _uiWrapper.trackDetailsPadding1x),
                            _uiWrapper.trackDetailsLine(_trackDetailsPlayerIcons(track, setModalState)),
                          ]),
                        )))));
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  List<Widget> _trackDetailsSeek(Track track, StateSetter setModalState) => [
        ValueListenableBuilder<Duration?>(
            valueListenable: track.duration,
            builder: (context, duration, child) => ValueListenableBuilder<Duration?>(
                valueListenable: track.position,
                builder: (context, position, child) => (duration == null)
                    ? Text('')
                    : Expanded(
                        child: Slider(
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          divisions: duration.inMilliseconds.toInt(),
                          value: position!.inMilliseconds.toDouble(),
                          onChanged: (value) async {
                            await track.player.seek(Duration(milliseconds: (value).toInt()));
                          },
                        ),
                      )))
      ];

  List<Widget> _trackDetailsProgress(Track track, StateSetter setModalState) => [
        ValueListenableBuilder<Duration?>(
            valueListenable: track.position, builder: (context, position, child) => Text(_uiWrapper.formatTime(position?.inMilliseconds ?? 0))),
        ValueListenableBuilder<Duration?>(
            valueListenable: track.duration, builder: (context, duration, child) => Text(_uiWrapper.formatTime(duration?.inMilliseconds ?? 0))),
      ];

  List<Widget> _trackDetailsCurrentStateIndicator(Track track, StateSetter setModalState) => [
        _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingStart, _trans.trackRecordingStart(track.name.value), onPressed: () {
          Navigator.pop(context);
          startRecording(track);
        }),
        _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingImport, _trans.trackRecordingImport(track.name.value), onPressed: () async {
          if (await Permission.audio.request().isGranted == false) {
            _uiWrapper.toast(_trans.trackRecordingImportNoPermissions(track.name.value), icon: AppIcon.trackRecordingImport, type: ToastType.error);
            return;
          }
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
          );

          if (result == null) {
            _uiWrapper.toast(_trans.trackRecordingImportCancelled(track.name.value), icon: AppIcon.trackRecordingImport, type: ToastType.error);
            return;
          }
          String sourcePath = result.files.single.path!;
          String fileName = result.files.single.name;

          Directory appDir = await getApplicationDocumentsDirectory();
          String destinationPath = "${appDir.path}/${track.id}.$fileName";

          File sourceFile = File(sourcePath);
          await sourceFile.copy(destinationPath);

          track.setPath(destinationPath);
          save(track);

          _uiWrapper.toast(_trans.trackRecordingImported(track.name.value), icon: AppIcon.trackRecordingImport);
        }),
      ];

  List<Widget> _trackDetailsPlayerIcons(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) =>
                _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingShare, _trans.trackRecordingShare(track.name.value),
                    onPressed: (state != TrackState.empty && state != TrackState.recording)
                        ? () async {
                            if (track.path == null) {
                              _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                                  icon: AppIcon.trackRecordingShare, type: ToastType.error);
                              return;
                            }
                            File file = File(track.path!);
                            if (await file.exists() == false) {
                              _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                                  icon: AppIcon.trackRecordingShare, type: ToastType.error);
                              return;
                            }
                            await Share.shareXFiles([XFile(track.path!)], text: _trans.trackRecordingShareMessage(track.name.value));
                          }
                        : null)),
        _uiWrapper.mediaPlayerButton(track.playbackModeIcon, _trans.trackPlaybackModeToggle(track.name.value), onPressed: () {
          setModalState(() {
            track.togglePlaybackMode();
            save(track);
          });
        }),
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) => _uiWrapper.mediaPlayerButton(
                  (state == TrackState.paused)
                      ? AppIcon.trackPlayingResume
                      : ((state == TrackState.playing) ? AppIcon.trackPlayingPause : AppIcon.trackPlayingStart),
                  (state == TrackState.paused)
                      ? _trans.trackPlayingResume(track.name.value)
                      : ((state == TrackState.playing) ? _trans.trackPlayingPause(track.name.value) : _trans.trackPlayingStart(track.name.value)),
                  onPressed: (state == TrackState.paused)
                      ? () {
                          setModalState(() {
                            track.resumePlaying();
                            save(track);
                          });
                        }
                      : ((state == TrackState.playing)
                          ? () {
                              setModalState(() {
                                track.pausePLaying();
                                save(track);
                              });
                            }
                          : ((state == TrackState.stopped)
                              ? () {
                                  setModalState(() {
                                    track.startPlaying();
                                    save(track);
                                  });
                                }
                              : null)),
                  iconSize: _uiWrapper.mediaPlayerIconSize2x,
                )),
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) => _uiWrapper.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.trackPlayingStop(track.name.value),
                onPressed: (track.state.value == TrackState.playing || track.state.value == TrackState.paused)
                    ? () {
                        setModalState(() {
                          track.stopPlaying();
                          save(track);
                        });
                      }
                    : null)),
        PopupMenuButton<TrackMenuItem>(
          style: _uiWrapper.circledButtonStyle(),
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _trackMenuItems(track),
          onSelected: (TrackMenuItem selection) => _trackMenuItemSelected(track, selection, setModalState),
        ),
      ];

  List<Widget> _trackDetailsPlaybackSpeedControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) =>
                _uiWrapper.mediaPlayerButton(AppIcon.trackPlaybackSpeed, _trans.trackPlaybackSpeedSet(track.name.value), onPressed: () {
                  setModalState(() {
                    track.setPlaybackSpeed(1);
                    save(track);
                  });
                })),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) => Expanded(
                    child: Slider(
                  value: playbackSpeed,
                  min: AppGlobalConfig.trackPlaybackSpeedSliderValues.minValue,
                  max: AppGlobalConfig.trackPlaybackSpeedSliderValues.maxValue,
                  divisions: AppGlobalConfig.trackPlaybackSpeedSliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed),
                  onChanged: (double value) {
                    setModalState(() {
                      track.setPlaybackSpeed(value);
                      save(track);
                    });
                  },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) =>
                _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackSpeedSliderValues.codec.valueFormatter(playbackSpeed))),
      ];

  List<Widget> _trackDetailsPlaybackVolumeControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) =>
                _uiWrapper.mediaPlayerButton(track.playbackVolumeIcon, _trans.trackPlaybackVolumeSet(track.name.value), onPressed: () {
                  setModalState(() {
                    track.setPlaybackVolume((playbackVolume == AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue)
                        ? AppGlobalConfig.trackPlaybackVolumeSliderValues.maxValue
                        : AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue);
                    save(track);
                  });
                })),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) => Expanded(
                    child: Slider(
                  value: playbackVolume,
                  min: AppGlobalConfig.trackPlaybackVolumeSliderValues.minValue,
                  max: AppGlobalConfig.trackPlaybackVolumeSliderValues.maxValue,
                  divisions: AppGlobalConfig.trackPlaybackVolumeSliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(playbackVolume),
                  onChanged: (double value) {
                    setModalState(() {
                      track.setPlaybackVolume(value);
                      save(track);
                    });
                  },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) =>
                _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackVolumeSliderValues.codec.valueFormatter(playbackVolume))),
      ];

  List<Widget> _trackDetailsPlaybackBalanceControl(Track track, StateSetter setModalState) => [
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) =>
                _uiWrapper.mediaPlayerButton(track.playbackBalanceIcon, _trans.trackPlaybackBalanceSet(track.name.value), onPressed: () {
                  setModalState(() {
                    track.setPlaybackBalance(0);
                    save(track);
                  });
                })),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) => Expanded(
                    child: Slider(
                  value: playbackBalance,
                  min: AppGlobalConfig.trackPlaybackBalanceSliderValues.minValue,
                  max: AppGlobalConfig.trackPlaybackBalanceSliderValues.maxValue,
                  divisions: AppGlobalConfig.trackPlaybackBalanceSliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueTranslator(playbackBalance, _trans),
                  onChanged: (double value) {
                    setModalState(() {
                      track.setPlaybackBalance(value);
                      save(track);
                    });
                  },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) =>
                _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackBalanceSliderValues.codec.valueFormatter(playbackBalance))),
      ];

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(Track track) {
    var items = <PopupMenuEntry<TrackMenuItem>>[];
    items.add(_uiWrapper.trackMenuItem(TrackMenuItem.changeName, AppIcon.trackTitle, _trans.trackNameChange));
    items.add(_uiWrapper.trackMenuItem(TrackMenuItem.changeKeyboardKey, AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChange));
    if (track.state.value != TrackState.empty) {
      items.add(_uiWrapper.trackMenuItem(TrackMenuItem.delete, AppIcon.deleteForever, _trans.trackRecordingDelete));
    }
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection, StateSetter setModalState) async {
    switch (selection) {
      case TrackMenuItem.changeName:
        String selectedEmoji = track.name.value;
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                      title: _uiWrapper.statusIconTile(AppIcon.trackTitle, _trans.trackNameChangeTitle(track.name.value)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_trans.trackNameChangeInfo(track.name.value)),
                          SizedBox(height: _uiWrapper.dividerSize),
                          SizedBox(
                              width: double.maxFinite,
                              height: 200,
                              child: EmojiPicker(
                                  onEmojiSelected: (Category? category, Emoji emoji) {
                                    setState(() {
                                      selectedEmoji = emoji.emoji;
                                    });
                                  },
                                  scrollController: ScrollController(),
                                  config: Config(
                                    height: 200,
                                    checkPlatformCompatibility: true,
                                    viewOrderConfig: const ViewOrderConfig(),
                                    emojiViewConfig: EmojiViewConfig(
                                      /// Issue: https://github.com/flutter/flutter/issues/28894
                                      emojiSizeMax: 20 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.2 : 1.0),
                                      backgroundColor: Colors.transparent,
                                      noRecents: Text(
                                        _trans.noRecents,
                                        style: TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    locale: widget.settingsGet(GlobalConfigKey.locale),
                                    skinToneConfig: const SkinToneConfig(),
                                    categoryViewConfig: CategoryViewConfig(
                                      extraTab: CategoryExtraTab.SEARCH,
                                      backgroundColor: Colors.transparent,
                                    ),
                                    bottomActionBarConfig: const BottomActionBarConfig(
                                      showBackspaceButton: false,
                                      showSearchViewButton: false,
                                    ),
                                    searchViewConfig: SearchViewConfig(
                                      hintText: _trans.buttonSearch,
                                      backgroundColor: Colors.transparent,
                                      buttonIconColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ))),
                        ],
                      ),
                      actions: <Widget>[
                        if (selectedEmoji != track.id)
                          _uiWrapper.errorButton(_trans.buttonResetTo(track.id), () {
                            setModalState(() {
                              track.setName(track.id);
                              save(track);
                              Navigator.pop(context, track.id);
                              _uiWrapper.toast(_trans.trackNameChangeSuccess(track.id), icon: AppIcon.trackTitle);
                            });
                          }),
                        _uiWrapper.simpleButton(_trans.buttonCancel, () {
                          Navigator.pop(context, 'cancel');
                        }),
                        _uiWrapper.primaryButton(_trans.buttonSaveTo(selectedEmoji), () {
                          setModalState(() {
                            track.setName(selectedEmoji);
                            save(track);
                            Navigator.pop(context, selectedEmoji);
                            _uiWrapper.toast(_trans.trackNameChangeSuccess(selectedEmoji), icon: AppIcon.trackTitle);
                          });
                        }),
                      ],
                    )));
        break;
      case TrackMenuItem.changeKeyboardKey:
        _uiWrapper.alertDialog(AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChangeTitle(track.name.value),
            contentText: _trans.trackKeyboardKeyChangeInfo(track.name.value),
            contentWidget: _uiWrapper.gridBuilder(
                itemCount: AppKeyboardKeyMap.keyboardKeyNames().length,
                itemBuilder: (context, index) {
                  String key = AppKeyboardKeyMap.keyboardKeyNames().elementAt(index);
                  return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(_uiWrapper.trackButtonRoundRadius)),
                        ),
                        backgroundColor: (key == track.keyboardKey.value) ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: () {
                        setModalState(() {
                          track.setKeyboardKey(key);
                          save(track);
                          Navigator.pop(context, key);
                          _uiWrapper.toast(_trans.trackKeyboardKeyChangeSuccess(key), icon: AppIcon.trackKeyboardKey);
                        });
                      },
                      child: Text(
                        key,
                        style: TextStyle(color: (key == track.keyboardKey.value) ? Theme.of(context).colorScheme.inversePrimary : null),
                      ));
                }));
        break;
      case TrackMenuItem.delete:
        _uiWrapper.alertDialog(AppIcon.deleteForever, _trans.trackRecordingDeleteTitle(track.name.value),
            contentText: _trans.trackRecordingDeleteInfo(track.name.value),
            actions: <Widget>[
              _uiWrapper.simpleButton(_trans.buttonNo, () {
                Navigator.pop(context, _trans.buttonNo);
              }),
              _uiWrapper.errorButton(_trans.buttonYes, () {
                setModalState(() {
                  removeTrackRecording(track);
                  save(track);
                  Navigator.pop(context, _trans.buttonYes);
                  _uiWrapper.toast(_trans.trackRecordingDeleteSuccess(track.name.value), icon: AppIcon.deleteForever);
                });
              }),
            ]);
        break;
    }
  }
}
