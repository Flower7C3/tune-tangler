// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tune Tangler';

  @override
  String get appTitleDebug => 'Tune Tangler (Debug)';

  @override
  String get legalNote => 'Made with ♥️ by Flower7C3';

  @override
  String cell(Object cellName) {
    return '$cellName';
  }

  @override
  String trackTitle(Object trackName) {
    return 'Track $trackName';
  }

  @override
  String get allTracksPlayingStart => 'Start playing all tracks';

  @override
  String get allTracksPlayingStop => 'Stop playing all tracks';

  @override
  String rowTracksPlayingStart(Object rowName) {
    return 'Start playing tracks in row $rowName';
  }

  @override
  String rowTracksPlayingStop(Object rowName) {
    return 'Stop playing tracks in row $rowName';
  }

  @override
  String trackPlayingStart(Object trackName) {
    return 'Start playing track $trackName';
  }

  @override
  String trackPlayingPause(Object trackName) {
    return 'Pause track $trackName';
  }

  @override
  String trackPlayingResume(Object trackName) {
    return 'Resume track $trackName';
  }

  @override
  String trackPlayingStop(Object trackName) {
    return 'Stop track $trackName';
  }

  @override
  String trackPlaybackModeToggle(Object trackName) {
    return 'Toggle playback mode for track $trackName';
  }

  @override
  String trackKeyboardKey(Object trackName) {
    return 'Keyboard shortcut for track $trackName';
  }

  @override
  String get thePlaybackPosition => 'Position';

  @override
  String get thePlaybackTrim => 'Trimming';

  @override
  String get thePlaybackSpeed => 'Playback speed';

  @override
  String get thePlaybackVolume => 'Playback volume';

  @override
  String get thePlaybackBalance => 'Audio balance';

  @override
  String thePlaybackBalanceAt(Object value) {
    return 'Audio balance: $value';
  }

  @override
  String get thePlaybackStartAtPosition => 'Start position';

  @override
  String get thePlaybackEndAtPosition => 'End position';

  @override
  String get trackRecording => 'Recording in progress';

  @override
  String get theAudioSourceRecorded => 'Audio recorded';

  @override
  String get theAudioSourceImported => 'Audio imported';

  @override
  String get theKeyboardKey => 'Keyboard shortcut';

  @override
  String trackRecordingImport(Object trackName) {
    return 'Import a file into track $trackName';
  }

  @override
  String trackRecordingImported(Object trackName) {
    return 'Imported a file into track $trackName.';
  }

  @override
  String trackRecordingImportCancelled(Object trackName) {
    return 'Import cancelled for track $trackName.';
  }

  @override
  String trackRecordingImportNoPermissions(Object trackName) {
    return 'You don’t have permission to import a file into track $trackName.';
  }

  @override
  String trackRecordingInfo(Object trackName) {
    return 'Recording to track $trackName';
  }

  @override
  String get clickToOpenApp => 'Tap to open the app';

  @override
  String trackRecordingStart(Object trackName) {
    return 'Start recording to track $trackName';
  }

  @override
  String get trackRecordingAlreadyStarted =>
      'Another recording has already been started.';

  @override
  String get trackRecordingStartNoAudioPermission =>
      'You don’t have permission to record audio.';

  @override
  String get trackRecordingStartNoNotificationPermission =>
      'You don’t have permission to show recording notifications.';

  @override
  String trackRecordingStartError(Object error, Object trackName) {
    return 'An error occurred while starting recording for track $trackName.\n$error';
  }

  @override
  String trackRecordingCancel(Object trackName) {
    return 'Cancel recording for track $trackName';
  }

  @override
  String trackRecordingCancelled(Object trackName) {
    return 'Cancelled recording for track $trackName.';
  }

  @override
  String trackRecordingStop(Object trackName) {
    return 'Stop recording for track $trackName';
  }

  @override
  String trackRecordingStopSuccess(Object trackName) {
    return 'Recording completed for track $trackName.';
  }

  @override
  String trackRecordingStopError(Object error, Object trackName) {
    return 'An error occurred while finishing recording for track $trackName.\n$error';
  }

  @override
  String trackPlaybackSpeedSet(Object trackName) {
    return 'Set playback speed for track $trackName';
  }

  @override
  String trackPlaybackVolumeSet(Object trackName) {
    return 'Set playback volume for track $trackName';
  }

  @override
  String trackPlaybackBalanceSet(Object trackName) {
    return 'Set playback balance for track $trackName';
  }

  @override
  String get trackPlaybackStartAtPositionSub10 =>
      'Change track playback start at by -0.01 s';

  @override
  String get trackPlaybackStartAtPositionSub100 =>
      'Change track playback start at by -0.1 s';

  @override
  String get trackPlaybackStartAtPositionReset =>
      'Reset track playback start at';

  @override
  String get trackPlaybackStartAtPositionAdd100 =>
      'Change track playback start at by +0.1 s';

  @override
  String get trackPlaybackStartAtPositionAdd10 =>
      'Change track playback start at by +0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub10 =>
      'Change track playback end at by -0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub100 =>
      'Change track playback end at by -0.1 s';

  @override
  String get trackPlaybackEndAtPositionReset => 'Reset track playback end at';

  @override
  String get trackPlaybackEndAtPositionAdd100 =>
      'Change track playback end at by +0.1 s';

  @override
  String get trackPlaybackEndAtPositionAdd10 =>
      'Change track playback end at by +0.01 s';

  @override
  String get trackNameChange => 'Change track name';

  @override
  String trackNameChangeTitle(Object trackName) {
    return 'Change name of $trackName track';
  }

  @override
  String trackNameChangeInfo(Object trackName) {
    return 'Select an icon to use as the new name for track $trackName.';
  }

  @override
  String trackNameChangeSuccess(Object trackName) {
    return 'Track name updated to $trackName.';
  }

  @override
  String get trackKeyboardKeyChange => 'Change keyboard key';

  @override
  String trackKeyboardKeyChangeTitle(Object trackName) {
    return 'Change keyboard key of $trackName track';
  }

  @override
  String trackKeyboardKeyChangeInfo(Object trackName) {
    return 'Select an icon to use as the new keyboard shortcut for track $trackName.';
  }

  @override
  String trackKeyboardKeyChangeSuccess(Object trackName) {
    return 'Shortcut updated for track $trackName.';
  }

  @override
  String get trackRecordingMove => 'Move recording';

  @override
  String trackRecordingMoveTitle(Object trackName) {
    return 'Move recording of $trackName track';
  }

  @override
  String trackRecordingMoveInfo(Object trackName) {
    return 'Select new location for recording of $trackName track.';
  }

  @override
  String trackRecordingMoveSuccess(
    Object firstTrackName,
    Object secondTrackName,
  ) {
    return 'Swapped location of #$firstTrackName and #$secondTrackName recordings.';
  }

  @override
  String get trackRecordingMoveInProgress =>
      'Recording move is already in progress. Please try again in a moment.';

  @override
  String get trackRecordingMoveNotAllowed =>
      'Cannot move tracks during recording, playback, or processing.';

  @override
  String get trackRecordingMoveFailed =>
      'Failed to move tracks. Check if files were moved or deleted and try again.';

  @override
  String trackRecordingShare(Object trackName) {
    return 'Share $trackName track recording';
  }

  @override
  String trackRecordingShareMessage(Object trackName) {
    return 'Here is my recording file for the track $trackName made with the Tune Tangler app!';
  }

  @override
  String trackRecordingShareNoFile(Object trackName) {
    return 'There is no recording file for $trackName track';
  }

  @override
  String trackRecordingShareRaw(Object trackTime) {
    return 'Share raw recording ($trackTime)';
  }

  @override
  String trackRecordingShareProcessed(Object trackTime) {
    return 'Share modified recording ($trackTime)';
  }

  @override
  String trackRecordingShareSuccess(Object trackName) {
    return 'Shared recording for $trackName.';
  }

  @override
  String trackRecordingShareFailed(Object trackName) {
    return 'Failed to share recording for $trackName.';
  }

  @override
  String get trackRecordingDelete => 'Delete recording';

  @override
  String trackRecordingDeleteTitle(Object trackName) {
    return 'Delete $trackName track recording';
  }

  @override
  String trackRecordingDeleteInfo(Object trackName) {
    return 'Recording for $trackName track will be deleted permanently. Continue?';
  }

  @override
  String trackRecordingDeleteSuccess(Object trackName) {
    return 'Deleted recording for $trackName track.';
  }

  @override
  String get rowTracksPlaybackModeSet => 'Playback mode';

  @override
  String rowTracksPlaybackModeSetTitle(Object value) {
    return 'Set $value playback mode';
  }

  @override
  String rowTracksPlaybackModeSetSuccess(Object rowName, Object value) {
    return 'Playback mode for tracks in row $rowName updated to $value.';
  }

  @override
  String get rowTracksPlaybackSpeedSet => 'Playback speed';

  @override
  String rowTracksPlaybackSpeedTitleSet(Object value) {
    return 'Set playback speed to $value';
  }

  @override
  String rowTracksPlaybackSpeedSuccessSet(Object rowName, Object value) {
    return 'Playback speed for tracks in row $rowName updated to $value.';
  }

  @override
  String get rowTracksPlaybackVolumeSet => 'Playback volume';

  @override
  String rowTracksPlaybackVolumeTitleSet(Object value) {
    return 'Set playback volume to $value';
  }

  @override
  String rowTracksPlaybackVolumeSuccessSet(Object rowName, Object value) {
    return 'Volume for tracks in row $rowName updated to $value.';
  }

  @override
  String get rowTracksPlaybackBalanceSet => 'Playback balance';

  @override
  String rowTracksPlaybackBalanceTitleSet(Object value) {
    return 'Set playback balance to $value';
  }

  @override
  String rowTracksPlaybackBalanceSuccessSet(Object rowName, Object value) {
    return 'Balance for tracks in row $rowName updated to $value.';
  }

  @override
  String get rowTracksPlaybackStartAtPositionReset => 'Reset playback start at';

  @override
  String get rowTracksPlaybackStartAtPositionResetTitle =>
      'Reset row tracks playback start at';

  @override
  String rowTracksPlaybackStartAtPositionResetInfo(Object rowName) {
    return 'All tracks in $rowName row will have default playback start at. Continue?';
  }

  @override
  String rowTracksPlaybackStartAtPositionResetSuccess(Object rowName) {
    return 'Playback start reset for tracks in row $rowName.';
  }

  @override
  String get rowTracksPlaybackEndAtPositionReset => 'Reset playback end at';

  @override
  String get rowTracksPlaybackEndAtPositionResetTitle =>
      'Reset row tracks playback end at';

  @override
  String rowTracksPlaybackEndAtPositionResetInfo(Object rowName) {
    return 'All tracks in $rowName row will have default playback end at. Continue?';
  }

  @override
  String rowTracksPlaybackEndAtPositionResetSuccess(Object rowName) {
    return 'Playback end reset for tracks in row $rowName.';
  }

  @override
  String get rowTracksRecordingsDelete => 'Delete recordings';

  @override
  String get rowTracksRecordingsDeleteTitle => 'Delete row recordings';

  @override
  String rowTracksRecordingsDeleteInfo(Object rowName) {
    return 'Recordings for all tracks in $rowName row will be deleted permanently. Continue?';
  }

  @override
  String rowTracksRecordingsDeleteSuccess(Object rowName) {
    return 'Deleted recordings for tracks in $rowName row.';
  }

  @override
  String get balanceLeft100 => 'left 100%, right 0%';

  @override
  String get balanceLeft75 => 'left 100%, right 25%';

  @override
  String get balanceLeft50 => 'left 100%, right 50%';

  @override
  String get balanceLeft25 => 'left 100%, right 75%';

  @override
  String get balanceLeft => 'left 100%';

  @override
  String get balanceCenter => 'center';

  @override
  String get balanceRight => 'right 100%';

  @override
  String get balanceRight25 => 'left 75%, right 100%';

  @override
  String get balanceRight50 => 'left 50%, right 100%';

  @override
  String get balanceRight75 => 'left 25%, right 100%';

  @override
  String get balanceRight100 => 'left 0%, right 100%';

  @override
  String languageWithLocale(Object locale, Object name) {
    return '$name ($locale)';
  }

  @override
  String get keepScreenOnEnabled => 'Keep screen on enabled';

  @override
  String get keepScreenOnDisabled => 'Keep screen on disabled';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get menuKeepScreenOn => 'Keep screen on';

  @override
  String get settingsProfile => 'Settings profile';

  @override
  String get settingsProfiles => 'Settings profiles';

  @override
  String get settingsProfilesListTitle => 'Settings profiles';

  @override
  String get settingsProfilesEmpty => 'Settings profiles list is empty.';

  @override
  String get settingsProfileDelete => 'Delete';

  @override
  String get settingsProfileDeleteTitle => 'Delete Settings profile';

  @override
  String get settingsProfileDeleteInfo =>
      'Settings profile will be deleted. Continue?';

  @override
  String get settingsProfileDeleted => 'Settings profile deleted.';

  @override
  String get settingsProfileCreate => 'Create';

  @override
  String get settingsProfileCreated => 'Settings profile created.';

  @override
  String get settingsProfileSaveSuccess => 'Settings profile saved.';

  @override
  String get settingsProfileLoad => 'Load';

  @override
  String get settingsProfileLoaded => 'Settings profile loaded.';

  @override
  String get helpScreenMessageSettingsProfilesTitle => 'Settings profiles';

  @override
  String get helpScreenMessageSettingsProfilesContent =>
      '\$[settingsProfiles]You can save several profiles. Each profile stores a full set of app settings — for example one for a quiet room and another for a loud rehearsal — and you can switch between them quickly.\n\nEach profile includes:\n• Recording settings (\$[recordingInputDevice]where audio is captured from, \$[recordingAudioEncoder]file format, \$[recordingSampleRate]time resolution, \$[recordingBitRate]bitrate, \$[recordingAudioMode]mono or stereo, \$[recordingAutoGain]automatic level, \$[recordingEchoCancel]less room echo, \$[recordingNoiseSuppress]quieter background noise)\n• Screen settings (\$[language]language, \$[screenThemeMode]light or dark theme, \$[screenThemeColor]accent color, \$[keepScreenOn]keep the screen on)\n\nNew profile: tap \$[create]\"Create\" in the profiles dialog. To load: tap a profile in the list. To remove: \$[touchLong]press and hold a profile, then choose \$[deleteForever]delete.';

  @override
  String get projectExportInfo =>
      'Project export saves all recordings and their parameters to a ZIP file that can be loaded later. Project name is optional and will be added to the file name.';

  @override
  String get settingsProfilesInfo =>
      'Save and restore application configuration. Tap to load a profile, or long-press to see details.';

  @override
  String get moreSettings => 'More settings...';

  @override
  String get help => 'Help';

  @override
  String get helpScreenMessageAboutTitle => 'About';

  @override
  String get helpScreenMessageAboutContent =>
      'A simple grid for musical ideas. Record with the built-in microphone or with USB-connected audio hardware. You can also load a file from the device.\n\nPlay tracks together so they stay in time, or run them independently. Use looping or a single pass — whatever you need.\n\nDon’t worry: all your recordings and settings are kept after you close the app. If you need to, you can share them or save the whole project as a ZIP file.';

  @override
  String get helpScreenMessageGridScreenTitle => 'Tracks grid screen';

  @override
  String get helpScreenMessageGridScreenContent =>
      'Each colored block is a quick control. Tap it, or — with a keyboard connected — press the matching shortcut key. Want sliders and finer options? Hold the block — or, with an external keyboard connected — press your shortcut together with Control \$[controlKey] to open track details. Set each track’s shortcut in its details.\n\nEach grid row also has start/stop for that row and a “⋮” menu with bulk actions for every track in that row (playback mode, level, balance, speed, trim resets, delete that row’s recordings).\n\nIn the side menu, pick a preset shortcut map for your keyboard: standard (PC-style, flexible grid) or the 24-key 6×4 layout.';

  @override
  String get helpScreenMessageDetailsScreenTitle => 'Track details screen';

  @override
  String get helpScreenMessageDetailsScreenContent =>
      'Here you choose how the track should sound. Icons by the options show what you are editing:\n• \$[recordingClip]trim where the sound starts and ends\n• \$[trackPlaybackMode]loop or play once\n• \$[trackPlaybackVolume]volume\n• \$[trackPlaybackBalance]left/right balance\n• \$[trackPlaybackSpeed]speed up or slow down\n• \$[trackName]give the track a name\n• \$[trackKeyboardKey]pick a keyboard shortcut\n\nYou can also \$[trackRecordingMove]move it on the grid, \$[trackRecordingImport]bring in a file, \$[trackRecordingShare]share your work, or \$[deleteForever]delete it.';

  @override
  String get helpScreenMessageTrackStates => 'Track states and what a tap does';

  @override
  String get helpScreenMessageTrackStatesInfo =>
      'A track is always in one of several simple states. One tap usually takes the next sensible step based on the track’s current state.';

  @override
  String get helpScreenMessageTrackIcons => 'Icons on the track block';

  @override
  String get helpScreenMessageTrackIconsInfo =>
      'Icons on the block show quick information: shortcuts, audio source, volume, balance, trim, and whether looping is enabled.';

  @override
  String get helpTrackIconBalanceLeftLegend =>
      'Balance shifted left — the exact value is shown in track details.';

  @override
  String get helpTrackIconBalanceCenterLegend =>
      'Centered balance: left and right channels play at the same level.';

  @override
  String get helpTrackIconBalanceRightLegend =>
      'Balance shifted right — the exact value is shown in track details.';

  @override
  String get helpTrackIconPlaybackStartTrimLegend =>
      'The start of the recording is trimmed — see track details for the trim time.';

  @override
  String get helpTrackIconPlaybackEndTrimLegend =>
      'The end of the recording is trimmed — see track details for the trim time.';

  @override
  String get helpTrackIconSinglePlaybackModeLegend =>
      'Playback: one pass from start to end, then stop.';

  @override
  String get helpTrackIconRepeatPlaybackModeLegend =>
      'Looping playback: when it reaches the end, it returns to the start and continues.';

  @override
  String get helpScreenMessageSettingsInfo =>
      'Tune recording to your phone and environment: \$[recordingAudioEncoder]file format, \$[recordingSampleRate]time resolution, \$[recordingBitRate]bit rate (bitrate), \$[recordingAudioMode]stereo or mono, and — when the device supports it — \$[recordingAutoGain]automatic level control (AGC), \$[recordingEchoCancel]less room echo, and \$[recordingNoiseSuppress]quieter background noise.';

  @override
  String get helpScreenMessageProjectExportImportTitle =>
      'Project export and import';

  @override
  String get helpScreenMessageProjectExportImportContent =>
      'You can \$[projectExport]pack the whole session into one ZIP file — your grid layout, every track’s settings, and the recordings. Later, \$[projectImport]you can load it and pick up exactly where you left off.\n\nThe ZIP archive includes, among other things:\n• Grid size (rows and columns)\n• Names, trims, playback choices, and shortcuts for each track\n• Audio files with a short integrity check\n• A short note (version, export time, a few numbers)\n\nBefore anything is overwritten, you’ll see a preview and a warning. The app checks the file first so it does not load a damaged or incomplete file.';

  @override
  String get stateEmpty => 'empty slot — tap to start recording';

  @override
  String get stateRecording => 'recording… tap to finish and save';

  @override
  String get stateProcessing => 'finishing touches on the file';

  @override
  String get stateIdle => 'ready to play — tap to start';

  @override
  String get statePlaying => 'in the air — tap to stop';

  @override
  String get statePaused => 'taking a breath — tap to resume';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonOk => 'Ok';

  @override
  String get buttonYes => 'Yes';

  @override
  String get buttonNo => 'No';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonReset => 'Reset';

  @override
  String buttonResetTo(Object value) {
    return 'Reset to $value';
  }

  @override
  String get buttonLoad => 'Load';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonSave => 'Save';

  @override
  String buttonSaveTo(Object value) {
    return 'Save as $value';
  }

  @override
  String get buttonSearch => 'Search';

  @override
  String get noRecents => 'No recent items';

  @override
  String get screenSettings => 'Screen settings';

  @override
  String get screen => 'Screen';

  @override
  String get languageVersion => 'Language version';

  @override
  String languageVersionValue(Object value) {
    return 'Language version: $value';
  }

  @override
  String get screenThemeMode => 'Screen theme mode';

  @override
  String screenThemeModeValue(Object value) {
    return 'Screen theme mode: $value';
  }

  @override
  String get screenSystemThemeMode => 'System default';

  @override
  String get screenDarkThemeMode => 'dark mode';

  @override
  String get screenLightThemeMode => 'light mode';

  @override
  String get enabled => 'enabled';

  @override
  String get disabled => 'disabled';

  @override
  String get screenSystemThemeColor => 'System default';

  @override
  String get screenThemeColor => 'Accent color';

  @override
  String screenThemeColorValue(Object value) {
    return 'Theme accent color: $value';
  }

  @override
  String get screenThemeColorTitle => 'Set theme accent color';

  @override
  String get screenThemeColorInfo =>
      'Choose color that will be applied as theme accent.';

  @override
  String screenThemeColorSuccess(Object name) {
    return 'Theme accent color updated to $name.';
  }

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String keepScreenOnValue(Object value) {
    return 'Keep screen on: $value';
  }

  @override
  String get keepScreenOnIsEnabledSuccess => 'Enabled keep screen on feature.';

  @override
  String get keepScreenOnIsDisabledSuccess =>
      'Disabled keep screen on feature.';

  @override
  String get gridRowsAmount => 'Number of rows';

  @override
  String gridRowsAmountValue(Object value) {
    return 'Rows: $value';
  }

  @override
  String get gridRowsAmountTitle => 'Number of rows';

  @override
  String get gridRowsAmountInfo =>
      'Choose how many rows are shown in the tracks grid.';

  @override
  String gridRowsAmountSuccess(Object value) {
    return 'Grid rows set to $value.';
  }

  @override
  String get gridColsAmount => 'Number of columns';

  @override
  String gridColsAmountValue(Object value) {
    return 'Columns: $value';
  }

  @override
  String get gridColsAmountTitle => 'Number of columns';

  @override
  String get gridColsAmountInfo =>
      'Choose how many columns are shown in the tracks grid.';

  @override
  String gridColsAmountSuccess(Object value) {
    return 'Grid columns set to $value.';
  }

  @override
  String get keyboardLayoutPreset => 'Keyboard layout';

  @override
  String get keyboardLayoutPresetInfo =>
      'Standard layout uses the full PC keyboard map. The 24-key layout matches a fixed 6×4 pad and locks the track grid to that size.';

  @override
  String get keyboardLayoutQwertyName => 'Standard (QWERTY)';

  @override
  String get keyboardLayoutGrid24Name => '24 keys (6×4 pad)';

  @override
  String keyboardLayoutPresetSuccess(Object layout) {
    return 'Keyboard layout: $layout.';
  }

  @override
  String keyboardLayoutPresetSuccessWithReset(Object layout) {
    return 'Keyboard layout: $layout. Shortcut keys were reset to defaults.';
  }

  @override
  String get keyboardLayoutChangeTitle => 'Confirm keyboard layout change';

  @override
  String keyboardLayoutChangeIntro(Object fromLayout, Object toLayout) {
    return 'You are switching from $fromLayout to $toLayout.';
  }

  @override
  String get keyboardLayoutChangeDetailGrid24 =>
      'The 24-key layout matches a fixed 6×4 pad. The track grid will always be 6 rows × 4 columns. Shortcuts you created for the full keyboard may not exist on this pad; keeping them can leave some tracks without a matching hardware key.';

  @override
  String get keyboardLayoutChangeDetailQwerty =>
      'The standard layout uses the full PC keyboard map (digits, letter rows, shifted symbols). You can change grid size again in track settings. Shortcuts from the 24-key pad remain valid if the same keys exist on your computer keyboard.';

  @override
  String get keyboardLayoutChangeDecision =>
      'Reset all track shortcut keys to the defaults for the new layout, or keep your current assignments knowing some keys may no longer line up with the new map.';

  @override
  String get keyboardLayoutChangeKeepShortcuts =>
      'Change layout, keep shortcuts';

  @override
  String get keyboardLayoutChangeResetShortcuts => 'Change and reset shortcuts';

  @override
  String get keyboardLayoutGridLockedTitle => 'Grid size (fixed)';

  @override
  String get keyboardLayoutGridLockedSubtitle =>
      'This layout always uses 6 rows and 4 columns.';

  @override
  String get tracksSettings => 'Tracks settings';

  @override
  String get trackSettings => 'Track settings';

  @override
  String get tracks => 'Tracks';

  @override
  String get track => 'Track';

  @override
  String get trackTitleEmojis => 'Track title emojis';

  @override
  String get trackTitleEmojisTitle => 'Track title emojis';

  @override
  String get trackTitleEmojisInfo =>
      'Set emojis that might be used as track title.';

  @override
  String get trackTitleEmojisSuccess => 'Saved emoji list for track titles.';

  @override
  String get allTracksTitleReset => 'Reset track titles';

  @override
  String get allTracksTitleResetTitle => 'Reset track titles';

  @override
  String get allTracksTitleResetInfo =>
      'All tracks will be reset to the default title. Continue?';

  @override
  String get allTracksTitleResetSuccess => 'All track titles have been reset.';

  @override
  String get allTracksShortcutKeyReset => 'Reset track shortcuts';

  @override
  String get allTracksShortcutKeyResetTitle => 'Reset track shortcuts';

  @override
  String get allTracksShortcutKeyResetInfo =>
      'All tracks will be reset to the default shortcut. Continue?';

  @override
  String get allTracksShortcutKeyResetSuccess =>
      'All track shortcuts have been reset.';

  @override
  String get allTracksPlaybackModeSet => 'Set playback mode for all tracks';

  @override
  String get allTracksPlaybackModeTitleSet =>
      'Set playback mode for all tracks';

  @override
  String get allTracksPlaybackModeInfoSet =>
      'Choose the playback mode to apply to all tracks.';

  @override
  String allTracksPlaybackModeSuccessSet(Object mode) {
    return 'Playback mode for all tracks updated to $mode.';
  }

  @override
  String get singlePlaybackMode => 'single';

  @override
  String get repeatPlaybackMode => 'repeat';

  @override
  String get allTracksPlaybackVolumeSet => 'Set volume for all tracks';

  @override
  String get allTracksPlaybackVolumeTitleSet =>
      'Set all tracks playback volume';

  @override
  String get allTracksPlaybackVolumeInfoSet =>
      'Choose the volume to apply to all tracks.';

  @override
  String allTracksPlaybackVolumeSuccessSet(Object value) {
    return 'Volume for all tracks updated to $value.';
  }

  @override
  String get allTracksPlaybackBalanceSet => 'Set balance for all tracks';

  @override
  String get allTracksPlaybackBalanceTitleSet =>
      'Set all tracks playback balance';

  @override
  String get allTracksPlaybackBalanceInfoSet =>
      'Choose the balance to apply to all tracks.';

  @override
  String allTracksPlaybackBalanceSuccessSet(Object value) {
    return 'Balance for all tracks updated to $value.';
  }

  @override
  String get allTracksPlaybackSpeedSet => 'Set playback speed';

  @override
  String get allTracksPlaybackSpeedTitleSet => 'Set all tracks playback speed';

  @override
  String get allTracksPlaybackSpeedInfoSet =>
      'Choose the playback speed to apply to all tracks.';

  @override
  String allTracksPlaybackSpeedSuccessSet(Object value) {
    return 'Playback speed for all tracks updated to $value.';
  }

  @override
  String get allTracksPlaybackStartAtPositionReset => 'Reset playback start at';

  @override
  String get allTracksPlaybackStartAtPositionResetTitle =>
      'Reset all tracks playback start at';

  @override
  String get allTracksPlaybackStartAtPositionResetInfo =>
      'All tracks will have default playback start at. Continue?';

  @override
  String get allTracksPlaybackStartAtPositionResetSuccess =>
      'Playback start reset for all tracks.';

  @override
  String get allTracksPlaybackEndAtPositionReset => 'Reset playback end at';

  @override
  String get allTracksPlaybackEndAtPositionResetTitle =>
      'Reset all tracks playback end at';

  @override
  String get allTracksPlaybackEndAtPositionResetInfo =>
      'All tracks will have default playback end at. Continue?';

  @override
  String get allTracksPlaybackEndAtPositionResetSuccess =>
      'Playback end reset for all tracks.';

  @override
  String get allTracksSettingsReset => 'Reset track settings';

  @override
  String get allTracksSettingsResetTitle => 'Reset track settings';

  @override
  String get allTracksSettingsResetInfo =>
      'All track settings will be reset to defaults. Continue?';

  @override
  String get allTracksSettingsResetSuccess =>
      'All track settings have been reset to defaults.';

  @override
  String get allTracksRecordingsDelete => 'Delete all recordings';

  @override
  String get allTracksRecordingsDeleteTitle => 'Delete all recordings';

  @override
  String get allTracksRecordingsDeleteInfo =>
      'Recordings for all tracks will be deleted permanently. Continue?';

  @override
  String get allTracksRecordingsDeleteSuccess =>
      'Deleted recordings for all tracks.';

  @override
  String get recordingSettings => 'Recording settings';

  @override
  String get settingsChange => 'Change settings';

  @override
  String get recording => 'Recording';

  @override
  String get defaultDevice => 'default';

  @override
  String get recordingInputDevice => 'Device';

  @override
  String recordingInputDeviceValue(Object label) {
    return 'Input device: $label';
  }

  @override
  String get recordingInputDeviceTitle => 'Device';

  @override
  String get recordingInputDeviceInfo =>
      'Choose the input device for recording.';

  @override
  String recordingInputDeviceSuccess(Object value) {
    return 'Input device set to $value.';
  }

  @override
  String get recordingAudioEncoders => 'Audio encoder details';

  @override
  String get recordingAudioEncoder => 'Audio encoder';

  @override
  String recordingAudioEncoderValue(Object value) {
    return 'Audio encoder: $value';
  }

  @override
  String get recordingAudioEncoderTitle => 'Audio encoder';

  @override
  String recordingAudioEncoderSuccess(Object value) {
    return 'Audio encoder set to $value.';
  }

  @override
  String get audioRecorderAacHeName =>
      'MPEG-4 AAC HE (Advanced Audio Codec - High Efficiency)';

  @override
  String get audioRecorderAacHeInfo =>
      'Internet radio and streaming at low bitrates';

  @override
  String get audioRecorderAacHeDetails =>
      'Designed for low bitrates (e.g. 32-64 kbps). Used for radio broadcasts and streaming. Higher latency compared to AAC LC.';

  @override
  String get audioRecorderAacEldName =>
      'MPEG-4 AAC ELD (Advanced Audio Codec - Enhanced Low Delay)';

  @override
  String get audioRecorderAacEldInfo => 'Real-time voice communication';

  @override
  String get audioRecorderAacEldDetails =>
      'Optimized for very low latency. Lower quality than AAC LC, but better for live communication.';

  @override
  String get audioRecorderAacLcName =>
      'MPEG-4 AAC LC (Advanced Audio Codec - Low Complexity)';

  @override
  String get audioRecorderAacLcInfo => 'Good quality music at low bitrates';

  @override
  String get audioRecorderAacLcDetails =>
      'Lossy compression, but better quality than MP3 at the same bitrate. Good for music and video.';

  @override
  String get audioRecorderWavName =>
      'Waveform Audio File (pcm16bit with headers)';

  @override
  String get audioRecorderWavInfo => 'High quality recording';

  @override
  String get audioRecorderWavDetails =>
      'Lossless audio format, uses no compression. Very large files, but excellent quality. Perfect for professional editing and recording.';

  @override
  String get audioRecorderFlacName => 'FLAC (Free Lossless Audio Codec)';

  @override
  String get audioRecorderFlacInfo => 'Audiophile music collection';

  @override
  String get audioRecorderFlacDetails =>
      'Lossless, but compressed (about 50-70% less than WAV). Supports metadata, which WAV cannot. Great for archiving high-quality music.';

  @override
  String recordingDurationValue(Object value) {
    return 'Duration: $value';
  }

  @override
  String get recordingSampleRate => 'Sample rate';

  @override
  String recordingSampleRateValue(Object value) {
    return 'Sample rate: $value';
  }

  @override
  String get recordingSampleRateTitle => 'Sample rate';

  @override
  String get recordingSampleRateInfo =>
      'The sample rate for audio in samples per second (if available on the device).';

  @override
  String recordingSampleRateSuccess(Object value) {
    return 'Sample rate set to $value.';
  }

  @override
  String get recordingBitRate => 'Bit rate';

  @override
  String recordingBitRateValue(Object value) {
    return 'Bit rate: $value';
  }

  @override
  String get recordingBitRateTitle => 'Bit rate';

  @override
  String get recordingBitRateInfo =>
      'The audio encoding bit rate in bits per second (if available on the device).';

  @override
  String recordingBitRateSuccess(Object value) {
    return 'Bit rate set to $value.';
  }

  @override
  String get recordingAudioMode => 'Audio mode';

  @override
  String recordingAudioModeValue(Object value) {
    return 'Audio mode: $value';
  }

  @override
  String recordingAudioModeSuccess(Object value) {
    return 'Audio mode set to $value.';
  }

  @override
  String get recordingAudioModeOptionMono => 'mono';

  @override
  String get recordingAudioModeOptionStereo => 'stereo';

  @override
  String get recordingAutoGain => 'Automatic gain';

  @override
  String recordingAutoGainValue(Object value) {
    return 'Automatic gain: $value';
  }

  @override
  String get recordingAutoGainInfo =>
      'The recorder will try to auto adjust recording volume in a limited range (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingAutoGainSuccess(Object value) {
    return 'Automatic gain set to $value.';
  }

  @override
  String get recordingEchoCancel => 'Echo cancellation';

  @override
  String recordingEchoCancelValue(Object value) {
    return 'Echo cancellation: $value';
  }

  @override
  String get recordingEchoCancelInfo =>
      'The recorder will try to reduce echo (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingEchoCancelSuccess(Object value) {
    return 'Echo cancellation set to $value.';
  }

  @override
  String get recordingNoiseSuppress => 'Noise suppression';

  @override
  String recordingNoiseSuppressValue(Object value) {
    return 'Noise suppression: $value';
  }

  @override
  String get recordingNoiseSuppressInfo =>
      'The recorder will try to reduce input noise (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingNoiseSuppressSuccess(Object value) {
    return 'Noise suppression set to $value.';
  }

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get screenSettingsReset => 'Reset screen settings';

  @override
  String get screenSettingsResetTitle => 'Reset screen settings';

  @override
  String get screenSettingsResetInfo =>
      'All screen settings will be reset to defaults. Continue?';

  @override
  String get screenSettingsResetSuccess =>
      'All screen settings were restored to defaults.';

  @override
  String get recordingSettingsReset => 'Reset recording settings';

  @override
  String get recordingSettingsResetTitle => 'Reset recording settings';

  @override
  String get recordingSettingsResetInfo =>
      'All recording settings will be reset to defaults. Continue?';

  @override
  String get recordingSettingsResetSuccess =>
      'All recording settings were restored to defaults.';

  @override
  String get red => 'red';

  @override
  String get green => 'green';

  @override
  String get blue => 'blue';

  @override
  String get yellow => 'yellow';

  @override
  String get purple => 'purple';

  @override
  String get orange => 'orange';

  @override
  String get cyan => 'cyan';

  @override
  String get pink => 'pink';

  @override
  String get indigo => 'indigo';

  @override
  String get brown => 'brown';

  @override
  String get teal => 'teal';

  @override
  String get black => 'black';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get permissions => 'Permissions';

  @override
  String get audioPermission => 'Read audio file from device';

  @override
  String get microphonePermission => 'Record sound via microphone';

  @override
  String get notificationPermission => 'Display recording state notification';

  @override
  String get permissionStatusGranted => 'Granted';

  @override
  String get permissionStatusDenied => 'Denied';

  @override
  String get permissionStatusPermanentlyDenied =>
      'Permanently denied (settings)';

  @override
  String get permissionStatusRestricted => 'Restricted';

  @override
  String get permissionStatusUndefined => 'Unknown status';

  @override
  String get grantPermission => 'Allow';

  @override
  String get audioWarnings => 'Audio Warnings';

  @override
  String audioWarningsCount(Object count) {
    return 'Warnings ($count)';
  }

  @override
  String get audioWarningFileSize => 'File size';

  @override
  String get audioWarningDuration => 'Recording length';

  @override
  String get audioWarningsSampleRate => 'Sample rate';

  @override
  String get audioWarningBitRate => 'Bit rate';

  @override
  String get audioWarningChannels => 'Audio channels';

  @override
  String get audioWarningFileCorruption => 'File corruption';

  @override
  String audioWarningFileSizeLarge(Object size) {
    return 'Large file ($size MB)';
  }

  @override
  String audioWarningFileSizeVeryLarge(Object size) {
    return 'Very large file ($size MB) — may slow down playback';
  }

  @override
  String audioWarningDurationLong(Object minutes) {
    return 'Long recording ($minutes min)';
  }

  @override
  String audioWarningDurationMedium(Object minutes) {
    return 'Medium recording ($minutes min)';
  }

  @override
  String audioWarningSampleRateNonStandard(Object sampleRate) {
    return 'Non-standard sample rate: $sampleRate Hz';
  }

  @override
  String audioWarningBitRateHigh(Object bitRate) {
    return 'High bitrate: $bitRate kbps';
  }

  @override
  String audioWarningBitRateLow(Object bitRate) {
    return 'Low bitrate: $bitRate kbps';
  }

  @override
  String get audioWarningChannelsMicrophone => 'Microphone recording';

  @override
  String get audioWarningFileNotExists => 'File does not exist';

  @override
  String get audioWarningSuggestionCompress =>
      'Consider compression or splitting into smaller parts';

  @override
  String get audioWarningSuggestionPerformance => 'May affect performance';

  @override
  String get audioWarningSuggestionInterfaceDelays =>
      'May cause interface delays';

  @override
  String get audioWarningSuggestionMultiTrackPerformance =>
      'Watch performance with multiple tracks';

  @override
  String get audioWarningSuggestionCompatibility =>
      'May cause compatibility issues';

  @override
  String get audioWarningSuggestionFileSize => 'May affect file size';

  @override
  String get audioWarningSuggestionAudioQuality => 'May affect audio quality';

  @override
  String get audioWarningSuggestionChannelSettings =>
      'Check audio channel settings';

  @override
  String get audioWarningSuggestionCheckFile =>
      'Check if file was moved or deleted';

  @override
  String get projectExport => 'Save project';

  @override
  String get projectImport => 'Load project';

  @override
  String get projectExportName => 'Project name (optional)';

  @override
  String get projectExportNameHint => 'Enter project name';

  @override
  String get projectExportSuccess => 'Project has been saved';

  @override
  String get projectImportSuccess => 'Project has been loaded';

  @override
  String get projectImportWarning =>
      'Loading a project will overwrite the current session. All recordings will be deleted and track settings will be replaced. Continue?';

  @override
  String get projectImportWarningTitle => 'Warning';

  @override
  String get projectPreview => 'Project preview';

  @override
  String get projectMetadata => 'Project metadata';

  @override
  String get projectName => 'Project name';

  @override
  String get projectVersion => 'Version';

  @override
  String get projectExportDate => 'Export date';

  @override
  String get projectGridSize => 'Grid size';

  @override
  String get projectTotalTracks => 'Total tracks';

  @override
  String get projectTracksWithRecordings => 'Tracks with recordings';

  @override
  String get projectTotalRecordingsSize => 'Recordings size';

  @override
  String get projectExporting => 'Exporting project...';

  @override
  String get projectImporting => 'Loading project...';

  @override
  String get projectExportError => 'Error exporting project';

  @override
  String get projectImportError => 'Error loading project';

  @override
  String get projectInvalidFormat => 'Invalid project file format';

  @override
  String get projectFileNotFound => 'Project file not found';

  @override
  String projectFileMissing(Object fileName) {
    return 'Required file missing: $fileName';
  }

  @override
  String projectFileParseError(Object fileName) {
    return 'Parse error in file $fileName. The file is corrupted or has invalid format.';
  }

  @override
  String projectFileEncodingError(Object fileName) {
    return 'Encoding error in file $fileName. The file may be corrupted or was created in a different version of the application.';
  }

  @override
  String projectFileStructureError(Object fieldName, Object fileName) {
    return 'Invalid structure in file $fileName. Missing required field: $fieldName';
  }

  @override
  String projectFileInvalidValue(Object details, Object fileName) {
    return 'Invalid value in file $fileName: $details';
  }

  @override
  String get projectRecordingNotFound =>
      'Recording listed in project was not found in archive';

  @override
  String get projectMetadataCorrupted =>
      'Project file is corrupted. The metadata.json file cannot be read.';

  @override
  String get projectMetadataEncodingError =>
      'Project file has invalid encoding. The file may be corrupted or was created in a different version of the application.';

  @override
  String get projectMetadataParseError =>
      'Cannot read project data. The metadata.json file is corrupted or has invalid format.';

  @override
  String projectChecksumMismatch(Object fileName) {
    return 'Checksum mismatch for file $fileName';
  }

  @override
  String get projectChecksumMismatchTitle => 'Verification error';

  @override
  String projectDurationMismatch(Object fileName) {
    return 'File length mismatch for $fileName. Playback positions have been reset';
  }

  @override
  String get projectDurationMismatchTitle => 'File length warning';

  @override
  String get projectExportCancel => 'Project export cancelled';

  @override
  String get projectImportCancel => 'Project import cancelled';

  @override
  String get buttonExport => 'Export';

  @override
  String get buttonImport => 'Load';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonYesImport => 'Yes, import';

  @override
  String get projectValidating => 'Validating project...';

  @override
  String get projectValidationFailed => 'Project validation failed';
}
