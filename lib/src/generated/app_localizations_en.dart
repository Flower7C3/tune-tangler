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
    return 'Start playing tracks in $rowName row';
  }

  @override
  String rowTracksPlayingStop(Object rowName) {
    return 'Stop playing tracks in $rowName row';
  }

  @override
  String trackPlayingStart(Object trackName) {
    return 'Start playing $trackName track';
  }

  @override
  String trackPlayingPause(Object trackName) {
    return 'Pause playing $trackName track';
  }

  @override
  String trackPlayingResume(Object trackName) {
    return 'Resume playing $trackName track';
  }

  @override
  String trackPlayingStop(Object trackName) {
    return 'Stop playing $trackName track';
  }

  @override
  String trackPlaybackModeToggle(Object trackName) {
    return 'Toggle playback mode for $trackName track';
  }

  @override
  String trackKeyboardKey(Object trackName) {
    return 'Keyboard key for $trackName track';
  }

  @override
  String get thePlaybackPosition => 'Position';

  @override
  String get thePlaybackTrim => 'Trimming';

  @override
  String get thePlaybackSpeed => 'Playback speed rate';

  @override
  String get thePlaybackVolume => 'Playback volume value';

  @override
  String get thePlaybackBalance => 'Audio balance';

  @override
  String thePlaybackBalanceAt(Object value) {
    return 'Audio balance to $value';
  }

  @override
  String get thePlaybackStartAtPosition => 'Start at position';

  @override
  String get thePlaybackEndAtPosition => 'End at position';

  @override
  String get trackRecording => 'On air';

  @override
  String get theAudioSourceRecorded => 'Audio recorded';

  @override
  String get theAudioSourceImported => 'Audio imported';

  @override
  String get theKeyboardKey => 'Keyboard shortcut key';

  @override
  String trackRecordingImport(Object trackName) {
    return 'Import file to $trackName track';
  }

  @override
  String trackRecordingImported(Object trackName) {
    return 'Imported file to $trackName track.';
  }

  @override
  String trackRecordingImportCancelled(Object trackName) {
    return 'Cancelled import file to $trackName track.';
  }

  @override
  String trackRecordingImportNoPermissions(Object trackName) {
    return 'No permissions to import file to $trackName track.';
  }

  @override
  String trackRecordingInfo(Object trackName) {
    return 'Recording to $trackName track';
  }

  @override
  String get clickToOpenApp => 'Touch to open app';

  @override
  String trackRecordingStart(Object trackName) {
    return 'Start recording to $trackName track';
  }

  @override
  String get trackRecordingAlreadyStarted => 'Another recording has already been started.';

  @override
  String get trackRecordingStartNoAudioPermission => 'No permissions to audio recording.';

  @override
  String get trackRecordingStartNoNotificationPermission => 'No permissions to recording notification.';

  @override
  String trackRecordingStartError(Object error, Object trackName) {
    return 'Error during start recording $trackName track.\n$error';
  }

  @override
  String trackRecordingCancel(Object trackName) {
    return 'Cancel recording to $trackName track';
  }

  @override
  String trackRecordingCancelled(Object trackName) {
    return 'Canceled recording $trackName track.';
  }

  @override
  String trackRecordingStop(Object trackName) {
    return 'Stop recording to $trackName track';
  }

  @override
  String trackRecordingStopSuccess(Object trackName) {
    return 'Recording $trackName track complete.';
  }

  @override
  String trackRecordingStopError(Object error, Object trackName) {
    return 'Error during finalize recording $trackName track.\n$error';
  }

  @override
  String trackPlaybackSpeedSet(Object trackName) {
    return 'Set track $trackName playback speed';
  }

  @override
  String trackPlaybackVolumeSet(Object trackName) {
    return 'Set track $trackName playback volume';
  }

  @override
  String trackPlaybackBalanceSet(Object trackName) {
    return 'Set track $trackName playback balance';
  }

  @override
  String get trackPlaybackStartAtPositionSub10 => 'Change track playback start at by -0.01 s';

  @override
  String get trackPlaybackStartAtPositionSub100 => 'Change track playback start at by -0.1 s';

  @override
  String get trackPlaybackStartAtPositionReset => 'Reset track playback start at';

  @override
  String get trackPlaybackStartAtPositionAdd100 => 'Change track playback start at by +0.1 s';

  @override
  String get trackPlaybackStartAtPositionAdd10 => 'Change track playback start at by +0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub10 => 'Change track playback end at by -0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub100 => 'Change track playback end at by -0.1 s';

  @override
  String get trackPlaybackEndAtPositionReset => 'Reset track playback end at';

  @override
  String get trackPlaybackEndAtPositionAdd100 => 'Change track playback end at by +0.1 s';

  @override
  String get trackPlaybackEndAtPositionAdd10 => 'Change track playback end at by +0.01 s';

  @override
  String get trackNameChange => 'Change track name';

  @override
  String trackNameChangeTitle(Object trackName) {
    return 'Change name of $trackName track';
  }

  @override
  String trackNameChangeInfo(Object trackName) {
    return 'Select icon to be setted as new name for $trackName track.';
  }

  @override
  String trackNameChangeSuccess(Object trackName) {
    return 'Setted new track name to $trackName.';
  }

  @override
  String get trackKeyboardKeyChange => 'Change keyboard key';

  @override
  String trackKeyboardKeyChangeTitle(Object trackName) {
    return 'Change keyboard key of $trackName track';
  }

  @override
  String trackKeyboardKeyChangeInfo(Object trackName) {
    return 'Select icon to be setted as new keyboard key for $trackName track.';
  }

  @override
  String trackKeyboardKeyChangeSuccess(Object trackName) {
    return 'Setted new keyboard key to $trackName.';
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
  String trackRecordingMoveSuccess(Object firstTrackName, Object secondTrackName) {
    return 'Swapped location of #$firstTrackName and #$secondTrackName recordings.';
  }

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
    return 'Setted playback mode for tracks in $rowName row to $value.';
  }

  @override
  String get rowTracksPlaybackSpeedSet => 'Playback speed';

  @override
  String rowTracksPlaybackSpeedTitleSet(Object value) {
    return 'Set playback speed to $value';
  }

  @override
  String rowTracksPlaybackSpeedSuccessSet(Object rowName, Object value) {
    return 'Setted playback speed for tracks in $rowName row to $value.';
  }

  @override
  String get rowTracksPlaybackVolumeSet => 'Playback volume';

  @override
  String rowTracksPlaybackVolumeTitleSet(Object value) {
    return 'Set playback volume to $value';
  }

  @override
  String rowTracksPlaybackVolumeSuccessSet(Object rowName, Object value) {
    return 'Setted volume for tracks in $rowName row to $value.';
  }

  @override
  String get rowTracksPlaybackBalanceSet => 'Playback balance';

  @override
  String rowTracksPlaybackBalanceTitleSet(Object value) {
    return 'Set playback balance to $value';
  }

  @override
  String rowTracksPlaybackBalanceSuccessSet(Object rowName, Object value) {
    return 'Setted balance for tracks in $rowName row to $value.';
  }

  @override
  String get rowTracksPlaybackStartAtPositionReset => 'Reset playback start at';

  @override
  String get rowTracksPlaybackStartAtPositionResetTitle => 'Reset row tracks playback start at';

  @override
  String rowTracksPlaybackStartAtPositionResetInfo(Object rowName) {
    return 'All tracks in $rowName row will have default playback start at. Continue?';
  }

  @override
  String rowTracksPlaybackStartAtPositionResetSuccess(Object rowName) {
    return 'Resetted row tracks playback start at in $rowName row.';
  }

  @override
  String get rowTracksPlaybackEndAtPositionReset => 'Reset playback end at';

  @override
  String get rowTracksPlaybackEndAtPositionResetTitle => 'Reset row tracks playback end at';

  @override
  String rowTracksPlaybackEndAtPositionResetInfo(Object rowName) {
    return 'All tracks in $rowName row will have default playback end at. Continue?';
  }

  @override
  String rowTracksPlaybackEndAtPositionResetSuccess(Object rowName) {
    return 'Resetted all tracks playback end at in $rowName row.';
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
  String get balanceLeft100 => 'left 100%';

  @override
  String get balanceLeft75 => 'left 75%';

  @override
  String get balanceLeft50 => 'left 50%';

  @override
  String get balanceLeft25 => 'left 25%';

  @override
  String get balanceLeft => 'left';

  @override
  String get balanceCenter => 'center';

  @override
  String get balanceRight => 'right';

  @override
  String get balanceRight25 => 'right 25%';

  @override
  String get balanceRight50 => 'right 50%';

  @override
  String get balanceRight75 => 'right 75%';

  @override
  String get balanceRight100 => 'right 100%';

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
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get helpScreenMessageAboutTitle => 'About';

  @override
  String get helpScreenMessageAboutContent => 'This application allows you to record audio from a microphone or USB audio interface (your device must support USB OTG technology) to one of several tracks. You can also import an existing audio file.\n\nRecordings can be played synchronously or asynchronously, in a loop or not.\n\nRecordings and their settings, as well as the graphic mode and language, are remembered after the application is closed.';

  @override
  String get helpScreenMessageGridScreenTitle => 'Tracks grid screen';

  @override
  String get helpScreenMessageGridScreenContent => 'Short press a colored track block or use a hotkey (visible at the top of the track) to perform one of the available actions.\n\nHold the track block or use the hotkey with the Control key \$[controlKey] to open the track details.';

  @override
  String get helpScreenMessageDetailsScreenTitle => 'Track details screen';

  @override
  String get helpScreenMessageDetailsScreenContent => 'There are several settings, such as: \$[recordingClip]recording trimming, \$[trackPlaybackMode]playback mode, \$[trackPlaybackVolume]playback volume value, \$[trackPlaybackBalance]audio balance, \$[trackPlaybackSpeed]playback speed, \$[trackName]track name, \$[trackKeyboardKey]track keyboard shortcut. You can also \$[trackRecordingMove]change the track location on the grid, \$[trackRecordingImport]import recording file, \$[trackRecordingShare]share or \$[deleteForever]delete recording.';

  @override
  String get helpScreenMessageTrackStates => 'Track states and actions';

  @override
  String get helpScreenMessageTrackIcons => 'Track info icons';

  @override
  String get helpScreenMessageSettingsInfo => 'You can set \$[recordingAudioEncoder]audio codec, \$[recordingSampleRate]sample rate, \$[recordingBitRate]bit rate, \$[recordingAudioMode]audio mode, \$[recordingAudioGain]auto gain, \$[recordingEchoCancel]echo cancel and \$[recordingNoiseSuppress]noise suppression.';

  @override
  String get stateEmpty => 'track empty (click on box to start recording)';

  @override
  String get stateRecording => 'recording in progress (click on box to stop recording)';

  @override
  String get stateProcessing => 'track processing in progress';

  @override
  String get stateIdle => 'idle: recording done/playing stopped (click on box to start playing)';

  @override
  String get statePlaying => 'playing started track (click on box to stop playing)';

  @override
  String get statePaused => 'playing paused (click on box to unpause playing)';

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
  String get buttonSave => 'Save';

  @override
  String buttonSaveTo(Object value) {
    return 'Save as $value';
  }

  @override
  String get buttonSearch => 'Search';

  @override
  String get noRecents => 'No Recents';

  @override
  String get screenSettings => 'Screen settings';

  @override
  String get screen => 'Screen';

  @override
  String get languageVersion => 'Language version';

  @override
  String get screenThemeMode => 'Screen theme mode';

  @override
  String get screenSystemThemeMode => 'device settings';

  @override
  String get screenDarkThemeMode => 'dark mode';

  @override
  String get screenLightThemeMode => 'light mode';

  @override
  String get enabled => 'enabled';

  @override
  String get disabled => 'disabled';

  @override
  String get screenThemeColor => 'Theme accent color';

  @override
  String get screenThemeColorTitle => 'Set theme accent color';

  @override
  String get screenThemeColorInfo => 'Choose color that will be applied as theme accent.';

  @override
  String screenThemeColorSuccess(Object name) {
    return 'Setted theme accent color to $name.';
  }

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get keepScreenOnIsEnabledSuccess => 'Enabled keep screen on feature.';

  @override
  String get keepScreenOnIsDisabledSuccess => 'Disabled keep screen on feature.';

  @override
  String get gridRowsAmount => 'Grid rows amount';

  @override
  String get gridRowsAmountTitle => 'Grid rows amount';

  @override
  String get gridRowsAmountInfo => 'Set grid rows amount, that will be visible on tracks list.';

  @override
  String gridRowsAmountSuccess(Object value) {
    return 'Setted grid rows amount to $value.';
  }

  @override
  String get gridColsAmount => 'Grid columns amount';

  @override
  String get gridColsAmountTitle => 'Grid columns amount';

  @override
  String get gridColsAmountInfo => 'Set grid columns amount, that will be visible on tracks list.';

  @override
  String gridColsAmountSuccess(Object value) {
    return 'Setted grid columns amount to $value.';
  }

  @override
  String get trackSettings => 'Track settings';

  @override
  String get track => 'Track';

  @override
  String get trackTitleEmojis => 'Track title emojis';

  @override
  String get trackTitleEmojisTitle => 'Track title emojis';

  @override
  String get trackTitleEmojisInfo => 'Set emojis that might be used as track title.';

  @override
  String get trackTitleEmojisSuccess => 'Setted emojis that might be used as track title.';

  @override
  String get allTracksTitleReset => 'Reset tracks title';

  @override
  String get allTracksTitleResetTitle => 'Reset tracks title';

  @override
  String get allTracksTitleResetInfo => 'All tracks will have default title. Continue?';

  @override
  String get allTracksTitleResetSuccess => 'Resetted all tracks title.';

  @override
  String get allTracksShortcutKeyReset => 'Reset tracks shortcut key';

  @override
  String get allTracksShortcutKeyResetTitle => 'Reset all tracks shortcut key';

  @override
  String get allTracksShortcutKeyResetInfo => 'All tracks will have default shortcut key. Continue?';

  @override
  String get allTracksShortcutKeyResetSuccess => 'Resetted all tracks shortcut key.';

  @override
  String get allTracksPlaybackModeSet => 'Set tracks playback mode';

  @override
  String get allTracksPlaybackModeTitleSet => 'Set all tracks playback mode';

  @override
  String get allTracksPlaybackModeInfoSet => 'Select playback mode to which all track will be setted.';

  @override
  String allTracksPlaybackModeSuccessSet(Object mode) {
    return 'Setted all tracks playback mode to $mode.';
  }

  @override
  String get singlePlaybackMode => 'single';

  @override
  String get repeatPlaybackMode => 'repeat';

  @override
  String get allTracksPlaybackVolumeSet => 'Set tracks volume';

  @override
  String get allTracksPlaybackVolumeTitleSet => 'Set all tracks playback volume';

  @override
  String get allTracksPlaybackVolumeInfoSet => 'Select volume to which all track will be setted.';

  @override
  String allTracksPlaybackVolumeSuccessSet(Object value) {
    return 'Setted all tracks playback volume to $value.';
  }

  @override
  String get allTracksPlaybackBalanceSet => 'Set tracks balance';

  @override
  String get allTracksPlaybackBalanceTitleSet => 'Set all tracks playback balance';

  @override
  String get allTracksPlaybackBalanceInfoSet => 'Select balance to which all track will be setted.';

  @override
  String allTracksPlaybackBalanceSuccessSet(Object value) {
    return 'Setted all tracks playback balance to $value.';
  }

  @override
  String get allTracksPlaybackSpeedSet => 'Set playback speed';

  @override
  String get allTracksPlaybackSpeedTitleSet => 'Set all tracks playback speed';

  @override
  String get allTracksPlaybackSpeedInfoSet => 'Select track speed which all track will be setted.';

  @override
  String allTracksPlaybackSpeedSuccessSet(Object value) {
    return 'Setted all tracks playback speed to $value.';
  }

  @override
  String get allTracksPlaybackStartAtPositionReset => 'Reset playback start at';

  @override
  String get allTracksPlaybackStartAtPositionResetTitle => 'Reset all tracks playback start at';

  @override
  String get allTracksPlaybackStartAtPositionResetInfo => 'All tracks will have default playback start at. Continue?';

  @override
  String get allTracksPlaybackStartAtPositionResetSuccess => 'Resetted all tracks playback start at.';

  @override
  String get allTracksPlaybackEndAtPositionReset => 'Reset playback end at';

  @override
  String get allTracksPlaybackEndAtPositionResetTitle => 'Reset all tracks playback end at';

  @override
  String get allTracksPlaybackEndAtPositionResetInfo => 'All tracks will have default playback end at. Continue?';

  @override
  String get allTracksPlaybackEndAtPositionResetSuccess => 'Resetted all tracks playback end at.';

  @override
  String get allTracksSettingsReset => 'Reset tracks settings';

  @override
  String get allTracksSettingsResetTitle => 'Reset all tracks settings';

  @override
  String get allTracksSettingsResetInfo => 'All all tracks settings will be restored to default. Continue?';

  @override
  String get allTracksSettingsResetSuccess => 'All all tracks settings was restored to default.';

  @override
  String get allTracksRecordingsDelete => 'Delete tracks recordings';

  @override
  String get allTracksRecordingsDeleteTitle => 'Delete all tracks recordings';

  @override
  String get allTracksRecordingsDeleteInfo => 'Recordings for all track will be deleted permanently. Continue?';

  @override
  String get allTracksRecordingsDeleteSuccess => 'Deleted recordings for all tracks.';

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
  String get recordingInputDeviceInfo => 'Set device for sound recording.';

  @override
  String recordingInputDeviceSuccess(Object value) {
    return 'Setted device to $value.';
  }

  @override
  String get recordingAudioEncoders => 'Audio encoders details';

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
    return 'Setted audio encoder to $value.';
  }

  @override
  String get audioRecorderAacHeName => 'MPEG-4 AAC HE (Advanced Audio Codec - High Efficiency)';

  @override
  String get audioRecorderAacHeInfo => 'Internet radio and streaming at low bitrates';

  @override
  String get audioRecorderAacHeDetails => 'Designed for low bitrates (e.g. 32-64 kbps). Used for radio broadcasts and streaming. Higher latency compared to AAC LC.';

  @override
  String get audioRecorderAacEldName => 'MPEG-4 AAC ELD (Advanced Audio Codec - Enhanced Low Delay)';

  @override
  String get audioRecorderAacEldInfo => 'Real-time voice communication';

  @override
  String get audioRecorderAacEldDetails => 'Optimized for very low latency. Lower quality than AAC LC, but better for live communication.';

  @override
  String get audioRecorderAacLcName => 'MPEG-4 AAC LC (Advanced Audio Codec - Low Complexity)';

  @override
  String get audioRecorderAacLcInfo => 'Good quality music at low bitrates';

  @override
  String get audioRecorderAacLcDetails => 'Lossy compression, but better quality than MP3 at the same bitrate. Good for music and video.';

  @override
  String get audioRecorderWavName => 'Waveform Audio File (pcm16bit with headers)';

  @override
  String get audioRecorderWavInfo => 'High quality recording';

  @override
  String get audioRecorderWavDetails => 'Lossless audio format, uses no compression. Very large files, but excellent quality. Perfect for professional editing and recording.';

  @override
  String get audioRecorderFlacName => 'FLAC (Free Lossless Audio Codec)';

  @override
  String get audioRecorderFlacInfo => 'Audiophile music collection';

  @override
  String get audioRecorderFlacDetails => 'Lossless, but compressed (about 50-70% less than WAV). Supports metadata, which WAV cannot. Great for archiving high-quality music.';

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
  String get recordingSampleRateInfo => 'The sample rate for audio in samples per second (if available on the device).';

  @override
  String recordingSampleRateSuccess(Object value) {
    return 'Setted recording sample rate to $value.';
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
  String get recordingBitRateInfo => 'The audio encoding bit rate in bits per second (if available on the device).';

  @override
  String recordingBitRateSuccess(Object value) {
    return 'Setted recording bit rate to $value.';
  }

  @override
  String get recordingAudioMode => 'Audio mode';

  @override
  String recordingAudioModeValue(Object value) {
    return 'Audio rate: $value';
  }

  @override
  String recordingAudioModeSuccess(Object value) {
    return 'Setted recording audio mode to $value.';
  }

  @override
  String get recordingAudioModeOptionMono => 'mono';

  @override
  String get recordingAudioModeOptionStereo => 'stereo';

  @override
  String get recordingAutoGain => 'Auto gain';

  @override
  String recordingAutoGainValue(Object value) {
    return 'Auto gain: $value';
  }

  @override
  String get recordingAutoGainInfo => 'The recorder will try to auto adjust recording volume in a limited range (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingAutoGainSuccess(Object value) {
    return 'Setted auto gain to $value.';
  }

  @override
  String get recordingEchoCancel => 'Echo cancel';

  @override
  String recordingEchoCancelValue(Object value) {
    return 'Echo cancel: $value';
  }

  @override
  String get recordingEchoCancelInfo => 'The recorder will try to reduce echo (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingEchoCancelSuccess(Object value) {
    return 'Setted echo cancel to $value.';
  }

  @override
  String get recordingNoiseSuppress => 'Noise suppress';

  @override
  String recordingNoiseSuppressValue(Object value) {
    return 'Noise suppress: $value';
  }

  @override
  String get recordingNoiseSuppressInfo => 'The recorder will try to negates the input noise (if available on the device). Recording volume may be lowered by using this.';

  @override
  String recordingNoiseSuppressSuccess(Object value) {
    return 'Setted noise suppress to $value.';
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
  String get screenSettingsResetInfo => 'All screen settings will be restored to default. Continue?';

  @override
  String get screenSettingsResetSuccess => 'All screen settings was restored to default.';

  @override
  String get recordingSettingsReset => 'Reset recording settings';

  @override
  String get recordingSettingsResetTitle => 'Reset recording settings';

  @override
  String get recordingSettingsResetInfo => 'All recording settings will be restored to default. Continue?';

  @override
  String get recordingSettingsResetSuccess => 'All recording settings was restored to default.';

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
  String get permissionStatusPermanentlyDenied => 'Permanently denied (settings)';

  @override
  String get permissionStatusRestricted => 'Restricted';

  @override
  String get permissionStatusUndefined => 'Unknown status';

  @override
  String get grantPermission => 'Allow';
}
