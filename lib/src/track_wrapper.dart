import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tune_tangler/config/config_collection.dart';
import 'package:tune_tangler/screen/screen.dart';
import 'package:tune_tangler/src/ui_wrapper.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/fields.dart';
import '../config/keyboard.dart';
import '../config/menu_item.dart';
import '../entity/track.dart';
import '../main.dart';
import 'combined_notifier.dart';

class TrackWrapper {
  final BuildContext _context;
  final ScreenInterface _widget;
  final AppLocalizations _trans;
  final UIWrapper _uiWrapper;

  TrackWrapper(this._context, this._widget, this._trans, this._uiWrapper);

  void initStreams(Track track) {
    if (track.streamsInitialized) {
      return;
    }
    track.setStreamsInitialized();
    save(track);
  }

  void save(Track track) {
    _widget.settingsSet(track.id, track, space: AppConfigSpace.track);
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
    track.setAudioSource(TrackAudioSource.file);
    save(track);

    _uiWrapper.toast(_trans.trackRecordingImported(track.name.value), icon: AppIcon.trackRecordingImport);
  }

  Future<void> _startRecording(Track track) async {
    try {
      if (await _widget.audioRecorder.isRecording()) {
        throw Exception(_trans.trackRecordingAlreadyStarted);
      }
      if (!await _widget.audioRecorder.hasPermission()) {
        throw Exception(_trans.trackRecordingStartNoAudioPermission);
      }
      if (!await Permission.notification.request().isGranted) {
        throw Exception(_trans.trackRecordingStartNoNotificationPermission);
      }

      RecordConfig recordConfig = _widget.settingsGet(AppConfigFieldKey.recording);
      String fileExtension = AppGlobalConfig.recordingAudioEncoder.text(recordConfig.encoder, domain: ConfigItemPropertyDomain.extension);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = await getApplicationDocumentsDirectory().then((value) => '${value.path}/${track.id}.$timestamp.$fileExtension');

      _widget.audioRecorder.start(
        recordConfig,
        path: filePath,
      );

      track.startTimer();

      track.setAudioSource(TrackAudioSource.recording);
      track.setAudioEncoder(recordConfig.encoder);
      track.setSampleRate(recordConfig.sampleRate);
      track.setBitRate(recordConfig.bitRate);
      track.setRecorderState(RecorderState.recording);
      save(track);

      showRecordingNotification(track);
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

    flutterLocalNotificationsPlugin.show(
      0,
      _trans.trackRecordingInfo(track.name.value),
      _trans.clickToOpenApp,
      platformChannelSpecifics,
    );
  }

  Future<void> _cancelRecording(Track track) async {
    _widget.audioRecorder.cancel();
    flutterLocalNotificationsPlugin.cancel(0);
    track.stopTimer();
    track.setPath(null);
    save(track);
    _uiWrapper.toast(_trans.trackRecordingCancelled(track.name.value), icon: AppGlobalConfig.trackState.icon(TrackState.empty));
  }

  Future<void> _stopAndSaveRecording(Track track) async {
    try {
      String? path = await _widget.audioRecorder.stop();
      track.setPath(path);
      _uiWrapper.toast(_trans.trackRecordingStopSuccess(track.name.value), icon: AppGlobalConfig.trackState.icon(TrackState.idle));
    } catch (e) {
      track.setRecorderState(RecorderState.empty);
      _uiWrapper.toast(_trans.trackRecordingStopError(e.toString(), track.name.value), icon: AppIcon.exception, type: ToastType.error, duration: 4);
    }
    flutterLocalNotificationsPlugin.cancel(0);
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

  void setTracksPlaybackMode(Set<Track> tracksList, ReleaseMode value) async {
    for (Track track in tracksList) {
      track.setPlaybackReleaseMode(value);
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

  void resetTracksPlaybackStartAtPosition(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetPlaybackStartAtPosition();
      save(track);
    }
  }

  void resetTracksPlaybackEndAtPosition(Set<Track> tracksList) async {
    for (Track track in tracksList) {
      track.resetPlaybackEndAtPosition();
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

  void resetTracksSettings(Set<Track> tracksList) {
    setTracksPlaybackMode(tracksList, AppGlobalConfig.trackPlaybackReleaseMode.defaultValue);
    setTracksPlaybackBalance(tracksList, AppGlobalConfig.trackPlaybackBalance.defaultValue);
    setTracksPlaybackVolume(tracksList, AppGlobalConfig.trackPlaybackVolume.defaultValue);
    setTracksPlaybackSpeed(tracksList, AppGlobalConfig.trackPlaybackSpeed.defaultValue);
    resetTracksPlaybackStartAtPosition(tracksList);
    resetTracksPlaybackEndAtPosition(tracksList);
    resetTracksName(tracksList);
    resetTracksKeyboardKey(tracksList);
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
    for (Track track in _widget.tracksList.all()) {
      if (track.keyboardKey.value == pressedKeyName) {
        if (withControl) {
          _openTrackDetails(track);
        } else {
          _runTrackPressedAction(track);
        }
        break;
      }
    }
  }

  void _runTrackPressedAction(Track track) {
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
      default:
    }
  }

  Expanded buildRowTracks(int rowIndex) => Expanded(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: PageScrollPhysics(),
          child: Row(
              children: List.generate(
                  _widget.settingsGet(AppConfigFieldKey.gridColsAmount),
                  (columnIndex) => _buildRowTrackContainer(_widget.settingsGet(
                        Track.buildId(rowIndex, columnIndex),
                        space: AppConfigSpace.track,
                        defaultValue: Track(rowIndex, columnIndex),
                      ))))));

  Container _buildRowTrackContainer(Track track) => Container(
      margin: EdgeInsets.all(_uiWrapper.gridGap),
      width: Theme.of(_context).textTheme.displaySmall!.fontSize! * 2.1,
      child: ValueListenableBuilder<TrackState>(
          valueListenable: track.state,
          builder: (context, state, child) => ElevatedButton(
                onPressed: () => _runTrackPressedAction(track),
                onLongPress: () => _openTrackDetails(track),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(_uiWrapper.gridGap),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_uiWrapper.gridGap * 2)),
                  backgroundColor: track.stateBackgroundColor(context),
                  foregroundColor: track.stateForegroundColor(context),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: _buildTrackButton(track)),
              )));

