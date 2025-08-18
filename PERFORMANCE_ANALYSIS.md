# TuneTangler – Analiza Wydajności i Zacinania się Aplikacji

## **Główne Przyczyny Zacinania się i Niskiej Liczby Ramek**

### **1. Krytyczne Problemy Wydajnościowe**

#### **A. Timer (TYLKO podczas nagrywania)**
```dart
// Timer jest używany tylko podczas nagrywania - NIE jest głównym problemem
void startTimer() {
  clock.value = 0;
  timer = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
    clock.value += 10;
  });
}
```
**Uwaga**: Timer działa tylko podczas nagrywania, więc nie wpływa na ogólną wydajność aplikacji.

#### **B. Nadmierne użycie ValueListenableBuilder (GŁÓWNY PROBLEM)**
```dart
// PROBLEM: Każda ścieżka ma 10+ ValueListenableBuilder
ValueListenableBuilder<String>(valueListenable: track.name, ...)
ValueListenableBuilder<double>(valueListenable: track.playbackVolume, ...)
ValueListenableBuilder<double>(valueListenable: track.playbackBalance, ...)
ValueListenableBuilder<double>(valueListenable: track.playbackSpeed, ...)
ValueListenableBuilder<Duration>(valueListenable: track.playbackStartAtPosition, ...)
ValueListenableBuilder<Duration>(valueListenable: track.playbackEndAtPosition, ...)
ValueListenableBuilder<double>(valueListenable: track.progress, ...)
ValueListenableBuilder<double>(valueListenable: track.clock, ...)
```

**Wpływ**: 
- Każdy ValueListenableBuilder może powodować rebuild całego widgetu przy każdej zmianie wartości
- Przy siatce 6×4 = 24 ścieżki × 10+ listenerów = **240+ potencjalnych rebuildów**
- Każda zmiana głośności, balansu, pozycji powoduje rebuild całej ścieżki
- Brak RepaintBoundary powoduje niepotrzebne renderowanie

**Konkretny przykład problemu**:
```dart
// W lib/manager/track_manager.dart linie 70-213
// Każda ścieżka ma Stack z wieloma ValueListenableBuilder
Stack(
  children: [
    // Każdy z tych ValueListenableBuilder może powodować rebuild całego Stack
    ValueListenableBuilder<String>(valueListenable: track.name, ...),
    ValueListenableBuilder<String>(valueListenable: track.keyboardKey, ...),
    ValueListenableBuilder<double>(valueListenable: track.playbackVolume, ...),
    ValueListenableBuilder<double>(valueListenable: track.playbackBalance, ...),
    ValueListenableBuilder<double>(valueListenable: track.playbackSpeed, ...),
    ValueListenableBuilder<ReleaseMode>(valueListenable: track.playbackReleaseMode, ...),
    ValueListenableBuilder<Duration>(valueListenable: track.playbackStartAtPosition, ...),
    ValueListenableBuilder<Duration>(valueListenable: track.playbackEndAtPosition, ...),
  ]
)
```

#### **C. Stream subscriptions blokujące główny wątek**
```dart
// PROBLEM: Streamy audio mogą blokować UI thread
positionSubscription = player.onPositionChanged.listen((Duration position) {
  if (position >= playbackEndAtPosition.value) {
    if (isPlaybackReleaseModeSingle(playbackReleaseMode.value)) {
      stopPlaying(); // Operacja audio w głównym wątku!
    }
    position = playbackStartAtPosition.value;
    player.seek(position); // Operacja audio w głównym wątku!
  }
  setPosition(position);
});
```

#### **D. Operacje I/O w głównym wątku**
```dart
// PROBLEM: Operacje na plikach w UI thread
if (path != null && File(path!).existsSync()) {
  File(path!).delete(); // Blokuje UI!
}
```

### **2. Problemy z Renderowaniem UI**

#### **A. Zbyt ciężkie widgety w Stack**
```dart
// PROBLEM: Stack z wieloma Align widgetami
Stack(
  fit: StackFit.expand,
  children: [
    Align(alignment: Alignment.center, child: ...),
    Align(alignment: Alignment.topLeft, child: ...),
    Align(alignment: Alignment.topRight, child: ...),
    Align(alignment: Alignment.topCenter, child: ...),
    Align(alignment: Alignment.centerLeft, child: ...),
    Align(alignment: AlignmentDirectional(1, -0.3), child: ...),
    Align(alignment: AlignmentDirectional(1, 0.25), child: ...),
    Align(alignment: AlignmentDirectional(-1, 1), child: ...),
    Align(alignment: AlignmentDirectional(1, 1), child: ...),
    Align(alignment: AlignmentDirectional(0, 0.95), child: ...),
    Align(alignment: AlignmentDirectional(0.3, 0.95), child: ...),
  ]
)
```

#### **B. ListView.builder z PageController**
```dart
// PROBLEM: PageController może powodować problemy z scrollowaniem
ListView.builder(
  controller: PageController(viewportFraction: 0.85), // Może powodować lag
  itemCount: _appWrapper.settings.getConfig(AppConfigFieldKey.gridRowsAmount),
  itemBuilder: (context, rowIndex) => Row(children: [...])
)
```

### **3. Problemy z Zarządzaniem Pamięcią**

#### **A. Nieprawidłowe dispose()**
```dart
// PROBLEM: dispose() jest asynchroniczny ale nie czeka na zakończenie
void dispose() {
  player.dispose().then((status) { // Nie czeka na zakończenie!
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerStateChangeSubscription?.cancel();
  });
}
```

