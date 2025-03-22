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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tune Tangler'**
  String get appTitle;

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
  /// **'Change track playback start at by -0.01 s'**
  String get trackPlaybackStartAtPositionSub10;

  /// No description provided for @trackPlaybackStartAtPositionSub100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by -0.1 s'**
  String get trackPlaybackStartAtPositionSub100;

  /// No description provided for @trackPlaybackStartAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset track playback start at'**
  String get trackPlaybackStartAtPositionReset;

  /// No description provided for @trackPlaybackStartAtPositionAdd100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by +0.1 s'**
  String get trackPlaybackStartAtPositionAdd100;

  /// No description provided for @trackPlaybackStartAtPositionAdd10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback start at by +0.01 s'**
  String get trackPlaybackStartAtPositionAdd10;

  /// No description provided for @trackPlaybackEndAtPositionSub10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by -0.01 s'**
  String get trackPlaybackEndAtPositionSub10;

  /// No description provided for @trackPlaybackEndAtPositionSub100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by -0.1 s'**
  String get trackPlaybackEndAtPositionSub100;

  /// No description provided for @trackPlaybackEndAtPositionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset track playback end at'**
  String get trackPlaybackEndAtPositionReset;

  /// No description provided for @trackPlaybackEndAtPositionAdd100.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by +0.1 s'**
  String get trackPlaybackEndAtPositionAdd100;

  /// No description provided for @trackPlaybackEndAtPositionAdd10.
  ///
  /// In en, this message translates to:
  /// **'Change track playback end at by +0.01 s'**
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
  /// **'Select icon to be setted as new name for {trackName} track.'**
  String trackNameChangeInfo(Object trackName);

  /// No description provided for @trackNameChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Setted new track name to {trackName}.'**
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
  /// **'Select icon to be setted as new keyboard key for {trackName} track.'**
  String trackKeyboardKeyChangeInfo(Object trackName);

  /// No description provided for @trackKeyboardKeyChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Setted new keyboard key to {trackName}.'**
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
  String trackRecordingMoveSuccess(Object firstTrackName, Object secondTrackName);

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
  /// **'Setted playback mode for tracks in {rowName} row to {value}.'**
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
  /// **'Setted playback speed for tracks in {rowName} row to {value}.'**
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
  /// **'Setted volume for tracks in {rowName} row to {value}.'**
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
  /// **'Setted balance for tracks in {rowName} row to {value}.'**
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
  /// **'Resetted row tracks playback start at in {rowName} row.'**
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
  /// **'Resetted all tracks playback end at in {rowName} row.'**
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
  /// **'left 100%, right 0%'**
  String get balanceLeft100;

  /// No description provided for @balanceLeft75.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 25%'**
  String get balanceLeft75;

  /// No description provided for @balanceLeft50.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 50%'**
  String get balanceLeft50;

  /// No description provided for @balanceLeft25.
  ///
  /// In en, this message translates to:
  /// **'left 100%, right 75%'**
  String get balanceLeft25;

  /// No description provided for @balanceLeft.
  ///
  /// In en, this message translates to:
  /// **'left 100%'**
  String get balanceLeft;

  /// No description provided for @balanceCenter.
  ///
  /// In en, this message translates to:
  /// **'center'**
  String get balanceCenter;

  /// No description provided for @balanceRight.
  ///
  /// In en, this message translates to:
  /// **'right 100%'**
  String get balanceRight;

  /// No description provided for @balanceRight25.
  ///
  /// In en, this message translates to:
  /// **'left 75%, right 100%'**
  String get balanceRight25;

  /// No description provided for @balanceRight50.
  ///
  /// In en, this message translates to:
  /// **'left 50%, right 100%'**
  String get balanceRight50;

  /// No description provided for @balanceRight75.
  ///
  /// In en, this message translates to:
  /// **'left 25%, right 100%'**
  String get balanceRight75;

  /// No description provided for @balanceRight100.
  ///
  /// In en, this message translates to:
  /// **'left 0%, right 100%'**
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

  /// No description provided for @settingProfile.
  ///
  /// In en, this message translates to:
  /// **'Settings profile'**
  String get settingProfile;

  /// No description provided for @settingsProfiles.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles'**
  String get settingsProfiles;

  /// No description provided for @settingProfilesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles'**
  String get settingProfilesListTitle;

  /// No description provided for @settingProfilesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Settings profiles list is empty.'**
  String get settingProfilesEmpty;

  /// No description provided for @settingProfileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingProfileDelete;

  /// No description provided for @settingProfileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete settings profile'**
  String get settingProfileDeleteTitle;

  /// No description provided for @settingProfileDeleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Settings profile will be deleted. Continue?'**
  String get settingProfileDeleteInfo;

  /// No description provided for @settingProfileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Settings profile deleted.'**
  String get settingProfileDeleted;

  /// No description provided for @settingProfileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get settingProfileCreate;

  /// No description provided for @settingProfileCreated.
  ///
  /// In en, this message translates to:
  /// **'Settings profile created.'**
  String get settingProfileCreated;

  /// No description provided for @settingProfileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings profile saved.'**
  String get settingProfileSaveSuccess;

  /// No description provided for @settingProfileLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get settingProfileLoad;

  /// No description provided for @settingProfileLoaded.
  ///
  /// In en, this message translates to:
  /// **'Settings profile loaded.'**
  String get settingProfileLoaded;

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
  /// **'This application allows you to record audio from a microphone or USB audio interface (your device must support USB OTG technology) to one of several tracks. You can also import an existing audio file.\n\nRecordings can be played synchronously or asynchronously, in a loop or not.\n\nRecordings and their settings, as well as the graphic mode and language, are remembered after the application is closed.'**
  String get helpScreenMessageAboutContent;

  /// No description provided for @helpScreenMessageGridScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracks grid screen'**
  String get helpScreenMessageGridScreenTitle;

  /// No description provided for @helpScreenMessageGridScreenContent.
  ///
  /// In en, this message translates to:
  /// **'Short press a colored track block or use a hotkey (visible at the top of the track) to perform one of the available actions.\n\nHold the track block or use the hotkey with the Control key \$[controlKey] to open the track details.'**
  String get helpScreenMessageGridScreenContent;

  /// No description provided for @helpScreenMessageDetailsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Track details screen'**
  String get helpScreenMessageDetailsScreenTitle;

  /// No description provided for @helpScreenMessageDetailsScreenContent.
  ///
  /// In en, this message translates to:
  /// **'There are several settings, such as: \$[recordingClip]recording trimming, \$[trackPlaybackMode]playback mode, \$[trackPlaybackVolume]playback volume value, \$[trackPlaybackBalance]audio balance, \$[trackPlaybackSpeed]playback speed, \$[trackName]track name, \$[trackKeyboardKey]track keyboard shortcut. You can also \$[trackRecordingMove]change the track location on the grid, \$[trackRecordingImport]import recording file, \$[trackRecordingShare]share or \$[deleteForever]delete recording.'**
  String get helpScreenMessageDetailsScreenContent;

  /// No description provided for @helpScreenMessageTrackStates.
  ///
  /// In en, this message translates to:
  /// **'Track states and actions'**
  String get helpScreenMessageTrackStates;

  /// No description provided for @helpScreenMessageTrackIcons.
  ///
  /// In en, this message translates to:
  /// **'Track info icons'**
  String get helpScreenMessageTrackIcons;

  /// No description provided for @helpScreenMessageSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'You can set \$[recordingAudioEncoder]audio codec, \$[recordingSampleRate]sample rate, \$[recordingBitRate]bit rate, \$[recordingAudioMode]audio mode, \$[recordingAutoGain]auto gain, \$[recordingEchoCancel]echo cancel and \$[recordingNoiseSuppress]noise suppression.'**
  String get helpScreenMessageSettingsInfo;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'track empty (click on box to start recording)'**
  String get stateEmpty;

  /// No description provided for @stateRecording.
  ///
  /// In en, this message translates to:
  /// **'recording in progress (click on box to stop recording)'**
  String get stateRecording;

  /// No description provided for @stateProcessing.
  ///
  /// In en, this message translates to:
  /// **'track processing in progress'**
  String get stateProcessing;

  /// No description provided for @stateIdle.
  ///
  /// In en, this message translates to:
  /// **'idle: recording done/playing stopped (click on box to start playing)'**
  String get stateIdle;

  /// No description provided for @statePlaying.
  ///
  /// In en, this message translates to:
  /// **'playing started track (click on box to stop playing)'**
  String get statePlaying;

  /// No description provided for @statePaused.
  ///
  /// In en, this message translates to:
  /// **'playing paused (click on box to unpause playing)'**
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

  /// No description provided for @screenThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme accent color'**
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
  /// **'Setted theme accent color to {name}.'**
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
  /// **'Setted grid rows amount to {value}.'**
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
  /// **'Setted grid columns amount to {value}.'**
  String gridColsAmountSuccess(Object value);

  /// No description provided for @trackSettings.
  ///
  /// In en, this message translates to:
  /// **'Track settings'**
  String get trackSettings;

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
  /// **'Setted emojis that might be used as track title.'**
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
  /// **'Resetted all tracks title.'**
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
  /// **'Resetted all tracks shortcut key.'**
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
  /// **'Select playback mode to which all track will be setted.'**
  String get allTracksPlaybackModeInfoSet;

  /// No description provided for @allTracksPlaybackModeSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Setted all tracks playback mode to {mode}.'**
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
  /// **'Select volume to which all track will be setted.'**
  String get allTracksPlaybackVolumeInfoSet;

  /// No description provided for @allTracksPlaybackVolumeSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Setted all tracks playback volume to {value}.'**
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
  /// **'Select balance to which all track will be setted.'**
  String get allTracksPlaybackBalanceInfoSet;

  /// No description provided for @allTracksPlaybackBalanceSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Setted all tracks playback balance to {value}.'**
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
  /// **'Select track speed which all track will be setted.'**
  String get allTracksPlaybackSpeedInfoSet;

  /// No description provided for @allTracksPlaybackSpeedSuccessSet.
  ///
  /// In en, this message translates to:
  /// **'Setted all tracks playback speed to {value}.'**
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
  /// **'Resetted all tracks playback start at.'**
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
  /// **'Resetted all tracks playback end at.'**
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
  /// **'All all tracks settings will be restored to default. Continue?'**
  String get allTracksSettingsResetInfo;

  /// No description provided for @allTracksSettingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All all tracks settings was restored to default.'**
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
  /// **'Recordings for all track will be deleted permanently. Continue?'**
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
  /// **'Setted device to {value}.'**
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
  /// **'Setted audio encoder to {value}.'**
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
  /// **'Setted recording sample rate to {value}.'**
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
  /// **'Setted recording bit rate to {value}.'**
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
  /// **'Setted recording audio mode to {value}.'**
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
  /// **'The recorder will try to auto adjust recording volume in a limited range (if available on the device). Recording volume may be lowered by using this.'**
  String get recordingAutoGainInfo;

  /// No description provided for @recordingAutoGainSuccess.
  ///
  /// In en, this message translates to:
  /// **'Setted auto gain to {value}.'**
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
  /// **'Setted echo cancel to {value}.'**
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
  /// **'The recorder will try to negates the input noise (if available on the device). Recording volume may be lowered by using this.'**
  String get recordingNoiseSuppressInfo;

  /// No description provided for @recordingNoiseSuppressSuccess.
  ///
  /// In en, this message translates to:
  /// **'Setted noise suppress to {value}.'**
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
  /// **'All screen settings was restored to default.'**
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
  /// **'All recording settings was restored to default.'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
