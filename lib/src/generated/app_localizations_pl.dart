// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Plątacz Melodii';

  @override
  String get appTitleDebug => 'Plątacz Melodii (Debug)';

  @override
  String get legalNote => 'Stworzone z ♥️ przez Flower7C3';

  @override
  String cell(Object cellName) {
    return '$cellName';
  }

  @override
  String trackTitle(Object trackName) {
    return 'Ścieżka $trackName';
  }

  @override
  String get allTracksPlayingStart => 'Odtwarzaj wszystkie ścieżki';

  @override
  String get allTracksPlayingStop => 'Zatrzymaj wszystkie ścieżki';

  @override
  String rowTracksPlayingStart(Object rowName) {
    return 'Odtwarzaj ścieżki w wierszu $rowName';
  }

  @override
  String rowTracksPlayingStop(Object rowName) {
    return 'Zatrzymaj ścieżki w wierszu $rowName';
  }

  @override
  String trackPlayingStart(Object trackName) {
    return 'Rozpocznij odtwarzanie ścieżki $trackName';
  }

  @override
  String trackPlayingPause(Object trackName) {
    return 'Wstrzymaj odtwarzanie ścieżki $trackName';
  }

  @override
  String trackPlayingResume(Object trackName) {
    return 'Wznów odtwarzanie ścieżki $trackName';
  }

  @override
  String trackPlayingStop(Object trackName) {
    return 'Zatrzymaj odtwarzanie ścieżki $trackName';
  }

  @override
  String trackPlaybackModeToggle(Object trackName) {
    return 'Przełącz tryb odtwarzania ścieżki $trackName';
  }

  @override
  String trackKeyboardKey(Object trackName) {
    return 'Klawisz skrótu dla ścieżki $trackName';
  }

  @override
  String get thePlaybackPosition => 'Pozycja';

  @override
  String get thePlaybackTrim => 'Przycinanie';

  @override
  String get thePlaybackSpeed => 'Prędkość odtwarzania';

  @override
  String get thePlaybackVolume => 'Głośność odtwarzania';

  @override
  String get thePlaybackBalance => 'Balans audio';

  @override
  String thePlaybackBalanceAt(Object value) {
    return 'Balans audio: $value';
  }

  @override
  String get thePlaybackStartAtPosition => 'Pozycja początku nagrania';

  @override
  String get thePlaybackEndAtPosition => 'Pozycja końca nagrania';

  @override
  String get trackRecording => 'Trwa nagrywanie';

  @override
  String get theAudioSourceRecorded => 'Audio nagrane';

  @override
  String get theAudioSourceImported => 'Audio zaimportowane';

  @override
  String get theKeyboardKey => 'Klawisz skrótu';

  @override
  String trackRecordingImport(Object trackName) {
    return 'Importuj plik do ścieżki $trackName';
  }

  @override
  String trackRecordingImported(Object trackName) {
    return 'Importowano plik do ścieżki $trackName.';
  }

  @override
  String trackRecordingImportCancelled(Object trackName) {
    return 'Anulowano import pliku do ścieżki $trackName.';
  }

  @override
  String trackRecordingImportNoPermissions(Object trackName) {
    return 'Brak uprawnień do importowania pliku do ścieżki $trackName.';
  }

  @override
  String trackRecordingInfo(Object trackName) {
    return 'Nagrywanie do ścieżki $trackName';
  }

  @override
  String get clickToOpenApp => 'Dotknij, aby otworzyć aplikację';

  @override
  String trackRecordingStart(Object trackName) {
    return 'Rozpocznij nagrywanie do ścieżki $trackName';
  }

  @override
  String get trackRecordingAlreadyStarted =>
      'Inne nagrywanie już zostało rozpoczęte.';

  @override
  String get trackRecordingStartNoAudioPermission =>
      'Brak uprawnień do nagrywania dźwięku.';

  @override
  String get trackRecordingStartNoNotificationPermission =>
      'Brak uprawnień do powiadamiania o nagrywaniu.';

  @override
  String trackRecordingStartError(Object error, Object trackName) {
    return 'Wystąpił błąd podczas startu nagrywania ścieżki $trackName\n$error';
  }

  @override
  String trackRecordingCancel(Object trackName) {
    return 'Anuluj nagrywanie do ścieżki $trackName';
  }

  @override
  String trackRecordingCancelled(Object trackName) {
    return 'Anulowano nagrywanie ścieżki $trackName.';
  }

  @override
  String trackRecordingStop(Object trackName) {
    return 'Zatrzymaj nagrywanie do ścieżki $trackName';
  }

  @override
  String trackRecordingStopSuccess(Object trackName) {
    return 'Ukończono nagrywanie ścieżki $trackName.';
  }

  @override
  String trackRecordingStopError(Object error, Object trackName) {
    return 'Wystąpił błąd podczas nagrywanie ścieżki $trackName\n$error';
  }

  @override
  String trackPlaybackSpeedSet(Object trackName) {
    return 'Ustaw prędkość odtwarzania ścieżki $trackName';
  }

  @override
  String trackPlaybackVolumeSet(Object trackName) {
    return 'Ustaw głośność odtwarzania ścieżki $trackName';
  }

  @override
  String trackPlaybackBalanceSet(Object trackName) {
    return 'Ustaw balans odtwarzania ścieżki $trackName';
  }

  @override
  String get trackPlaybackStartAtPositionSub10 =>
      'Zmień początek odtwarzania ścieżki o -0.01 s';

  @override
  String get trackPlaybackStartAtPositionSub100 =>
      'Zmień początek odtwarzania ścieżki o -0,1 s';

  @override
  String get trackPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania ścieżki';

  @override
  String get trackPlaybackStartAtPositionAdd100 =>
      'Zmień początek odtwarzania ścieżki o +0,1 s';

  @override
  String get trackPlaybackStartAtPositionAdd10 =>
      'Zmień początek odtwarzania ścieżki o +0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub10 =>
      'Zmień koniec odtwarzania ścieżki o -0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub100 =>
      'Zmień koniec odtwarzania ścieżki o -0,1 s';

  @override
  String get trackPlaybackEndAtPositionReset =>
      'Resetuj koniec odtwarzania ścieżki';

  @override
  String get trackPlaybackEndAtPositionAdd100 =>
      'Zmień koniec odtwarzania ścieżki o +0,1 s';

  @override
  String get trackPlaybackEndAtPositionAdd10 =>
      'Zmień koniec odtwarzania ścieżki o +0.01 s';

  @override
  String get trackNameChange => 'Zmień nazwę ścieżki';

  @override
  String trackNameChangeTitle(Object trackName) {
    return 'Zmień nazwę ścieżki $trackName';
  }

  @override
  String trackNameChangeInfo(Object trackName) {
    return 'Wybierz ikonę, która ma zostać ustawiona jako nowa nazwa ścieżki $trackName.';
  }

  @override
  String trackNameChangeSuccess(Object trackName) {
    return 'Ustawiono nową nazwę ścieżki na $trackName.';
  }

  @override
  String get trackKeyboardKeyChange => 'Zmień klawisz skrótu';

  @override
  String trackKeyboardKeyChangeTitle(Object trackName) {
    return 'Zmień klawisz klawiatury ścieżki $trackName';
  }

  @override
  String trackKeyboardKeyChangeInfo(Object trackName) {
    return 'Wybierz klawisz, który ma zostać ustawiona jako nowy klawisz klawiatury dla ścieżki $trackName.';
  }

  @override
  String trackKeyboardKeyChangeSuccess(Object trackName) {
    return 'Ustawiono nowy klawisz klawiatury dla ścieżki $trackName.';
  }

  @override
  String get trackRecordingMove => 'Przenieś nagranie';

  @override
  String trackRecordingMoveTitle(Object trackName) {
    return 'Przenieś nagranie ścieżki $trackName';
  }

  @override
  String trackRecordingMoveInfo(Object trackName) {
    return 'Wybierz nową lokalizację dla nagrania ścieżki $trackName.';
  }

  @override
  String trackRecordingMoveSuccess(
      Object firstTrackName, Object secondTrackName) {
    return 'Zamieniono lokalizację dla nagrań #$firstTrackName i #$secondTrackName.';
  }

  @override
  String trackRecordingShare(Object trackName) {
    return 'Udostępnij nagranie ścieżki $trackName';
  }

  @override
  String trackRecordingShareMessage(Object trackName) {
    return 'Oto mój plik nagrania dla ścieżki $trackName zrealizowany za pomocą aplikacji Plątacz Melodii!';
  }

  @override
  String trackRecordingShareNoFile(Object trackName) {
    return 'Brak pliku nagrania dla ścieżki $trackName';
  }

  @override
  String get trackRecordingDelete => 'Usuń nagranie';

  @override
  String trackRecordingDeleteTitle(Object trackName) {
    return 'Usuń nagranie ścieżki $trackName';
  }

  @override
  String trackRecordingDeleteInfo(Object trackName) {
    return 'Nagranie ścieżki $trackName zostanie trwale usunięte. Kontynuować?';
  }

  @override
  String trackRecordingDeleteSuccess(Object trackName) {
    return 'Usunięto nagranie ścieżki $trackName.';
  }

  @override
  String get rowTracksPlaybackModeSet => 'Tryb odtwarzania';

  @override
  String rowTracksPlaybackModeSetTitle(Object value) {
    return 'Ustaw tryb odtwarzania na $value';
  }

  @override
  String rowTracksPlaybackModeSetSuccess(Object rowName, Object value) {
    return 'Ustawiono tryb odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackSpeedSet => 'Prędkość odtwarzania';

  @override
  String rowTracksPlaybackSpeedTitleSet(Object value) {
    return 'Ustaw prędkość odtwarzania na $value';
  }

  @override
  String rowTracksPlaybackSpeedSuccessSet(Object rowName, Object value) {
    return 'Ustawiono prędkość odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackVolumeSet => 'Głośność odtwarzania';

  @override
  String rowTracksPlaybackVolumeTitleSet(Object value) {
    return 'Ustaw głośność na $value';
  }

  @override
  String rowTracksPlaybackVolumeSuccessSet(Object rowName, Object value) {
    return 'Ustawiono głośność dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackBalanceSet => 'Balans odtwarzania';

  @override
  String rowTracksPlaybackBalanceTitleSet(Object value) {
    return 'Ustaw balans odtwarzania na $value';
  }

  @override
  String rowTracksPlaybackBalanceSuccessSet(Object rowName, Object value) {
    return 'Ustawiono balans odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania';

  @override
  String get rowTracksPlaybackStartAtPositionResetTitle =>
      'Zresetuj początek odtwarzania utworów wiersza';

  @override
  String rowTracksPlaybackStartAtPositionResetInfo(Object rowName) {
    return 'Wszystkie utwory w wierszu $rowName będą miały domyślny początek odtwarzania na. Kontynuować?';
  }

  @override
  String rowTracksPlaybackStartAtPositionResetSuccess(Object rowName) {
    return 'Zresetowano początek odtwarzania utworów wiersza na w wierszu $rowName.';
  }

  @override
  String get rowTracksPlaybackEndAtPositionReset =>
      'Zresetuj koniec odtwarzania';

  @override
  String get rowTracksPlaybackEndAtPositionResetTitle =>
      'Zresetuj koniec odtwarzania utworów wiersza';

  @override
  String rowTracksPlaybackEndAtPositionResetInfo(Object rowName) {
    return 'Wszystkie utwory w wierszu $rowName będą miały domyślny koniec odtwarzania na. Kontynuować?';
  }

  @override
  String rowTracksPlaybackEndAtPositionResetSuccess(Object rowName) {
    return 'Zresetowano wszystkie zakończenia odtwarzania utworów w wierszu $rowName.';
  }

  @override
  String get rowTracksRecordingsDelete => 'Usuń nagrania';

  @override
  String get rowTracksRecordingsDeleteTitle => 'Usuń nagrania wiersza';

  @override
  String rowTracksRecordingsDeleteInfo(Object rowName) {
    return 'Wszystkie nagrania ścieżek w wierszu $rowName zostaną usunięte. Kontynuować?';
  }

  @override
  String rowTracksRecordingsDeleteSuccess(Object rowName) {
    return 'Usunięto nagrania ścieżek w wierszu $rowName.';
  }

  @override
  String get balanceLeft100 => 'lewa 100%, prawa 0%';

  @override
  String get balanceLeft75 => 'lewa 100%, prawa 25%';

  @override
  String get balanceLeft50 => 'lewa 100%, prawa 50%';

  @override
  String get balanceLeft25 => 'lewa 100%, prawa 75%';

  @override
  String get balanceLeft => 'lewa 100%';

  @override
  String get balanceCenter => 'centralnie';

  @override
  String get balanceRight => 'prawa 100%';

  @override
  String get balanceRight25 => 'lewa 75%, prawa 100%';

  @override
  String get balanceRight50 => 'lewa 50%, prawa 100%';

  @override
  String get balanceRight75 => 'lewa 25%, prawa 100%';

  @override
  String get balanceRight100 => 'lewa 0%, prawa 100%';

  @override
  String languageWithLocale(Object locale, Object name) {
    return '$name ($locale)';
  }

  @override
  String get keepScreenOnEnabled => 'Utrzymywanie włączonego ekranu aktywne';

  @override
  String get keepScreenOnDisabled =>
      'Utrzymywanie włączonego ekranu nieaktywne';

  @override
  String get changeLanguage => 'Zmień język';

  @override
  String get menuKeepScreenOn => 'Utrzymaj ekran włączony';

  @override
  String get settingProfile => 'Profil ustawień';

  @override
  String get settingsProfiles => 'Profile ustawień';

  @override
  String get settingProfilesListTitle => 'Profile ustawień';

  @override
  String get settingProfilesEmpty => 'Brak zapisanych profili ustawień.';

  @override
  String get settingProfileDelete => 'Usuń';

  @override
  String get settingProfileDeleteTitle => 'Usuń profil ustawień';

  @override
  String get settingProfileDeleteInfo =>
      'Profil ustawień zostanie usunięty. Kontynuować?';

  @override
  String get settingProfileDeleted => 'Profil ustawień został usunięty.';

  @override
  String get settingProfileCreate => 'Utwórz';

  @override
  String get settingProfileCreated => 'Profil ustawień został utworzony.';

  @override
  String get settingProfileSaveSuccess => 'Profil ustawień został zapisany.';

  @override
  String get settingProfileLoad => 'Wczytaj';

  @override
  String get settingProfileLoaded => 'Profil ustawień został załadowany.';

  @override
  String get moreSettings => 'Więcej ustawień...';

  @override
  String get help => 'Pomoc';

  @override
  String get helpScreenMessageAboutTitle => 'O aplikacji';

  @override
  String get helpScreenMessageAboutContent =>
      'Ta aplikacja umożliwia rejestrację dźwięku z mikrofonu lub interfejsu USB audio (urządzenie musi obsługiwać technologię USB OTG) do jednej z wielu ścieżek. Możliwe jest również zaimportowanie istniejącego pliku audio.\n\nNagrania można odtwarzać synchronicznie lub asynchronicznie, w pętli lub bez.\n\nNagrania i ich ustawienia oraz tryb graficzny i język są zapamiętywane po wyłączeniu aplikacji.';

  @override
  String get helpScreenMessageGridScreenTitle => 'Ekran siatki ścieżek';

  @override
  String get helpScreenMessageGridScreenContent =>
      'Naciśnij krótko kolorowy blok ścieżki lub użyj skrótu klawiszowego (widocznego u góry ścieżki), aby wykonać jedną z dostępnych akcji.\n\nPrzytrzymaj blok ścieżki lub użyj skrótu klawiszowego z klawiszem Control \$[controlKey], aby otworzyć szczegóły ścieżki.';

  @override
  String get helpScreenMessageDetailsScreenTitle => 'Ekran szczegółów ścieżki';

  @override
  String get helpScreenMessageDetailsScreenContent =>
      'Istnieje kilka ustawień, takich jak: \$[recordingClip]przycinanie nagrania, \$[trackPlaybackMode]tryb odtwarzania, \$[trackPlaybackVolume]wartość głośności odtwarzania, \$[trackPlaybackBalance]balans audio, \$[trackPlaybackSpeed]prędkość odtwarzania, \$[trackName]nazwa ścieżki, \$[trackKeyboardKey]skrót klawiszowy ścieżki.\nMożesz również \$[trackRecordingMove]zmienić lokalizację ścieżki na siatce, \$[trackRecordingImport]zaimportować plik nagrania, \$[trackRecordingShare]udostępnić lub \$[deleteForever]usunąć nagranie.';

  @override
  String get helpScreenMessageTrackStates => 'Statusy i akcje ścieżki';

  @override
  String get helpScreenMessageTrackIcons => 'Ikony informacji o ścieżce';

  @override
  String get helpScreenMessageSettingsInfo =>
      'Dostępne jest ustawianie \$[recordingAudioEncoder]kodeka audio, \$[recordingSampleRate]częstotliwości próbkowania, \$[recordingBitRate]szybkości transmisji, \$[recordingAudioMode]trybu audio, \$[recordingAutoGain]automatycznego wzmocnienia, \$[recordingEchoCancel]anulowania echa i \$[recordingNoiseSuppress]tłumienia szumów.';

  @override
  String get stateEmpty =>
      'ścieżka pusta (kliknij blok, aby rozpocząć nagrywanie ścieżki)';

  @override
  String get stateRecording =>
      'nagrywanie w toku (kliknij blok, aby zatrzymać nagrywanie ścieżki)';

  @override
  String get stateProcessing => 'ładowanie nagrania w trakcie';

  @override
  String get stateIdle =>
      'bezczynność: nagrywanie zakończone/odtwarzanie zatrzymane (kliknij blok, aby rozpocząć odtwarzanie ścieżki)';

  @override
  String get statePlaying =>
      'odtwarzanie rozpoczętej ścieżki (kliknij blok, aby zatrzymać odtwarzanie ścieżki)';

  @override
  String get statePaused =>
      'odtwarzanie wstrzymane (kliknij blok, aby wznowić odtwarzanie ścieżki)';

  @override
  String get buttonAdd => 'Dodaj';

  @override
  String get buttonOk => 'Ok';

  @override
  String get buttonYes => 'Tak';

  @override
  String get buttonNo => 'Nie';

  @override
  String get buttonCancel => 'Anuluj';

  @override
  String get buttonReset => 'Resetuj';

  @override
  String buttonResetTo(Object value) {
    return 'Resetuj do $value';
  }

  @override
  String get buttonLoad => 'Załaduj';

  @override
  String get buttonDelete => 'Usuń';

  @override
  String get buttonSave => 'Zapisz';

  @override
  String buttonSaveTo(Object value) {
    return 'Zapisz $value';
  }

  @override
  String get buttonSearch => 'Szukaj';

  @override
  String get noRecents => 'Brak ostatnio używanych';

  @override
  String get screenSettings => 'Ustawienia ekranu';

  @override
  String get screen => 'Ekran';

  @override
  String get languageVersion => 'Wersja językowa';

  @override
  String languageVersionValue(Object value) {
    return 'Wersja językowa: $value';
  }

  @override
  String get screenThemeMode => 'Tryb motywu ekranu';

  @override
  String screenThemeModeValue(Object value) {
    return 'Tryb motywu ekranu: $value';
  }

  @override
  String get screenSystemThemeMode => 'wg urządzenia';

  @override
  String get screenDarkThemeMode => 'tryb ciemny';

  @override
  String get screenLightThemeMode => 'tryb jasny';

  @override
  String get enabled => 'włączono';

  @override
  String get disabled => 'wyłączono';

  @override
  String get screenThemeColor => 'Kolor akcentu motywu';

  @override
  String screenThemeColorValue(Object value) {
    return 'Kolor akcentu motywu: $value';
  }

  @override
  String get screenThemeColorTitle => 'Ustaw kolor akcentu motywu';

  @override
  String get screenThemeColorInfo =>
      'Wybierz kolor, który zostanie zastosowany jako akcent motywu.';

  @override
  String screenThemeColorSuccess(Object name) {
    return 'Ustawiono kolor akcentu motywu na $name.';
  }

  @override
  String get keepScreenOn => 'Utrzymaj ekran włączony';

  @override
  String keepScreenOnValue(Object value) {
    return 'Utrzymaj ekran włączony: $value';
  }

  @override
  String get keepScreenOnIsEnabledSuccess =>
      'Włączono funkcję utrzymywania włączonego ekranu.';

  @override
  String get keepScreenOnIsDisabledSuccess =>
      'Wyłączono funkcję utrzymywania włączonego ekranu.';

  @override
  String get gridRowsAmount => 'Liczba wierszy siatki';

  @override
  String gridRowsAmountValue(Object value) {
    return 'Liczba wierszy siatki: $value';
  }

  @override
  String get gridRowsAmountTitle => 'Liczba wierszy siatki';

  @override
  String get gridRowsAmountInfo =>
      'Ustaw liczbę wierszy siatki, która będzie widoczna na liście ścieżek.';

  @override
  String gridRowsAmountSuccess(Object value) {
    return 'Ustawiono liczbę wierszy siatki na $value.';
  }

  @override
  String get gridColsAmount => 'Liczba kolumn siatki';

  @override
  String gridColsAmountValue(Object value) {
    return 'Liczba kolumn siatki: $value';
  }

  @override
  String get gridColsAmountTitle => 'Liczba kolumn siatki';

  @override
  String get gridColsAmountInfo =>
      'Ustaw liczbę kolumn siatki, która będzie widoczna na liście ścieżek.';

  @override
  String gridColsAmountSuccess(Object value) {
    return 'Ustawiono liczbę kolumn siatki na $value.';
  }

  @override
  String get trackSettings => 'Ustawienia ścieżki';

  @override
  String get track => 'Ścieżka';

  @override
  String get trackTitleEmojis => 'Emoji tytułu';

  @override
  String get trackTitleEmojisTitle => 'Emoji tytułu ścieżki';

  @override
  String get trackTitleEmojisInfo =>
      'Ustaw emoji, które mogą być używane jako tytuł ścieżki.';

  @override
  String get trackTitleEmojisSuccess =>
      'Ustawiono emoji, które mogą być używane jako tytuł ścieżki.';

  @override
  String get allTracksTitleReset => 'Zresetuj tytuły';

  @override
  String get allTracksTitleResetTitle => 'Zresetuj tytuły ścieżek';

  @override
  String get allTracksTitleResetInfo =>
      'Wszystkie ścieżki będą miały domyślny tytuł. Kontynuować?';

  @override
  String get allTracksTitleResetSuccess =>
      'Zresetowano tytuły dla wszystkich ścieżek.';

  @override
  String get allTracksShortcutKeyReset => 'Zresetuj klawisze skrótu';

  @override
  String get allTracksShortcutKeyResetTitle =>
      'Zresetuj klawisze skrótu ścieżek';

  @override
  String get allTracksShortcutKeyResetInfo =>
      'Wszystkie ścieżki będą miały domyślny klawisz skrótu. Kontynuować?';

  @override
  String get allTracksShortcutKeyResetSuccess =>
      'Zresetowano klawisze skrótu dla wszystkich ścieżek.';

  @override
  String get allTracksPlaybackModeSet => 'Ustaw tryb odtwarzania';

  @override
  String get allTracksPlaybackModeTitleSet => 'Ustaw tryb odtwarzania ścieżek';

  @override
  String get allTracksPlaybackModeInfoSet =>
      'Wybierz tryb odtwarzania, na który zostaną ustawione wszystkie ścieżki.';

  @override
  String allTracksPlaybackModeSuccessSet(Object mode) {
    return 'Ustawiono tryb odtwarzania wszystkich ścieżek na $mode.';
  }

  @override
  String get singlePlaybackMode => 'pojedyńczo';

  @override
  String get repeatPlaybackMode => 'w pętli';

  @override
  String get allTracksPlaybackVolumeSet => 'Ustaw głośność odtwarzania';

  @override
  String get allTracksPlaybackVolumeTitleSet => 'Ustaw głośność ścieżek';

  @override
  String get allTracksPlaybackVolumeInfoSet =>
      'Wybierz głośność, na którą zostaną ustawione wszystkie ścieżki.';

  @override
  String allTracksPlaybackVolumeSuccessSet(Object value) {
    return 'Ustawiono głośność odtwarzania wszystkich ścieżek na $value.';
  }

  @override
  String get allTracksPlaybackBalanceSet => 'Ustaw balans odtwarzania';

  @override
  String get allTracksPlaybackBalanceTitleSet =>
      'Ustaw balans odtwarzania wszystkich ścieżek';

  @override
  String get allTracksPlaybackBalanceInfoSet =>
      'Wybierz balans odtwarzania, na który zostaną ustawione wszystkie ścieżki.';

  @override
  String allTracksPlaybackBalanceSuccessSet(Object value) {
    return 'Ustawiono balans odtwarzania wszystkich ścieżek na $value.';
  }

  @override
  String get allTracksPlaybackSpeedSet => 'Ustaw prędkość';

  @override
  String get allTracksPlaybackSpeedTitleSet => 'Ustaw prędkość ścieżek';

  @override
  String get allTracksPlaybackSpeedInfoSet =>
      'Wybierz prędkość, na którą będą ustawione wszystkie ścieżki.';

  @override
  String allTracksPlaybackSpeedSuccessSet(Object value) {
    return 'Prędkość ścieżek została ustawiona na $value.';
  }

  @override
  String get allTracksPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania na';

  @override
  String get allTracksPlaybackStartAtPositionResetTitle =>
      'Zresetuj początek odtwarzania wszystkich ścieżek na';

  @override
  String get allTracksPlaybackStartAtPositionResetInfo =>
      'Wszystkie ścieżki będą miały domyślny początek odtwarzania na. Kontynuować?';

  @override
  String get allTracksPlaybackStartAtPositionResetSuccess =>
      'Zresetowano początek odtwarzania wszystkich ścieżek na.';

  @override
  String get allTracksPlaybackEndAtPositionReset =>
      'Zresetowano koniec odtwarzania na';

  @override
  String get allTracksPlaybackEndAtPositionResetTitle =>
      'Zresetowano koniec odtwarzania wszystkich ścieżek na';

  @override
  String get allTracksPlaybackEndAtPositionResetInfo =>
      'Wszystkie ścieżki będą miały domyślny koniec odtwarzania na. Kontynuować?';

  @override
  String get allTracksPlaybackEndAtPositionResetSuccess =>
      'Zresetowano koniec odtwarzania wszystkich ścieżek na.';

  @override
  String get allTracksSettingsReset => 'Zresetuj ustawienia ścieżek';

  @override
  String get allTracksSettingsResetTitle =>
      'Zresetuj ustawienia wszystkich ścieżek';

  @override
  String get allTracksSettingsResetInfo =>
      'Ustawienia wszystkich ścieżek zostaną przywrócone do domyślnych. Kontynuować?';

  @override
  String get allTracksSettingsResetSuccess =>
      'Ustawienia wszystkich ścieżek zostały przywrócone do domyślnych.';

  @override
  String get allTracksRecordingsDelete => 'Usuń wszystkie nagrania';

  @override
  String get allTracksRecordingsDeleteTitle => 'Usuń wszystkie nagrania';

  @override
  String get allTracksRecordingsDeleteInfo =>
      'Wszystkie nagrania zostaną trwale usunięte. Kontynuować?';

  @override
  String get allTracksRecordingsDeleteSuccess =>
      'Wszystkie nagrania zostały trwale usunięte.';

  @override
  String get recordingSettings => 'Ustawienia nagrywania';

  @override
  String get settingsChange => 'Zmień ustawienia';

  @override
  String get recording => 'Nagrywanie';

  @override
  String get defaultDevice => 'domyślne';

  @override
  String get recordingInputDevice => 'Urządzenie wejściowe';

  @override
  String recordingInputDeviceValue(Object label) {
    return 'Urządzenie wejściowe: $label';
  }

  @override
  String get recordingInputDeviceTitle => 'Urządzenie wejściowe';

  @override
  String get recordingInputDeviceInfo =>
      'Ustaw urządzenie wejściowe do nagrywania dźwięku.';

  @override
  String recordingInputDeviceSuccess(Object value) {
    return 'Ustawiono urządzenie wejściowe na $value.';
  }

  @override
  String get recordingAudioEncoders => 'Szczegóły kodeków audio';

  @override
  String get recordingAudioEncoder => 'Kodek audio';

  @override
  String recordingAudioEncoderValue(Object value) {
    return 'Kodek audio: $value';
  }

  @override
  String get recordingAudioEncoderTitle => 'Kodek audio';

  @override
  String recordingAudioEncoderSuccess(Object value) {
    return 'Ustawiono kodek audio na $value.';
  }

  @override
  String get audioRecorderAacHeName =>
      'MPEG-4 AAC HE (Advanced Audio Codec - High Efficiency)';

  @override
  String get audioRecorderAacHeInfo =>
      'Radio internetowe i strumieniowanie przy niskim bitrate';

  @override
  String get audioRecorderAacHeDetails =>
      'Stratna kompresja, ale lepsza jakość niż MP3 przy tym samym bitrate. Świetnie nadaje się do muzyki i wideo.';

  @override
  String get audioRecorderAacEldName =>
      'MPEG-4 AAC ELD (Advanced Audio Codec - Enhanced Low Delay)';

  @override
  String get audioRecorderAacEldInfo =>
      'Komunikacja głosowa w czasie rzeczywistym';

  @override
  String get audioRecorderAacEldDetails =>
      'Optymalizowany pod kątem bardzo niskiego opóźnienia. Mniejsza jakość niż AAC LC, ale lepsza w komunikacji na żywo.';

  @override
  String get audioRecorderAacLcName =>
      'MPEG-4 AAC LC (Advanced Audio Codec - Low Complexity)';

  @override
  String get audioRecorderAacLcInfo =>
      'Muzyka w dobrej jakości przy niskim bitrate';

  @override
  String get audioRecorderAacLcDetails =>
      'Zaprojektowany dla niskiego bitrate (np. 32-64 kbps). Używany do transmisji radiowych i strumieniowania. Wyższe opóźnienie w porównaniu do AAC LC.';

  @override
  String get audioRecorderWavName =>
      'Waveform Audio File (pcm16bit with headers)';

  @override
  String get audioRecorderWavInfo => 'Nagrywanie w wysokiej jakości';

  @override
  String get audioRecorderWavDetails =>
      'Bezstratny format audio, nie stosuje kompresji. Bardzo duże pliki, ale doskonała jakość. Idealny do profesjonalnej edycji i nagrywania.';

  @override
  String get audioRecorderFlacName => 'FLAC (Free Lossless Audio Codec)';

  @override
  String get audioRecorderFlacInfo => 'Audiofilska kolekcja muzyczna';

  @override
  String get audioRecorderFlacDetails =>
      'Bezstratny, ale z kompresją (ok. 50-70% mniejszy niż WAV). Obsługuje metadane, czego WAV nie potrafi. Świetny do archiwizacji muzyki w wysokiej jakości.';

  @override
  String recordingDurationValue(Object value) {
    return 'Długość nagrania: $value';
  }

  @override
  String get recordingSampleRate => 'Częstotliwość próbkowania';

  @override
  String recordingSampleRateValue(Object value) {
    return 'Częstotliwość próbkowania: $value';
  }

  @override
  String get recordingSampleRateTitle => 'Częstotliwość próbkowania';

  @override
  String get recordingSampleRateInfo =>
      'Częstotliwość próbkowania dźwięku w próbkach na sekundę (jeśli jest dostępne na urządzeniu).';

  @override
  String recordingSampleRateSuccess(Object value) {
    return 'Ustawiono częstotliwość próbkowania nagrywania na $value.';
  }

  @override
  String get recordingBitRate => 'Szybkość transmisji';

  @override
  String recordingBitRateValue(Object value) {
    return 'Szybkość transmisji: $value';
  }

  @override
  String get recordingBitRateTitle => 'Szybkość transmisji';

  @override
  String get recordingBitRateInfo =>
      'Szybkość kodowania dźwięku w bitach na sekundę (jeśli jest dostępne na urządzeniu).';

  @override
  String recordingBitRateSuccess(Object value) {
    return 'Ustawiono częstotliwość transmisji nagrywania na $value.';
  }

  @override
  String get recordingAudioMode => 'Tryb audio';

  @override
  String recordingAudioModeValue(Object value) {
    return 'Tryb audio: $value';
  }

  @override
  String recordingAudioModeSuccess(Object value) {
    return 'Ustawiono tryb nagrywania dźwięku na $value.';
  }

  @override
  String get recordingAudioModeOptionMono => 'mono';

  @override
  String get recordingAudioModeOptionStereo => 'stereo';

  @override
  String get recordingAutoGain => 'Automatyczne wzmocnienie';

  @override
  String recordingAutoGainValue(Object value) {
    return 'Automatyczne wzmocnienie: $value';
  }

  @override
  String get recordingAutoGainInfo =>
      'Rejestrator spróbuje automatycznie dostosować głośność nagrywania w ograniczonym zakresie (jeśli jest dostępna na urządzeniu). Głośność nagrywania może być mniejsza przy użyciu tej opcji.';

  @override
  String recordingAutoGainSuccess(Object value) {
    return 'Ustawiono automatyczne wzmocnienie na $value.';
  }

  @override
  String get recordingEchoCancel => 'Anulowanie echa';

  @override
  String recordingEchoCancelValue(Object value) {
    return 'Anulowanie echa: $value';
  }

  @override
  String get recordingEchoCancelInfo =>
      'Rejestrator spróbuje zmniejszyć echo (jeśli jest dostępne na urządzeniu). Głośność nagrywania może być mniejsza przy użyciu tej opcji.';

  @override
  String recordingEchoCancelSuccess(Object value) {
    return 'Ustawiono anulowanie echa na $value.';
  }

  @override
  String get recordingNoiseSuppress => 'Tłumienie szumów';

  @override
  String recordingNoiseSuppressValue(Object value) {
    return 'Tłumienie szumów: $value';
  }

  @override
  String get recordingNoiseSuppressInfo =>
      'Rejestrator spróbuje zniwelować szum wejściowy (jeśli jest dostępny na urządzeniu). Głośność nagrywania może być mniejsza przy użyciu tej opcji.';

  @override
  String recordingNoiseSuppressSuccess(Object value) {
    return 'Ustawiono tłumienie szumów na $value.';
  }

  @override
  String get yes => 'tak';

  @override
  String get no => 'nie';

  @override
  String get screenSettingsReset => 'Zresetuj ustawienia ekranu';

  @override
  String get screenSettingsResetTitle => 'Zresetuj ustawienia ekranu';

  @override
  String get screenSettingsResetInfo =>
      'Wszystkie ustawienia ekranu zostaną przywrócone do domyślnych. Kontynuować?';

  @override
  String get screenSettingsResetSuccess =>
      'Wszystkie ustawienia ekranu zostały przywrócone do domyślnych.';

  @override
  String get recordingSettingsReset => 'Zresetuj ustawienia nagrywania';

  @override
  String get recordingSettingsResetTitle => 'Zresetuj ustawienia nagrywania';

  @override
  String get recordingSettingsResetInfo =>
      'Wszystkie ustawienia nagrywania zostaną przywrócone do domyślnych. Kontynuować?';

  @override
  String get recordingSettingsResetSuccess =>
      'Wszystkie ustawienia nagrywania zostały przywrócone do domyślnych.';

  @override
  String get red => 'czerwony';

  @override
  String get green => 'zielony';

  @override
  String get blue => 'niebieski';

  @override
  String get yellow => 'żółty';

  @override
  String get purple => 'fioletowy';

  @override
  String get orange => 'pomarańczowy';

  @override
  String get cyan => 'cyjan';

  @override
  String get pink => 'różowy';

  @override
  String get indigo => 'indigo';

  @override
  String get brown => 'brązowy';

  @override
  String get teal => 'turkusowy';

  @override
  String get black => 'czarny';

  @override
  String get dangerZone => 'Strefa niebezpieczna';

  @override
  String get permissions => 'Uprawnienia';

  @override
  String get audioPermission => 'Odczyt pliku audio z urządzenia';

  @override
  String get microphonePermission => 'Nagrywanie dźwięku przez mikrofon';

  @override
  String get notificationPermission =>
      'Wyświetlanie powiadomienia o stanie nagrywania';

  @override
  String get permissionStatusGranted => 'Przyznane';

  @override
  String get permissionStatusDenied => 'Odmówione';

  @override
  String get permissionStatusPermanentlyDenied =>
      'Odmówione na stałe (ustawienia)';

  @override
  String get permissionStatusRestricted => 'Ograniczone';

  @override
  String get permissionStatusUndefined => 'Nieznany status';

  @override
  String get grantPermission => 'Zezwól';

  @override
  String get audioWarnings => 'Ostrzeżenia Audio';

  @override
  String audioWarningsCount(Object count) {
    return 'Ostrzeżenia ($count)';
  }

  @override
  String get audioWarningFileSize => 'Rozmiar pliku';

  @override
  String get audioWarningDuration => 'Długość nagrania';

  @override
  String get audioWarningsSampleRate => 'Częstotliwość próbkowania';

  @override
  String get audioWarningBitRate => 'Bitrate';

  @override
  String get audioWarningChannels => 'Kanały audio';

  @override
  String get audioWarningFileCorruption => 'Uszkodzenie pliku';

  @override
  String audioWarningFileSizeLarge(Object size) {
    return 'Duży plik (${size}MB)';
  }

  @override
  String audioWarningFileSizeVeryLarge(Object size) {
    return 'Bardzo duży plik (${size}MB) - może spowalniać odtwarzanie';
  }

  @override
  String audioWarningDurationLong(Object minutes) {
    return 'Długie nagranie (${minutes}min)';
  }

  @override
  String audioWarningDurationMedium(Object minutes) {
    return 'Średnie nagranie (${minutes}min)';
  }

  @override
  String audioWarningSampleRateNonStandard(Object sampleRate) {
    return 'Niestandardowa częstotliwość: ${sampleRate}Hz';
  }

  @override
  String audioWarningBitRateHigh(Object bitRate) {
    return 'Wysoki bitrate: ${bitRate}kbps';
  }

  @override
  String audioWarningBitRateLow(Object bitRate) {
    return 'Niski bitrate: ${bitRate}kbps';
  }

  @override
  String get audioWarningChannelsMicrophone => 'Nagrywanie mikrofonem';

  @override
  String get audioWarningFileNotExists => 'Plik nie istnieje';

  @override
  String get audioWarningSuggestionCompress =>
      'Rozważ kompresję lub podział na mniejsze części';

  @override
  String get audioWarningSuggestionPerformance => 'Może wpływać na wydajność';

  @override
  String get audioWarningSuggestionInterfaceDelays =>
      'Może powodować opóźnienia w interfejsie';

  @override
  String get audioWarningSuggestionMultiTrackPerformance =>
      'Uwaga na wydajność przy wielu ścieżkach';

  @override
  String get audioWarningSuggestionCompatibility =>
      'Może powodować problemy z kompatybilnością';

  @override
  String get audioWarningSuggestionFileSize => 'Może wpływać na rozmiar pliku';

  @override
  String get audioWarningSuggestionAudioQuality =>
      'Może wpływać na jakość dźwięku';

  @override
  String get audioWarningSuggestionChannelSettings =>
      'Sprawdź ustawienia kanałów audio';

  @override
  String get audioWarningSuggestionCheckFile =>
      'Sprawdź czy plik nie został przeniesiony lub usunięty';
}
