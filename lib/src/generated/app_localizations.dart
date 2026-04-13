import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tune Tangler'**
  String get appTitle;

  /// No description provided for @appTitleDebug.
  ///
  /// In en, this message translates to:
  /// **'Tune Tangler (Debug)'**
  String get appTitleDebug;

  /// No description provided for @legalNote.
  ///
  /// In en, this message translates to:
  /// **'Made with ♥️ by Flower7C3'**
  String get legalNote;

  /// No description provided for @cell.
  ///
  /// In en, this message translates to:
  /// **'{cellName}'**
  String cell(Object cellName);

  /// No description provided for @trackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track {trackName}'**
  String trackTitle(Object trackName);

  /// No description provided for @allTracksPlayingStart.
  ///
  /// In en, this message translates to:
  /// **'Start playing all tracks'**
  String get allTracksPlayingStart;

  /// No description provided for @allTracksPlayingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop playing all tracks'**
  String get allTracksPlayingStop;

  /// No description provided for @rowTracksPlayingStart.
  ///
  /// In en, this message translates to:
  /// **'Start playing tracks in {rowName} row'**
  String rowTracksPlayingStart(Object rowName);

  /// No description provided for @rowTracksPlayingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop playing tracks in {rowName} row'**
  String rowTracksPlayingStop(Object rowName);

  /// No description provided for @trackPlayingStart.
  ///
  /// In en, this message translates to:
  /// **'Start playing {trackName} track'**
  String trackPlayingStart(Object trackName);

  /// No description provided for @trackPlayingPause.
  ///
  /// In en, this message translates to:
  /// **'Pause playing {trackName} track'**
  String trackPlayingPause(Object trackName);

  /// No description provided for @trackPlayingResume.
  ///
  /// In en, this message translates to:
  /// **'Resume playing {trackName} track'**
  String trackPlayingResume(Object trackName);

  /// No description provided for @trackPlayingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop playing {trackName} track'**
  String trackPlayingStop(Object trackName);

  /// No description provided for @trackPlaybackModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle playback mode for {trackName} track'**
  String trackPlaybackModeToggle(Object trackName);

  /// No description provided for @trackKeyboardKey.
  ///
  /// In en, this message translates to:
  /// **'Keyboard key for {trackName} track'**
  String trackKeyboardKey(Object trackName);

  /// No description provided for @thePlaybackPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get thePlaybackPosition;

  /// No description provided for @thePlaybackTrim.
  ///
  /// In en, this message translates to:
  /// **'Trimming'**
  String get thePlaybackTrim;

  /// No description provided for @thePlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed rate'**
  String get thePlaybackSpeed;

  /// No description provided for @thePlaybackVolume.
  ///
  /// In en, this message translates to:
  /// **'Playback volume value'**
  String get thePlaybackVolume;

  /// No description provided for @thePlaybackBalance.
  ///
  /// In en, this message translates to:
  /// **'Audio balance'**
  String get thePlaybackBalance;

  /// No description provided for @thePlaybackBalanceAt.
  ///
  /// In en, this message translates to:
  /// **'Audio balance to {value}'**
  String thePlaybackBalanceAt(Object value);

  /// No description provided for @thePlaybackStartAtPosition.
  ///
  /// In en, this message translates to:
  /// **'Start at position'**
  String get thePlaybackStartAtPosition;

  /// No description provided for @thePlaybackEndAtPosition.
  ///
  /// In en, this message translates to:
  /// **'End at position'**
  String get thePlaybackEndAtPosition;

  /// No description provided for @trackRecording.
  ///
  /// In en, this message translates to:
  /// **'On air'**
  String get trackRecording;

  /// No description provided for @theAudioSourceRecorded.
  ///
  /// In en, this message translates to:
  /// **'Audio recorded'**
  String get theAudioSourceRecorded;

  /// No description provided for @theAudioSourceImported.
  ///
  /// In en, this message translates to:
  /// **'Audio imported'**
  String get theAudioSourceImported;

  /// No description provided for @theKeyboardKey.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcut key'**
  String get theKeyboardKey;

  /// No description provided for @trackRecordingImport.
  ///
  /// In en, this message translates to:
  /// **'Import file to {trackName} track'**
  String trackRecordingImport(Object trackName);

  /// No description provided for @trackRecordingImported.
  ///
  /// In en, this message translates to:
  /// **'Imported file to {trackName} track.'**
  String trackRecordingImported(Object trackName);

  /// No description provided for @trackRecordingImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled import file to {trackName} track.'**
  String trackRecordingImportCancelled(Object trackName);

  /// No description provided for @trackRecordingImportNoPermissions.
  ///
  /// In en, this message translates to:
  /// **'No permissions to import file to {trackName} track.'**
  String trackRecordingImportNoPermissions(Object trackName);

  /// No description provided for @trackRecordingInfo.
  ///
  /// In en, this message translates to:
  /// **'Recording to {trackName} track'**
  String trackRecordingInfo(Object trackName);

  /// No description provided for @clickToOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Touch to open app'**
  String get clickToOpenApp;

  /// No description provided for @trackRecordingStart.
  ///
  /// In en, this message translates to:
  /// **'Start recording to {trackName} track'**
  String trackRecordingStart(Object trackName);

  /// No description provided for @trackRecordingAlreadyStarted.
  ///
  /// In en, this message translates to:
  /// **'Another recording has already been started.'**
  String get trackRecordingAlreadyStarted;

  /// No description provided for @trackRecordingStartNoAudioPermission.
  ///
  /// In en, this message translates to:
  /// **'No permissions to audio recording.'**
  String get trackRecordingStartNoAudioPermission;

  /// No description provided for @trackRecordingStartNoNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'No permissions to recording notification.'**
  String get trackRecordingStartNoNotificationPermission;

  /// No description provided for @trackRecordingStartError.
  ///
  /// In en, this message translates to:
  /// **'Error during start recording {trackName} track.\n{error}'**
  String trackRecordingStartError(Object error, Object trackName);

  /// No description provided for @trackRecordingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel recording to {trackName} track'**
  String trackRecordingCancel(Object trackName);

  /// No description provided for @trackRecordingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Canceled recording {trackName} track.'**
  String trackRecordingCancelled(Object trackName);

  /// No description provided for @trackRecordingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording to {trackName} track'**
  String trackRecordingStop(Object trackName);

  /// No description provided for @trackRecordingStopSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recording {trackName} track complete.'**
  String trackRecordingStopSuccess(Object trackName);

  /// No description provided for @trackRecordingStopError.
  ///
  /// In en, this message translates to:
  /// **'Error during finalize recording {trackName} track.\n{error}'**
  String trackRecordingStopError(Object error, Object trackName);

  /// No description provided for @trackPlaybackSpeedSet.
  ///
  /// In en, this message translates to:
  /// **'Set track {trackName} playback speed'**
  String trackPlaybackSpeedSet(Object trackName);

  /// No description provided for @trackPlaybackVolumeSet.
  ///
  /// In en, this message translates to:
  /// **'Set track {trackName} playback volume'**
  String trackPlaybackVolumeSet(Object trackName);

  /// No description provided for @trackPlaybackBalanceSet.
  ///
  /// In en, this message translates to:
  /// **'Set track {trackName} playback balance'**
  String trackPlaybackBalanceSet(Object trackName);

  /// No description provided for @trackPlaybackStartAtPositionSub10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by -0.01 s'**
  String get trackPlaybackStartAtPositionSub10;

  /// No description provided for @trackPlaybackStartAtPositionSub100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by -0.1 s'**
  String get trackPlaybackStartAtPositionSub100;

  /// No description provided for @trackPlaybackStartAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset track playback start at'**
  String get trackPlaybackStartAtPositionReset;

  /// No description provided for @trackPlaybackStartAtPositionAdd100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by +0.1 s'**
  String get trackPlaybackStartAtPositionAdd100;

  /// No description provided for @trackPlaybackStartAtPositionAdd10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by +0.01 s'**
  String get trackPlaybackStartAtPositionAdd10;

  /// No description provided for @trackPlaybackEndAtPositionSub10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by -0.01 s'**
  String get trackPlaybackEndAtPositionSub10;

  /// No description provided for @trackPlaybackEndAtPositionSub100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by -0.1 s'**
  String get trackPlaybackEndAtPositionSub100;

  /// No description provided for @trackPlaybackEndAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset track playback end at'**
  String get trackPlaybackEndAtPositionReset;

  /// No description provided for @trackPlaybackEndAtPositionAdd100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by +0.1 s'**
  String get trackPlaybackEndAtPositionAdd100;

  /// No description provided for @trackPlaybackEndAtPositionAdd10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by +0.01 s'**
  String get trackPlaybackEndAtPositionAdd10;

  /// No description provided for @trackNameChange.
  ///
  /// In en, this message translates to:
  /// **'Change track name'**
  String get trackNameChange;

  /// No description provided for @trackNameChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change name of {trackName} track'**
  String trackNameChangeTitle(Object trackName);

  /// No description provided for @trackNameChangeInfo.
  ///
  /// In en, this message translates to:
  /// **'Select an icon to use as the new name for track {trackName}.'**
  String trackNameChangeInfo(Object trackName);

  /// No description provided for @trackNameChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Track name updated to {trackName}.'**
  String trackNameChangeSuccess(Object trackName);

  /// No description provided for @trackKeyboardKeyChange.
  ///
  /// In en, this message translates to:
  /// **'Change keyboard key'**
  String get trackKeyboardKeyChange;

  /// No description provided for @trackKeyboardKeyChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change keyboard key of {trackName} track'**
  String trackKeyboardKeyChangeTitle(Object trackName);

  /// No description provided for @trackKeyboardKeyChangeInfo.
  ///
  /// In en, this message translates to:
  /// **'Select an icon to use as the new keyboard shortcut for track {trackName}.'**
  String trackKeyboardKeyChangeInfo(Object trackName);

  /// No description provided for @trackKeyboardKeyChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shortcut updated for track {trackName}.'**
  String trackKeyboardKeyChangeSuccess(Object trackName);

  /// No description provided for @trackRecordingMove.
  ///
  /// In en, this message translates to:
  /// **'Move recording'**
  String get trackRecordingMove;

  /// No description provided for @trackRecordingMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move recording of {trackName} track'**
  String trackRecordingMoveTitle(Object trackName);

  /// No description provided for @trackRecordingMoveInfo.
  ///
  /// In en, this message translates to:
  /// **'Select new location for recording of {trackName} track.'**
  String trackRecordingMoveInfo(Object trackName);

  /// No description provided for @trackRecordingMoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Swapped location of #{firstTrackName} and #{secondTrackName} recordings.'**
  String trackRecordingMoveSuccess(
    Object firstTrackName,
    Object secondTrackName,
  );

  /// No description provided for @trackRecordingMoveInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording move is already in progress. Please try again in a moment.'**
  String get trackRecordingMoveInProgress;

  /// No description provided for @trackRecordingMoveNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Cannot move tracks during recording, playback, or processing.'**
  String get trackRecordingMoveNotAllowed;

  /// No description provided for @trackRecordingMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move tracks. Check if files were moved or deleted and try again.'**
  String get trackRecordingMoveFailed;

  /// No description provided for @trackRecordingShare.
  ///
  /// In en, this message translates to:
  /// **'Share {trackName} track recording'**
  String trackRecordingShare(Object trackName);

  /// No description provided for @trackRecordingShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Here is my recording file for the track {trackName} made with the Tune Tangler app!'**
  String trackRecordingShareMessage(Object trackName);

  /// No description provided for @trackRecordingShareNoFile.
  ///
  /// In en, this message translates to:
  /// **'There is no recording file for {trackName} track'**
  String trackRecordingShareNoFile(Object trackName);

  /// No description provided for @trackRecordingShareRaw.
  ///
  /// In en, this message translates to:
  /// **'Share raw recording ({trackTime})'**
  String trackRecordingShareRaw(Object trackTime);

  /// No description provided for @trackRecordingShareProcessed.
  ///
  /// In en, this message translates to:
  /// **'Share modified recording ({trackTime})'**
  String trackRecordingShareProcessed(Object trackTime);

  /// No description provided for @trackRecordingShareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shared recording for {trackName}.'**
  String trackRecordingShareSuccess(Object trackName);

  /// No description provided for @trackRecordingShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share recording for {trackName}.'**
  String trackRecordingShareFailed(Object trackName);

  /// No description provided for @trackRecordingDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get trackRecordingDelete;

  /// No description provided for @trackRecordingDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {trackName} track recording'**
  String trackRecordingDeleteTitle(Object trackName);

  /// No description provided for @trackRecordingDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Recording for {trackName} track will be deleted permanently. Continue?'**
  String trackRecordingDeleteInfo(Object trackName);

  /// No description provided for @trackRecordingDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted recording for {trackName} track.'**
  String trackRecordingDeleteSuccess(Object trackName);

  /// No description provided for @rowTracksPlaybackModeSet.
  ///
  /// In en, this message translates to:
  /// **'Playback mode'**
  String get rowTracksPlaybackModeSet;

  /// No description provided for @rowTracksPlaybackModeSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set {value} playback mode'**
  String rowTracksPlaybackModeSetTitle(Object value);

  /// No description provided for @rowTracksPlaybackModeSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Playback mode for tracks in row {rowName} updated to {value}.'**
  String rowTracksPlaybackModeSetSuccess(Object rowName, Object value);

  /// No description provided for @rowTracksPlaybackSpeedSet.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get rowTracksPlaybackSpeedSet;

  /// No description provided for @rowTracksPlaybackSpeedTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set playback speed to {value}'**
  String rowTracksPlaybackSpeedTitleSet(Object value);

  /// No description provided for @rowTracksPlaybackSpeedSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Playback speed for tracks in row {rowName} updated to {value}.'**
  String rowTracksPlaybackSpeedSuccessSet(Object rowName, Object value);

  /// No description provided for @rowTracksPlaybackVolumeSet.
  ///
  /// In en, this message translates to:
  /// **'Playback volume'**
  String get rowTracksPlaybackVolumeSet;

  /// No description provided for @rowTracksPlaybackVolumeTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set playback volume to {value}'**
  String rowTracksPlaybackVolumeTitleSet(Object value);

  /// No description provided for @rowTracksPlaybackVolumeSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Volume for tracks in row {rowName} updated to {value}.'**
  String rowTracksPlaybackVolumeSuccessSet(Object rowName, Object value);

  /// No description provided for @rowTracksPlaybackBalanceSet.
  ///
  /// In en, this message translates to:
  /// **'Playback balance'**
  String get rowTracksPlaybackBalanceSet;

  /// No description provided for @rowTracksPlaybackBalanceTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set playback balance to {value}'**
  String rowTracksPlaybackBalanceTitleSet(Object value);

  /// No description provided for @rowTracksPlaybackBalanceSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Balance for tracks in row {rowName} updated to {value}.'**
  String rowTracksPlaybackBalanceSuccessSet(Object rowName, Object value);

  /// No description provided for @rowTracksPlaybackStartAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset playback start at'**
  String get rowTracksPlaybackStartAtPositionReset;

  /// No description provided for @rowTracksPlaybackStartAtPositionResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset row tracks playback start at'**
  String get rowTracksPlaybackStartAtPositionResetTitle;

  /// No description provided for @rowTracksPlaybackStartAtPositionResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks in {rowName} row will have default playback start at. Continue?'**
  String rowTracksPlaybackStartAtPositionResetInfo(Object rowName);

  /// No description provided for @rowTracksPlaybackStartAtPositionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Playback start reset for tracks in row {rowName}.'**
  String rowTracksPlaybackStartAtPositionResetSuccess(Object rowName);

  /// No description provided for @rowTracksPlaybackEndAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset playback end at'**
  String get rowTracksPlaybackEndAtPositionReset;

  /// No description provided for @rowTracksPlaybackEndAtPositionResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset row tracks playback end at'**
  String get rowTracksPlaybackEndAtPositionResetTitle;

  /// No description provided for @rowTracksPlaybackEndAtPositionResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks in {rowName} row will have default playback end at. Continue?'**
  String rowTracksPlaybackEndAtPositionResetInfo(Object rowName);

  /// No description provided for @rowTracksPlaybackEndAtPositionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Playback end reset for tracks in row {rowName}.'**
  String rowTracksPlaybackEndAtPositionResetSuccess(Object rowName);

  /// No description provided for @rowTracksRecordingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete recordings'**
  String get rowTracksRecordingsDelete;

  /// No description provided for @rowTracksRecordingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete row recordings'**
  String get rowTracksRecordingsDeleteTitle;

  /// No description provided for @rowTracksRecordingsDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Recordings for all tracks in {rowName} row will be deleted permanently. Continue?'**
  String rowTracksRecordingsDeleteInfo(Object rowName);

  /// No description provided for @rowTracksRecordingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted recordings for tracks in {rowName} row.'**
  String rowTracksRecordingsDeleteSuccess(Object rowName);

  /// No description provided for @balanceLeft100.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 0%'**
  String get balanceLeft100;

  /// No description provided for @balanceLeft75.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 25%'**
  String get balanceLeft75;

  /// No description provided for @balanceLeft50.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 50%'**
  String get balanceLeft50;

  /// No description provided for @balanceLeft25.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 75%'**
  String get balanceLeft25;

  /// No description provided for @balanceLeft.
  ///
  /// In en, this message translates to:
  /// **'left 100%'**
  String get balanceLeft;

  /// No description provided for @balanceCenter.
  ///
  /// In en, this message translates to:
  /// **'center'**
  String get balanceCenter;

  /// No description provided for @balanceRight.
  ///
  /// In en, this message translates to:
  /// **'right 100%'**
  String get balanceRight;

  /// No description provided for @balanceRight25.
  ///
  /// In en, this message translates to:
  /// **'left 75%, right 100%'**
  String get balanceRight25;

  /// No description provided for @balanceRight50.
  ///
  /// In en, this message translates to:
  /// **'left 50%, right 100%'**
  String get balanceRight50;

  /// No description provided for @balanceRight75.
  ///
  /// In en, this message translates to:
  /// **'left 25%, right 100%'**
  String get balanceRight75;

  /// No description provided for @balanceRight100.
  ///
  /// In en, this message translates to:
  /// **'left 0%, right 100%'**
  String get balanceRight100;

  /// No description provided for @languageWithLocale.
  ///
  /// In en, this message translates to:
  /// **'{name} ({locale})'**
  String languageWithLocale(Object locale, Object name);

  /// No description provided for @keepScreenOnEnabled.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on enabled'**
  String get keepScreenOnEnabled;

  /// No description provided for @keepScreenOnDisabled.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on disabled'**
  String get keepScreenOnDisabled;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @menuKeepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get menuKeepScreenOn;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Settings profile'**
  String get settingsProfile;

  /// No description provided for @settingsProfiles.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles'**
  String get settingsProfiles;

  /// No description provided for @settingsProfilesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles'**
  String get settingsProfilesListTitle;

  /// No description provided for @settingsProfilesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles list is empty.'**
  String get settingsProfilesEmpty;

  /// No description provided for @settingsProfileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsProfileDelete;

  /// No description provided for @settingsProfileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Settings profile'**
  String get settingsProfileDeleteTitle;

  /// No description provided for @settingsProfileDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Settings profile will be deleted. Continue?'**
  String get settingsProfileDeleteInfo;

  /// No description provided for @settingsProfileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Settings profile deleted.'**
  String get settingsProfileDeleted;

  /// No description provided for @settingsProfileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get settingsProfileCreate;

  /// No description provided for @settingsProfileCreated.
  ///
  /// In en, this message translates to:
  /// **'Settings profile created.'**
  String get settingsProfileCreated;

  /// No description provided for @settingsProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings profile saved.'**
  String get settingsProfileSaveSuccess;

  /// No description provided for @settingsProfileLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get settingsProfileLoad;

  /// No description provided for @settingsProfileLoaded.
  ///
  /// In en, this message translates to:
  /// **'Settings profile loaded.'**
  String get settingsProfileLoaded;

  /// No description provided for @helpScreenMessageSettingsProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles'**
  String get helpScreenMessageSettingsProfilesTitle;

  /// No description provided for @helpScreenMessageSettingsProfilesContent.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles allow you to save and quickly restore application configuration. You can create multiple profiles with different recording and screen settings, then switch between them.\n\nEach profile contains:\n• Recording settings (\$[recordingInputDevice]input device, \$[recordingAudioEncoder]codec, \$[recordingSampleRate]sample rate, \$[recordingBitRate]bit rate, \$[recordingAudioMode]audio mode, \$[recordingAutoGain]automatic gain, \$[recordingEchoCancel]echo cancellation, \$[recordingNoiseSuppress]noise suppression)\n• Screen settings (\$[language]language, \$[screenThemeMode]theme, \$[screenThemeColor]accent color, \$[keepScreenOn]keep screen on)\n\nTo create a profile, use the \$[create]\"Create\" button in the profiles dialog. To load a profile, tap it. To delete a profile, \$[touchLong]long-press it and select the \$[deleteForever]delete option.'**
  String get helpScreenMessageSettingsProfilesContent;

  /// No description provided for @projectExportInfo.
  ///
  /// In en, this message translates to:
  /// **'Project export saves all recordings and their parameters to a ZIP file that can be loaded later. Project name is optional and will be added to the file name.'**
  String get projectExportInfo;

  /// No description provided for @settingsProfilesInfo.
  ///
  /// In en, this message translates to:
  /// **'Save and restore application configuration. Tap to load a profile, or long-press to see details.'**
  String get settingsProfilesInfo;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'More settings...'**
  String get moreSettings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpScreenMessageAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get helpScreenMessageAboutTitle;

  /// No description provided for @helpScreenMessageAboutContent.
  ///
  /// In en, this message translates to:
  /// **'This application lets you record audio from a microphone or USB audio interface (your device must support USB OTG) to one of several tracks. You can also import an existing audio file.\n\nRecordings can play in sync (all tracks together) or independently, in a loop or once.\n\nRecordings and their settings, plus the UI theme and language, are remembered after you close the app.'**
  String get helpScreenMessageAboutContent;

  /// No description provided for @helpScreenMessageGridScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracks grid screen'**
  String get helpScreenMessageGridScreenTitle;

  /// No description provided for @helpScreenMessageGridScreenContent.
  ///
  /// In en, this message translates to:
  /// **'Short press a colored track block or use a hotkey (visible at the top of the track) to perform one of the available actions.\n\nHold the track block or use a hotkey with a modifier key (usually Control \$[controlKey], often Command on Mac) to open track details.\n\nIn the drawer you can choose the keyboard mode (standard or 24-key pad). Set each track’s hotkey in that track’s details.'**
  String get helpScreenMessageGridScreenContent;

  /// No description provided for @helpScreenMessageDetailsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Track details screen'**
  String get helpScreenMessageDetailsScreenTitle;

  /// No description provided for @helpScreenMessageDetailsScreenContent.
  ///
  /// In en, this message translates to:
  /// **'Main track settings:\n• \$[recordingClip]recording trim\n• \$[trackPlaybackMode]playback mode\n• \$[trackPlaybackVolume]playback volume\n• \$[trackPlaybackBalance]audio balance\n• \$[trackPlaybackSpeed]playback speed\n• \$[trackName]track name\n• \$[trackKeyboardKey]keyboard shortcut\n\nYou can also \$[trackRecordingMove]move the track on the grid, \$[trackRecordingImport]import a recording file, \$[trackRecordingShare]share the recording, or \$[deleteForever]delete it.'**
  String get helpScreenMessageDetailsScreenContent;

  /// No description provided for @helpScreenMessageTrackStates.
  ///
  /// In en, this message translates to:
  /// **'Track states and actions'**
  String get helpScreenMessageTrackStates;

  /// No description provided for @helpScreenMessageTrackStatesInfo.
  ///
  /// In en, this message translates to:
  /// **'Each track can be in one of several states that determine available actions. Tapping the track block runs the action for the current state.'**
  String get helpScreenMessageTrackStatesInfo;

  /// No description provided for @helpScreenMessageTrackIcons.
  ///
  /// In en, this message translates to:
  /// **'Track info icons'**
  String get helpScreenMessageTrackIcons;

  /// No description provided for @helpScreenMessageTrackIconsInfo.
  ///
  /// In en, this message translates to:
  /// **'Icons displayed on the track block inform about its properties.'**
  String get helpScreenMessageTrackIconsInfo;

  /// No description provided for @helpTrackIconBalanceLeftLegend.
  ///
  /// In en, this message translates to:
  /// **'panned left; exact mix in track details'**
  String get helpTrackIconBalanceLeftLegend;

  /// No description provided for @helpTrackIconBalanceCenterLegend.
  ///
  /// In en, this message translates to:
  /// **'balance centered'**
  String get helpTrackIconBalanceCenterLegend;

  /// No description provided for @helpTrackIconBalanceRightLegend.
  ///
  /// In en, this message translates to:
  /// **'panned right; exact mix in track details'**
  String get helpTrackIconBalanceRightLegend;

  /// No description provided for @helpTrackIconPlaybackStartTrimLegend.
  ///
  /// In en, this message translates to:
  /// **'trimmed at the start; exact time in track details'**
  String get helpTrackIconPlaybackStartTrimLegend;

  /// No description provided for @helpTrackIconPlaybackEndTrimLegend.
  ///
  /// In en, this message translates to:
  /// **'trimmed at the end; exact time in track details'**
  String get helpTrackIconPlaybackEndTrimLegend;

  /// No description provided for @helpTrackIconSinglePlaybackModeLegend.
  ///
  /// In en, this message translates to:
  /// **'plays once, then stops'**
  String get helpTrackIconSinglePlaybackModeLegend;

  /// No description provided for @helpTrackIconRepeatPlaybackModeLegend.
  ///
  /// In en, this message translates to:
  /// **'loops back to the range start'**
  String get helpTrackIconRepeatPlaybackModeLegend;

  /// No description provided for @helpScreenMessageSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Here you can set \$[recordingAudioEncoder]audio codec, \$[recordingSampleRate]sample rate, \$[recordingBitRate]bit rate, \$[recordingAudioMode]audio mode, \$[recordingAutoGain]automatic gain, \$[recordingEchoCancel]echo cancellation, and \$[recordingNoiseSuppress]noise suppression.'**
  String get helpScreenMessageSettingsInfo;

  /// No description provided for @helpScreenMessageProjectExportImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Project export and import'**
  String get helpScreenMessageProjectExportImportTitle;

  /// No description provided for @helpScreenMessageProjectExportImportContent.
  ///
  /// In en, this message translates to:
  /// **'You can \$[projectExport]save the entire project to a ZIP file, which contains grid settings, all tracks with their settings, and audio recordings. The file can later be \$[projectImport]loaded to restore the entire application state.\n\nThe exported file contains:\n• Grid settings (number of rows and columns)\n• All track settings (names, playback parameters, playback trim, keyboard shortcuts)\n• All audio recordings with checksums\n• Project metadata (version, export date, statistics)\n\nBefore import, a project preview is displayed, and the application warns about overwriting the current session. Import performs full validation before modifying data.'**
  String get helpScreenMessageProjectExportImportContent;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'track empty (tap the box to start recording)'**
  String get stateEmpty;

  /// No description provided for @stateRecording.
  ///
  /// In en, this message translates to:
  /// **'recording in progress (tap the box to stop recording)'**
  String get stateRecording;

  /// No description provided for @stateProcessing.
  ///
  /// In en, this message translates to:
  /// **'track processing in progress'**
  String get stateProcessing;

  /// No description provided for @stateIdle.
  ///
  /// In en, this message translates to:
  /// **'idle: recording done/playing stopped (tap the box to start playing)'**
  String get stateIdle;

  /// No description provided for @statePlaying.
  ///
  /// In en, this message translates to:
  /// **'track is playing (tap the box to stop playback)'**
  String get statePlaying;

  /// No description provided for @statePaused.
  ///
  /// In en, this message translates to:
  /// **'playing paused (tap the box to resume)'**
  String get statePaused;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get buttonOk;

  /// No description provided for @buttonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get buttonYes;

  /// No description provided for @buttonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get buttonNo;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @buttonResetTo.
  ///
  /// In en, this message translates to:
  /// **'Reset to {value}'**
  String buttonResetTo(Object value);

  /// No description provided for @buttonLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get buttonLoad;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonSaveTo.
  ///
  /// In en, this message translates to:
  /// **'Save as {value}'**
  String buttonSaveTo(Object value);

  /// No description provided for @buttonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get buttonSearch;

  /// No description provided for @noRecents.
  ///
  /// In en, this message translates to:
  /// **'No Recents'**
  String get noRecents;

  /// No description provided for @screenSettings.
  ///
  /// In en, this message translates to:
  /// **'Screen settings'**
  String get screenSettings;

  /// No description provided for @screen.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screen;

  /// No description provided for @languageVersion.
  ///
  /// In en, this message translates to:
  /// **'Language version'**
  String get languageVersion;

  /// No description provided for @languageVersionValue.
  ///
  /// In en, this message translates to:
  /// **'Language version: {value}'**
  String languageVersionValue(Object value);

  /// No description provided for @screenThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Screen theme mode'**
  String get screenThemeMode;

  /// No description provided for @screenThemeModeValue.
  ///
  /// In en, this message translates to:
  /// **'Screen theme mode: {value}'**
  String screenThemeModeValue(Object value);

  /// No description provided for @screenSystemThemeMode.
  ///
  /// In en, this message translates to:
  /// **'device settings'**
  String get screenSystemThemeMode;

  /// No description provided for @screenDarkThemeMode.
  ///
  /// In en, this message translates to:
  /// **'dark mode'**
  String get screenDarkThemeMode;

  /// No description provided for @screenLightThemeMode.
  ///
  /// In en, this message translates to:
  /// **'light mode'**
  String get screenLightThemeMode;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// No description provided for @screenSystemThemeColor.
  ///
  /// In en, this message translates to:
  /// **'device settings'**
  String get screenSystemThemeColor;

  /// No description provided for @screenThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get screenThemeColor;

  /// No description provided for @screenThemeColorValue.
  ///
  /// In en, this message translates to:
  /// **'Theme accent color: {value}'**
  String screenThemeColorValue(Object value);

  /// No description provided for @screenThemeColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Set theme accent color'**
  String get screenThemeColorTitle;

  /// No description provided for @screenThemeColorInfo.
  ///
  /// In en, this message translates to:
  /// **'Choose color that will be applied as theme accent.'**
  String get screenThemeColorInfo;

  /// No description provided for @screenThemeColorSuccess.
  ///
  /// In en, this message translates to:
  /// **'Theme accent color updated to {name}.'**
  String screenThemeColorSuccess(Object name);

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnValue.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on: {value}'**
  String keepScreenOnValue(Object value);

  /// No description provided for @keepScreenOnIsEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Enabled keep screen on feature.'**
  String get keepScreenOnIsEnabledSuccess;

  /// No description provided for @keepScreenOnIsDisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Disabled keep screen on feature.'**
  String get keepScreenOnIsDisabledSuccess;

  /// No description provided for @gridRowsAmount.
  ///
  /// In en, this message translates to:
  /// **'Grid rows amount'**
  String get gridRowsAmount;

  /// No description provided for @gridRowsAmountValue.
  ///
  /// In en, this message translates to:
  /// **'Grid rows amount: {value}'**
  String gridRowsAmountValue(Object value);

  /// No description provided for @gridRowsAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid rows amount'**
  String get gridRowsAmountTitle;

  /// No description provided for @gridRowsAmountInfo.
  ///
  /// In en, this message translates to:
  /// **'Set grid rows amount, that will be visible on tracks list.'**
  String get gridRowsAmountInfo;

  /// No description provided for @gridRowsAmountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Grid rows set to {value}.'**
  String gridRowsAmountSuccess(Object value);

  /// No description provided for @gridColsAmount.
  ///
  /// In en, this message translates to:
  /// **'Grid columns amount'**
  String get gridColsAmount;

  /// No description provided for @gridColsAmountValue.
  ///
  /// In en, this message translates to:
  /// **'Grid columns amount: {value}'**
  String gridColsAmountValue(Object value);

  /// No description provided for @gridColsAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid columns amount'**
  String get gridColsAmountTitle;

  /// No description provided for @gridColsAmountInfo.
  ///
  /// In en, this message translates to:
  /// **'Set grid columns amount, that will be visible on tracks list.'**
  String get gridColsAmountInfo;

  /// No description provided for @gridColsAmountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Grid columns set to {value}.'**
  String gridColsAmountSuccess(Object value);

  /// No description provided for @keyboardLayoutPreset.
  ///
  /// In en, this message translates to:
  /// **'Keyboard layout'**
  String get keyboardLayoutPreset;

  /// No description provided for @keyboardLayoutPresetInfo.
  ///
  /// In en, this message translates to:
  /// **'Standard layout uses the full PC keyboard map. The 24-key layout matches a fixed 6×4 pad and locks the track grid to that size.'**
  String get keyboardLayoutPresetInfo;

  /// No description provided for @keyboardLayoutQwertyName.
  ///
  /// In en, this message translates to:
  /// **'Standard (QWERTY)'**
  String get keyboardLayoutQwertyName;

  /// No description provided for @keyboardLayoutGrid24Name.
  ///
  /// In en, this message translates to:
  /// **'24 keys (6×4 pad)'**
  String get keyboardLayoutGrid24Name;

  /// No description provided for @keyboardLayoutPresetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Keyboard layout: {layout}.'**
  String keyboardLayoutPresetSuccess(Object layout);

  /// No description provided for @keyboardLayoutPresetSuccessWithReset.
  ///
  /// In en, this message translates to:
  /// **'Keyboard layout: {layout}. Shortcut keys were reset to defaults.'**
  String keyboardLayoutPresetSuccessWithReset(Object layout);

  /// No description provided for @keyboardLayoutChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm keyboard layout change'**
  String get keyboardLayoutChangeTitle;

  /// No description provided for @keyboardLayoutChangeIntro.
  ///
  /// In en, this message translates to:
  /// **'You are switching from {fromLayout} to {toLayout}.'**
  String keyboardLayoutChangeIntro(Object fromLayout, Object toLayout);

  /// No description provided for @keyboardLayoutChangeDetailGrid24.
  ///
  /// In en, this message translates to:
  /// **'The 24-key layout matches a fixed 6×4 pad (physical rows: 1234, 8765, 90ab, fedc, ghij, nmlk). The track grid will always be 6 rows × 4 columns. Shortcuts you created for the full keyboard may not exist on this pad; keeping them can leave some tracks without a matching hardware key.'**
  String get keyboardLayoutChangeDetailGrid24;

  /// No description provided for @keyboardLayoutChangeDetailQwerty.
  ///
  /// In en, this message translates to:
  /// **'The standard layout uses the full PC keyboard map (digits, letter rows, shifted symbols). You can change grid size again in track settings. Shortcuts from the 24-key pad remain valid if the same keys exist on your computer keyboard.'**
  String get keyboardLayoutChangeDetailQwerty;

  /// No description provided for @keyboardLayoutChangeDecision.
  ///
  /// In en, this message translates to:
  /// **'Reset all track shortcut keys to the defaults for the new layout, or keep your current assignments knowing some keys may no longer line up with the new map.'**
  String get keyboardLayoutChangeDecision;

  /// No description provided for @keyboardLayoutChangeKeepShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Change layout, keep shortcuts'**
  String get keyboardLayoutChangeKeepShortcuts;

  /// No description provided for @keyboardLayoutChangeResetShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Change and reset shortcuts'**
  String get keyboardLayoutChangeResetShortcuts;

  /// No description provided for @keyboardLayoutGridLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid size (fixed)'**
  String get keyboardLayoutGridLockedTitle;

  /// No description provided for @keyboardLayoutGridLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This layout always uses 6 rows and 4 columns.'**
  String get keyboardLayoutGridLockedSubtitle;

  /// No description provided for @tracksSettings.
  ///
  /// In en, this message translates to:
  /// **'Tracks settings'**
  String get tracksSettings;

  /// No description provided for @trackSettings.
  ///
  /// In en, this message translates to:
  /// **'Track settings'**
  String get trackSettings;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @trackTitleEmojis.
  ///
  /// In en, this message translates to:
  /// **'Track title emojis'**
  String get trackTitleEmojis;

  /// No description provided for @trackTitleEmojisTitle.
  ///
  /// In en, this message translates to:
  /// **'Track title emojis'**
  String get trackTitleEmojisTitle;

  /// No description provided for @trackTitleEmojisInfo.
  ///
  /// In en, this message translates to:
  /// **'Set emojis that might be used as track title.'**
  String get trackTitleEmojisInfo;

  /// No description provided for @trackTitleEmojisSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved emoji list for track titles.'**
  String get trackTitleEmojisSuccess;

  /// No description provided for @allTracksTitleReset.
  ///
  /// In en, this message translates to:
  /// **'Reset tracks title'**
  String get allTracksTitleReset;

  /// No description provided for @allTracksTitleResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset tracks title'**
  String get allTracksTitleResetTitle;

  /// No description provided for @allTracksTitleResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks will have default title. Continue?'**
  String get allTracksTitleResetInfo;

  /// No description provided for @allTracksTitleResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All track titles reset.'**
  String get allTracksTitleResetSuccess;

  /// No description provided for @allTracksShortcutKeyReset.
  ///
  /// In en, this message translates to:
  /// **'Reset tracks shortcut key'**
  String get allTracksShortcutKeyReset;

  /// No description provided for @allTracksShortcutKeyResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tracks shortcut key'**
  String get allTracksShortcutKeyResetTitle;

  /// No description provided for @allTracksShortcutKeyResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks will have default shortcut key. Continue?'**
  String get allTracksShortcutKeyResetInfo;

  /// No description provided for @allTracksShortcutKeyResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All track shortcuts reset.'**
  String get allTracksShortcutKeyResetSuccess;

  /// No description provided for @allTracksPlaybackModeSet.
  ///
  /// In en, this message translates to:
  /// **'Set tracks playback mode'**
  String get allTracksPlaybackModeSet;

  /// No description provided for @allTracksPlaybackModeTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set all tracks playback mode'**
  String get allTracksPlaybackModeTitleSet;

  /// No description provided for @allTracksPlaybackModeInfoSet.
  ///
  /// In en, this message translates to:
  /// **'Choose the playback mode to apply to all tracks.'**
  String get allTracksPlaybackModeInfoSet;

  /// No description provided for @allTracksPlaybackModeSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Playback mode for all tracks updated to {mode}.'**
  String allTracksPlaybackModeSuccessSet(Object mode);

  /// No description provided for @singlePlaybackMode.
  ///
  /// In en, this message translates to:
  /// **'single'**
  String get singlePlaybackMode;

  /// No description provided for @repeatPlaybackMode.
  ///
  /// In en, this message translates to:
  /// **'repeat'**
  String get repeatPlaybackMode;

  /// No description provided for @allTracksPlaybackVolumeSet.
  ///
  /// In en, this message translates to:
  /// **'Set tracks volume'**
  String get allTracksPlaybackVolumeSet;

  /// No description provided for @allTracksPlaybackVolumeTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set all tracks playback volume'**
  String get allTracksPlaybackVolumeTitleSet;

  /// No description provided for @allTracksPlaybackVolumeInfoSet.
  ///
  /// In en, this message translates to:
  /// **'Choose the volume to apply to all tracks.'**
  String get allTracksPlaybackVolumeInfoSet;

  /// No description provided for @allTracksPlaybackVolumeSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Volume for all tracks updated to {value}.'**
  String allTracksPlaybackVolumeSuccessSet(Object value);

  /// No description provided for @allTracksPlaybackBalanceSet.
  ///
  /// In en, this message translates to:
  /// **'Set tracks balance'**
  String get allTracksPlaybackBalanceSet;

  /// No description provided for @allTracksPlaybackBalanceTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set all tracks playback balance'**
  String get allTracksPlaybackBalanceTitleSet;

  /// No description provided for @allTracksPlaybackBalanceInfoSet.
  ///
  /// In en, this message translates to:
  /// **'Choose the balance to apply to all tracks.'**
  String get allTracksPlaybackBalanceInfoSet;

  /// No description provided for @allTracksPlaybackBalanceSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Balance for all tracks updated to {value}.'**
  String allTracksPlaybackBalanceSuccessSet(Object value);

  /// No description provided for @allTracksPlaybackSpeedSet.
  ///
  /// In en, this message translates to:
  /// **'Set playback speed'**
  String get allTracksPlaybackSpeedSet;

  /// No description provided for @allTracksPlaybackSpeedTitleSet.
  ///
  /// In en, this message translates to:
  /// **'Set all tracks playback speed'**
  String get allTracksPlaybackSpeedTitleSet;

  /// No description provided for @allTracksPlaybackSpeedInfoSet.
  ///
  /// In en, this message translates to:
  /// **'Choose the playback speed to apply to all tracks.'**
  String get allTracksPlaybackSpeedInfoSet;

  /// No description provided for @allTracksPlaybackSpeedSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Playback speed for all tracks updated to {value}.'**
  String allTracksPlaybackSpeedSuccessSet(Object value);

  /// No description provided for @allTracksPlaybackStartAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset playback start at'**
  String get allTracksPlaybackStartAtPositionReset;

  /// No description provided for @allTracksPlaybackStartAtPositionResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tracks playback start at'**
  String get allTracksPlaybackStartAtPositionResetTitle;

  /// No description provided for @allTracksPlaybackStartAtPositionResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks will have default playback start at. Continue?'**
  String get allTracksPlaybackStartAtPositionResetInfo;

  /// No description provided for @allTracksPlaybackStartAtPositionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Playback start reset for all tracks.'**
  String get allTracksPlaybackStartAtPositionResetSuccess;

  /// No description provided for @allTracksPlaybackEndAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset playback end at'**
  String get allTracksPlaybackEndAtPositionReset;

  /// No description provided for @allTracksPlaybackEndAtPositionResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tracks playback end at'**
  String get allTracksPlaybackEndAtPositionResetTitle;

  /// No description provided for @allTracksPlaybackEndAtPositionResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All tracks will have default playback end at. Continue?'**
  String get allTracksPlaybackEndAtPositionResetInfo;

  /// No description provided for @allTracksPlaybackEndAtPositionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Playback end reset for all tracks.'**
  String get allTracksPlaybackEndAtPositionResetSuccess;

  /// No description provided for @allTracksSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset tracks settings'**
  String get allTracksSettingsReset;

  /// No description provided for @allTracksSettingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tracks settings'**
  String get allTracksSettingsResetTitle;

  /// No description provided for @allTracksSettingsResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All track settings will be restored to defaults. Continue?'**
  String get allTracksSettingsResetInfo;

  /// No description provided for @allTracksSettingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All track settings were restored to defaults.'**
  String get allTracksSettingsResetSuccess;

  /// No description provided for @allTracksRecordingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete tracks recordings'**
  String get allTracksRecordingsDelete;

  /// No description provided for @allTracksRecordingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all tracks recordings'**
  String get allTracksRecordingsDeleteTitle;

  /// No description provided for @allTracksRecordingsDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Recordings for all tracks will be deleted permanently. Continue?'**
  String get allTracksRecordingsDeleteInfo;

  /// No description provided for @allTracksRecordingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted recordings for all tracks.'**
  String get allTracksRecordingsDeleteSuccess;

  /// No description provided for @recordingSettings.
  ///
  /// In en, this message translates to:
  /// **'Recording settings'**
  String get recordingSettings;

  /// No description provided for @settingsChange.
  ///
  /// In en, this message translates to:
  /// **'Change settings'**
  String get settingsChange;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @defaultDevice.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get defaultDevice;

  /// No description provided for @recordingInputDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get recordingInputDevice;

  /// No description provided for @recordingInputDeviceValue.
  ///
  /// In en, this message translates to:
  /// **'Input device: {label}'**
  String recordingInputDeviceValue(Object label);

  /// No description provided for @recordingInputDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get recordingInputDeviceTitle;

  /// No description provided for @recordingInputDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Set device for sound recording.'**
  String get recordingInputDeviceInfo;

  /// No description provided for @recordingInputDeviceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Input device set to {value}.'**
  String recordingInputDeviceSuccess(Object value);

  /// No description provided for @recordingAudioEncoders.
  ///
  /// In en, this message translates to:
  /// **'Audio encoders details'**
  String get recordingAudioEncoders;

  /// No description provided for @recordingAudioEncoder.
  ///
  /// In en, this message translates to:
  /// **'Audio encoder'**
  String get recordingAudioEncoder;

  /// No description provided for @recordingAudioEncoderValue.
  ///
  /// In en, this message translates to:
  /// **'Audio encoder: {value}'**
  String recordingAudioEncoderValue(Object value);

  /// No description provided for @recordingAudioEncoderTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio encoder'**
  String get recordingAudioEncoderTitle;

  /// No description provided for @recordingAudioEncoderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio encoder set to {value}.'**
  String recordingAudioEncoderSuccess(Object value);

  /// No description provided for @audioRecorderAacHeName.
  ///
  /// In en, this message translates to:
  /// **'MPEG-4 AAC HE (Advanced Audio Codec - High Efficiency)'**
  String get audioRecorderAacHeName;

  /// No description provided for @audioRecorderAacHeInfo.
  ///
  /// In en, this message translates to:
  /// **'Internet radio and streaming at low bitrates'**
  String get audioRecorderAacHeInfo;

  /// No description provided for @audioRecorderAacHeDetails.
  ///
  /// In en, this message translates to:
  /// **'Designed for low bitrates (e.g. 32-64 kbps). Used for radio broadcasts and streaming. Higher latency compared to AAC LC.'**
  String get audioRecorderAacHeDetails;

  /// No description provided for @audioRecorderAacEldName.
  ///
  /// In en, this message translates to:
  /// **'MPEG-4 AAC ELD (Advanced Audio Codec - Enhanced Low Delay)'**
  String get audioRecorderAacEldName;

  /// No description provided for @audioRecorderAacEldInfo.
  ///
  /// In en, this message translates to:
  /// **'Real-time voice communication'**
  String get audioRecorderAacEldInfo;

  /// No description provided for @audioRecorderAacEldDetails.
  ///
  /// In en, this message translates to:
  /// **'Optimized for very low latency. Lower quality than AAC LC, but better for live communication.'**
  String get audioRecorderAacEldDetails;

  /// No description provided for @audioRecorderAacLcName.
  ///
  /// In en, this message translates to:
  /// **'MPEG-4 AAC LC (Advanced Audio Codec - Low Complexity)'**
  String get audioRecorderAacLcName;

  /// No description provided for @audioRecorderAacLcInfo.
  ///
  /// In en, this message translates to:
  /// **'Good quality music at low bitrates'**
  String get audioRecorderAacLcInfo;

  /// No description provided for @audioRecorderAacLcDetails.
  ///
  /// In en, this message translates to:
  /// **'Lossy compression, but better quality than MP3 at the same bitrate. Good for music and video.'**
  String get audioRecorderAacLcDetails;

  /// No description provided for @audioRecorderWavName.
  ///
  /// In en, this message translates to:
  /// **'Waveform Audio File (pcm16bit with headers)'**
  String get audioRecorderWavName;

  /// No description provided for @audioRecorderWavInfo.
  ///
  /// In en, this message translates to:
  /// **'High quality recording'**
  String get audioRecorderWavInfo;

  /// No description provided for @audioRecorderWavDetails.
  ///
  /// In en, this message translates to:
  /// **'Lossless audio format, uses no compression. Very large files, but excellent quality. Perfect for professional editing and recording.'**
  String get audioRecorderWavDetails;

  /// No description provided for @audioRecorderFlacName.
  ///
  /// In en, this message translates to:
  /// **'FLAC (Free Lossless Audio Codec)'**
  String get audioRecorderFlacName;

  /// No description provided for @audioRecorderFlacInfo.
  ///
  /// In en, this message translates to:
  /// **'Audiophile music collection'**
  String get audioRecorderFlacInfo;

  /// No description provided for @audioRecorderFlacDetails.
  ///
  /// In en, this message translates to:
  /// **'Lossless, but compressed (about 50-70% less than WAV). Supports metadata, which WAV cannot. Great for archiving high-quality music.'**
  String get audioRecorderFlacDetails;

  /// No description provided for @recordingDurationValue.
  ///
  /// In en, this message translates to:
  /// **'Duration: {value}'**
  String recordingDurationValue(Object value);

  /// No description provided for @recordingSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get recordingSampleRate;

  /// No description provided for @recordingSampleRateValue.
  ///
  /// In en, this message translates to:
  /// **'Sample rate: {value}'**
  String recordingSampleRateValue(Object value);

  /// No description provided for @recordingSampleRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get recordingSampleRateTitle;

  /// No description provided for @recordingSampleRateInfo.
  ///
  /// In en, this message translates to:
  /// **'The sample rate for audio in samples per second (if available on the device).'**
  String get recordingSampleRateInfo;

  /// No description provided for @recordingSampleRateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sample rate set to {value}.'**
  String recordingSampleRateSuccess(Object value);

  /// No description provided for @recordingBitRate.
  ///
  /// In en, this message translates to:
  /// **'Bit rate'**
  String get recordingBitRate;

  /// No description provided for @recordingBitRateValue.
  ///
  /// In en, this message translates to:
  /// **'Bit rate: {value}'**
  String recordingBitRateValue(Object value);

  /// No description provided for @recordingBitRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Bit rate'**
  String get recordingBitRateTitle;

  /// No description provided for @recordingBitRateInfo.
  ///
  /// In en, this message translates to:
  /// **'The audio encoding bit rate in bits per second (if available on the device).'**
  String get recordingBitRateInfo;

  /// No description provided for @recordingBitRateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bit rate set to {value}.'**
  String recordingBitRateSuccess(Object value);

  /// No description provided for @recordingAudioMode.
  ///
  /// In en, this message translates to:
  /// **'Audio mode'**
  String get recordingAudioMode;

  /// No description provided for @recordingAudioModeValue.
  ///
  /// In en, this message translates to:
  /// **'Audio rate: {value}'**
  String recordingAudioModeValue(Object value);

  /// No description provided for @recordingAudioModeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio mode set to {value}.'**
  String recordingAudioModeSuccess(Object value);

  /// No description provided for @recordingAudioModeOptionMono.
  ///
  /// In en, this message translates to:
  /// **'mono'**
  String get recordingAudioModeOptionMono;

  /// No description provided for @recordingAudioModeOptionStereo.
  ///
  /// In en, this message translates to:
  /// **'stereo'**
  String get recordingAudioModeOptionStereo;

  /// No description provided for @recordingAutoGain.
  ///
  /// In en, this message translates to:
  /// **'Auto gain'**
  String get recordingAutoGain;

  /// No description provided for @recordingAutoGainValue.
  ///
  /// In en, this message translates to:
  /// **'Auto gain: {value}'**
  String recordingAutoGainValue(Object value);

  /// No description provided for @recordingAutoGainInfo.
  ///
  /// In en, this message translates to:
  /// **'The recorder will try to auto adjust recording volume in a limited range (if available on the device). Recording volume may be lowered by using this.'**
  String get recordingAutoGainInfo;

  /// No description provided for @recordingAutoGainSuccess.
  ///
  /// In en, this message translates to:
  /// **'Automatic gain set to {value}.'**
  String recordingAutoGainSuccess(Object value);

  /// No description provided for @recordingEchoCancel.
  ///
  /// In en, this message translates to:
  /// **'Echo cancel'**
  String get recordingEchoCancel;

  /// No description provided for @recordingEchoCancelValue.
  ///
  /// In en, this message translates to:
  /// **'Echo cancel: {value}'**
  String recordingEchoCancelValue(Object value);

  /// No description provided for @recordingEchoCancelInfo.
  ///
  /// In en, this message translates to:
  /// **'The recorder will try to reduce echo (if available on the device). Recording volume may be lowered by using this.'**
  String get recordingEchoCancelInfo;

  /// No description provided for @recordingEchoCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Echo cancellation set to {value}.'**
  String recordingEchoCancelSuccess(Object value);

  /// No description provided for @recordingNoiseSuppress.
  ///
  /// In en, this message translates to:
  /// **'Noise suppress'**
  String get recordingNoiseSuppress;

  /// No description provided for @recordingNoiseSuppressValue.
  ///
  /// In en, this message translates to:
  /// **'Noise suppress: {value}'**
  String recordingNoiseSuppressValue(Object value);

  /// No description provided for @recordingNoiseSuppressInfo.
  ///
  /// In en, this message translates to:
  /// **'The recorder will try to reduce input noise (if available on the device). Recording volume may be lowered by using this.'**
  String get recordingNoiseSuppressInfo;

  /// No description provided for @recordingNoiseSuppressSuccess.
  ///
  /// In en, this message translates to:
  /// **'Noise suppression set to {value}.'**
  String recordingNoiseSuppressSuccess(Object value);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @screenSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset screen settings'**
  String get screenSettingsReset;

  /// No description provided for @screenSettingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset screen settings'**
  String get screenSettingsResetTitle;

  /// No description provided for @screenSettingsResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All screen settings will be restored to default. Continue?'**
  String get screenSettingsResetInfo;

  /// No description provided for @screenSettingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All screen settings were restored to defaults.'**
  String get screenSettingsResetSuccess;

  /// No description provided for @recordingSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset recording settings'**
  String get recordingSettingsReset;

  /// No description provided for @recordingSettingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset recording settings'**
  String get recordingSettingsResetTitle;

  /// No description provided for @recordingSettingsResetInfo.
  ///
  /// In en, this message translates to:
  /// **'All recording settings will be restored to default. Continue?'**
  String get recordingSettingsResetInfo;

  /// No description provided for @recordingSettingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All recording settings were restored to defaults.'**
  String get recordingSettingsResetSuccess;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get blue;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'yellow'**
  String get yellow;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'purple'**
  String get purple;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'orange'**
  String get orange;

  /// No description provided for @cyan.
  ///
  /// In en, this message translates to:
  /// **'cyan'**
  String get cyan;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'pink'**
  String get pink;

  /// No description provided for @indigo.
  ///
  /// In en, this message translates to:
  /// **'indigo'**
  String get indigo;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'brown'**
  String get brown;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'teal'**
  String get teal;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'black'**
  String get black;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @audioPermission.
  ///
  /// In en, this message translates to:
  /// **'Read audio file from device'**
  String get audioPermission;

  /// No description provided for @microphonePermission.
  ///
  /// In en, this message translates to:
  /// **'Record sound via microphone'**
  String get microphonePermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Display recording state notification'**
  String get notificationPermission;

  /// No description provided for @permissionStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionStatusGranted;

  /// No description provided for @permissionStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionStatusDenied;

  /// No description provided for @permissionStatusPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Permanently denied (settings)'**
  String get permissionStatusPermanentlyDenied;

  /// No description provided for @permissionStatusRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get permissionStatusRestricted;

  /// No description provided for @permissionStatusUndefined.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get permissionStatusUndefined;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get grantPermission;

  /// No description provided for @audioWarnings.
  ///
  /// In en, this message translates to:
  /// **'Audio Warnings'**
  String get audioWarnings;

  /// No description provided for @audioWarningsCount.
  ///
  /// In en, this message translates to:
  /// **'Warnings ({count})'**
  String audioWarningsCount(Object count);

  /// No description provided for @audioWarningFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get audioWarningFileSize;

  /// No description provided for @audioWarningDuration.
  ///
  /// In en, this message translates to:
  /// **'Recording length'**
  String get audioWarningDuration;

  /// No description provided for @audioWarningsSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get audioWarningsSampleRate;

  /// No description provided for @audioWarningBitRate.
  ///
  /// In en, this message translates to:
  /// **'Bit rate'**
  String get audioWarningBitRate;

  /// No description provided for @audioWarningChannels.
  ///
  /// In en, this message translates to:
  /// **'Audio channels'**
  String get audioWarningChannels;

  /// No description provided for @audioWarningFileCorruption.
  ///
  /// In en, this message translates to:
  /// **'File corruption'**
  String get audioWarningFileCorruption;

  /// No description provided for @audioWarningFileSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large file ({size} MB)'**
  String audioWarningFileSizeLarge(Object size);

  /// No description provided for @audioWarningFileSizeVeryLarge.
  ///
  /// In en, this message translates to:
  /// **'Very large file ({size} MB) - may slow down playback'**
  String audioWarningFileSizeVeryLarge(Object size);

  /// No description provided for @audioWarningDurationLong.
  ///
  /// In en, this message translates to:
  /// **'Long recording ({minutes} min)'**
  String audioWarningDurationLong(Object minutes);

  /// No description provided for @audioWarningDurationMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium recording ({minutes} min)'**
  String audioWarningDurationMedium(Object minutes);

  /// No description provided for @audioWarningSampleRateNonStandard.
  ///
  /// In en, this message translates to:
  /// **'Non-standard frequency: {sampleRate} Hz'**
  String audioWarningSampleRateNonStandard(Object sampleRate);

  /// No description provided for @audioWarningBitRateHigh.
  ///
  /// In en, this message translates to:
  /// **'High bitrate: {bitRate} kbps'**
  String audioWarningBitRateHigh(Object bitRate);

  /// No description provided for @audioWarningBitRateLow.
  ///
  /// In en, this message translates to:
  /// **'Low bitrate: {bitRate} kbps'**
  String audioWarningBitRateLow(Object bitRate);

  /// No description provided for @audioWarningChannelsMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone recording'**
  String get audioWarningChannelsMicrophone;

  /// No description provided for @audioWarningFileNotExists.
  ///
  /// In en, this message translates to:
  /// **'File does not exist'**
  String get audioWarningFileNotExists;

  /// No description provided for @audioWarningSuggestionCompress.
  ///
  /// In en, this message translates to:
  /// **'Consider compression or splitting into smaller parts'**
  String get audioWarningSuggestionCompress;

  /// No description provided for @audioWarningSuggestionPerformance.
  ///
  /// In en, this message translates to:
  /// **'May affect performance'**
  String get audioWarningSuggestionPerformance;

  /// No description provided for @audioWarningSuggestionInterfaceDelays.
  ///
  /// In en, this message translates to:
  /// **'May cause interface delays'**
  String get audioWarningSuggestionInterfaceDelays;

  /// No description provided for @audioWarningSuggestionMultiTrackPerformance.
  ///
  /// In en, this message translates to:
  /// **'Watch performance with multiple tracks'**
  String get audioWarningSuggestionMultiTrackPerformance;

  /// No description provided for @audioWarningSuggestionCompatibility.
  ///
  /// In en, this message translates to:
  /// **'May cause compatibility issues'**
  String get audioWarningSuggestionCompatibility;

  /// No description provided for @audioWarningSuggestionFileSize.
  ///
  /// In en, this message translates to:
  /// **'May affect file size'**
  String get audioWarningSuggestionFileSize;

  /// No description provided for @audioWarningSuggestionAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'May affect audio quality'**
  String get audioWarningSuggestionAudioQuality;

  /// No description provided for @audioWarningSuggestionChannelSettings.
  ///
  /// In en, this message translates to:
  /// **'Check audio channel settings'**
  String get audioWarningSuggestionChannelSettings;

  /// No description provided for @audioWarningSuggestionCheckFile.
  ///
  /// In en, this message translates to:
  /// **'Check if file was moved or deleted'**
  String get audioWarningSuggestionCheckFile;

  /// No description provided for @projectExport.
  ///
  /// In en, this message translates to:
  /// **'Save project'**
  String get projectExport;

  /// No description provided for @projectImport.
  ///
  /// In en, this message translates to:
  /// **'Load project'**
  String get projectImport;

  /// No description provided for @projectExportName.
  ///
  /// In en, this message translates to:
  /// **'Project name (optional)'**
  String get projectExportName;

  /// No description provided for @projectExportNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter project name'**
  String get projectExportNameHint;

  /// No description provided for @projectExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Project has been saved'**
  String get projectExportSuccess;

  /// No description provided for @projectImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Project has been loaded'**
  String get projectImportSuccess;

  /// No description provided for @projectImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Loading project will overwrite current session. All recordings will be deleted and track settings will be overridden. Continue?'**
  String get projectImportWarning;

  /// No description provided for @projectImportWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get projectImportWarningTitle;

  /// No description provided for @projectPreview.
  ///
  /// In en, this message translates to:
  /// **'Project preview'**
  String get projectPreview;

  /// No description provided for @projectMetadata.
  ///
  /// In en, this message translates to:
  /// **'Project metadata'**
  String get projectMetadata;

  /// No description provided for @projectStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get projectStatistics;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get projectVersion;

  /// No description provided for @projectExportDate.
  ///
  /// In en, this message translates to:
  /// **'Export date'**
  String get projectExportDate;

  /// No description provided for @projectGridSize.
  ///
  /// In en, this message translates to:
  /// **'Grid size'**
  String get projectGridSize;

  /// No description provided for @projectTotalTracks.
  ///
  /// In en, this message translates to:
  /// **'Total tracks'**
  String get projectTotalTracks;

  /// No description provided for @projectTracksWithRecordings.
  ///
  /// In en, this message translates to:
  /// **'Tracks with recordings'**
  String get projectTracksWithRecordings;

  /// No description provided for @projectTotalRecordingsSize.
  ///
  /// In en, this message translates to:
  /// **'Recordings size'**
  String get projectTotalRecordingsSize;

  /// No description provided for @projectExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting project...'**
  String get projectExporting;

  /// No description provided for @projectImporting.
  ///
  /// In en, this message translates to:
  /// **'Loading project...'**
  String get projectImporting;

  /// No description provided for @projectExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting project'**
  String get projectExportError;

  /// No description provided for @projectImportError.
  ///
  /// In en, this message translates to:
  /// **'Error loading project'**
  String get projectImportError;

  /// No description provided for @projectInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid project file format'**
  String get projectInvalidFormat;

  /// No description provided for @projectFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project file not found'**
  String get projectFileNotFound;

  /// No description provided for @projectFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Required file missing: {fileName}'**
  String projectFileMissing(Object fileName);

  /// No description provided for @projectFileParseError.
  ///
  /// In en, this message translates to:
  /// **'Parse error in file {fileName}. The file is corrupted or has invalid format.'**
  String projectFileParseError(Object fileName);

  /// No description provided for @projectFileEncodingError.
  ///
  /// In en, this message translates to:
  /// **'Encoding error in file {fileName}. The file may be corrupted or was created in a different version of the application.'**
  String projectFileEncodingError(Object fileName);

  /// No description provided for @projectFileStructureError.
  ///
  /// In en, this message translates to:
  /// **'Invalid structure in file {fileName}. Missing required field: {fieldName}'**
  String projectFileStructureError(Object fieldName, Object fileName);

  /// No description provided for @projectFileInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value in file {fileName}: {details}'**
  String projectFileInvalidValue(Object details, Object fileName);

  /// No description provided for @projectRecordingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recording listed in project was not found in archive'**
  String get projectRecordingNotFound;

  /// No description provided for @projectMetadataCorrupted.
  ///
  /// In en, this message translates to:
  /// **'Project file is corrupted. The metadata.json file cannot be read.'**
  String get projectMetadataCorrupted;

  /// No description provided for @projectMetadataEncodingError.
  ///
  /// In en, this message translates to:
  /// **'Project file has invalid encoding. The file may be corrupted or was created in a different version of the application.'**
  String get projectMetadataEncodingError;

  /// No description provided for @projectMetadataParseError.
  ///
  /// In en, this message translates to:
  /// **'Cannot read project data. The metadata.json file is corrupted or has invalid format.'**
  String get projectMetadataParseError;

  /// No description provided for @projectChecksumMismatch.
  ///
  /// In en, this message translates to:
  /// **'Checksum mismatch for file {fileName}'**
  String projectChecksumMismatch(Object fileName);

  /// No description provided for @projectChecksumMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification error'**
  String get projectChecksumMismatchTitle;

  /// No description provided for @projectDurationMismatch.
  ///
  /// In en, this message translates to:
  /// **'File length mismatch for {fileName}. Playback positions have been reset'**
  String projectDurationMismatch(Object fileName);

  /// No description provided for @projectDurationMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'File length warning'**
  String get projectDurationMismatchTitle;

  /// No description provided for @projectExportCancel.
  ///
  /// In en, this message translates to:
  /// **'Project export cancelled'**
  String get projectExportCancel;

  /// No description provided for @projectImportCancel.
  ///
  /// In en, this message translates to:
  /// **'Project import cancelled'**
  String get projectImportCancel;

  /// No description provided for @buttonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get buttonExport;

  /// No description provided for @buttonImport.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get buttonImport;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonYesImport.
  ///
  /// In en, this message translates to:
  /// **'Yes, import'**
  String get buttonYesImport;

  /// No description provided for @projectValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating project...'**
  String get projectValidating;

  /// No description provided for @projectValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Project validation failed'**
  String get projectValidationFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
