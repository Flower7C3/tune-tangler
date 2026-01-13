import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../adapter/track_adapter_key.dart';
import '../config/app_config_fields.dart';
import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../src/lazy_loading_manager.dart';
import '../wrapper/hive_settings_provider.dart';

class ProjectImportError {
  final String message;
  final String? fileName;
  final bool isWarning;

  ProjectImportError({
    required this.message,
    this.fileName,
    this.isWarning = false,
  });
}

class ProjectImportService {
  final HiveSettingsProvider _settings;
  final TrackRepository _trackRepository;

  ProjectImportService(this._settings, this._trackRepository);

  /// Pobiera podgląd projektu z pliku ZIP
  Future<Map<String, dynamic>> getProjectPreview(String zipPath) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw Exception('Project file not found');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Znajdź metadata.json
    final metadataFile = archive.findFile('metadata.json');
    if (metadataFile == null) {
      throw Exception('Invalid project format: metadata.json not found');
    }

    final metadataBytes = metadataFile.content as List<int>;
    String metadataJson;
    try {
      metadataJson = utf8.decode(metadataBytes, allowMalformed: false);
    } catch (e) {
      debugPrint('[ProjectImport] ERROR decoding metadata.json as UTF-8: $e');
      rethrow;
    }

      Map<String, dynamic> metadata;
      try {
        metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

        // Wyczyść nazwy z znaków kontrolnych w tracks (dla podglądu)
        if (metadata.containsKey('tracks') && metadata['tracks'] is List) {
          final tracks = metadata['tracks'] as List<dynamic>;
          for (var track in tracks) {
            if (track is Map<String, dynamic> && track.containsKey('name')) {
              final originalName = track['name'] as String?;
              if (originalName != null) {
                final cleanName = originalName.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
                if (cleanName != originalName) {
                  track['name'] = cleanName;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[ProjectImport] ERROR parsing metadata.json JSON: $e');
        debugPrint('[ProjectImport] JSON content: $metadataJson');
        // Spróbuj wyczyścić znaki kontrolne i ponownie sparsować
        try {
          String cleanedJson = metadataJson.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
          metadata = jsonDecode(cleanedJson) as Map<String, dynamic>;

          // Wyczyść nazwy w tracks
          if (metadata.containsKey('tracks') && metadata['tracks'] is List) {
            final tracks = metadata['tracks'] as List<dynamic>;
            for (var track in tracks) {
              if (track is Map<String, dynamic> && track.containsKey('name')) {
                final originalName = track['name'] as String?;
                if (originalName != null) {
                  final cleanName = originalName.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
                  track['name'] = cleanName;
                }
              }
            }
          }
        } catch (e2) {
          debugPrint('[ProjectImport] ERROR parsing cleaned metadata.json JSON: $e2');
          rethrow;
        }
      }

    return metadata;
  }

  /// Waliduje projekt przed importem (bez modyfikowania danych)
  Future<List<ProjectImportError>> validateProject(String zipPath) async {
    final errors = <ProjectImportError>[];

    try {
      final file = File(zipPath);
      if (!file.existsSync()) {
        errors.add(ProjectImportError(
          message: 'Project file not found',
        ));
        return errors;
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Walidacja struktury podstawowej
      if (archive.findFile('metadata.json') == null) {
        errors.add(ProjectImportError(
          message: 'Invalid project format: metadata.json not found',
        ));
        return errors;
      }
      if (archive.findFile('settings/grid_settings.json') == null) {
        errors.add(ProjectImportError(
          message: 'Invalid project format: settings/grid_settings.json not found',
        ));
        return errors;
      }

      // 2. Walidacja metadata.json
      await _validateMetadata(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 3. Walidacja grid_settings.json
      await _validateGridSettings(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 4. Walidacja wszystkich plików tracków
      await _validateTracks(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 5. Walidacja nagrań (sumy kontrolne, długości, dopasowanie do tracków)
      await _validateRecordings(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }
    } catch (e, stackTrace) {
      debugPrint('[ProjectImport] Exception during validation: $e');
      debugPrint('[ProjectImport] Stack trace: $stackTrace');
      errors.add(ProjectImportError(
        message: 'Validation error: $e',
      ));
    }

    return errors;
  }

  /// Importuje projekt z pliku ZIP (tylko po pomyślnej walidacji)
  Future<List<ProjectImportError>> importProject(String zipPath) async {
    final errors = <ProjectImportError>[];

    try {
      debugPrint('[ProjectImport] Starting import of project...');

      final file = File(zipPath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Usuń wszystkie bieżące nagrania PRZED importem tracków
      // (żeby nie było konfliktów z istniejącymi ścieżkami)
      _trackRepository.deleteTracksRecordings(_trackRepository.allTracks());

      // 2. Importuj ustawienia siatki
      await _importGridSettings(archive);

      // 3. Zresetuj kolekcję ścieżek (cache)
      _trackRepository.resetTracksCollection();

      // 4. Importuj wszystkie ścieżki PRZED nagraniami
      // (żeby tracki istniały w repozytorium gdy będziemy przypisywać do nich nagrania)
      await _importTracks(archive, errors);

      // 5. Importuj nagrania z weryfikacją
      // (teraz tracki już istnieją, więc można je znaleźć i przypisać do nich nagrania)
      await _importRecordings(archive, errors);

      // 6. Zresetuj kolekcję ścieżek po imporcie (żeby odświeżyć cache)
      // To wymusi ponowne załadowanie tracków z Hive przy następnym wywołaniu allTracks()
      _trackRepository.resetTracksCollection();

      // 7. Wyczyść cache LazyLoadingManager (żeby wymusić odbudowę widgetów)
      // To jest kluczowe - LazyLoadingManager cache'uje widgety, więc musimy wyczyścić cache
      // żeby widgety były odbudowane z nowymi danymi z Hive
      LazyLoadingManager().clearCache();

      // 8. Odśwież ustawienia (notifyListeners) żeby widok się zaktualizował
      // To jest kluczowe - podobnie jak przy zmianie języka, notifyListeners() powoduje
      // ponowne wywołanie build() w MaterialApp, co odświeża całą aplikację
      // Wersja jest zwiększana, co zmienia klucz w tracksList i wymusza rebuild
      _settings.reload();
    } catch (e, stackTrace) {
      debugPrint('[ProjectImport] Exception during import: $e');
      debugPrint('[ProjectImport] Stack trace: $stackTrace');
      errors.add(ProjectImportError(
        message: 'Import error: $e',
      ));
    }

    return errors;
  }

  Future<void> _validateMetadata(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    final metadataFile = archive.findFile('metadata.json');
    if (metadataFile == null) {
      errors.add(ProjectImportError(
        message: 'metadata.json not found',
      ));
      return;
    }

    try {
      final metadataBytes = metadataFile.content as List<int>;
      final metadataJson = utf8.decode(metadataBytes, allowMalformed: false);
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      // Sprawdź wymagane pola
      if (!metadata.containsKey('version')) {
        errors.add(ProjectImportError(message: 'metadata.json missing version'));
      }
      if (!metadata.containsKey('gridSize')) {
        errors.add(ProjectImportError(message: 'metadata.json missing gridSize'));
      }
      if (!metadata.containsKey('tracks')) {
        errors.add(ProjectImportError(message: 'metadata.json missing tracks'));
      }

    } catch (e) {
      errors.add(ProjectImportError(
        message: 'Failed to parse metadata.json: $e',
      ));
    }
  }

  Future<void> _validateGridSettings(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    final settingsFile = archive.findFile('settings/grid_settings.json');
    if (settingsFile == null) {
      errors.add(ProjectImportError(
        message: 'settings/grid_settings.json not found',
      ));
      return;
    }

    try {
      final settingsBytes = settingsFile.content as List<int>;
      final settingsJson = utf8.decode(settingsBytes, allowMalformed: false);
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      if (!settings.containsKey('gridRowsAmount') ||
          !settings.containsKey('gridColsAmount')) {
        errors.add(ProjectImportError(
          message: 'grid_settings.json missing required fields',
        ));
        return;
      }

      final rows = settings['gridRowsAmount'] as int?;
      final cols = settings['gridColsAmount'] as int?;

      if (rows == null || cols == null || rows < 1 || cols < 1) {
        errors.add(ProjectImportError(
          message: 'Invalid grid size in grid_settings.json',
        ));
      }

    } catch (e) {
      errors.add(ProjectImportError(
        message: 'Failed to parse grid_settings.json: $e',
      ));
    }
  }

  Future<void> _validateTracks(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    final tracksDir = archive.files.where(
      (file) => file.name.startsWith('tracks/') && file.name.endsWith('.json'),
    );

    for (final trackFile in tracksDir) {
      try {
        final trackBytes = trackFile.content as List<int>;
        final trackJson = utf8.decode(trackBytes);
        final trackMapJson = jsonDecode(trackJson) as Map<String, dynamic>;

        // Sprawdź wymagane pola
        if (!trackMapJson.containsKey('trackId')) {
          errors.add(ProjectImportError(
            message: 'Track file missing trackId: ${trackFile.name}',
            fileName: trackFile.name,
          ));
          continue;
        }

        final trackIdList = trackMapJson['trackId'] as List<dynamic>?;
        if (trackIdList == null || trackIdList.length != 2) {
          errors.add(ProjectImportError(
            message: 'Invalid trackId format: ${trackFile.name}',
            fileName: trackFile.name,
          ));
          continue;
        }

      } catch (e) {
        errors.add(ProjectImportError(
          message: 'Failed to validate track file: $e',
          fileName: trackFile.name,
        ));
      }
    }

  }

  Future<void> _validateRecordings(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    // Wczytaj sumy kontrolne
    final checksumsFile = archive.findFile('recordings/checksums.json');
    final checksums = <String, String>{};
    if (checksumsFile != null) {
      try {
        final checksumsBytes = checksumsFile.content as List<int>;
        final checksumsJson = utf8.decode(checksumsBytes, allowMalformed: false);
        final checksumsMap = jsonDecode(checksumsJson) as Map<String, dynamic>;
        checksumsMap.forEach((key, value) {
          checksums[key] = value as String;
        });
      } catch (e) {
        errors.add(ProjectImportError(
          message: 'Failed to parse checksums.json: $e',
        ));
        return;
      }
    }

    // Wczytaj metadata dla mapowania i długości
    final metadataFile = archive.findFile('metadata.json');
    final trackDurations = <String, int>{};
    final trackIdToFileName = <String, String>{};

    if (metadataFile != null) {
      try {
        final metadataBytes = metadataFile.content as List<int>;
        String metadataJson = utf8.decode(metadataBytes, allowMalformed: false);

        // Spróbuj wyczyścić znaki kontrolne jeśli potrzeba
        try {
          jsonDecode(metadataJson);
        } catch (_) {
          metadataJson = metadataJson.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
        }

        final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
        final tracks = metadata['tracks'] as List<dynamic>?;
        if (tracks != null) {
          for (final trackData in tracks) {
            final trackMap = trackData as Map<String, dynamic>;
            final hasRecording = trackMap['hasRecording'] as bool?;
            debugPrint('[ProjectImport] Track ${trackMap['id']}: hasRecording=$hasRecording');
            if (hasRecording == true) {
              final trackId = trackMap['id'] as String;
              final recordingSize = trackMap['recordingSize'] as int?;
              final recordingFileName = trackMap['recordingFileName'] as String?;

              if (recordingSize != null) {
                trackDurations[trackId] = recordingSize;
              }

              if (recordingFileName != null) {
                trackIdToFileName[trackId] = recordingFileName;
              } else {
                debugPrint('[ProjectImport] WARNING: Track $trackId has recording but no recordingFileName in metadata');
              }
            }
          }
        }
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] ERROR parsing metadata.json for recordings validation: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(ProjectImportError(
          message: 'Failed to parse metadata.json for recordings validation: $e',
        ));
        return;
      }
    } else {
      debugPrint('[ProjectImport] WARNING: metadata.json not found in archive for validation');
    }

    final recordingsDir = archive.files.where(
      (file) =>
          file.name.startsWith('recordings/') &&
          file.name != 'recordings/checksums.json',
    ).toList();


    for (final recordingFile in recordingsDir) {
      try {
        final fileName = path.basename(recordingFile.name);
        final fileBytes = recordingFile.content as List<int>;

        // Weryfikuj sumę kontrolną
        if (checksums.containsKey(fileName)) {
          final expectedChecksum = checksums[fileName]!;
          final actualChecksum = sha256.convert(fileBytes).toString();
          if (actualChecksum != expectedChecksum) {
            debugPrint('[ProjectImport] Checksum mismatch for $fileName: expected $expectedChecksum, got $actualChecksum');
            errors.add(ProjectImportError(
              message: 'Checksum mismatch for recording file',
              fileName: fileName,
            ));
            continue;
          }
          debugPrint('[ProjectImport] Checksum verified for $fileName');
        } else {
        }

        // Sprawdź czy plik ma odpowiadający track w metadata
        bool foundInMetadata = false;

        // Jeśli mapowanie jest puste, spróbuj znaleźć po trackId w nazwie pliku
        if (trackIdToFileName.isEmpty) {
          final nameWithoutExt = path.basenameWithoutExtension(fileName);
          // Sprawdź czy nazwa zaczyna się od trackId (format: trackId.timestamp.ext)
          for (final entry in trackDurations.entries) {
            final trackId = entry.key;
            if (nameWithoutExt == trackId || nameWithoutExt.startsWith('$trackId.')) {
              foundInMetadata = true;
              // Sprawdź długość
              final expectedSize = entry.value;
              if (fileBytes.length != expectedSize) {
                debugPrint('[ProjectImport] File size mismatch for $fileName: expected $expectedSize, got ${fileBytes.length}');
                errors.add(ProjectImportError(
                  message: 'File size mismatch for recording',
                  fileName: fileName,
                  isWarning: true,
                ));
              } else {
              }
              break;
            }
          }
        } else {
          // Normalne dopasowanie przez mapowanie
          for (final entry in trackIdToFileName.entries) {
            final trackId = entry.key;
            final mappedFileName = entry.value;
            if (mappedFileName == fileName) {
              foundInMetadata = true;
              // Sprawdź długość
              if (trackDurations.containsKey(trackId)) {
                final expectedSize = trackDurations[trackId]!;
                if (fileBytes.length != expectedSize) {
                  debugPrint('[ProjectImport] File size mismatch for $fileName: expected $expectedSize, got ${fileBytes.length}');
                  errors.add(ProjectImportError(
                    message: 'File size mismatch for recording',
                    fileName: fileName,
                    isWarning: true,
                  ));
                } else {
                }
              }
              break;
            }
          }
        }

        if (!foundInMetadata) {
          debugPrint('[ProjectImport] Recording file $fileName not found in metadata mapping');
          errors.add(ProjectImportError(
            message: 'Recording file not found in metadata',
            fileName: fileName,
          ));
        }
      } catch (e) {
        errors.add(ProjectImportError(
          message: 'Failed to validate recording file: $e',
          fileName: recordingFile.name,
        ));
      }
    }

  }

  Future<void> _importGridSettings(Archive archive) async {
    final settingsFile = archive.findFile('settings/grid_settings.json');
    if (settingsFile == null) return;

    final settingsBytes = settingsFile.content as List<int>;
    String settingsJson;
    try {
      settingsJson = utf8.decode(settingsBytes, allowMalformed: false);
    } catch (e) {
      debugPrint('[ProjectImport] ERROR decoding grid_settings.json as UTF-8: $e');
      rethrow;
    }

    Map<String, dynamic> settings;
    try {
      settings = jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[ProjectImport] ERROR parsing grid_settings.json JSON: $e');
      debugPrint('[ProjectImport] JSON content: $settingsJson');
      rethrow;
    }

    if (settings.containsKey('gridRowsAmount')) {
      await _settings.setConfig(
        AppConfigFieldKey.gridRowsAmount,
        settings['gridRowsAmount'],
      );
    }
    if (settings.containsKey('gridColsAmount')) {
      await _settings.setConfig(
        AppConfigFieldKey.gridColsAmount,
        settings['gridColsAmount'],
      );
    }
  }

  Future<void> _importTracks(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    final tracksDir = archive.files.where(
      (file) => file.name.startsWith('tracks/') && file.name.endsWith('.json'),
    ).toList();

    for (final trackFile in tracksDir) {
      try {
        final trackBytes = trackFile.content as List<int>;

        String trackJson;
        try {
          trackJson = utf8.decode(trackBytes);
        } catch (e) {
          debugPrint('[ProjectImport] ERROR decoding track file ${trackFile.name} as UTF-8: $e');
          rethrow;
        }

        Map<String, dynamic> trackMapJson;
        try {
          trackMapJson = jsonDecode(trackJson) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('[ProjectImport] ERROR parsing track JSON for ${trackFile.name}: $e');
          debugPrint('[ProjectImport] Track JSON content: $trackJson');
          // Sprawdź czy są znaki kontrolne
          for (int i = 0; i < trackJson.length; i++) {
            final char = trackJson[i];
            final code = char.codeUnitAt(0);
            if (code < 32 && code != 9 && code != 10 && code != 13) {
              debugPrint('[ProjectImport] Found control character at position $i: code $code (0x${code.toRadixString(16)})');
            }
          }
          rethrow;
        }

        // Konwertuj Map<String, dynamic> na Map<TrackAdapterKey, dynamic>
        final trackMap = <TrackAdapterKey, dynamic>{};
        trackMapJson.forEach((key, value) {
          final adapterKey = TrackAdapterKey.values.firstWhere(
            (e) => e.name == key,
            orElse: () => throw Exception('Unknown TrackAdapterKey: $key'),
          );
          trackMap[adapterKey] = value;
        });

        // Konwertuj listę [row, col] z powrotem na TrackId
        final trackIdList = trackMap[TrackAdapterKey.trackId] as List<dynamic>;
        final trackId = TrackId(
          trackIdList[0] as int,
          trackIdList[1] as int,
        );
        trackMap[TrackAdapterKey.trackId] = trackId;

        // Konwertuj milisekundy z powrotem na Duration
        if (trackMap[TrackAdapterKey.playbackStartAtPosition] != null) {
          final ms = trackMap[TrackAdapterKey.playbackStartAtPosition] as int;
          trackMap[TrackAdapterKey.playbackStartAtPosition] =
              Duration(milliseconds: ms);
        }
        if (trackMap[TrackAdapterKey.playbackEndAtPosition] != null) {
          final ms = trackMap[TrackAdapterKey.playbackEndAtPosition] as int;
          trackMap[TrackAdapterKey.playbackEndAtPosition] =
              Duration(milliseconds: ms);
        }

        // Utwórz track z mapy
        // WAŻNE: Zapisz wartości trimming przed wywołaniem fromMap(), bo fromMap() wywołuje setPath()
        // a jeśli path jest null, setPath() resetuje pozycje do Duration()
        final savedPlaybackStartAtPosition = trackMap[TrackAdapterKey.playbackStartAtPosition] as Duration?;
        final savedPlaybackEndAtPosition = trackMap[TrackAdapterKey.playbackEndAtPosition] as Duration?;

        // Usuń path z mapy przed fromMap(), żeby setPath() nie próbowało ustawić nieistniejącego pliku
        // (co spowodowałoby wywołanie _clearPath() i reset pozycji)
        trackMap[TrackAdapterKey.path] = null;

        // Utwórz track z mapy (bez path)
        final track = Track.fromMap(trackMap);

        // Przywróć wartości trimming (które mogły zostać zresetowane przez setPath(null))
        if (savedPlaybackStartAtPosition != null) {
          track.playbackStartAtPosition.value = savedPlaybackStartAtPosition;
        }
        if (savedPlaybackEndAtPosition != null) {
          track.playbackEndAtPosition.value = savedPlaybackEndAtPosition;
        }

        _trackRepository.save(track);
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] Exception importing track ${trackFile.name}: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(ProjectImportError(
          message: 'Failed to import track: ${trackFile.name} - $e',
          fileName: trackFile.name,
        ));
      }
    }

  }

  Future<void> _importRecordings(
    Archive archive,
    List<ProjectImportError> errors,
  ) async {
    // Wczytaj sumy kontrolne
    final checksumsFile = archive.findFile('recordings/checksums.json');
    final checksums = <String, String>{};
    if (checksumsFile != null) {
      final checksumsBytes = checksumsFile.content as List<int>;
      String checksumsJson;
      try {
        checksumsJson = utf8.decode(checksumsBytes, allowMalformed: false);
      } catch (e) {
        debugPrint('[ProjectImport] ERROR decoding checksums.json as UTF-8: $e');
        rethrow;
      }

      Map<String, dynamic> checksumsMap;
      try {
        checksumsMap = jsonDecode(checksumsJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[ProjectImport] ERROR parsing checksums.json JSON: $e');
        debugPrint('[ProjectImport] JSON content: $checksumsJson');
        rethrow;
      }
      checksumsMap.forEach((key, value) {
        checksums[key] = value as String;
      });
    }

    // Wczytaj metadata dla długości plików i mapowania trackId -> fileName
    final metadataFile = archive.findFile('metadata.json');
    final trackDurations = <String, int>{};
    final trackIdToFileName = <String, String>{}; // Mapowanie trackId -> fileName
    if (metadataFile != null) {
      final metadataBytes = metadataFile.content as List<int>;
      String metadataJson;
      try {
        metadataJson = utf8.decode(metadataBytes, allowMalformed: false);
      } catch (e) {
        debugPrint('[ProjectImport] ERROR decoding metadata.json as UTF-8 (second time): $e');
        rethrow;
      }

      Map<String, dynamic> metadata;
      try {
        metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[ProjectImport] ERROR parsing metadata.json JSON (second time): $e');
        debugPrint('[ProjectImport] JSON content: $metadataJson');
        // Spróbuj wyczyścić znaki kontrolne i ponownie sparsować
        try {
          String cleanedJson = metadataJson.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
          metadata = jsonDecode(cleanedJson) as Map<String, dynamic>;
        } catch (e2) {
          debugPrint('[ProjectImport] ERROR parsing cleaned metadata.json JSON (second time): $e2');
          rethrow;
        }
      }
      final tracks = metadata['tracks'] as List<dynamic>?;
      if (tracks != null) {
        for (final trackData in tracks) {
          final trackMap = trackData as Map<String, dynamic>;
          if (trackMap['hasRecording'] == true) {
            final trackId = trackMap['id'] as String;
            final recordingSize = trackMap['recordingSize'] as int?;
            final recordingFileName = trackMap['recordingFileName'] as String?;

            if (recordingSize != null) {
              trackDurations[trackId] = recordingSize;
            }

            if (recordingFileName != null) {
              trackIdToFileName[trackId] = recordingFileName;
            }
          }
        }
      }
    }

    final recordingsDir = archive.files.where(
      (file) =>
          file.name.startsWith('recordings/') &&
          file.name != 'recordings/checksums.json',
    ).toList();

    final appDir = await getApplicationDocumentsDirectory();

    for (final recordingFile in recordingsDir) {
      try {
        final fileName = path.basename(recordingFile.name);
        final fileBytes = recordingFile.content as List<int>;

        // Weryfikuj sumę kontrolną
        if (checksums.containsKey(fileName)) {
          final expectedChecksum = checksums[fileName]!;
          final actualChecksum = sha256.convert(fileBytes).toString();
          if (actualChecksum != expectedChecksum) {
            debugPrint('[ProjectImport] Checksum mismatch for $fileName: expected $expectedChecksum, got $actualChecksum');
            errors.add(ProjectImportError(
              message: 'Checksum mismatch',
              fileName: fileName,
            ));
            continue;
          }
          debugPrint('[ProjectImport] Checksum verified for $fileName');
        } else {
        }

        // Znajdź track dla tego pliku
        final allTracks = _trackRepository.allTracks();
        Track? targetTrack;

        // Metoda 1: Użyj mapowania z metadata.json (trackId -> fileName)
        String? targetTrackId;
        trackIdToFileName.forEach((trackId, mappedFileName) {
          if (mappedFileName == fileName) {
            targetTrackId = trackId;
          }
        });

        if (targetTrackId != null) {
          for (final track in allTracks) {
            if (track.id.toString() == targetTrackId) {
              targetTrack = track;
              break;
            }
          }
        }

        // Metoda 2: Szukaj po nazwie pliku w track.path (jeśli track już ma path)
        if (targetTrack == null) {
          for (final track in allTracks) {
            if (track.path != null) {
              final trackFileName = path.basename(track.path!);
              if (trackFileName == fileName) {
                targetTrack = track;
                break;
              }
            }
          }
        }

        // Metoda 3: Jeśli nie znaleziono tracku, spróbuj znaleźć po ID z nazwy pliku
        // Nazwa pliku może być w formacie {trackId}.{timestamp}.{ext} lub {trackId}.{ext}
        if (targetTrack == null) {
          final nameWithoutExt = path.basenameWithoutExtension(fileName);
          for (final track in allTracks) {
            final trackIdStr = track.id.toString();
            // Sprawdź czy nazwa pliku zaczyna się od trackId (może być format trackId.timestamp.ext)
            if (nameWithoutExt == trackIdStr || nameWithoutExt.startsWith('$trackIdStr.')) {
              targetTrack = track;
              break;
            }
          }
        }

        if (targetTrack == null) {
          debugPrint('[ProjectImport] ERROR: Track not found for recording file $fileName');
          debugPrint('[ProjectImport] Available track IDs: ${allTracks.map((t) => t.id.toString()).join(", ")}');
          errors.add(ProjectImportError(
            message: 'Track not found for recording',
            fileName: fileName,
          ));
          continue;
        }


        // Zapisz plik
        final ext = path.extension(fileName);
        final newFileName = '${targetTrack.id.toString()}$ext';
        final newFilePath = path.join(appDir.path, newFileName);
        debugPrint('[ProjectImport] Saving recording to: $newFilePath');
        final savedFile = File(newFilePath);
        await savedFile.writeAsBytes(fileBytes);

        // Weryfikuj długość pliku
        final fileSize = await savedFile.length();
        final trackId = targetTrack.id.toString();
        if (trackDurations.containsKey(trackId)) {
          final expectedSize = trackDurations[trackId]!;
          if (fileSize != expectedSize) {
            // Resetuj pozycje odtwarzania
            targetTrack.resetPlaybackStartAtPosition();
            targetTrack.resetPlaybackEndAtPosition();
            _trackRepository.save(targetTrack);

            errors.add(ProjectImportError(
              message: 'File length mismatch',
              fileName: fileName,
              isWarning: true,
            ));
          }
        }

        // Zapisz wartości trimming przed setPath() (żeby nie zostały nadpisane)
        final savedPlaybackStartAtPosition = targetTrack.playbackStartAtPosition.value;
        final savedPlaybackEndAtPosition = targetTrack.playbackEndAtPosition.value;

        // Ustaw ścieżkę w tracku
        // setPath() jest asynchroniczne - ustawia stan na processing, potem ready/idle
        // Używamy preserveDuration: false, żeby ustawić duration z pliku (potrzebne do poprawnego obliczenia durationAfterCut)
        // Używamy preservePlaybackPositions: true, żeby nie nadpisać pozycji podczas setPath()
        // Po zakończeniu setPath() ręcznie ustawimy pozycje z zaimportowanych danych
        targetTrack.setPath(
          newFilePath,
          preserveDuration: false, // Pozwól setPath() ustawić duration z pliku
          preservePlaybackPositions: true,
        );

        // Poczekaj na zakończenie setPath() (stan zmieni się z processing na ready/idle)
        // setPath() ustawia stan na processing, a następnie asynchronicznie na ready/idle
        // Sprawdzaj stan co 100ms, maksymalnie 5 sekund (50 prób)
        const int maxAttempts = 50;
        const int delayMs = 100;
        int attempts = 0;

        // Poczekaj chwilę, aby setPath() zdążyło ustawić stan na processing
        await Future.delayed(Duration(milliseconds: 50));

        // Sprawdź, czy stan jest processing - jeśli tak, czekaj na zmianę
        // Jeśli nie, setPath() może już się zakończyć lub nie zostało wywołane
        if (targetTrack.state.value == TrackState.processing) {
          // Czekaj na zmianę stanu z processing na ready/idle/empty
          while (targetTrack.state.value == TrackState.processing && attempts < maxAttempts) {
            await Future.delayed(Duration(milliseconds: delayMs));
            attempts++;
            // Sprawdź, czy stan się zmienił (nie jest już processing)
            if (targetTrack.state.value != TrackState.processing) {
              break;
            }
          }

          // Jeśli nadal jest processing po maxAttempts, to timeout
          if (targetTrack.state.value == TrackState.processing && attempts >= maxAttempts) {
            debugPrint('[ProjectImport] WARNING: setPath() did not complete within ${maxAttempts * delayMs / 1000}s for track ${targetTrack.id.toString()}, state: ${targetTrack.state.value}');
            // Dodaj błąd do listy, ale kontynuuj import
            errors.add(ProjectImportError(
              message: 'Track ${targetTrack.id.toString()} did not finish loading within timeout',
              fileName: fileName,
              isWarning: true,
            ));
          }
        }

        // Po zakończeniu setPath() ustaw pozycje odtwarzania z zaimportowanych danych
        // (preservePlaybackPositions: true oznacza, że setPath() nie ustawia pozycji)
        // Upewnij się, że playbackEndAtPosition nie przekracza duration z pliku
        final actualDuration = targetTrack.duration.value;
        final finalPlaybackStartAtPosition = savedPlaybackStartAtPosition;
        final finalPlaybackEndAtPosition = savedPlaybackEndAtPosition.inMilliseconds > actualDuration.inMilliseconds
            ? actualDuration
            : savedPlaybackEndAtPosition;

        targetTrack.setPlaybackStartAtPosition(finalPlaybackStartAtPosition);
        targetTrack.setPlaybackEndAtPosition(finalPlaybackEndAtPosition);

        // Zapisz track do Hive
        _trackRepository.save(targetTrack);

        // WAŻNE: Po zapisaniu tracku do Hive, widok używa tracku z cache
        // Cache ładuje tracki przez _settings.getTrack(), które zwraca NOWĄ instancję z Hive
        // ValueListenableBuilder używa starej instancji z cache, która nie jest aktualizowana
        // Musimy zresetować cache, żeby wymusić ponowne załadowanie tracków z Hive
        // Ale to nie wystarczy - musimy też odświeżyć widok przez _settings.reload()
        // (które zwiększa wersję i wywołuje notifyListeners())
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] Exception importing recording ${recordingFile.name}: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(ProjectImportError(
          message: 'Failed to import recording: $e',
          fileName: recordingFile.name,
        ));
      }
    }

  }
}
