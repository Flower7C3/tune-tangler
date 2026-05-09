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
    return 'Odtwarzaj ścieżki w wierszu $rowName';
  }

  @override
  String rowTracksPlayingStop(Object rowName) {
    return 'Zatrzymaj ścieżki w wierszu $rowName';
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
    return 'Zaimportowano plik do ścieżki $trackName.';
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
      'Brak uprawnień do powiadamiania o nagrywaniu.';

  @override
  String trackRecordingStartError(Object error, Object trackName) {
    return 'Wystąpił błąd podczas rozpoczynania nagrywania ścieżki $trackName\n$error';
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
    return 'Wystąpił błąd podczas nagrywania ścieżki $trackName\n$error';
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
      'Zmień początek odtwarzania ścieżki o -0.01 s';

  @override
  String get trackPlaybackStartAtPositionSub100 =>
      'Zmień początek odtwarzania ścieżki o -0,1 s';

  @override
  String get trackPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania ścieżki';

  @override
  String get trackPlaybackStartAtPositionAdd100 =>
      'Zmień początek odtwarzania ścieżki o +0,1 s';

  @override
  String get trackPlaybackStartAtPositionAdd10 =>
      'Zmień początek odtwarzania ścieżki o +0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub10 =>
      'Zmień koniec odtwarzania ścieżki o -0.01 s';

  @override
  String get trackPlaybackEndAtPositionSub100 =>
      'Zmień koniec odtwarzania ścieżki o -0,1 s';

  @override
  String get trackPlaybackEndAtPositionReset =>
      'Resetuj koniec odtwarzania ścieżki';

  @override
  String get trackPlaybackEndAtPositionAdd100 =>
      'Zmień koniec odtwarzania ścieżki o +0,1 s';

  @override
  String get trackPlaybackEndAtPositionAdd10 =>
      'Zmień koniec odtwarzania ścieżki o +0.01 s';

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
    return 'Wybierz klawisz, który ma zostać ustawiony jako nowy skrót klawiaturowy dla ścieżki $trackName.';
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
    Object firstTrackName,
    Object secondTrackName,
  ) {
    return 'Zamieniono lokalizację dla nagrań #$firstTrackName i #$secondTrackName.';
  }

  @override
  String get trackRecordingMoveInProgress =>
      'Przenoszenie nagrania już trwa. Spróbuj ponownie za chwilę.';

  @override
  String get trackRecordingMoveNotAllowed =>
      'Nie można przenosić ścieżek podczas nagrywania, odtwarzania ani przetwarzania.';

  @override
  String get trackRecordingMoveFailed =>
      'Nie udało się przenieść nagrań. Sprawdź, czy pliki nie zostały przeniesione lub usunięte i spróbuj ponownie.';

  @override
  String trackRecordingShare(Object trackName) {
    return 'Udostępnij ścieżkę $trackName';
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
  String trackRecordingShareRaw(Object trackTime) {
    return 'Surowe nagranie ($trackTime)';
  }

  @override
  String trackRecordingShareProcessed(Object trackTime) {
    return 'Zmodyfikowane nagranie ($trackTime)';
  }

  @override
  String trackRecordingShareSuccess(Object trackName) {
    return 'Wyeksportowano nagranie ścieżki $trackName.';
  }

  @override
  String trackRecordingShareFailed(Object trackName) {
    return 'Nie udało się wyeksportować nagrania ścieżki $trackName.';
  }

  @override
  String get trackRecordingShareProcessedAndroidOnly =>
      'Udostępnianie z przycięciem, głośnością, balansem i prędkością jest dostępne tylko na Androidzie. Nadal możesz udostępnić surowe nagranie.';

  @override
  String get trackRecordingSharePreparingModified =>
      'Przygotowywanie zmodyfikowanego nagrania…';

  @override
  String get trackRecordingShareExportCancelled => 'Anulowano eksport.';

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
    return 'Ustawiono tryb odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackSpeedSet => 'Prędkość odtwarzania';

  @override
  String rowTracksPlaybackSpeedTitleSet(Object value) {
    return 'Ustaw prędkość odtwarzania na $value';
  }

  @override
  String rowTracksPlaybackSpeedSuccessSet(Object rowName, Object value) {
    return 'Ustawiono prędkość odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackVolumeSet => 'Głośność odtwarzania';

  @override
  String rowTracksPlaybackVolumeTitleSet(Object value) {
    return 'Ustaw głośność na $value';
  }

  @override
  String rowTracksPlaybackVolumeSuccessSet(Object rowName, Object value) {
    return 'Ustawiono głośność dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackBalanceSet => 'Balans odtwarzania';

  @override
  String rowTracksPlaybackBalanceTitleSet(Object value) {
    return 'Ustaw balans odtwarzania na $value';
  }

  @override
  String rowTracksPlaybackBalanceSuccessSet(Object rowName, Object value) {
    return 'Ustawiono balans odtwarzania dla ścieżek w wierszu $rowName na $value.';
  }

  @override
  String get rowTracksPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania';

  @override
  String get rowTracksPlaybackStartAtPositionResetTitle =>
      'Zresetuj początek odtwarzania utworów wiersza';

  @override
  String rowTracksPlaybackStartAtPositionResetInfo(Object rowName) {
    return 'Wszystkie utwory w wierszu $rowName będą miały domyślny początek odtwarzania. Kontynuować?';
  }

  @override
  String rowTracksPlaybackStartAtPositionResetSuccess(Object rowName) {
    return 'Zresetowano początek odtwarzania utworów wiersza na w wierszu $rowName.';
  }

  @override
  String get rowTracksPlaybackEndAtPositionReset =>
      'Zresetuj koniec odtwarzania';

  @override
  String get rowTracksPlaybackEndAtPositionResetTitle =>
      'Zresetuj koniec odtwarzania utworów wiersza';

  @override
  String rowTracksPlaybackEndAtPositionResetInfo(Object rowName) {
    return 'Wszystkie utwory w wierszu $rowName będą miały domyślny koniec odtwarzania. Kontynuować?';
  }

  @override
  String rowTracksPlaybackEndAtPositionResetSuccess(Object rowName) {
    return 'Zresetowano wszystkie zakończenia odtwarzania utworów w wierszu $rowName.';
  }

  @override
  String get rowTracksRecordingsDelete => 'Usuń nagrania';

  @override
  String get rowTracksRecordingsDeleteTitle => 'Usuń nagrania wiersza';

  @override
  String rowTracksRecordingsDeleteInfo(Object rowName) {
    return 'Wszystkie nagrania ścieżek w wierszu $rowName zostaną usunięte. Kontynuować?';
  }

  @override
  String rowTracksRecordingsDeleteSuccess(Object rowName) {
    return 'Usunięto nagrania ścieżek w wierszu $rowName.';
  }

  @override
  String get balanceLeft100 => 'lewa 100%, prawa 0%';

  @override
  String get balanceLeft75 => 'lewa 100%, prawa 25%';

  @override
  String get balanceLeft50 => 'lewa 100%, prawa 50%';

  @override
  String get balanceLeft25 => 'lewa 100%, prawa 75%';

  @override
  String get balanceLeft => 'lewa 100%';

  @override
  String get balanceCenter => 'centralnie';

  @override
  String get balanceRight => 'prawa 100%';

  @override
  String get balanceRight25 => 'lewa 75%, prawa 100%';

  @override
  String get balanceRight50 => 'lewa 50%, prawa 100%';

  @override
  String get balanceRight75 => 'lewa 25%, prawa 100%';

  @override
  String get balanceRight100 => 'lewa 0%, prawa 100%';

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
  String get settingsProfile => 'Profil ustawień';

  @override
  String get settingsProfiles => 'Profile ustawień';

  @override
  String get settingsProfilesListTitle => 'Profile ustawień';

  @override
  String get settingsProfilesEmpty => 'Brak zapisanych profili ustawień.';

  @override
  String get settingsProfileDelete => 'Usuń';

  @override
  String get settingsProfileDeleteTitle => 'Usuń profil ustawień';

  @override
  String get settingsProfileDeleteInfo =>
      'Profil ustawień zostanie usunięty. Kontynuować?';

  @override
  String get settingsProfileDeleted => 'Profil ustawień został usunięty.';

  @override
  String get settingsProfileCreate => 'Utwórz';

  @override
  String get settingsProfileCreated => 'Profil ustawień został utworzony.';

  @override
  String get settingsProfileSaveSuccess => 'Profil ustawień został zapisany.';

  @override
  String get settingsProfileLoad => 'Wczytaj';

  @override
  String get settingsProfileLoaded => 'Profil ustawień został załadowany.';

  @override
  String get helpScreenMessageSettingsProfilesTitle => 'Profile ustawień';

  @override
  String get helpScreenMessageSettingsProfilesContent =>
      '\$[settingsProfiles]Możesz zapisać kilka profili. Każdy profil to pełny zestaw ustawień aplikacji — np. jeden do cichego pokoju, drugi na głośną próbę — i możesz szybko przełączać się między profilami.\n\nW profilu znajdziesz:\n• Ustawienia nagrywania (\$[recordingInputDevice]skąd jest pobierany dźwięk, \$[recordingAudioEncoder]format pliku, \$[recordingSampleRate]dokładność w czasie, \$[recordingBitRate]bitrate, \$[recordingAudioMode]mono lub stereo, \$[recordingAutoGain]automatyczny poziom głośności, \$[recordingEchoCancel]mniej echa z pomieszczenia, \$[recordingNoiseSuppress]ciszej w tle)\n• Ustawienia ekranu (\$[language]język, \$[screenThemeMode]jasny lub ciemny motyw, \$[screenThemeColor]kolor akcentu, \$[keepScreenOn]podtrzymywanie włączonego ekranu)\n\nNowy profil: przycisk \$[create]„Utwórz” w oknie profili. Wczytanie: stuknij profil na liście. Usunięcie: \$[touchLong]przytrzymaj profil i wybierz \$[deleteForever]usuń.';

  @override
  String get projectExportInfo =>
      'Eksport projektu zapisuje wszystkie nagrania i ich parametry do pliku ZIP, który można później wczytać. Nazwa projektu jest opcjonalna i zostanie dodana do nazwy pliku.';

  @override
  String get settingsProfilesInfo =>
      'Zapisuj i przywracaj konfigurację aplikacji. Stuknij, aby wczytać profil, lub przytrzymaj, aby zobaczyć szczegóły.';

  @override
  String get moreSettings => 'Więcej ustawień...';

  @override
  String get help => 'Pomoc';

  @override
  String get helpScreenMessageAboutTitle => 'O aplikacji';

  @override
  String get helpScreenMessageAboutContent =>
      'Prosta siatka na muzyczne pomysły. Nagrasz wbudowanym mikrofonem albo urządzeniem audio podłączonym przez USB. Możesz też wczytać plik z urządzenia.\n\nOdtwarzaj ścieżki naraz, żeby szły w jednym tempie, albo niezależnie od siebie. Ustaw zapętlanie albo jednorazowe odtwarzanie — jak potrzebujesz.\n\nNie martw się: wszystkie Twoje nagrania i ustawienia są zachowane po zamknięciu aplikacji. W razie potrzeby możesz je udostępnić albo zapisać cały projekt w pliku ZIP.';

  @override
  String get helpScreenMessageGridScreenTitle => 'Ekran siatki ścieżek';

  @override
  String get helpScreenMessageGridScreenContent =>
      'Kolorowy blok to szybki przycisk. Stuknij go lub – używając podłączonej klawiatury – wciśnij odpowiedni klawisz skrótu. Chcesz suwaków i bardziej szczegółowych opcji? Przytrzymaj blok albo — przy podłączonej klawiaturze zewnętrznej — naciśnij skrót razem z klawiszem Control \$[controlKey], aby otworzyć szczegóły ścieżki. Skrót do ścieżki ustawisz w jej szczegółach.\n\nPrzy każdym wierszu siatki są przyciski startu i zatrzymania odtwarzania dla tego wiersza oraz menu „⋮” z opcjami dla wszystkich ścieżek w tym wierszu (m.in. tryb odtwarzania, głośność, balans, prędkość, reset przycięć, usunięcie nagrań z wiersza).\n\nW menu bocznym wybierzesz gotowy zestaw skrótów na klawiaturę: standard (jak klawiatura PC, elastyczna siatka) albo 24 klawisze (6×4).';

  @override
  String get helpScreenMessageDetailsScreenTitle => 'Ekran szczegółów ścieżki';

  @override
  String get helpScreenMessageDetailsScreenContent =>
      'Tu ustawiasz, jak ścieżka ma grać. Ikony przy opcjach pokazują, co edytujesz:\n• \$[recordingClip]przycinanie początku i końca nagrania\n• \$[trackPlaybackMode]odtwarzanie w pętli albo jedno przejście\n• \$[trackPlaybackVolume]głośność\n• \$[trackPlaybackBalance]balans lewo/prawo\n• \$[trackPlaybackSpeed]prędkość odtwarzania\n• \$[trackName]własna nazwa\n• \$[trackKeyboardKey]skrót z klawiatury\n\nMożesz też \$[trackRecordingMove]przenieść ścieżkę po siatce, \$[trackRecordingImport]wgrać plik, \$[trackRecordingShare]podzielić się nagraniem lub \$[deleteForever]je usunąć.';

  @override
  String get helpScreenMessageTrackStates =>
      'Stany ścieżki i co robi stuknięcie';

  @override
  String get helpScreenMessageTrackStatesInfo =>
      'Ścieżka jest zawsze w jednym z kilku prostych stanów. Jedno stuknięcie wykonuje kolejny krok odpowiedni do tego, w jakim stanie jest teraz ścieżka.';

  @override
  String get helpScreenMessageTrackIcons => 'Ikony na bloku ścieżki';

  @override
  String get helpScreenMessageTrackIconsInfo =>
      'Ikony na bloku pokazują skrócone informacje: skróty, skąd pochodzi dźwięk, głośność, balans, przycięcia oraz czy włączona jest pętla.';

  @override
  String get helpTrackIconBalanceLeftLegend =>
      'Balans przesunięty w lewo — dokładną wartość zobaczysz w szczegółach ścieżki.';

  @override
  String get helpTrackIconBalanceCenterLegend =>
      'Balans na środku: lewy i prawy kanał grają tak samo głośno.';

  @override
  String get helpTrackIconBalanceRightLegend =>
      'Balans przesunięty w prawo — dokładną wartość zobaczysz w szczegółach ścieżki.';

  @override
  String get helpTrackIconPlaybackStartTrimLegend =>
      'Początek nagrania jest przycięty — czas przycięcia zobaczysz w szczegółach ścieżki.';

  @override
  String get helpTrackIconPlaybackEndTrimLegend =>
      'Koniec nagrania jest przycięty — czas przycięcia zobaczysz w szczegółach ścieżki.';

  @override
  String get helpTrackIconSinglePlaybackModeLegend =>
      'Odtwarzanie: jeden przebieg od początku do końca, potem stop.';

  @override
  String get helpTrackIconRepeatPlaybackModeLegend =>
      'Odtwarzanie w pętli: po dojściu do końca wraca na początek i gra dalej.';

  @override
  String get helpScreenMessageSettingsInfo =>
      'Dopasuj nagrywanie do telefonu i otoczenia: \$[recordingAudioEncoder]format pliku, \$[recordingSampleRate]dokładność w czasie, \$[recordingBitRate]przepływność bitowa (bitrate), \$[recordingAudioMode]stereo czy mono, a także — gdy sprzęt pozwala — \$[recordingAutoGain]automatyczna regulacja poziomu (AGC), \$[recordingEchoCancel]mniej echa z pomieszczenia i \$[recordingNoiseSuppress]ciszej w tle.';

  @override
  String get helpScreenMessageProjectExportImportTitle =>
      'Eksport i import projektu';

  @override
  String get helpScreenMessageProjectExportImportContent =>
      'Możesz \$[projectExport]spakować całą sesję do jednego pliku ZIP — siatkę, ustawienia ścieżek i nagrania. Później \$[projectImport]wczytasz go i wrócisz dokładnie tam, gdzie skończyłeś.\n\nW archiwum ZIP jest m.in.:\n• rozmiar siatki (wiersze i kolumny),\n• nazwy, przycięcia, wybory odtwarzania i skróty dla każdej ścieżki,\n• pliki audio z krótką kontrolą spójności,\n• metadane projektu (wersja, czas eksportu, rozmiar siatki i statystyki nagrań).\n\nZanim cokolwiek zostanie nadpisane, zobaczysz podgląd i ostrzeżenie. Aplikacja najpierw sprawdza plik, żeby nie wczytać uszkodzonego lub niekompletnego pliku.';

  @override
  String get stateEmpty => 'puste miejsce — stuknij, żeby zacząć nagrywać';

  @override
  String get stateRecording =>
      'nagrywam… stuknij, żeby zakończyć i zapisać nagranie';

  @override
  String get stateProcessing => 'dopinam szczegóły pliku';

  @override
  String get stateIdle => 'gotowe do grania — stuknij, żeby odtwarzać';

  @override
  String get statePlaying => 'leci — stuknij, żeby zatrzymać';

  @override
  String get statePaused => 'pauza — stuknij, żeby iść dalej';

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
  String get screenSystemThemeColor => 'wg urządzenia';

  @override
  String get screenThemeColor => 'Kolor akcentu';

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
  String get keyboardLayoutPreset => 'Układ klawiatury';

  @override
  String get keyboardLayoutPresetInfo =>
      'Układ standardowy wykorzystuje pełną mapę klawiatury PC. Układ 24 klawiszy odpowiada stałemu blokowi 6×4 i blokuje rozmiar siatki ścieżek.';

  @override
  String get keyboardLayoutQwertyName => 'Standard (QWERTY)';

  @override
  String get keyboardLayoutGrid24Name => '24 klawisze (blok 6×4)';

  @override
  String keyboardLayoutPresetSuccess(Object layout) {
    return 'Układ klawiatury: $layout.';
  }

  @override
  String keyboardLayoutPresetSuccessWithReset(Object layout) {
    return 'Układ klawiatury: $layout. Skróty zostały zresetowane do domyślnych.';
  }

  @override
  String get keyboardLayoutChangeTitle => 'Potwierdź zmianę układu klawiatury';

  @override
  String keyboardLayoutChangeIntro(Object fromLayout, Object toLayout) {
    return 'Przechodzisz z układu „$fromLayout” na „$toLayout”.';
  }

  @override
  String get keyboardLayoutChangeDetailGrid24 =>
      'Układ 24 klawiszy odpowiada stałemu blokowi 6×4. Siatka ścieżek będzie zawsze miała 6 wierszy i 4 kolumny. Skróty ustawione pod pełną klawiaturę mogą nie mieć odpowiednika na tym bloku — ich zachowanie może sprawić, że części ścieżek nie da się już wygodnie wyzwolić z urządzenia.';

  @override
  String get keyboardLayoutChangeDetailQwerty =>
      'Układ standardowy wykorzystuje pełną mapę klawiatury PC (cyfry, rzędy liter, znaki z Shift). Znowu możesz zmieniać rozmiar siatki w ustawieniach ścieżek. Skróty z bloku 24 klawiszy nadal działają, jeśli te same klawisze są na klawiaturze komputera.';

  @override
  String get keyboardLayoutChangeDecision =>
      'Zresetować skróty wszystkich ścieżek do domyślnych dla nowego układu, czy zachować obecne przypisania — wtedy część skrótów może nie odpowiadać nowej mapie.';

  @override
  String get keyboardLayoutChangeKeepShortcuts =>
      'Zmień układ, zachowaj skróty';

  @override
  String get keyboardLayoutChangeResetShortcuts => 'Zmień i zresetuj skróty';

  @override
  String get keyboardLayoutGridLockedTitle => 'Rozmiar siatki (stały)';

  @override
  String get keyboardLayoutGridLockedSubtitle =>
      'Ten układ zawsze używa 6 wierszy i 4 kolumn.';

  @override
  String get tracksSettings => 'Ustawienia ścieżek';

  @override
  String get trackSettings => 'Ustawienia ścieżki';

  @override
  String get tracks => 'Ścieżki';

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
  String get singlePlaybackMode => 'pojedynczo';

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
  String get allTracksPlaybackSpeedSet => 'Ustaw prędkość odtwarzania';

  @override
  String get allTracksPlaybackSpeedTitleSet =>
      'Ustaw prędkość odtwarzania ścieżek';

  @override
  String get allTracksPlaybackSpeedInfoSet =>
      'Wybierz prędkość, na którą będą ustawione wszystkie ścieżki.';

  @override
  String allTracksPlaybackSpeedSuccessSet(Object value) {
    return 'Prędkość ścieżek została ustawiona na $value.';
  }

  @override
  String get allTracksPlaybackStartAtPositionReset =>
      'Zresetuj początek odtwarzania';

  @override
  String get allTracksPlaybackStartAtPositionResetTitle =>
      'Zresetuj początek odtwarzania wszystkich ścieżek';

  @override
  String get allTracksPlaybackStartAtPositionResetInfo =>
      'Wszystkie ścieżki będą miały domyślny początek odtwarzania. Kontynuować?';

  @override
  String get allTracksPlaybackStartAtPositionResetSuccess =>
      'Zresetowano początek odtwarzania wszystkich ścieżek.';

  @override
  String get allTracksPlaybackEndAtPositionReset =>
      'Zresetuj koniec odtwarzania';

  @override
  String get allTracksPlaybackEndAtPositionResetTitle =>
      'Zresetuj koniec odtwarzania wszystkich ścieżek';

  @override
  String get allTracksPlaybackEndAtPositionResetInfo =>
      'Wszystkie ścieżki będą miały domyślny koniec odtwarzania. Kontynuować?';

  @override
  String get allTracksPlaybackEndAtPositionResetSuccess =>
      'Zresetowano koniec odtwarzania wszystkich ścieżek.';

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
      'Wybierz urządzenie wejściowe do nagrywania dźwięku.';

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
      'Radio internetowe i strumieniowanie przy niskim bitrate';

  @override
  String get audioRecorderAacHeDetails =>
      'Stratna kompresja, ale lepsza jakość niż MP3 przy tym samym bitrate. Świetnie nadaje się do muzyki i wideo.';

  @override
  String get audioRecorderAacEldName =>
      'MPEG-4 AAC ELD (Advanced Audio Codec - Enhanced Low Delay)';

  @override
  String get audioRecorderAacEldInfo =>
      'Komunikacja głosowa w czasie rzeczywistym';

  @override
  String get audioRecorderAacEldDetails =>
      'Optymalizowany pod kątem bardzo niskiego opóźnienia. Mniejsza jakość niż AAC LC, ale lepsza w komunikacji na żywo.';

  @override
  String get audioRecorderAacLcName =>
      'MPEG-4 AAC LC (Advanced Audio Codec - Low Complexity)';

  @override
  String get audioRecorderAacLcInfo =>
      'Muzyka w dobrej jakości przy niskim bitrate';

  @override
  String get audioRecorderAacLcDetails =>
      'Zaprojektowany dla niskiego bitrate (np. 32-64 kbps). Używany do transmisji radiowych i strumieniowania. Wyższe opóźnienie w porównaniu do AAC LC.';

  @override
  String get audioRecorderWavName =>
      'Waveform Audio File (pcm16bit with headers)';

  @override
  String get audioRecorderWavInfo => 'Nagrywanie w wysokiej jakości';

  @override
  String get audioRecorderWavDetails =>
      'Bezstratny format audio, nie stosuje kompresji. Bardzo duże pliki, ale doskonała jakość. Idealny do profesjonalnej edycji i nagrywania.';

  @override
  String get audioRecorderFlacName => 'FLAC (Free Lossless Audio Codec)';

  @override
  String get audioRecorderFlacInfo => 'Audiofilska kolekcja muzyczna';

  @override
  String get audioRecorderFlacDetails =>
      'Bezstratny, ale z kompresją (ok. 50-70% mniejszy niż WAV). Obsługuje metadane, czego WAV nie potrafi. Świetny do archiwizacji muzyki w wysokiej jakości.';

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
      'Częstotliwość próbkowania dźwięku w próbkach na sekundę (jeśli jest dostępne na urządzeniu).';

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
      'Szybkość kodowania dźwięku w bitach na sekundę (jeśli jest dostępne na urządzeniu).';

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
      'Rejestrator spróbuje automatycznie dostosować głośność nagrywania w ograniczonym zakresie (jeśli jest dostępna na urządzeniu). Głośność nagrywania może być mniejsza przy użyciu tej opcji.';

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
  String get audioPermission => 'Odczyt pliku audio z urządzenia';

  @override
  String get microphonePermission => 'Nagrywanie dźwięku przez mikrofon';

  @override
  String get notificationPermission =>
      'Wyświetlanie powiadomienia o stanie nagrywania';

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
    return 'Duży plik ($size MB)';
  }

  @override
  String audioWarningFileSizeVeryLarge(Object size) {
    return 'Bardzo duży plik ($size MB) - może spowalniać odtwarzanie';
  }

  @override
  String audioWarningDurationLong(Object minutes) {
    return 'Długie nagranie ($minutes min)';
  }

  @override
  String audioWarningDurationMedium(Object minutes) {
    return 'Średnie nagranie ($minutes min)';
  }

  @override
  String audioWarningSampleRateNonStandard(Object sampleRate) {
    return 'Niestandardowa częstotliwość: $sampleRate Hz';
  }

  @override
  String audioWarningBitRateHigh(Object bitRate) {
    return 'Wysoki bitrate: $bitRate kbps';
  }

  @override
  String audioWarningBitRateLow(Object bitRate) {
    return 'Niski bitrate: $bitRate kbps';
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
      'Może powodować opóźnienia w interfejsie';

  @override
  String get audioWarningSuggestionMultiTrackPerformance =>
      'Uwaga na wydajność przy wielu ścieżkach';

  @override
  String get audioWarningSuggestionCompatibility =>
      'Może powodować problemy z kompatybilnością';

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

  @override
  String get projectExport => 'Zapisz projekt';

  @override
  String get projectImport => 'Wczytaj projekt';

  @override
  String get projectExportName => 'Nazwa projektu (opcjonalnie)';

  @override
  String get projectExportNameHint => 'Wprowadź nazwę projektu';

  @override
  String get projectExportSuccess => 'Projekt został zapisany';

  @override
  String get projectImportSuccess => 'Projekt został wczytany';

  @override
  String get projectImportWarning =>
      'Wczytanie projektu nadpisze bieżącą sesję. Wszystkie nagrania zostaną usunięte, a ustawienia ścieżek zostaną nadpisane. Kontynuować?';

  @override
  String get projectImportWarningTitle => 'Ostrzeżenie';

  @override
  String get projectPreview => 'Podgląd projektu';

  @override
  String get projectMetadata => 'Metadane projektu';

  @override
  String get projectName => 'Nazwa projektu';

  @override
  String get projectVersion => 'Wersja';

  @override
  String get projectExportDate => 'Data eksportu';

  @override
  String get projectGridSize => 'Rozmiar siatki';

  @override
  String get projectTotalTracks => 'Wszystkie ścieżki';

  @override
  String get projectTracksWithRecordings => 'Ścieżki z nagraniami';

  @override
  String get projectTotalRecordingsSize => 'Rozmiar nagrań';

  @override
  String get projectExporting => 'Eksportowanie projektu...';

  @override
  String get projectImporting => 'Wczytywanie projektu...';

  @override
  String get projectExportError => 'Błąd podczas eksportu projektu';

  @override
  String get projectImportError => 'Błąd podczas wczytywania projektu';

  @override
  String get projectInvalidFormat => 'Nieprawidłowy format pliku projektu';

  @override
  String get projectFileNotFound => 'Plik projektu nie został znaleziony';

  @override
  String projectFileMissing(Object fileName) {
    return 'Brakuje wymaganego pliku: $fileName';
  }

  @override
  String projectFileParseError(Object fileName) {
    return 'Błąd parsowania pliku $fileName. Plik jest uszkodzony lub ma nieprawidłowy format.';
  }

  @override
  String projectFileEncodingError(Object fileName) {
    return 'Błąd kodowania w pliku $fileName. Plik może być uszkodzony lub został utworzony w innej wersji aplikacji.';
  }

  @override
  String projectFileStructureError(Object fieldName, Object fileName) {
    return 'Nieprawidłowa struktura w pliku $fileName. Brakuje wymaganego pola: $fieldName';
  }

  @override
  String projectFileInvalidValue(Object details, Object fileName) {
    return 'Nieprawidłowa wartość w pliku $fileName: $details';
  }

  @override
  String get projectRecordingNotFound =>
      'Nagranie wymienione w projekcie nie zostało znalezione w archiwum';

  @override
  String get projectMetadataCorrupted =>
      'Plik projektu jest uszkodzony. Plik metadata.json nie może zostać odczytany.';

  @override
  String get projectMetadataEncodingError =>
      'Plik projektu ma nieprawidłowe kodowanie. Plik może być uszkodzony lub został utworzony w innej wersji aplikacji.';

  @override
  String get projectMetadataParseError =>
      'Nie można odczytać danych projektu. Plik metadata.json jest uszkodzony lub ma nieprawidłowy format.';

  @override
  String projectChecksumMismatch(Object fileName) {
    return 'Suma kontrolna pliku $fileName się nie zgadza';
  }

  @override
  String get projectChecksumMismatchTitle => 'Błąd weryfikacji';

  @override
  String projectDurationMismatch(Object fileName) {
    return 'Długość pliku $fileName się nie zgadza. Pozycje odtwarzania zostały zresetowane';
  }

  @override
  String get projectDurationMismatchTitle => 'Ostrzeżenie długości pliku';

  @override
  String get projectExportCancel => 'Anulowano eksport projektu';

  @override
  String get projectImportCancel => 'Anulowano wczytywanie projektu';

  @override
  String get buttonExport => 'Eksportuj';

  @override
  String get buttonImport => 'Wczytaj';

  @override
  String get buttonConfirm => 'Potwierdź';

  @override
  String get buttonYesImport => 'Tak, importuj';

  @override
  String get projectValidating => 'Walidacja projektu...';

  @override
  String get projectValidationFailed => 'Walidacja projektu nie powiodła się';
}
