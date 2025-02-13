import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/manager/recording_manager.dart';
import 'package:tune_tangler/manager/track_details_manager.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/keyboard.dart';
import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../src/combined_notifier.dart';
import '../wrapper/hive_settings_provider.dart';

class TrackManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  late final TrackDetailsManager _trackDetailsManager;

  TrackManager(this._context, this._settings, this._trans, this._uiHelper, this._trackRepository, _audioRecorder) {
    RecordingManager recordingManager = RecordingManager(_settings, _trans, _uiHelper, _trackRepository, _audioRecorder);
    _trackDetailsManager = TrackDetailsManager(_context, _settings, _trans, _uiHelper, _trackRepository, recordingManager);
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
    for (Track track in _trackRepository.allTracks()) {
      if (track.keyboardKey.value == pressedKeyName) {
        if (withControl) {
          _trackDetailsManager.openModal(track);
        } else {
          _trackDetailsManager.runClickAction(track);
        }
        break;
      }
    }
  }

  Expanded buildRowTracks(int rowIndex) => Expanded(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: PageScrollPhysics(),
          child: Row(
              children: List.generate(
                  _settings.getConfig(AppConfigFieldKey.gridColsAmount),
                  (columnIndex) => _buildRowTrackContainer(
                        _settings.getTrack(rowIndex, columnIndex),
                      )))));

  Container _buildRowTrackContainer(Track track) => Container(
      margin: EdgeInsets.all(UIHelper.gridGap),
      width: Theme.of(_context).textTheme.displaySmall!.fontSize! * 2.1,
      child: ValueListenableBuilder<TrackState>(
          valueListenable: track.state,
          builder: (context, state, child) => ElevatedButton(
                onPressed: () => _trackDetailsManager.runClickAction(track),
                onLongPress: () => _trackDetailsManager.openModal(track),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(UIHelper.gridGap),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UIHelper.gridGap * 2)),
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
                            strokeWidth: UIHelper.gridGap, color: track.stateProgressColor(_context), strokeCap: StrokeCap.round),
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
                                builder: (context, keyboardKey, child) => AppIcon.trackKeyboardKeyBox(keyboardKey,
                                    foregroundColor: track.stateBackgroundColor(context),
                                    backgroundColor: track.stateForegroundColor(context),
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
                            alignment: AlignmentDirectional(1, -0.3),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackBalance,
                                builder: (context, playbackBalance, child) => SizedBox(
                                      width: Theme.of(context).textTheme.titleMedium!.fontSize,
                                      height: Theme.of(context).textTheme.titleMedium!.fontSize,
                                      child: Text(
                                        AppGlobalConfig.trackPlaybackBalance.format(playbackBalance),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, color: track.stateForegroundColor(context)),
                                      ),
                                    ))),
                        Align(
                            alignment: AlignmentDirectional(1, 0.25),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackBalance,
                                builder: (context, playbackBalance, child) => Icon(AppGlobalConfig.trackPlaybackBalance.icon(playbackBalance),
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(-1, 1),
                            child: ValueListenableBuilder<double>(
                                valueListenable: track.playbackSpeed,
                                builder: (context, playbackSpeed, child) => Text(AppGlobalConfig.trackPlaybackSpeed.format(playbackSpeed),
                                    style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.labelMedium!.fontSize, color: track.stateForegroundColor(context))))),
                        Align(
                            alignment: AlignmentDirectional(1, 1),
                            child: ValueListenableBuilder<ReleaseMode>(
                                valueListenable: track.playbackReleaseMode,
                                builder: (context, playbackReleaseMode, child) => Icon(
                                    AppGlobalConfig.trackPlaybackReleaseMode.icon(playbackReleaseMode),
                                    size: Theme.of(context).textTheme.titleMedium!.fontSize,
                                    color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(0, 0.95),
                            child: ValueListenableBuilder<Duration>(
                                valueListenable: track.playbackStartAtPosition,
                                builder: (context, time, child) => Icon(track.playbackStartAtPositionIcon,
                                    size: Theme.of(context).textTheme.labelLarge!.fontSize, color: track.stateForegroundColor(context)))),
                        Align(
                            alignment: AlignmentDirectional(0.3, 0.95),
                            child: ValueListenableBuilder<Duration>(
                                valueListenable: track.playbackEndAtPosition,
                                builder: (context, time, child) => Icon(track.playbackEndAtPositionIcon,
                                    size: Theme.of(context).textTheme.labelLarge!.fontSize, color: track.stateForegroundColor(context)))),
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
                  builder: (context, clock, child) => _uiHelper.statusIconRow(
                        AppIcon.trackTimer,
                        _uiHelper.formatTime(clock.toInt()),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * UIHelper.iconSizeMultiplier,
                        textColor: track.stateForegroundColor(context),
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      ))
              : ValueListenableBuilder(
                  valueListenable: CombinedNotifier([track.durationAfterCut, track.playbackSpeed]),
                  builder: (context, _, __) => _uiHelper.statusIconRow(
                        AppIcon.trackPosition,
                        _uiHelper.formatTime((track.durationAfterCut.value.inMilliseconds * 1 / track.playbackSpeed.value).toInt()),
                        iconColor: track.stateForegroundColor(context),
                        iconSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4 * UIHelper.iconSizeMultiplier,
                        textColor: track.stateForegroundColor(context),
                        fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
                      )),
      ];
}
