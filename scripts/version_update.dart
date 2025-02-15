import 'dart:io';

void main() {
  final file = File('pubspec.yaml');
  final lines = file.readAsLinesSync();

  // Szukamy linii, która zaczyna się od 'version:'
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('version:')) {
      // Rozdzielamy wersję na dwie części: numer wersji i numer builda
      final parts = lines[i].split('+');
      if (parts.length == 2) {
        final version = parts[0].trim();
        final buildNumber = int.tryParse(parts[1].trim());

        // Jeśli wersja builda jest poprawna, zwiększamy ją
        if (buildNumber != null) {
          final newBuildNumber = buildNumber + 1;
          final newVersion = '$version+$newBuildNumber';

          // Zmieniamy linię w pliku na nową wersję
          lines[i] = '$newVersion';
          print('Zmieniono wersję na: $newVersion');
        } else {
          print('Nie udało się sparsować numeru builda.');
        }
      } else {
        print('Format wersji jest niepoprawny w pliku pubspec.yaml.');
      }
      break; // Kończymy po znalezieniu wersji
    }
  }

  // Zapisujemy zmienione linie z powrotem do pliku
  file.writeAsStringSync(lines.join('\n'));
}