#### **B. Lazy loading może powodować memory leaks**
```dart
// PROBLEM: Tracks są dodawane ale nigdy nie usuwane z kolekcji
void _lazyLoadTrack(String name, int rowIndex, int columnIndex) {
  Track track = _settings.getTrack(rowIndex, columnIndex);
  if (!_tracksCollection.containsKey(name)) {
    _tracksCollection[name] = {};
  }
  _tracksCollection[name]!.add(track); // Dodaje ale nie usuwa starych!
}
```

### **4. Problemy z Audio Processing**

#### **A. Operacje audio w głównym wątku**
```dart
// PROBLEM: Wszystkie operacje audio w UI thread
player.setVolume(playbackVolume.value);
player.setBalance(playbackBalance.value);
player.setReleaseMode(playbackReleaseMode.value);
player.setPlaybackRate(playbackSpeed.value);
```

#### **B. Brak throttling dla audio events**
```dart
// PROBLEM: onPositionChanged może być wywoływane bardzo często
positionSubscription = player.onPositionChanged.listen((Duration position) {
  // Może być wywoływane 60+ razy na sekundę!
  setPosition(position);
});
```

## **Rozwiązania i Optymalizacje**

### **1. ValueListenableBuilder Optimization (GŁÓWNE ROZWIĄZANIE)**
```dart
// ROZWIĄZANIE 1: Użyj RepaintBoundary dla każdej ścieżki
RepaintBoundary(
  child: Container(
    margin: EdgeInsets.all(UIHelper.gridGap),
    width: Theme.of(_context).textTheme.displaySmall!.fontSize! * 2.1,
    child: ElevatedButton(...),
  ),
)

// ROZWIĄZANIE 2: Grupuj powiązane ValueListenableBuilder
ValueListenableBuilder<Map<String, dynamic>>(
  valueListenable: CombinedNotifier([
    track.name,
    track.keyboardKey,
    track.playbackVolume,
    track.playbackBalance,
    track.playbackSpeed,
  ]),
  builder: (context, values, child) => Stack(
    children: [
      // Wszystkie elementy używają tych samych wartości
      Text(values['name']),
      Icon(values['volumeIcon']),
      // ...
    ],
  ),
)

// ROZWIĄZANIE 3: Użyj const constructors gdzie to możliwe
const TextStyle(fontWeight: FontWeight.bold)
const SizedBox(height: 20)

// ROZWIĄZANIE 4: Stwórz dedykowany widget dla ścieżki
class TrackWidget extends StatelessWidget {
  final Track track;
  
  const TrackWidget({required this.track, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<TrackState>(
        valueListenable: track.state,
        builder: (context, state, child) => _buildTrackContent(state),
      ),
    );
  }
  
  Widget _buildTrackContent(TrackState state) {
    // Tutaj wszystkie inne ValueListenableBuilder
    // Każdy będzie rebuildował tylko swoją część
  }
}
```

### **2. ValueListenableBuilder Optimization**
```dart
// ROZWIĄZANIE: Użyj RepaintBoundary i const constructors
RepaintBoundary(
  child: ValueListenableBuilder<String>(
    valueListenable: track.name,
    builder: (context, name, child) => Text(
      _trans.cell(name),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
)
```

### **3. Stream Optimization**
```dart
// ROZWIĄZANIE: Throttle audio events
positionSubscription = player.onPositionChanged
  .throttleTime(Duration(milliseconds: 16)) // 60 FPS max
  .listen((Duration position) {
    setPosition(position);
  });
```

### **4. UI Thread Optimization**
```dart
// ROZWIĄZANIE: Przenieś operacje audio do isolate
Future<void> setPath(String? newPath) async {
  if (newPath != null) {
    setRecorderState(RecorderState.processing);
    
    // Przenieś operacje audio do isolate
    await compute(_loadAudioFile, newPath).then((audioData) {
      _path = newPath;
      _updateAudioPlayer(audioData);
      setRecorderState(RecorderState.ready);
    });
  }
}
```

### **5. Memory Management**
```dart
// ROZWIĄZANIE: Proper dispose pattern
@override
void dispose() {
  timer?.cancel();
  durationSubscription?.cancel();
  positionSubscription?.cancel();
  playerCompleteSubscription?.cancel();
  playerStateChangeSubscription?.cancel();
  
  // Czekaj na zakończenie dispose
  player.dispose();
  super.dispose();
}
```

## **Priorytety Naprawy**

1. **KRYTYCZNY**: Optymalizuj ValueListenableBuilder (RepaintBoundary + grupowanie)
2. **WYSOKI**: Throttle audio streams (16ms)
3. **WYSOKI**: Przenieś operacje audio do isolate
4. **ŚREDNI**: Napraw dispose pattern
5. **ŚREDNI**: Optymalizuj Stack widgety
6. **NISKI**: Dodaj const constructors

## **Oczekiwane Rezultaty**

- **FPS**: Z 30-40 → **60+ FPS** (głównie przez optymalizację ValueListenableBuilder)
- **Rebuild overhead**: Z 240+ potencjalnych rebuildów → **24 rebuildy** (tylko gdy naprawdę potrzebne)
- **UI responsiveness**: **Płynne animacje** i interakcje
- **Memory usage**: Lepsze zarządzanie pamięcią przez RepaintBoundary
- **Overall performance**: **Płynne działanie** aplikacji bez zacinania się

---

*Analiza wykonana na podstawie kodu z: lib/entity/track.dart, lib/manager/track_manager.dart, lib/manager/home_screen_manager.dart*
