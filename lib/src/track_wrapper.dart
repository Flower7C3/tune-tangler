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
import '../config/fields.dart';
import '../config/keyboard.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';
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
    widget.settingsSet(track.id, track, space: AppConfigSpace.track, updateState: updateState);
  }

  Future<void> _importRecording(Track track) async {
    if (await Permission.audio.request().isGranted == false) {
      _uiWrapper.toast(_trans.trackRecordingImportNoPermissions(track.name.value),
          icon: AppIcon.trackRecordingImport, type: ToastType.error, duration: 4);
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result == null) {
      _uiWrapper.toast(_trans.trackRecordingImportCancelled(track.name.value),
          icon: AppIcon.trackRecordingImport, type: ToastType.error, duration: 4);
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
  }

  Future<void> _startRecording(Track track) async {
    try {
      if (await widget.audioRecorder.isRecording()) {
        throw Exception(_trans.trackRecordingAlreadyStarted);
      }
      if (!await widget.audioRecorder.hasPermission()) {
        throw Exception(_trans.trackRecordingStartNoAudioPermission);
      }
      if (!await Permission.notification.request().isGranted) {
        throw Exception(_trans.trackRecordingStartNoNotificationPermission);
      }

      RecordConfig recordConfig = widget.settingsGet(AppConfigFieldKey.recording);
      String fileExtension = AppGlobalConfig.readerEncoderExtension.text(recordConfig.encoder);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = await getApplicationDocumentsDirectory().then((value) => '${value.path}/${track.id}.$timestamp.$fileExtension');

      await widget.audioRecorder.start(
        recordConfig,
        path: filePath,
      );

      track.startTimer();

      track.setAudioEncoder(recordConfig.encoder);
      track.setSampleRate(recordConfig.sampleRate);
      track.setBitRate(recordConfig.bitRate);
      track.setRecordingState(RecorderState.recording);
      save(track);

      await showRecordingNotification(track);
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
    track.stopTimer();
    track.setPath(null);
    save(track);
    _uiWrapper.toast(_trans.trackRecordingCancelled(track.name.value), icon: AppGlobalConfig.trackState.icon(TrackState.empty));
  }

  Future<void> _stopAndSaveRecording(Track track) async {
    try {
      String? path = await widget.audioRecorder.stop();
      track.setPath(path);
      _uiWrapper.toast(_trans.trackRecordingStopSuccess(track.name.value), icon: AppGlobalConfig.trackState.icon(TrackState.idle));
    } catch (e) {
      track.setRecordingState(RecorderState.empty);
      _uiWrapper.toast(_trans.trackRecordingStopError(e.toString(), track.name.value), icon: AppIcon.exception, type: ToastType.error, duration: 4);
    }
    await flutterLocalNotificationsPlugin.cancel(0);
    track.stopTimer();
    save(track);
  }

  Future<void> removeTrackRecording(Track track) async {
    track.setPath(null);
    save(track);
  }

  void removeTracksRecordings(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      removeTrackRecording(track);
      save(track);
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
        _startRecording(track);
        break;
      case TrackState.recording:
        _stopAndSaveRecording(track);
        break;
      case TrackState.idle:
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
    }
  }

  /// *************************************************************************
  /// ROW
  Container buildRowButtons(
    int rowIndex,
    String rowName,
  ) =>
      Container(
          width: Theme.of(context).textTheme.displaySmall!.fontSize,
          padding: EdgeInsets.zero,
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            _uiWrapper.rowButton(_uiWrapper.mediaPlayerButton(
              AppIcon.trackPlayingStart,
              _trans.rowTracksPlayingStart(rowName),
              onPressed: () {
                startTracksPlaying(widget.tracksList.row(rowIndex));
              },
            )),
            _uiWrapper.rowButton(_uiWrapper.mediaPlayerButton(
              AppIcon.trackPlayingStop,
              _trans.rowTracksPlayingStop(rowName),
              onPressed: () {
                stopTracksPlaying(widget.tracksList.row(rowIndex));
              },
            )),
            _uiWrapper.rowButton(_rowMenu(rowName, widget.tracksList.row(rowIndex))),
          ]));

  PopupMenuButton _rowMenu(
    String rowName,
    Set<Track> tracksList,
  ) =>
      PopupMenuButton<dynamic>(
          style: _uiWrapper.circledButtonStyle(),
          icon: Icon(AppIcon.moreMenu, color: Theme.of(context).colorScheme.secondary),
          itemBuilder: (BuildContext context) => _rowMenuItems(rowName, tracksList),
          onSelected: (dynamic selection) {
            _rowMenuItemSelected(selection, rowName, tracksList);
          });

  List<PopupMenuEntry<dynamic>> _rowMenuItems(
    String rowName,
    Set<Track> tracksList,
  ) =>
      <PopupMenuEntry<dynamic>>[
        _uiWrapper.rowMenuButton(RowMenuItem.playbackMode, AppIcon.trackPlaybackMode, _trans.rowTracksPlaybackModeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackMode.values<double>().forEach((double value) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              AppGlobalConfig.trackPlaybackMode.icon(value),
              _trans.rowTracksPlaybackModeSetTitle((value == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          setTracksPlaybackMode(tracksList, (selection == 1) ? true : false);
          _uiWrapper.toast(_trans.rowTracksPlaybackModeSetSuccess(rowName, (selection == 1) ? _trans.singlePlaybackMode : _trans.repeatPlaybackMode),
              icon: AppIcon.trackPlaybackMode);
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackVolume, AppIcon.trackPlaybackVolume, _trans.rowTracksPlaybackVolumeSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackVolume.values<double>().forEach((double value) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              AppGlobalConfig.trackPlaybackVolume.icon(value),
              _trans.rowTracksPlaybackVolumeTitleSet(AppGlobalConfig.trackPlaybackVolume.format(value)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          setTracksPlaybackVolume(tracksList, selection);
          _uiWrapper.toast(_trans.rowTracksPlaybackVolumeSuccessSet(rowName, AppGlobalConfig.trackPlaybackVolume.format(selection)),
              icon: AppIcon.trackPlaybackSpeed);
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackBalance, AppIcon.trackPlaybackBalance, _trans.rowTracksPlaybackBalanceSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackBalance.values<double>().forEach((double value) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              AppGlobalConfig.trackPlaybackBalance.icon(value),
              _trans.rowTracksPlaybackBalanceTitleSet(AppGlobalConfig.trackPlaybackBalance.translate(value, trans: _trans)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          setTracksPlaybackBalance(tracksList, selection);
          _uiWrapper.toast(
              _trans.rowTracksPlaybackBalanceSuccessSet(rowName, AppGlobalConfig.trackPlaybackBalance.translate(selection, trans: _trans)),
              icon: AppIcon.trackPlaybackBalance);
          Navigator.pop(context);
        }),
        _uiWrapper.rowMenuButton(RowMenuItem.playbackSpeed, AppIcon.trackPlaybackSpeed, _trans.rowTracksPlaybackSpeedSet, itemBuilder: () {
          var items = <PopupMenuItem<dynamic>>[];
          AppGlobalConfig.trackPlaybackSpeed.values<double>().forEach((double value) {
            items.add(_uiWrapper.rowPopupMenuItem(
              value,
              AppGlobalConfig.trackPlaybackSpeed.icon(value),
              _trans.rowTracksPlaybackSpeedTitleSet(AppGlobalConfig.trackPlaybackSpeed.format(value)),
            ));
          });
          return items.toList();
        }, onSelected: (selection) {
          setTracksPlaybackSpeed(tracksList, selection);
          _uiWrapper.toast(_trans.rowTracksPlaybackSpeedSuccessSet(rowName, AppGlobalConfig.trackPlaybackSpeed.format(selection)),
              icon: AppIcon.trackPlaybackSpeed);
          Navigator.pop(context);
        }),
        const PopupMenuDivider(),
        _uiWrapper.rowPopupMenuItem(RowMenuItem.delete, AppIcon.deleteForever, _trans.rowTracksRecordingsDelete),
      ];

  void _rowMenuItemSelected(
    RowMenuItem selection,
    String rowName,
    Set<Track> tracksList,
  ) {
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

  List<Widget> trackButton(Track track) => [
        SizedBox(
            height: Theme.of(context).textTheme.titleLarge!.fontSize! * 3,
            child: Stack(fit: StackFit.expand, children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: ValueListenableBuilder(
                      valueListenable: track.stateIcon,
                      builder: (context, stateIcon, child) =>
                          Icon(stateIcon, size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
              Align(
                  alignment: Alignment.topRight,
                  child: ValueListenableBuilder(
                      valueListenable: track.keyboardKey,
                      builder: (context, keyboardKey, child) => AppIcon.trackKeyboardKeyBox(track,
                          ui: _uiWrapper,
                          context: context,
                          foregroundColor: track.stateForegroundColor(context),
                          size: Theme.of(context).textTheme.titleMedium!.fontSize!))),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: ValueListenableBuilder(
                      valueListenable: track.playbackVolume,
                      builder: (context, playbackVolume, child) => Icon(track.playbackVolumeIcon,
                          size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
              Align(
                  alignment: Alignment.bottomRight,
                  child: ValueListenableBuilder(
                      valueListenable: track.playbackBalance,
                      builder: (context, playbackBalance, child) => Icon(track.playbackBalanceIcon,
                          size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                      valueListenable: track.playbackBalance,
                      builder: (context, playbackBalance, child) => Text(AppGlobalConfig.trackPlaybackBalance.text(playbackBalance),
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, color: track.stateForegroundColor(context))))),
              Align(
                  alignment: Alignment.centerLeft,
                  child: ValueListenableBuilder(
                      valueListenable: track.playbackSpeed,
                      builder: (context, playbackSpeed, child) => Text(AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed),
                          style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize, color: track.stateForegroundColor(context))))),
              Align(
                  alignment: Alignment.centerRight,
                  child: ValueListenableBuilder(
                      valueListenable: track.playbackModeSingle,
                      builder: (context, playbackModeSingle, child) => Icon(track.playbackModeIcon,
                          size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
              Align(
                  alignment: Alignment.center,
                  child: ValueListenableBuilder(
                      valueListenable: track.name,
                      builder: (context, name, child) => Text(_trans.cell(name),
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize, fontWeight: FontWeight.bold)))),
            ])),
        ValueListenableBuilder<double>(
          valueListenable: track.progress,
          builder: (context, progress, child) => (track.state.value == TrackState.recording)
              ? LinearProgressIndicator(color: track.stateForegroundColor(context), backgroundColor: track.stateProgressColor(context))
              : LinearProgressIndicator(
                  value: progress, color: track.stateForegroundColor(context), backgroundColor: track.stateProgressColor(context)),
        ),
        ValueListenableBuilder<TrackState>(
          valueListenable: track.state,
          builder: (context, state, child) => (state == TrackState.recording)
              ? ValueListenableBuilder<double>(
                  valueListenable: track.clock,
                  builder: (context, clock, child) => _uiWrapper.statusIconRow(
                        AppIcon.trackDuration,
                        _uiWrapper.formatTime(clock.toInt()),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * _uiWrapper.iconSizeMultiplier,
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      ))
              : ValueListenableBuilder<Duration?>(
                  valueListenable: track.duration,
                  builder: (context, duration, child) => _uiWrapper.statusIconRow(
                        AppIcon.trackDuration,
                        _uiWrapper.formatTime((duration == null) ? 0 : duration.inMilliseconds),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * _uiWrapper.iconSizeMultiplier,
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      )),
        ),
      ];

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
        builder: (context) => LayoutBuilder(
            builder: (context, constraints) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                minChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                maxChildSize: (500 / constraints.maxHeight).clamp(0.3, 0.9),
                builder: (context, scrollController) => Padding(
                    padding: EdgeInsets.all(Theme.of(context).textTheme.titleLarge!.fontSize!),
                    child: ValueListenableBuilder(
                        valueListenable: track.recorderState,
                        builder: (context, recorderState, child) => Column(mainAxisSize: MainAxisSize.min, children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: _trackDetailsTitle(track)),
                              SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
                              const Divider(height: 1),
                              Expanded(
                                  child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: _trackDetailsScroll(track, recorderState)))),
                              const Divider(height: 1),
                              SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
                              ValueListenableBuilder(
                                  valueListenable: track.recorderState,
                                  builder: (context, recorderState, child) => _uiWrapper.trackDetailsLine(_trackDetailsPlayerIcons(track))),
                            ]))))));
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  List<Widget> _trackDetailsTitle(Track track) => [
        ValueListenableBuilder(
            valueListenable: track.state,
            builder: (context, state, child) => Tooltip(
                message: AppGlobalConfig.trackState.translate(state, trans: _trans),
                child: ValueListenableBuilder(
                  valueListenable: track.stateIcon,
                  builder: (context, icon, child) =>
                      Icon(icon, size: Theme.of(context).textTheme.headlineMedium!.fontSize! * _uiWrapper.iconSizeMultiplier),
                ))),
        Expanded(
            child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: track.name,
                builder: (context, name, child) => Text(_trans.trackTitle(name),
                    style: TextStyle(fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize, fontWeight: FontWeight.bold))),
            Text(track.path == null ? '' : path.basename(track.path.toString()),
                style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize)),
          ],
        )),
        ValueListenableBuilder(
            valueListenable: track.name,
            builder: (context, name, child) => Tooltip(
                message: _trans.trackKeyboardKey(name),
                child: ValueListenableBuilder(
                    valueListenable: track.keyboardKey,
                    builder: (context, keyboardKey, child) => AppIcon.trackKeyboardKeyBox(
                          track,
                          ui: _uiWrapper,
                          context: context,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          size: Theme.of(context).textTheme.headlineSmall!.fontSize!,
                        )))),
      ];

  List<Widget> _trackDetailsScroll(Track track, RecorderState recorderState) => [
        SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
        _uiWrapper.trackDetailsLine(_trackDetailsPlaybackSpeedControl(track), mainAxisAlignment: MainAxisAlignment.spaceBetween),
        _uiWrapper.trackDetailsLine(_trackDetailsPlaybackVolumeControl(track), mainAxisAlignment: MainAxisAlignment.spaceBetween),
        _uiWrapper.trackDetailsLine(_trackDetailsPlaybackBalanceControl(track), mainAxisAlignment: MainAxisAlignment.spaceBetween),
        SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
        // if (recorderState == RecorderState.ready && track.path != null)
        //   _uiWrapper.statusIconRow(
        //     AppIcon.recordingFile,
        //     path.basename(track.path.toString()),
        // iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize!*_uiWrapper.iconSizeMultiplier,
        // fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
        //     separatorSize: _uiWrapper.gridGap * 2,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //   ),
        if (track.audioEncoder != null)
          _uiWrapper.statusIconRow(
            AppIcon.recordingAudioEncoder,
            AppGlobalConfig.recordingAudioEncoder.translate(track.audioEncoder?.index.toDouble(), trans: _trans),
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
            separatorSize: _uiWrapper.gridGap * 2,
          ),
        if (track.sampleRate != null)
          _uiWrapper.statusIconRow(
            AppIcon.recordingSampleRate,
            _trans.recordingSampleRateValue(AppGlobalConfig.recordingSampleRate.format(track.sampleRate?.toDouble())),
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
            separatorSize: _uiWrapper.gridGap * 2,
          ),
        if (track.bitRate != null)
          _uiWrapper.statusIconRow(
            AppIcon.recordingBitRate,
            _trans.recordingBitRateValue(AppGlobalConfig.recordingBitRate.format(track.bitRate?.toDouble())),
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
            separatorSize: _uiWrapper.gridGap * 2,
          ),
        SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
        if (recorderState == RecorderState.recording)
          LinearProgressIndicator(color: track.stateForegroundColor(context), backgroundColor: track.stateProgressColor(context)),
        if (recorderState == RecorderState.recording) SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
        if (recorderState == RecorderState.recording)
          ValueListenableBuilder<double>(
              valueListenable: track.clock, builder: (context, clock, child) => Center(child: Text(_uiWrapper.formatTime(clock.toInt())))),
        if (recorderState == RecorderState.recording) SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
        if (recorderState == RecorderState.ready) _uiWrapper.trackDetailsLine(_trackDetailsSeek(track)),
        if (recorderState == RecorderState.ready)
          _uiWrapper.trackDetailsLine(_trackDetailsProgress(track), mainAxisAlignment: MainAxisAlignment.spaceBetween),
        if (recorderState == RecorderState.ready) SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
      ];

  List<Widget> _trackDetailsSeek(Track track) => [
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

  List<Widget> _trackDetailsProgress(Track track) => [
        ValueListenableBuilder<Duration?>(
            valueListenable: track.position, builder: (context, position, child) => Text(_uiWrapper.formatTime(position?.inMilliseconds ?? 0))),
        ValueListenableBuilder<Duration?>(
            valueListenable: track.duration, builder: (context, duration, child) => Text(_uiWrapper.formatTime(duration?.inMilliseconds ?? 0))),
      ];

  List<Widget> _trackDetailsPlayerIcons(Track track) => [
        _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingShare, _trans.trackRecordingShare(track.name.value),
            onPressed: (track.recorderState.value == RecorderState.ready)
                ? () async {
                    if (track.path == null) {
                      _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                          icon: AppIcon.trackRecordingShare, type: ToastType.error, duration: 4);
                      return;
                    }
                    File file = File(track.path!);
                    if (await file.exists() == false) {
                      _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                          icon: AppIcon.trackRecordingShare, type: ToastType.error, duration: 4);
                      return;
                    }
                    await Share.shareXFiles([XFile(track.path!)], text: _trans.trackRecordingShareMessage(track.name.value));
                  }
                : null),
        ValueListenableBuilder(
            valueListenable: track.playbackModeSingle,
            builder: (context, playbackModeSingle, child) =>
                _uiWrapper.mediaPlayerButton(track.playbackModeIcon, _trans.trackPlaybackModeToggle(track.name.value),
                    onPressed: (track.state.value != TrackState.recording)
                        ? () {
                            track.togglePlaybackMode();
                            save(track);
                          }
                        : null)),
        if (track.recorderState.value == RecorderState.empty)
          _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingStart, _trans.trackRecordingStart(track.name.value),
              iconSize: Theme.of(context).textTheme.displayLarge!.fontSize, onPressed: () {
            _startRecording(track);
          }),
        if (track.recorderState.value == RecorderState.recording)
          _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingStop, _trans.trackRecordingStop(track.name.value),
              iconSize: Theme.of(context).textTheme.displayLarge!.fontSize, onPressed: () {
            _stopAndSaveRecording(track);
          }),
        if (track.recorderState.value == RecorderState.recording)
          _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingCancel, _trans.trackRecordingCancel(track.name.value), onPressed: () {
            _cancelRecording(track);
          }),
        if (track.recorderState.value == RecorderState.empty)
          _uiWrapper.mediaPlayerButton(AppIcon.trackRecordingImport, _trans.trackRecordingImport(track.name.value), onPressed: () async {
            _importRecording(track);
          }),
        if (track.recorderState.value == RecorderState.ready)
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
                            track.resumePlaying();
                            save(track);
                          }
                        : ((state == TrackState.playing)
                            ? () {
                                track.pausePLaying();
                                save(track);
                              }
                            : ((state == TrackState.idle)
                                ? () {
                                    track.startPlaying();
                                    save(track);
                                  }
                                : null)),
                    iconSize: Theme.of(context).textTheme.displayLarge!.fontSize,
                  )),
        if (track.recorderState.value == RecorderState.ready)
          ValueListenableBuilder(
              valueListenable: track.state,
              builder: (context, state, child) => _uiWrapper.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.trackPlayingStop(track.name.value),
                  onPressed: (state == TrackState.playing || state == TrackState.paused)
                      ? () {
                          track.stopPlaying();
                          save(track);
                        }
                      : null)),
        PopupMenuButton<TrackMenuItem>(
          style: _uiWrapper.circledButtonStyle(),
          icon: Icon(AppIcon.moreMenu),
          itemBuilder: (BuildContext context) => _trackMenuItems(track),
          enabled: (track.state.value != TrackState.recording),
          onSelected: (TrackMenuItem selection) => _trackMenuItemSelected(track, selection),
        ),
      ];

  List<Widget> _trackDetailsPlaybackSpeedControl(Track track) => [
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) =>
                _uiWrapper.mediaPlayerButton(AppIcon.trackPlaybackSpeed, _trans.trackPlaybackSpeedSet(track.name.value),
                    onPressed: (track.state.value == TrackState.recording)
                        ? null
                        : () {
                            track.setPlaybackSpeed(1);
                            save(track);
                          })),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) => Expanded(
                    child: Slider(
                  value: playbackSpeed,
                  min: AppGlobalConfig.trackPlaybackSpeed.sliderValues.min,
                  max: AppGlobalConfig.trackPlaybackSpeed.sliderValues.max,
                  divisions: AppGlobalConfig.trackPlaybackSpeed.sliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed),
                  onChanged: (track.state.value == TrackState.recording)
                      ? null
                      : (double value) {
                          track.setPlaybackSpeed(value);
                          save(track);
                        },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackSpeed,
            builder: (context, playbackSpeed, child) => _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed))),
      ];

  List<Widget> _trackDetailsPlaybackVolumeControl(Track track) => [
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) =>
                _uiWrapper.mediaPlayerButton(track.playbackVolumeIcon, _trans.trackPlaybackVolumeSet(track.name.value),
                    onPressed: (track.state.value == TrackState.recording)
                        ? null
                        : () {
                            track.setPlaybackVolume((playbackVolume == AppGlobalConfig.trackPlaybackVolume.sliderValues.min)
                                ? AppGlobalConfig.trackPlaybackVolume.sliderValues.max
                                : AppGlobalConfig.trackPlaybackVolume.sliderValues.min);
                            save(track);
                          })),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) => Expanded(
                    child: Slider(
                  value: playbackVolume,
                  min: AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
                  max: AppGlobalConfig.trackPlaybackVolume.sliderValues.max,
                  divisions: AppGlobalConfig.trackPlaybackVolume.sliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackVolume.format(playbackVolume),
                  onChanged: (track.state.value == TrackState.recording)
                      ? null
                      : (double value) {
                          track.setPlaybackVolume(value);
                          save(track);
                        },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackVolume,
            builder: (context, playbackVolume, child) => _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackVolume.format(playbackVolume))),
      ];

  List<Widget> _trackDetailsPlaybackBalanceControl(Track track) => [
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) =>
                _uiWrapper.mediaPlayerButton(track.playbackBalanceIcon, _trans.trackPlaybackBalanceSet(track.name.value),
                    onPressed: (track.state.value == TrackState.recording)
                        ? null
                        : () {
                            track.setPlaybackBalance(0);
                            save(track);
                          })),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) => Expanded(
                    child: Slider(
                  value: playbackBalance,
                  min: AppGlobalConfig.trackPlaybackBalance.sliderValues.min,
                  max: AppGlobalConfig.trackPlaybackBalance.sliderValues.max,
                  divisions: AppGlobalConfig.trackPlaybackBalance.sliderValues.divisions,
                  label: AppGlobalConfig.trackPlaybackBalance.translate(playbackBalance, trans: _trans),
                  onChanged: (track.state.value == TrackState.recording)
                      ? null
                      : (double value) {
                          track.setPlaybackBalance(value);
                          save(track);
                        },
                ))),
        ValueListenableBuilder(
            valueListenable: track.playbackBalance,
            builder: (context, playbackBalance, child) => _uiWrapper.trailingLabel(AppGlobalConfig.trackPlaybackBalance.format(playbackBalance))),
      ];

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(Track track) => [
        if (track.state.value != TrackState.recording) _uiWrapper.trackMenuItem(TrackMenuItem.changeName, AppIcon.trackTitle, _trans.trackNameChange),
        if (track.state.value != TrackState.recording)
          _uiWrapper.trackMenuItem(TrackMenuItem.changeKeyboardKey, AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChange),
        if (track.state.value != TrackState.empty && track.state.value != TrackState.recording)
          _uiWrapper.trackMenuItem(TrackMenuItem.delete, AppIcon.deleteForever, _trans.trackRecordingDelete),
      ];

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection) async {
    switch (selection) {
      case TrackMenuItem.changeName:
        String selectedEmoji = track.name.value;
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                builder: (context, setDialogState) => AlertDialog(
                      title: _uiWrapper.statusIconTile(AppIcon.trackTitle, _trans.trackNameChangeTitle(track.name.value)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_trans.trackNameChangeInfo(track.name.value)),
                          SizedBox(height: Theme.of(context).textTheme.labelSmall!.fontSize),
                          SizedBox(
                              width: double.maxFinite,
                              height: 200,
                              child: EmojiPicker(
                                  onEmojiSelected: (Category? category, Emoji emoji) {
                                    setDialogState(() {
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
                                      emojiSizeMax: Theme.of(context).textTheme.bodyLarge!.fontSize! *
                                          (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.2 : 1.0),
                                      backgroundColor: Colors.transparent,
                                      noRecents: Text(
                                        _trans.noRecents,
                                        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    locale: widget.settingsGet(AppConfigFieldKey.locale),
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
                            track.setName(track.id);
                            save(track);
                            Navigator.pop(context, track.id);
                            _uiWrapper.toast(_trans.trackNameChangeSuccess(track.id), icon: AppIcon.trackTitle);
                          }),
                        _uiWrapper.simpleButton(_trans.buttonCancel, () {
                          Navigator.pop(context, 'cancel');
                        }),
                        _uiWrapper.primaryButton(_trans.buttonSaveTo(selectedEmoji), () {
                          track.setName(selectedEmoji);
                          save(track);
                          Navigator.pop(context, selectedEmoji);
                          _uiWrapper.toast(_trans.trackNameChangeSuccess(selectedEmoji), icon: AppIcon.trackTitle);
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
                          borderRadius: BorderRadius.all(Radius.circular(_uiWrapper.gridGap)),
                        ),
                        backgroundColor: (key == track.keyboardKey.value) ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: () {
                        track.setKeyboardKey(key);
                        save(track);
                        Navigator.pop(context, key);
                        _uiWrapper.toast(_trans.trackKeyboardKeyChangeSuccess(key), icon: AppIcon.trackKeyboardKey);
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
                removeTrackRecording(track);
                save(track);
                Navigator.pop(context, _trans.buttonYes);
                _uiWrapper.toast(_trans.trackRecordingDeleteSuccess(track.name.value), icon: AppIcon.deleteForever);
              }),
            ]);
        break;
    }
  }
}
