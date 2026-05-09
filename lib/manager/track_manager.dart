import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/manager/recording_manager.dart';
import 'package:tune_tangler/manager/track_details_manager.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/keyboard.dart';
import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../src/combined_notifier.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class TrackManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  late final TrackDetailsManager _trackDetailsManager;

  TrackManager(
    this._context,
    this._settings,
    this._trans,
    this._uiHelper,
    this._trackRepository,
    _audioRecorder,
  ) {
    RecordingManager recordingManager = RecordingManager(
      _settings,
      _trans,
      _uiHelper,
      _trackRepository,
      _audioRecorder,
    );
    _trackDetailsManager = TrackDetailsManager(
      _context,
      _settings,
      _trans,
      _uiHelper,
      _trackRepository,
      recordingManager,
    );
  }

  void onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      return;
    }

    bool withControl =
        (HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.controlLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.controlRight,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.control,
        ));

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

  Expanded buildRowTracks(int rowIndex, int colsAmount) => Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: PageScrollPhysics(),
      child: Row(
        children: List.generate(
          colsAmount,
          (columnIndex) => _buildRowTrackContainer(
            _settings.getTrack(rowIndex, columnIndex),
          ),
        ),
      ),
    ),
  );

  Widget _buildRowTrackContainer(Track track) => RepaintBoundary(
    child: Container(
      margin: EdgeInsets.all(UIHelper.gridGap),
      width: Theme.of(_context).textTheme.displaySmall!.fontSize! * 2.1,
      child: ValueListenableBuilder<TrackState>(
        valueListenable: track.state,
        builder: (context, state, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onSecondaryTapDown: (TapDownDetails details) {
              _trackDetailsManager.openModal(track);
            },
            child: ElevatedButton(
              onPressed: () => _trackDetailsManager.runClickAction(track),
              onLongPress: () => _trackDetailsManager.openModal(track),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(UIHelper.gridGap),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIHelper.gridGap * 2),
                ),
                backgroundColor: track.stateBackgroundColor(context),
                foregroundColor: track.stateForegroundColor(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildTrackButton(track),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _buildTrackButton(Track track) => [
    SizedBox(
      height: Theme.of(_context).textTheme.titleLarge!.fontSize! * 3,
      child: Stack(
        fit: StackFit.expand,
        children: (track.state.value == TrackState.processing)
            ? [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: CircularProgressIndicator(
                    strokeWidth: UIHelper.gridGap,
                    color: track.stateProgressColor(_context),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ValueListenableBuilder<String>(
                    valueListenable: track.name,
                    builder: (context, name, child) => Text(
                      _trans.cell(name),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]
            : [
                // Optimized: Single ValueListenableBuilder for frequently changing values
                ValueListenableBuilder(
                  valueListenable: CombinedNotifier([
                    track.state,
                    track.name,
                    track.keyboardKey,
                  ]),
                  builder: (context, _, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      // Grupa 1: Nazwa i klawisz klawiatury (często zmieniające się)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _trans.cell(track.name.value),
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.headlineMedium!.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: AppIcon.trackKeyboardKeyBox(
                          track.keyboardKey.value,
                          foregroundColor: track.stateBackgroundColor(context),
                          backgroundColor: track.stateForegroundColor(context),
                          size: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize!,
                        ),
                      ),

                      // Grupa 2: Ikony stanu i źródła audio (nie zmieniają się często)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          track.stateIcon,
                          size: Theme.of(
                            _context,
                          ).textTheme.titleMedium!.fontSize,
                          color: track.stateForegroundColor(_context),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          track.audioSourceIcon,
                          size: Theme.of(
                            _context,
                          ).textTheme.titleMedium!.fontSize,
                          color: track.stateForegroundColor(_context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Separate ValueListenableBuilder for playback controls (less frequent changes)
                ValueListenableBuilder(
                  valueListenable: CombinedNotifier([
                    track.playbackVolume,
                    track.playbackBalance,
                    track.playbackSpeed,
                    track.playbackReleaseMode,
                  ]),
                  builder: (context, _, _) => Stack(
                    children: [
                      // Kontrolki odtwarzania
                      Align(
                        alignment: Alignment.topCenter,
                        child: Icon(
                          track.playbackVolumeIcon,
                          size: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize,
                          color: track.stateForegroundColor(context),
                        ),
                      ),

                      // Balans audio (tekst + ikona)
                      Align(
                        alignment: AlignmentDirectional(1, -0.3),
                        child: SizedBox(
                          width: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize,
                          height: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize,
                          child: Text(
                            AppGlobalConfig.trackPlaybackBalance.format(
                              track.playbackBalance.value,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.labelSmall!.fontSize,
                              color: track.stateForegroundColor(context),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1, 0.25),
                        child: Icon(
                          AppGlobalConfig.trackPlaybackBalance.icon(
                            track.playbackBalance.value,
                          ),
                          size: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize,
                          color: track.stateForegroundColor(context),
                        ),
                      ),

                      // Prędkość odtwarzania
                      Align(
                        alignment: AlignmentDirectional(-1, 1),
                        child: Text(
                          AppGlobalConfig.trackPlaybackSpeed.format(
                            track.playbackSpeed.value,
                          ),
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.labelMedium!.fontSize,
                            color: track.stateForegroundColor(context),
                          ),
                        ),
                      ),

                      // Tryb odtwarzania
                      Align(
                        alignment: AlignmentDirectional(1, 1),
                        child: Icon(
                          AppGlobalConfig.trackPlaybackReleaseMode.icon(
                            track.playbackReleaseMode.value,
                          ),
                          size: Theme.of(
                            context,
                          ).textTheme.titleMedium!.fontSize,
                          color: track.stateForegroundColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Separate ValueListenableBuilder for position controls (least frequent changes)
                ValueListenableBuilder(
                  valueListenable: CombinedNotifier([
                    track.playbackStartAtPosition,
                    track.playbackEndAtPosition,
                  ]),
                  builder: (context, _, _) => Stack(
                    children: [
                      // Pozycje odtwarzania (start/end)
                      Align(
                        alignment: AlignmentDirectional(0, 0.95),
                        child: Icon(
                          track.playbackStartAtPositionIcon,
                          size: Theme.of(
                            context,
                          ).textTheme.labelLarge!.fontSize,
                          color: track.stateForegroundColor(context),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.3, 0.95),
                        child: Icon(
                          track.playbackEndAtPositionIcon,
                          size: Theme.of(
                            context,
                          ).textTheme.labelLarge!.fontSize,
                          color: track.stateForegroundColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    ),
    if (track.state.value != TrackState.processing)
      (track.state.value == TrackState.recording)
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                color: track.stateForegroundColor(_context),
                backgroundColor: track.stateProgressColor(_context),
              ),
            )
          : ValueListenableBuilder(
              valueListenable: CombinedNotifier([track.progress, track.state]),
              builder: (context, _, _) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: LinearProgressIndicator(
                  value: track.progress.value,
                  color: track.stateForegroundColor(context),
                  backgroundColor: track.stateProgressColor(context),
                ),
              ),
            ),
    if (track.state.value != TrackState.processing)
      ValueListenableBuilder(
        valueListenable: CombinedNotifier([
          track.state,
          track.clock,
          track.durationAfterCut,
        ]),
        builder: (context, _, _) {
          if (track.state.value == TrackState.recording) {
            return _uiHelper.statusIconRow(
              AppIcon.trackTimer,
              _uiHelper.formatTime(track.clock.value.toInt()),
              iconColor: track.stateForegroundColor(context),
              iconSize:
                  Theme.of(context).textTheme.labelLarge!.fontSize! /
                  1.4 *
                  UIHelper.iconSizeMultiplier,
              textColor: track.stateForegroundColor(context),
              fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
            );
          } else {
            return _uiHelper.statusIconRow(
              AppIcon.trackPosition,
              _uiHelper.formatTime(
                track.durationAfterCut.value.inMilliseconds,
              ),
              iconColor: track.stateForegroundColor(context),
              iconSize:
                  Theme.of(context).textTheme.labelLarge!.fontSize! /
                  1.4 *
                  UIHelper.iconSizeMultiplier,
              textColor: track.stateForegroundColor(context),
              fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! / 1.4,
            );
          }
        },
      ),
  ];
}
