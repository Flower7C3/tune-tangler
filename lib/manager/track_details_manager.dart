import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/manager/recording_manager.dart';

import '../config/app_config_fields.dart';
import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/keyboard.dart';
import '../config/menu_item_enums.dart';
import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../src/combined_notifier.dart';
import '../src/generated/app_localizations.dart';
import '../src/warnings/audio_quality_checker.dart';
import '../src/warnings/audio_warning.dart';
import '../wrapper/hive_settings_provider.dart';

class TrackDetailsManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;
  final RecordingManager _recordingManager;

  TrackDetailsManager(
    this._context,
    this._settings,
    this._trans,
    this._uiHelper,
    this._trackRepository,
    this._recordingManager,
  );

  void runClickAction(Track track) => switch (track.state.value) {
    TrackState.empty => _recordingManager.startRecording(track),
    TrackState.recording => _recordingManager.stopAndSaveRecording(track),
    TrackState.idle => track.startPlaying(),
    TrackState.playing => track.stopPlaying(),
    TrackState.paused => track.resumePlaying(),
    _ => null,
  };

  /// *************************************************************************
  /// TRACK DETAILS
  void openModal(Track track) {
    showModalBottomSheet<void>(
      context: _context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LayoutBuilder(
        builder: (context, BoxConstraints constraints) =>
            DraggableScrollableSheet(
              expand: false,
              initialChildSize: (640 / constraints.maxHeight).clamp(0.3, 0.9),
              minChildSize: (420 / constraints.maxHeight).clamp(0.3, 0.9),
              maxChildSize: (900 / constraints.maxHeight).clamp(0.3, 0.9),
              builder: (context, ScrollController scrollController) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._trackDetailsTitle(track),
                  _trackDetailsTabs(track),
                  ..._trackDetailsPlayerIcons(track),
                ],
              ),
            ),
      ),
    );
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  List<Widget> _trackDetailsTitle(Track track) => [
    _uiHelper.dragHandle,
    // Optimized: Single ValueListenableBuilder for title with keyboard key
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.state,
        track.name,
        track.keyboardKey,
      ]),
      builder: (context, _, _) => ListTile(
        leading: Tooltip(
          message: AppGlobalConfig.trackState.translate(
            track.state.value,
            trans: _trans,
          ),
          child: Icon(
            track.stateIcon,
            size:
                Theme.of(context).textTheme.headlineMedium!.fontSize! *
                UIHelper.iconSizeMultiplier,
          ),
        ),
        title: Text(_trans.trackTitle(track.name.value)),
        titleAlignment: ListTileTitleAlignment.top,
        titleTextStyle: Theme.of(_context).textTheme.headlineMedium,
        subtitle: Text(
          track.path == null ? '' : path.basename(track.path.toString()),
        ),
        subtitleTextStyle: Theme.of(_context).textTheme.labelSmall,
        trailing: Tooltip(
          message: _trans.trackKeyboardKey(track.name.value),
          child: AppIcon.trackKeyboardKeyBox(
            track.keyboardKey.value,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: track.stateBackgroundColor(context),
            size: Theme.of(context).textTheme.headlineSmall!.fontSize!,
          ),
        ),
      ),
    ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (recorderState != RecorderState.processing)
              TabBar(
                tabs: [
                  if (recorderState == RecorderState.recording)
                    Tab(icon: Icon(AppIcon.recordingInProgress)),
                  if (recorderState == RecorderState.ready)
                    Tab(icon: Icon(AppIcon.recordingProgress)),
                  if (recorderState == RecorderState.empty ||
                      recorderState == RecorderState.ready)
                    Tab(icon: Icon(AppIcon.recordingControls)),
                  if (recorderState == RecorderState.ready)
                    Tab(icon: Icon(AppIcon.recordingInfo)),
                ],
              ),
            if (recorderState != RecorderState.processing)
              Expanded(
                child: TabBarView(
                  children: [
                    if (recorderState == RecorderState.recording)
                      _uiHelper.trackDetailsTabElement([
                        _trackDetailsRecordingBox(track),
                        _trackDetailsInfoBox(track),
                      ]),
                    if (recorderState == RecorderState.ready)
                      _uiHelper.trackDetailsTabElement([
                        _trackDetailsProgress(track),
                        _trackDetailsClip(track),
                      ]),
                    if (recorderState == RecorderState.empty ||
                        recorderState == RecorderState.ready)
                      ValueListenableBuilder(
                        valueListenable: CombinedNotifier([
                          track.playbackVolume,
                          track.playbackBalance,
                          track.playbackSpeed,
                        ]),
                        builder: (context, _, _) =>
                            _uiHelper.trackDetailsTabElement([
                              _trackDetailsPlaybackVolumeControl(track),
                              _trackDetailsPlaybackBalanceControl(track),
                              _trackDetailsPlaybackSpeedControl(track),
                            ]),
                      ),
                    if (recorderState == RecorderState.ready)
                      _uiHelper.trackDetailsTabElement([
                        _trackDetailsInfoBox(track),
                      ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _trackDetailsInfoBox(Track track) => _uiHelper.trackDetailsBox([
    if (track.audioSourceIcon != null && track.path != null)
      _uiHelper.statusIconTile(
        track.audioSourceIcon!,
        path.basename(track.path.toString()),
        iconSize:
            Theme.of(_context).textTheme.bodyLarge!.fontSize! *
            UIHelper.iconSizeMultiplier,
        fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
      ),
    ValueListenableBuilder<Duration>(
      valueListenable: track.duration,
      builder: (context, time, child) => track.duration.value.inMilliseconds > 0
          ? _uiHelper.statusIconTile(
              AppIcon.trackDuration,
              _trans.recordingDurationValue(
                _uiHelper.formatTime(time.inMilliseconds),
              ),
              iconColor: track.stateForegroundColor(context),
              iconSize:
                  Theme.of(_context).textTheme.bodyLarge!.fontSize! *
                  UIHelper.iconSizeMultiplier,
              fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            )
          : SizedBox(height: 0),
    ),
    if (track.audioEncoder != null)
      _uiHelper.statusIconTile(
        AppIcon.recordingAudioEncoder,
        AppGlobalConfig.recordingAudioEncoder.translate(
          track.audioEncoder,
          trans: _trans,
        ),
        iconSize:
            Theme.of(_context).textTheme.bodyLarge!.fontSize! *
            UIHelper.iconSizeMultiplier,
        fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
      ),
    if (track.sampleRate != null)
      _uiHelper.statusIconTile(
        AppIcon.recordingSampleRate,
        _trans.recordingSampleRateValue(
          AppGlobalConfig.recordingSampleRate.format(
            track.sampleRate?.toDouble(),
          ),
        ),
        iconSize:
            Theme.of(_context).textTheme.bodyLarge!.fontSize! *
            UIHelper.iconSizeMultiplier,
        fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
      ),
    if (track.bitRate != null)
      _uiHelper.statusIconTile(
        AppIcon.recordingBitRate,
        _trans.recordingBitRateValue(
          AppGlobalConfig.recordingBitRate.format(track.bitRate?.toDouble()),
        ),
        iconSize:
            Theme.of(_context).textTheme.bodyLarge!.fontSize! *
            UIHelper.iconSizeMultiplier,
        fontSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
      ),
    // Sekcja ostrzeżeń
    _buildWarningsSection(track),
  ]);

  Widget _trackDetailsRecordingBox(Track track) => _uiHelper.trackDetailsBox([
    SizedBox(height: Theme.of(_context).textTheme.titleLarge!.fontSize),
    LinearProgressIndicator(
      color: track.stateForegroundColor(_context),
      backgroundColor: track.stateProgressColor(_context),
    ),
    SizedBox(height: Theme.of(_context).textTheme.titleLarge!.fontSize),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(AppIcon.trackTimer),
        ValueListenableBuilder<double>(
          valueListenable: track.clock,
          builder: (context, clock, child) =>
              Text(_uiHelper.formatTime(clock.toInt())),
        ),
      ],
    ),
  ]);

  Widget _trackDetailsPlaybackVolumeControl(Track track) =>
      _uiHelper.trackDetailsBox([
        ListTile(
          visualDensity: VisualDensity.compact,
          leading: _uiHelper.mediaPlayerButton(
            track.playbackVolumeIcon,
            _trans.trackPlaybackVolumeSet(track.name.value),
            onPressed: () {
              track.setPlaybackVolume(
                (track.playbackVolume.value ==
                        AppGlobalConfig.trackPlaybackVolume.sliderValues.min)
                    ? AppGlobalConfig.trackPlaybackVolume.sliderValues.max
                    : AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
              );
              _trackRepository.save(track);
            },
          ),
          trailing: Text(
            AppGlobalConfig.trackPlaybackVolume.format(
              track.playbackVolume.value,
            ),
          ),
          title: Text(_trans.thePlaybackVolume),
        ),
        Slider(
          value: track.playbackVolume.value,
          min: AppGlobalConfig.trackPlaybackVolume.sliderValues.min,
          max: AppGlobalConfig.trackPlaybackVolume.sliderValues.max,
          divisions: AppGlobalConfig.trackPlaybackVolume.sliderValues.divisions,
          label: AppGlobalConfig.trackPlaybackVolume.format(
            track.playbackVolume.value,
          ),
          onChanged: (double value) => track.setPlaybackVolume(value),
          onChangeEnd: (double value) => _trackRepository.save(track),
        ),
      ]);

  Widget _trackDetailsPlaybackBalanceControl(
    Track track,
  ) => _uiHelper.trackDetailsBox([
    ListTile(
      visualDensity: VisualDensity.compact,
      style: ListTileStyle.drawer,
      leading: _uiHelper.mediaPlayerButton(
        AppGlobalConfig.trackPlaybackBalance.icon(track.playbackBalance.value),
        _trans.trackPlaybackBalanceSet(track.name.value),
        onPressed: () {
          track.setPlaybackBalance(0);
          _trackRepository.save(track);
        },
      ),
      trailing: Text(
        AppGlobalConfig.trackPlaybackBalance.format(
          track.playbackBalance.value,
        ),
      ),
      title: Text(_trans.thePlaybackBalance),
    ),
    SliderTheme(
      data: _uiHelper.balanceSliderThemeData(_context),
      child: Slider(
        value: track.playbackBalance.value,
        min: AppGlobalConfig.trackPlaybackBalance.sliderValues.min,
        max: AppGlobalConfig.trackPlaybackBalance.sliderValues.max,
        divisions: AppGlobalConfig.trackPlaybackBalance.sliderValues.divisions,
        label: AppGlobalConfig.trackPlaybackBalance.translate(
          track.playbackBalance.value,
          trans: _trans,
        ),
        onChanged: (double value) => track.setPlaybackBalance(value),
        onChangeEnd: (double value) => _trackRepository.save(track),
      ),
    ),
  ]);

  Widget _trackDetailsPlaybackSpeedControl(Track track) =>
      _uiHelper.trackDetailsBox([
        ListTile(
          visualDensity: VisualDensity.compact,
          style: ListTileStyle.drawer,
          leading: _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackSpeed,
            _trans.trackPlaybackSpeedSet(track.name.value),
            onPressed: () {
              track.setPlaybackSpeed(1);
              _trackRepository.save(track);
            },
          ),
          trailing: Text(
            AppGlobalConfig.trackPlaybackSpeed.format(
              track.playbackSpeed.value,
            ),
          ),
          title: Text(_trans.thePlaybackSpeed),
        ),
        Slider(
          value: track.playbackSpeed.value,
          min: AppGlobalConfig.trackPlaybackSpeed.sliderValues.min,
          max: AppGlobalConfig.trackPlaybackSpeed.sliderValues.max,
          divisions: AppGlobalConfig.trackPlaybackSpeed.sliderValues.divisions,
          label: AppGlobalConfig.trackPlaybackSpeed.format(
            track.playbackSpeed.value,
          ),
          onChanged: (double value) => track.setPlaybackSpeed(value),
          onChangeEnd: (double value) => _trackRepository.save(track),
        ),
      ]);

  Widget _trackDetailsProgress(Track track) => _uiHelper.trackDetailsBox([
    _uiHelper.trackDetailsLine([
      Expanded(
        child: ListTile(
          visualDensity: VisualDensity.compact,
          leading: Icon(AppIcon.recordingProgressSlider),
          title: Text(_trans.thePlaybackPosition),
        ),
      ),
    ]),
    _uiHelper.trackDetailsLine([_trackDetailsProgressSlider(track)]),
    _uiHelper.trackDetailsLine(
      _trackDetailsProgressText(track),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    ),
  ]);

  Widget _trackDetailsProgressSlider(Track track) => ValueListenableBuilder(
    valueListenable: CombinedNotifier([
      track.duration,
      track.position,
      track.playbackStartAtPosition,
      track.playbackEndAtPosition,
    ]),
    builder: (context, _, _) => Expanded(
      child: Slider(
        min: 0,
        max: track.duration.value.inMilliseconds.toDouble(),
        value: track.position.value.inMilliseconds.toDouble(),
        onChanged: (value) {
          if (track.playbackStartAtPosition.value.inMilliseconds <= value &&
              value <= track.playbackEndAtPosition.value.inMilliseconds) {
            track.player.seek(Duration(milliseconds: value.toInt()));
          }
        },
      ),
    ),
  );

  List<Widget> _trackDetailsProgressText(Track track) => [
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.positionAfterCut,
        track.playbackSpeed,
      ]),
      builder: (context, _, _) => _uiHelper.statusIconRow(
        AppIcon.trackPosition,
        _uiHelper.formatTime(
          (track.positionAfterCut.value.inMilliseconds *
                  1 /
                  track.playbackSpeed.value)
              .toInt(),
        ),
        wrapExpanded: false,
      ),
    ),
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.durationAfterCut,
        track.playbackSpeed,
      ]),
      builder: (context, _, _) => _uiHelper.statusIconRow(
        AppIcon.trackDuration,
        _uiHelper.formatTime(
          (track.durationAfterCut.value.inMilliseconds *
                  1 /
                  track.playbackSpeed.value)
              .toInt(),
        ),
        wrapExpanded: false,
        iconAlignment: IconAlignment.end,
      ),
    ),
  ];

  Widget _trackDetailsClip(Track track) => _uiHelper.trackDetailsBox([
    _uiHelper.trackDetailsLine([
      Expanded(
        child: ListTile(
          visualDensity: VisualDensity.compact,
          leading: Icon(AppIcon.recordingClipSlider),
          title: Text(_trans.thePlaybackTrim),
        ),
      ),
    ]),
    _uiHelper.trackDetailsLine([_trackDetailsClipSlider(track)]),
    _uiHelper.trackDetailsLine(
      _trackDetailsClipText(track),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    ),
    _uiHelper.trackDetailsLine(
      _trackDetailsClipButtons(track),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    ),
  ]);

  Widget _trackDetailsClipSlider(Track track) => ValueListenableBuilder(
    valueListenable: CombinedNotifier([
      track.duration,
      track.playbackStartAtPosition,
      track.playbackEndAtPosition,
    ]),
    builder: (context, _, _) => Expanded(
      child: RangeSlider(
        values: RangeValues(
          (track.playbackStartAtPosition.value.inMilliseconds).toDouble(),
          (track.playbackEndAtPosition.value.inMilliseconds).toDouble(),
        ),
        min: 0,
        max: (track.duration.value.inMilliseconds).toDouble(),
        onChanged: (RangeValues value) =>
            track.setPlaybackStartEndAtPosition(value),
        onChangeEnd: (RangeValues value) => _trackRepository.save(track),
      ),
    ),
  );

  List<Widget> _trackDetailsClipText(Track track) => [
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.playbackStartAtPosition,
        track.playbackSpeed,
      ]),
      builder: (context, _, _) => _uiHelper.statusIconRow(
        AppIcon.trackPlaybackStartAtPosition,
        _uiHelper.formatTime(
          (track.playbackStartAtPosition.value.inMilliseconds *
                  1 /
                  track.playbackSpeed.value)
              .toInt(),
        ),
        wrapExpanded: false,
      ),
    ),
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.playbackEndAtPosition,
        track.playbackSpeed,
      ]),
      builder: (context, _, _) => _uiHelper.statusIconRow(
        AppIcon.trackPlaybackEndAtPosition,
        _uiHelper.formatTime(
          (track.playbackEndAtPosition.value.inMilliseconds *
                  1 /
                  track.playbackSpeed.value)
              .toInt(),
        ),
        wrapExpanded: false,
        iconAlignment: IconAlignment.end,
      ),
    ),
  ];

  List<Widget> _trackDetailsClipButtons(Track track) => [
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.playbackStartAtPosition,
        track.playbackEndAtPosition,
      ]),
      builder: (context, _, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackStartAtPositionReset,
            _trans.trackPlaybackStartAtPositionReset,
            onPressed: (track.playbackStartAtPosition.value.inMilliseconds == 0)
                ? null
                : () => track.resetPlaybackStartAtPosition(),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackPositionSub,
            (track.playbackStartAtPosition.value.inMilliseconds + 100 >
                    track.playbackEndAtPosition.value.inMilliseconds)
                ? _trans.trackPlaybackStartAtPositionSub10
                : _trans.trackPlaybackStartAtPositionSub100,
            onPressed: (track.playbackStartAtPosition.value.inMilliseconds == 0)
                ? null
                : () => track.changePlaybackStartAtPosition(
                    (track.playbackStartAtPosition.value.inMilliseconds + 100 >
                            track.playbackEndAtPosition.value.inMilliseconds)
                        ? -10
                        : -100,
                  ),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackPositionAdd,
            (track.playbackStartAtPosition.value.inMilliseconds + 100 >=
                    track.playbackEndAtPosition.value.inMilliseconds)
                ? _trans.trackPlaybackStartAtPositionAdd10
                : _trans.trackPlaybackStartAtPositionAdd100,
            onPressed:
                (track.playbackStartAtPosition.value.inMilliseconds >
                    track.playbackEndAtPosition.value.inMilliseconds)
                ? null
                : () => track.changePlaybackStartAtPosition(
                    (track.playbackStartAtPosition.value.inMilliseconds + 100 >=
                            track.playbackEndAtPosition.value.inMilliseconds)
                        ? 10
                        : 100,
                  ),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
        ],
      ),
    ),
    ValueListenableBuilder(
      valueListenable: CombinedNotifier([
        track.playbackStartAtPosition,
        track.playbackEndAtPosition,
        track.duration,
      ]),
      builder: (context, _, _) => Row(
        children: [
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackPositionSub,
            (track.playbackEndAtPosition.value.inMilliseconds - 100 <=
                    track.playbackStartAtPosition.value.inMilliseconds)
                ? _trans.trackPlaybackEndAtPositionSub10
                : _trans.trackPlaybackEndAtPositionSub100,
            onPressed:
                (track.playbackEndAtPosition.value.inMilliseconds <
                    track.playbackStartAtPosition.value.inMilliseconds)
                ? null
                : () => track.changePlaybackEndAtPosition(
                    (track.playbackEndAtPosition.value.inMilliseconds - 100 <=
                            track.playbackStartAtPosition.value.inMilliseconds)
                        ? -10
                        : -100,
                  ),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackPositionAdd,
            (track.playbackEndAtPosition.value.inMilliseconds - 100 <
                    track.playbackStartAtPosition.value.inMilliseconds)
                ? _trans.trackPlaybackEndAtPositionAdd10
                : _trans.trackPlaybackEndAtPositionAdd100,
            onPressed:
                (track.playbackEndAtPosition.value.inMilliseconds ==
                    track.duration.value.inMilliseconds)
                ? null
                : () => track.changePlaybackEndAtPosition(
                    (track.playbackEndAtPosition.value.inMilliseconds - 100 <
                            track.playbackStartAtPosition.value.inMilliseconds)
                        ? 10
                        : 100,
                  ),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlaybackEndAtPositionReset,
            _trans.trackPlaybackEndAtPositionReset,
            onPressed:
                (track.playbackEndAtPosition.value.inMilliseconds ==
                    track.duration.value.inMilliseconds)
                ? null
                : () => track.resetPlaybackEndAtPosition(),
            iconSize: Theme.of(_context).textTheme.bodyLarge!.fontSize!,
            boxSize: Theme.of(_context).textTheme.bodyLarge!.fontSize! * 2,
          ),
        ],
      ),
    ),
  ];

  List<Widget> _trackDetailsPlayerIcons(Track track) => [
    const Divider(height: 1),
    Container(
      color: Theme.of(_context).colorScheme.surfaceContainer,
      padding: EdgeInsets.all(
        Theme.of(_context).textTheme.titleSmall!.fontSize!,
      ),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ValueListenableBuilder(
          valueListenable: CombinedNotifier([
            track.recorderState,
            track.state,
            track.playbackReleaseMode,
            track.progress,
          ]),
          builder: (context, recorderState, child) =>
              _uiHelper.trackDetailsLine([
                if (track.recorderState.value != RecorderState.processing)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(-2),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackRecordingShare,
                      _trans.trackRecordingShare(track.name.value),
                      onPressed:
                          (track.recorderState.value == RecorderState.ready)
                          ? () => _share(track)
                          : null,
                    ),
                  ),
                if (track.recorderState.value != RecorderState.processing)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(-1),
                    child: _uiHelper.mediaPlayerButton(
                      AppGlobalConfig.trackPlaybackReleaseMode.icon(
                        track.playbackReleaseMode.value,
                      ),
                      _trans.trackPlaybackModeToggle(track.name.value),
                      onPressed: (track.state.value != TrackState.recording)
                          ? () => _trackRepository.togglePlaybackMode(track)
                          : null,
                    ),
                  ),
                if (track.recorderState.value == RecorderState.empty)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackRecordingStart,
                      _trans.trackRecordingStart(track.name.value),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                      onPressed: () => _recordingManager.startRecording(track),
                    ),
                  ),
                if (track.recorderState.value == RecorderState.recording)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackRecordingStop,
                      _trans.trackRecordingStop(track.name.value),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                      onPressed: () =>
                          _recordingManager.stopAndSaveRecording(track),
                      borderStyle: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(UIHelper.gridGap * 3),
                        ),
                      ),
                    ),
                  ),
                if (track.recorderState.value == RecorderState.recording)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(2),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackRecordingCancel,
                      _trans.trackRecordingCancel(track.name.value),
                      onPressed: () => _recordingManager.cancelRecording(track),
                    ),
                  ),
                if (track.recorderState.value == RecorderState.empty)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(3),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackRecordingImport,
                      _trans.trackRecordingImport(track.name.value),
                      onPressed: () async =>
                          _recordingManager.importRecording(track),
                    ),
                  ),
                if (track.recorderState.value == RecorderState.processing)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(4),
                    child: _uiHelper.mediaPlayerButton(
                      Symbols.hourglass_rounded,
                      _trans.trackRecordingStop(track.name.value),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                      onPressed: null,
                    ),
                  ),
                if (track.state.value == TrackState.idle)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackPlayingStart,
                      _trans.trackPlayingStart(track.name.value),
                      onPressed: () => track.startPlaying(),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                    ),
                  ),
                if (track.state.value == TrackState.playing)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackPlayingPause,
                      _trans.trackPlayingPause(track.name.value),
                      onPressed: () => track.pausePlaying(),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                      borderStyle: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(UIHelper.gridGap * 3),
                        ),
                      ),
                    ),
                  ),
                if (track.state.value == TrackState.paused)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackPlayingResume,
                      _trans.trackPlayingResume(track.name.value),
                      onPressed: () => track.resumePlaying(),
                      iconSize: Theme.of(
                        _context,
                      ).textTheme.displayLarge!.fontSize,
                      borderStyle: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(UIHelper.gridGap * 6),
                        ),
                      ),
                    ),
                  ),
                if (track.recorderState.value == RecorderState.ready)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1),
                    child: _uiHelper.mediaPlayerButton(
                      AppIcon.trackPlayingStop,
                      _trans.trackPlayingStop(track.name.value),
                      onPressed:
                          (track.state.value == TrackState.playing ||
                              track.state.value == TrackState.paused ||
                              track.progress.value > 0)
                          ? () => track.stopPlaying()
                          : null,
                    ),
                  ),
                if (track.recorderState.value != RecorderState.processing)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(7),
                    child: PopupMenuButton<TrackMenuItem>(
                      style: _uiHelper.circledButtonStyle(),
                      icon: Icon(AppIcon.moreMenu),
                      itemBuilder: (BuildContext context) =>
                          _trackMenuItems(track, track.state.value),
                      enabled:
                          (track.state.value != TrackState.recording &&
                          track.state.value != TrackState.processing),
                      onSelected: (TrackMenuItem selection) =>
                          _trackMenuItemSelected(track, selection),
                    ),
                  ),
              ]),
        ),
      ),
    ),
  ];

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(
    Track track,
    TrackState state,
  ) => [
    if (state != TrackState.recording)
      _uiHelper.popupMenuItem<TrackMenuItem>(
        TrackMenuItem.nameChange,
        AppIcon.trackName,
        _trans.trackNameChange,
      ),
    if (state != TrackState.recording)
      _uiHelper.popupMenuItem<TrackMenuItem>(
        TrackMenuItem.keyboardKeyChange,
        AppIcon.trackKeyboardKey,
        _trans.trackKeyboardKeyChange,
      ),
    if (state != TrackState.empty && state != TrackState.recording)
      _uiHelper.popupMenuItem<TrackMenuItem>(
        TrackMenuItem.recordingMove,
        AppIcon.trackRecordingMove,
        _trans.trackRecordingMove,
      ),
    if (state != TrackState.empty && state != TrackState.recording)
      _uiHelper.popupMenuItem<TrackMenuItem>(
        TrackMenuItem.recordingDelete,
        AppIcon.deleteForever,
        _trans.trackRecordingDelete,
      ),
  ];

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection) async {
    switch (selection) {
      case TrackMenuItem.nameChange:
        String selectedEmoji = track.name.value;
        showDialog(
          context: _context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: _uiHelper.statusIconTile(
                AppIcon.trackName,
                _trans.trackNameChangeTitle(track.name.value),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_trans.trackNameChangeInfo(track.name.value)),
                  SizedBox(
                    height: Theme.of(context).textTheme.labelSmall!.fontSize,
                  ),
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
                          emojiSizeMax:
                              Theme.of(
                                context,
                              ).textTheme.headlineLarge!.fontSize! *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.2
                                  : 1.0),
                          columns: 6,
                          backgroundColor: Colors.transparent,
                          noRecents: Text(
                            _trans.noRecents,
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        locale: _settings.getConfig(AppConfigFieldKey.locale),
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
                          buttonIconColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                if (selectedEmoji != track.id.toString())
                  _uiHelper.errorButton(
                    _trans.buttonResetTo(track.id.toString()),
                    () {
                      track.setName(track.id.toString());
                      _trackRepository.save(track);
                      Navigator.pop(context, track.id);
                      _uiHelper.toast(
                        _trans.trackNameChangeSuccess(track.id.toString()),
                        icon: AppIcon.trackName,
                      );
                    },
                  ),
                _uiHelper.simpleButton(
                  _trans.buttonCancel,
                  () => Navigator.pop(context, 'cancel'),
                ),
                _uiHelper.primaryButton(_trans.buttonSaveTo(selectedEmoji), () {
                  track.setName(selectedEmoji);
                  _trackRepository.save(track);
                  Navigator.pop(context, selectedEmoji);
                  _uiHelper.toast(
                    _trans.trackNameChangeSuccess(selectedEmoji),
                    icon: AppIcon.trackName,
                  );
                }),
              ],
            ),
          ),
        );
        break;
      case TrackMenuItem.keyboardKeyChange:
        _uiHelper.alertDialog(
          AppIcon.trackKeyboardKey,
          _trans.trackKeyboardKeyChangeTitle(track.name.value),
          contentText: _trans.trackKeyboardKeyChangeInfo(track.name.value),
          contentWidget: _uiHelper.gridBuilder(
            itemCount: AppKeyboardKeyMap.keyboardKeyNames().length,
            itemBuilder: (context, index) {
              String key = AppKeyboardKeyMap.keyboardKeyName(index);
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(UIHelper.gridGap),
                    ),
                  ),
                  backgroundColor: (key == track.keyboardKey.value)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () {
                  track.setKeyboardKey(key);
                  _trackRepository.save(track);
                  Navigator.pop(context, key);
                  _uiHelper.toast(
                    _trans.trackKeyboardKeyChangeSuccess(key),
                    icon: AppIcon.trackKeyboardKey,
                  );
                },
                child: Text(
                  key,
                  style: TextStyle(
                    color: (key == track.keyboardKey.value)
                        ? Theme.of(context).colorScheme.inversePrimary
                        : null,
                  ),
                ),
              );
            },
          ),
        );
        break;
      case TrackMenuItem.recordingMove:
        _uiHelper.alertDialog(
          AppIcon.trackRecordingMove,
          _trans.trackRecordingMoveTitle(track.name.value),
          contentText: _trans.trackRecordingMoveInfo(track.name.value),
          contentWidget: _uiHelper.gridBuilder(
            itemCount: _trackRepository.allTracks().length,
            rowSize: _settings.getConfig(AppConfigFieldKey.gridColsAmount),
            itemBuilder: (context, index) {
              Track loopTrack = _trackRepository.allTracks().toList().elementAt(
                index,
              );
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(UIHelper.gridGap),
                    ),
                  ),
                  backgroundColor: (loopTrack.id == track.id)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: (loopTrack.id == track.id)
                    ? null
                    : () async {
                        _trackRepository.safeSwapTracks(track, loopTrack);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        _uiHelper.toast(
                          _trans.trackRecordingMoveSuccess(
                            track.id.toString(),
                            loopTrack.id.toString(),
                          ),
                          icon: AppIcon.trackRecordingMove,
                        );
                      },
                child: Text(
                  loopTrack.name.value,
                  style: TextStyle(
                    color: (loopTrack.id == track.id)
                        ? Theme.of(context).colorScheme.inversePrimary
                        : null,
                  ),
                ),
              );
            },
          ),
        );
      case TrackMenuItem.recordingDelete:
        _uiHelper.alertDialog(
          AppIcon.deleteForever,
          _trans.trackRecordingDeleteTitle(track.name.value),
          contentText: _trans.trackRecordingDeleteInfo(track.name.value),
          actions: <Widget>[
            _uiHelper.simpleButton(
              _trans.buttonNo,
              () => Navigator.pop(_context, _trans.buttonNo),
            ),
            _uiHelper.errorButton(_trans.buttonYes, () {
              _trackRepository.trackRecordingDelete(track);
              Navigator.pop(_context, _trans.buttonYes);
              _uiHelper.toast(
                _trans.trackRecordingDeleteSuccess(track.name.value),
                icon: AppIcon.deleteForever,
              );
            }),
          ],
        );
        break;
    }
  }

  void _share(Track track) async {
    if (track.path == null) {
      _uiHelper.toast(
        _trans.trackRecordingShareNoFile(track.name.value),
        icon: AppIcon.trackRecordingShare,
        type: ToastType.error,
        duration: 4,
      );
      return;
    }
    File file = File(track.path!);
    if (file.existsSync() == false) {
      _uiHelper.toast(
        _trans.trackRecordingShareNoFile(track.name.value),
        icon: AppIcon.trackRecordingShare,
        type: ToastType.error,
        duration: 4,
      );
      return;
    }
    SharePlus.instance.share(
      ShareParams(
        text: _trans.trackRecordingShareMessage(track.name.value),
        files: [XFile(track.path!)],
      ),
    );
  }

  /// *************************************************************************
  /// WARNINGS SECTION
  Widget _buildWarningsSection(Track track) {
    final warnings = AudioQualityChecker.checkTrack(track, _trans);

    if (warnings.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      leading: Icon(
        AppIcon.exception,
        color: AudioWarning.getWarningColorForList(warnings),
      ),
      title: Text(_trans.audioWarningsCount(warnings.length.toString())),
      children: warnings.map((warning) => _buildWarningTile(warning)).toList(),
    );
  }

  Widget _buildWarningTile(AudioWarning warning) {
    return ListTile(
      dense: true,
      leading: Icon(
        warning.getWarningTypeIcon(),
        size: 20,
        color: warning.severity.color,
      ),
      title: Text(warning.message, style: const TextStyle(fontSize: 14)),
      subtitle: warning.suggestion != null
          ? Text(
              warning.suggestion!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
    );
  }
}