  List<Widget> _buildTrackButton(Track track) => [
        SizedBox(
            height: Theme.of(_context).textTheme.titleLarge!.fontSize! * 3,
            child: Stack(
                fit: StackFit.expand,
                children: (track.state.value == TrackState.processing)
                    ? [
                        CircularProgressIndicator(
                            strokeWidth: _uiWrapper.gridGap, color: track.stateProgressColor(_context), strokeCap: StrokeCap.round),
                        Align(
                            alignment: Alignment.center,
                            child: ValueListenableBuilder<String>(
                                valueListenable: track.name,
                                builder: (context, name, child) => Text(_trans.cell(name),
                                    style: TextStyle(fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize, fontWeight: FontWeight.bold)))),
                      ]
                    : [
                        Align(
                            alignment: Alignment.center,
                            child: ValueListenableBuilder<String>(
                                valueListenable: track.name,
                                builder: (context, name, child) => Text(_trans.cell(name),
                                    style: TextStyle(fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize, fontWeight: FontWeight.bold)))),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Icon(track.stateIcon,
                                size: Theme.of(_context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(_context))),
                        Align(
                            alignment: Alignment.topRight,
                            child: ValueListenableBuilder<String>(
                                valueListenable: track.keyboardKey,
                                builder: (context, keyboardKey, child) => AppIcon.trackKeyboardKeyBox(track,
                                    ui: _uiWrapper,
                                    context: context,
                                    foregroundColor: track.stateForegroundColor(context),
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize!))),
                        Align(
                            alignment: Alignment.topCenter,
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackVolume,
                                builder: (context, playbackVolume, child) => Icon(track.playbackVolumeIcon,
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(track.audioSourceIcon,
                                size: Theme.of(_context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(_context))),
                        Align(
                            alignment: AlignmentDirectional(1, -0.25),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackBalance,
                                builder: (context, playbackBalance, child) => Text(AppGlobalConfig.trackPlaybackBalance.text(playbackBalance),
                                    style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, color: track.stateForegroundColor(context))))),
                        Align(
                            alignment: AlignmentDirectional(1, 0.25),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackBalance,
                                builder: (context, playbackBalance, child) => Icon(track.playbackBalanceIcon,
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(-1, 1),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackSpeed,
                                builder: (context, playbackSpeed, child) => Text(AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed),
                                    style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize, color: track.stateForegroundColor(context))))),
                        Align(
                            alignment: AlignmentDirectional(1, 1),
                            child: ValueListenableBuilder<ReleaseMode>(
                                valueListenable: track.playbackReleaseMode,
                                builder: (context, playbackModeSingle, child) => Icon(track.playbackModeIcon,
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(-0.1, 1),
                            child: ValueListenableBuilder<Duration>(
                                valueListenable: track.playbackStartAtPosition,
                                builder: (context, time, child) => Icon(track.playbackStartAtPositionIcon,
                                    size: Theme.of(context).textTheme.titleSmall!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(0.3, 1),
                            child: ValueListenableBuilder<Duration>(
                                valueListenable: track.playbackEndAtPosition,
                                builder: (context, time, child) => Icon(track.playbackEndAtPositionIcon,
                                    size: Theme.of(context).textTheme.titleSmall!.fontSize, color: track.stateForegroundColor(context)))),
                      ])),
        if (track.state.value != TrackState.processing)
          (track.state.value == TrackState.recording)
              ? LinearProgressIndicator(
                  color: track.stateForegroundColor(_context),
                  backgroundColor: track.stateProgressColor(_context),
                )
              : ValueListenableBuilder<double>(
                  valueListenable: track.progress,
                  builder: (context, progress, child) => LinearProgressIndicator(
                    value: progress,
                    color: track.stateForegroundColor(context),
                    backgroundColor: track.stateProgressColor(context),
                  ),
                ),
        if (track.state.value != TrackState.processing)
          (track.state.value == TrackState.recording)
              ? ValueListenableBuilder<double>(
                  valueListenable: track.clock,
                  builder: (context, clock, child) => _uiWrapper.statusIconRow(
                        AppIcon.trackTimer,
                        _uiWrapper.formatTime(clock.toInt()),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * _uiWrapper.iconSizeMultiplier,
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      ))
              : ValueListenableBuilder<Duration>(
                  valueListenable: track.durationAfterCut,
                  builder: (context, time, child) => _uiWrapper.statusIconRow(
                        AppIcon.trackPosition,
                        _uiWrapper.formatTime(time.inMilliseconds),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * _uiWrapper.iconSizeMultiplier,
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      )),
      ];

  /// *************************************************************************
  /// TRACK DETAILS
  void _openTrackDetails(Track track) {
    showModalBottomSheet<void>(
        context: _context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => LayoutBuilder(
            builder: (context, BoxConstraints constraints) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: (640 / constraints.maxHeight).clamp(0.3, 0.9),
                minChildSize: (420 / constraints.maxHeight).clamp(0.3, 0.9),
                maxChildSize: (900 / constraints.maxHeight).clamp(0.3, 0.9),
                builder: (context, ScrollController scrollController) => Column(mainAxisSize: MainAxisSize.min, children: [
                      ..._trackDetailsTitle(track),
                      _trackDetailsTabs(track),
                      ..._trackDetailsPlayerIcons(track),
                    ]))));
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  List<Widget> _trackDetailsTitle(Track track) => [
        _uiWrapper.dragHandle,
        ListTile(
          leading: ValueListenableBuilder<TrackState>(
              valueListenable: track.state,
              builder: (context, state, child) => Tooltip(
                    message: AppGlobalConfig.trackState.translate(state, trans: _trans),
                    child: Icon(track.stateIcon, size: Theme.of(context).textTheme.headlineMedium!.fontSize! * _uiWrapper.iconSizeMultiplier),
                  )),
          trailing: ValueListenableBuilder(
              valueListenable: CombinedNotifier([track.name, track.keyboardKey]),
              builder: (context, name, child) => Tooltip(
                  message: _trans.trackKeyboardKey(track.name.value),
                  child: AppIcon.trackKeyboardKeyBox(
                    track,
                    ui: _uiWrapper,
                    context: context,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    size: Theme.of(context).textTheme.headlineSmall!.fontSize!,
                  ))),
          title: ValueListenableBuilder<String>(
            valueListenable: track.name,
            builder: (context, name, child) => Text(_trans.trackTitle(name)),
          ),
          titleAlignment: ListTileTitleAlignment.top,
          titleTextStyle: Theme.of(_context).textTheme.headlineMedium,
          subtitle: ValueListenableBuilder<TrackState>(
            valueListenable: track.state,
            builder: (context, state, child) => Text(track.path == null ? '' : path.basename(track.path.toString())),
          ),
          subtitleTextStyle: Theme.of(_context).textTheme.labelSmall,
        )
      ];

  Expanded _trackDetailsTabs(Track track) => Expanded(
      child: ValueListenableBuilder<RecorderState>(
          valueListenable: track.recorderState,
          builder: (context, recorderState, child) => DefaultTabController(
              length: switch (recorderState) {
                RecorderState.empty => 1,
                RecorderState.processing => 0,
                RecorderState.recording => 1,
                RecorderState.ready => 3,
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (recorderState != RecorderState.processing)
                  TabBar(
                    tabs: [
                      if (recorderState == RecorderState.recording) Tab(icon: Icon(AppIcon.recordingInProgress)),
                      if (recorderState == RecorderState.ready) Tab(icon: Icon(AppIcon.recordingProgress)),
                      if (recorderState == RecorderState.empty || recorderState == RecorderState.ready) Tab(icon: Icon(AppIcon.recordingControls)),
                      if (recorderState == RecorderState.ready) Tab(icon: Icon(AppIcon.recordingInfo)),
                    ],
                  ),
                if (recorderState != RecorderState.processing)
                  Expanded(
                      child: TabBarView(children: [
                    if (recorderState == RecorderState.recording)
                      _uiWrapper.trackDetailsTabElement([
                        _trackDetailsRecordingBox(track),
                        _trackDetailsInfoBox(track),
                      ]),
                    if (recorderState == RecorderState.ready)
                      _uiWrapper.trackDetailsTabElement([
                        _trackDetailsProgress(track),
                        _trackDetailsClip(track),
                      ]),
                    if (recorderState == RecorderState.empty || recorderState == RecorderState.ready)
                      _uiWrapper.trackDetailsTabElement([
                        _trackDetailsPlaybackVolumeControl(track),
                        _trackDetailsPlaybackBalanceControl(track),
                        _trackDetailsPlaybackSpeedControl(track),
                      ]),
                    if (recorderState == RecorderState.ready)
                      _uiWrapper.trackDetailsTabElement([
                        _trackDetailsInfoBox(track),
                      ]),
                  ]))
              ]))));

  _trackDetailsInfoBox(Track track) => _uiWrapper.trackDetailsBox([
        if (track.audioSourceIcon != null && track.path != null)
          _uiWrapper.statusIconTile(track.audioSourceIcon!, path.basename(track.path.toString()),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
              fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!),
        if (track.audioEncoder != null)
          _uiWrapper.statusIconTile(AppIcon.recordingAudioEncoder, AppGlobalConfig.recordingAudioEncoder.translate(track.audioEncoder, trans: _trans),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
              fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!),
        if (track.sampleRate != null)
          _uiWrapper.statusIconTile(
              AppIcon.recordingSampleRate, _trans.recordingSampleRateValue(AppGlobalConfig.recordingSampleRate.format(track.sampleRate?.toDouble())),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
              fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!),
        if (track.bitRate != null)
          _uiWrapper.statusIconTile(
              AppIcon.recordingBitRate, _trans.recordingBitRateValue(AppGlobalConfig.recordingBitRate.format(track.bitRate?.toDouble())),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * _uiWrapper.iconSizeMultiplier,
              fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!),
      ]);

  _trackDetailsRecordingBox(Track track) => _uiWrapper.trackDetailsBox([
        LinearProgressIndicator(color: track.stateForegroundColor(_context), backgroundColor: track.stateProgressColor(_context)),
        SizedBox(height: Theme.of(_context).textTheme.titleLarge!.fontSize),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(AppIcon.trackTimer),
          ValueListenableBuilder<double>(
              valueListenable: track.clock, builder: (context, clock, child) => Text(_uiWrapper.formatTime(clock.toInt()))),
        ]),
      ]);

  Widget _trackDetailsPlaybackVolumeControl(Track track) => ValueListenableBuilder<double>(
      valueListenable: track.playbackVolume,
      child: Text(_trans.thePlaybackVolume),
      builder: (context, playbackVolume, child) => _uiWrapper.trackDetailsBox([
            ListTile(
              visualDensity: VisualDensity.compact,
              leading: _uiWrapper.mediaPlayerButton(
                track.playbackVolumeIcon,
                _trans.trackPlaybackVolumeSet(track.name.value),
                onPressed: () {
                  track.setPlaybackVolume((playbackVolume == AppGlobalConfig.trackPlaybackVolume.sliderValues.min)
                      ? AppGlobalConfig.trackPlaybackVolume.sliderValues.max
                      : AppGlobalConfig.trackPlaybackVolume.sliderValues.min);
                  save(track);
                },
              ),
              trailing: Text(AppGlobalConfig.trackPlaybackVolume.format(playbackVolume)),
              title: child,
            ),
            Slider(
              value: playbackVolume,
              min: AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
              max: AppGlobalConfig.trackPlaybackVolume.sliderValues.max,
              divisions: AppGlobalConfig.trackPlaybackVolume.sliderValues.divisions,
              label: AppGlobalConfig.trackPlaybackVolume.format(playbackVolume),
              onChanged: (double value) {
                track.setPlaybackVolume(value);
                save(track);
              },
            ),
          ]));

  Widget _trackDetailsPlaybackBalanceControl(Track track) => ValueListenableBuilder<double>(
      valueListenable: track.playbackBalance,
      child: Text(_trans.thePlaybackBalance),
      builder: (context, playbackBalance, child) => _uiWrapper.trackDetailsBox([
            ListTile(
              visualDensity: VisualDensity.compact,
              style: ListTileStyle.drawer,
              leading: _uiWrapper.mediaPlayerButton(
                track.playbackBalanceIcon,
                _trans.trackPlaybackBalanceSet(track.name.value),
                onPressed: () {
                  track.setPlaybackBalance(0);
                  save(track);
                },
              ),
              trailing: Text(AppGlobalConfig.trackPlaybackBalance.format(playbackBalance)),
              title: child,
            ),
            Slider(
              value: playbackBalance,
              min: AppGlobalConfig.trackPlaybackBalance.sliderValues.min,
              max: AppGlobalConfig.trackPlaybackBalance.sliderValues.max,
              divisions: AppGlobalConfig.trackPlaybackBalance.sliderValues.divisions,
              label: AppGlobalConfig.trackPlaybackBalance.translate(playbackBalance, trans: _trans),
              onChanged: (double value) {
                track.setPlaybackBalance(value);
                save(track);
              },
            ),
          ]));

  Widget _trackDetailsPlaybackSpeedControl(Track track) => ValueListenableBuilder<double>(
      valueListenable: track.playbackSpeed,
      child: Text(_trans.thePlaybackSpeed),
      builder: (context, playbackSpeed, child) => _uiWrapper.trackDetailsBox([
            ListTile(
              visualDensity: VisualDensity.compact,
              style: ListTileStyle.drawer,
              leading: _uiWrapper.mediaPlayerButton(
                AppIcon.trackPlaybackSpeed,
                _trans.trackPlaybackSpeedSet(track.name.value),
                onPressed: () {
                  track.setPlaybackSpeed(1);
                  save(track);
                },
              ),
              trailing: Text(AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed)),
              title: child,
            ),
            Slider(
              value: playbackSpeed,
              min: AppGlobalConfig.trackPlaybackSpeed.sliderValues.min,
              max: AppGlobalConfig.trackPlaybackSpeed.sliderValues.max,
              divisions: AppGlobalConfig.trackPlaybackSpeed.sliderValues.divisions,
              label: AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed),
              onChanged: (double value) {
                track.setPlaybackSpeed(value);
                save(track);
              },
            ),
          ]));

  Widget _trackDetailsProgress(Track track) => _uiWrapper.trackDetailsBox([
        _uiWrapper.trackDetailsLine([
          Expanded(
              child: ListTile(
                  visualDensity: VisualDensity.compact, leading: Icon(AppIcon.recordingProgressSlider), title: Text(_trans.thePlaybackPosition)))
        ]),
        _uiWrapper.trackDetailsLine([_trackDetailsProgressSlider(track)]),
        _uiWrapper.trackDetailsLine(_trackDetailsProgressText(track), mainAxisAlignment: MainAxisAlignment.spaceAround),
      ]);

  Widget _trackDetailsProgressSlider(Track track) => ValueListenableBuilder(
      valueListenable: CombinedNotifier([track.duration, track.position, track.playbackStartAtPosition, track.playbackEndAtPosition]),
      builder: (context, _, __) => Expanded(
          child: Slider(
              min: 0,
              max: track.duration.value.inMilliseconds.toDouble(),
              value: track.position.value.inMilliseconds.toDouble(),
              onChanged: (value) {
                if (track.playbackStartAtPosition.value.inMilliseconds <= value && value <= track.playbackEndAtPosition.value.inMilliseconds) {
                  track.player.seek(Duration(milliseconds: value.toInt()));
                }
              })));

  List<Widget> _trackDetailsProgressText(Track track) => [
        ValueListenableBuilder<Duration>(
            valueListenable: track.positionAfterCut,
            builder: (context, time, child) => _uiWrapper.statusIconRow(
                  AppIcon.trackPosition,
                  _uiWrapper.formatTime(time.inMilliseconds),
                  wrapExpanded: false,
                )),
        ValueListenableBuilder<Duration>(
            valueListenable: track.durationAfterCut,
            builder: (context, time, child) => _uiWrapper.statusIconRow(
                  AppIcon.trackDuration,
                  _uiWrapper.formatTime(time.inMilliseconds),
                  wrapExpanded: false,
                  iconAlignment: IconAlignment.end,
                )),
      ];

  Widget _trackDetailsClip(Track track) => _uiWrapper.trackDetailsBox([
        _uiWrapper.trackDetailsLine([
          Expanded(
              child: ListTile(
            visualDensity: VisualDensity.compact,
            leading: Transform.rotate(angle: 90 * (3.1415927 / 180), child: Icon(AppIcon.recordingClipSlider)),
            title: Text(_trans.thePlaybackTrim),
          ))
        ]),
        _uiWrapper.trackDetailsLine([_trackDetailsClipSlider(track)]),
        _uiWrapper.trackDetailsLine(_trackDetailsClipText(track), mainAxisAlignment: MainAxisAlignment.spaceAround),
        _uiWrapper.trackDetailsLine(_trackDetailsClipButtons(track), mainAxisAlignment: MainAxisAlignment.spaceAround),
      ]);

  Widget _trackDetailsClipSlider(Track track) => ValueListenableBuilder(
      valueListenable: CombinedNotifier([track.duration, track.playbackStartAtPosition, track.playbackEndAtPosition]),
      builder: (context, _, __) => Expanded(
          child: RangeSlider(
              values: RangeValues(
                  (track.playbackStartAtPosition.value.inMilliseconds).toDouble(), (track.playbackEndAtPosition.value.inMilliseconds).toDouble()),
              min: 0,
              max: (track.duration.value.inMilliseconds).toDouble(),
              onChanged: (RangeValues value) {
                track.setPlaybackStartAtPosition(Duration(milliseconds: value.start.toInt()));
                track.setPlaybackEndAtPosition(Duration(milliseconds: value.end.toInt()));
                save(track);
              })));

  List<Widget> _trackDetailsClipText(Track track) => [
        ValueListenableBuilder<Duration>(
            valueListenable: track.playbackStartAtPosition,
            builder: (context, startAt, child) => _uiWrapper.statusIconRow(
                  AppIcon.trackPlaybackStartAtPosition,
                  _uiWrapper.formatTime(startAt.inMilliseconds),
                  wrapExpanded: false,
                )),
        ValueListenableBuilder<Duration>(
            valueListenable: track.playbackEndAtPosition,
            builder: (context, endAt, child) => _uiWrapper.statusIconRow(
                  AppIcon.trackPlaybackEndAtPosition,
                  _uiWrapper.formatTime(endAt.inMilliseconds),
                  wrapExpanded: false,
                  iconAlignment: IconAlignment.end,
                )),
      ];

  List<Widget> _trackDetailsClipButtons(Track track) => [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionSub100,
              _trans.trackPlaybackStartAtPositionSub100,
              onPressed: () => track.changePlaybackStartAtPosition(-100),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionReset,
              _trans.trackPlaybackStartAtPositionReset,
              onPressed: () => track.resetPlaybackStartAtPosition(),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionAdd100,
              _trans.trackPlaybackStartAtPositionAdd100,
              onPressed: () => track.changePlaybackStartAtPosition(100),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
          ],
        ),
        Row(
          children: [
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionSub100,
              _trans.trackPlaybackEndAtPositionSub100,
              onPressed: () => track.changePlaybackEndAtPosition(-100),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionReset,
              _trans.trackPlaybackEndAtPositionReset,
              onPressed: () => track.resetPlaybackEndAtPosition(),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
            _uiWrapper.mediaPlayerButton(
              AppIcon.trackPlaybackPositionAdd100,
              _trans.trackPlaybackEndAtPositionAdd100,
              onPressed: () => track.changePlaybackEndAtPosition(100),
              iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
              boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
            ),
          ],
        ),
      ];

  List<Widget> _trackDetailsPlayerIcons(Track track) => [
        const Divider(height: 1),
        Container(
          color: Theme.of(_context).colorScheme.surfaceContainer,
          padding: EdgeInsets.all(Theme.of(_context).textTheme.titleSmall!.fontSize!),
          child: ValueListenableBuilder(
            valueListenable: CombinedNotifier([track.recorderState, track.state]),
            builder: (context, recorderState, child) => _uiWrapper.trackDetailsLine(
              [
                if (track.recorderState.value != RecorderState.processing)
                  _uiWrapper.mediaPlayerButton(
                    AppIcon.trackRecordingShare,
                    _trans.trackRecordingShare(track.name.value),
                    onPressed: (track.recorderState.value == RecorderState.ready)
                        ? () {
                            if (track.path == null) {
                              _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                                  icon: AppIcon.trackRecordingShare, type: ToastType.error, duration: 4);
                              return;
                            }
                            File file = File(track.path!);
                            if (file.existsSync() == false) {
                              _uiWrapper.toast(_trans.trackRecordingShareNoFile(track.name.value),
                                  icon: AppIcon.trackRecordingShare, type: ToastType.error, duration: 4);
                              return;
                            }
                            Share.shareXFiles([XFile(track.path!)], text: _trans.trackRecordingShareMessage(track.name.value));
                          }
                        : null,
                  ),
                if (track.recorderState.value != RecorderState.processing)
                  ValueListenableBuilder<ReleaseMode>(
                      valueListenable: track.playbackReleaseMode,
                      builder: (context, playbackModeSingle, child) => _uiWrapper.mediaPlayerButton(
                            track.playbackModeIcon,
                            _trans.trackPlaybackModeToggle(track.name.value),
                            onPressed: (track.state.value != TrackState.recording)
                                ? () {
                                    track.togglePlaybackMode();
                                    save(track);
                                  }
                                : null,
                          )),
                if (track.recorderState.value == RecorderState.empty)
                  _uiWrapper.mediaPlayerButton(
                    AppIcon.trackRecordingStart,
                    _trans.trackRecordingStart(track.name.value),
                    iconSize: Theme.of(_context).textTheme.displayLarge!.fontSize,
                    onPressed: () => _startRecording(track),
                  ),
                if (track.recorderState.value == RecorderState.empty)
                  _uiWrapper.mediaPlayerButton(
                    AppIcon.trackRecordingImport,
                    _trans.trackRecordingImport(track.name.value),
                    onPressed: () async => _importRecording(track),
                  ),
                if (track.recorderState.value == RecorderState.recording)
                  _uiWrapper.mediaPlayerButton(
                    AppIcon.trackRecordingStop,
                    _trans.trackRecordingStop(track.name.value),
                    iconSize: Theme.of(_context).textTheme.displayLarge!.fontSize,
                    onPressed: () => _stopAndSaveRecording(track),
                  ),
                if (track.recorderState.value == RecorderState.recording)
                  _uiWrapper.mediaPlayerButton(
                    AppIcon.trackRecordingCancel,
                    _trans.trackRecordingCancel(track.name.value),
                    onPressed: () => _cancelRecording(track),
                  ),
                if (track.recorderState.value == RecorderState.processing)
                  _uiWrapper.mediaPlayerButton(
                    Symbols.hourglass_rounded,
                    _trans.trackRecordingStop(track.name.value),
                    iconSize: Theme.of(_context).textTheme.displayLarge!.fontSize,
                    onPressed: null,
                  ),
                if (track.recorderState.value == RecorderState.ready)
                  _uiWrapper.mediaPlayerButton(
                    (track.state.value == TrackState.paused)
                        ? AppIcon.trackPlayingResume
                        : ((track.state.value == TrackState.playing) ? AppIcon.trackPlayingPause : AppIcon.trackPlayingStart),
                    (track.state.value == TrackState.paused)
                        ? _trans.trackPlayingResume(track.name.value)
                        : ((track.state.value == TrackState.playing)
                            ? _trans.trackPlayingPause(track.name.value)
                            : _trans.trackPlayingStart(track.name.value)),
                    onPressed: (track.state.value == TrackState.paused)
                        ? () {
                            track.resumePlaying();
                            save(track);
                          }
                        : ((track.state.value == TrackState.playing)
                            ? () {
                                track.pausePLaying();
                                save(track);
                              }
                            : ((track.state.value == TrackState.idle)
                                ? () {
                                    track.startPlaying();
                                    save(track);
                                  }
                                : null)),
                    iconSize: Theme.of(_context).textTheme.displayLarge!.fontSize,
                  ),
                if (track.recorderState.value == RecorderState.ready)
                  ValueListenableBuilder<double>(
                      valueListenable: track.progress,
                      builder: (context, progress, child) =>
                          _uiWrapper.mediaPlayerButton(AppIcon.trackPlayingStop, _trans.trackPlayingStop(track.name.value),
                              onPressed: (track.state.value == TrackState.playing || track.state.value == TrackState.paused || progress > 0)
                                  ? () {
                                      track.stopPlaying();
                                      save(track);
                                    }
                                  : null)),
                if (track.recorderState.value != RecorderState.processing)
                  PopupMenuButton<TrackMenuItem>(
                    style: _uiWrapper.circledButtonStyle(),
                    icon: Icon(AppIcon.moreMenu),
                    itemBuilder: (BuildContext context) => _trackMenuItems(track, track.state.value),
                    enabled: (track.state.value != TrackState.recording && track.state.value != TrackState.processing),
                    onSelected: (TrackMenuItem selection) => _trackMenuItemSelected(track, selection),
                  ),
              ],
            ),
          ),
        ),
      ];

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(Track track, TrackState state) => [
        if (state != TrackState.recording) _uiWrapper.trackMenuItem(TrackMenuItem.changeName, AppIcon.trackTitle, _trans.trackNameChange),
        if (state != TrackState.recording)
          _uiWrapper.trackMenuItem(TrackMenuItem.changeKeyboardKey, AppIcon.trackKeyboardKey, _trans.trackKeyboardKeyChange),
        if (state != TrackState.empty && state != TrackState.recording)
          _uiWrapper.trackMenuItem(TrackMenuItem.delete, AppIcon.deleteForever, _trans.trackRecordingDelete),
      ];

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection) async {
    switch (selection) {
      case TrackMenuItem.changeName:
        String selectedEmoji = track.name.value;
        showDialog(
            context: _context,
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
                                      emojiSizeMax: Theme.of(context).textTheme.headlineLarge!.fontSize! *
                                          (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.2 : 1.0),
                                      columns: 6,
                                      backgroundColor: Colors.transparent,
                                      noRecents: Text(
                                        _trans.noRecents,
                                        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    locale: _widget.settingsGet(AppConfigFieldKey.locale),
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
                        _uiWrapper.simpleButton(_trans.buttonCancel, () => Navigator.pop(context, 'cancel')),
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
              _uiWrapper.simpleButton(_trans.buttonNo, () => Navigator.pop(_context, _trans.buttonNo)),
              _uiWrapper.errorButton(_trans.buttonYes, () {
                removeTrackRecording(track);
                save(track);
                Navigator.pop(_context, _trans.buttonYes);
                _uiWrapper.toast(_trans.trackRecordingDeleteSuccess(track.name.value), icon: AppIcon.deleteForever);
              }),
            ]);
        break;
    }
  }

  void initTracks({bool forceRebuild = false}) {
    if (forceRebuild == true) {
      _widget.tracksList.reset();
    }
    for (int rowIndex = 0; rowIndex < _widget.settingsGet(AppConfigFieldKey.gridRowsAmount); rowIndex++) {
      for (int columnIndex = 0; columnIndex < _widget.settingsGet(AppConfigFieldKey.gridColsAmount); columnIndex++) {
        String trackId = Track.buildId(rowIndex, columnIndex);
        Track track = _widget.settingsGet(trackId, space: AppConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));
        _widget.tracksList.add(rowIndex, track);
        initStreams(track);
      }
    }
  }
}
