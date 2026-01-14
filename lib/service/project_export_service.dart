import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../adapter/track_adapter_key.dart';
import '../config/app_config_fields.dart';
import '../entity/track.dart';
import '../repository/track_repository.dart';
import '../wrapper/hive_settings_provider.dart';

class ProjectExportMetadata {
  final String version;
  final String appVersion;
  final DateTime exportDate;
  final String? projectName;
  final Map<String, int> gridSize;
  final Map<String, dynamic> statistics;
  final List<Map<String, dynamic>> tracks;

  ProjectExportMetadata({
    required this.version,
    required this.appVersion,
    required this.exportDate,
    this.projectName,
    required this.gridSize,
    required this.statistics,
    required this.tracks,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'appVersion': appVersion,
    'exportDate': exportDate.toIso8601String(),
    'exportDateFormatted': _formatDate(exportDate),
    if (projectName != null) 'projectName': projectName,
    'gridSize': gridSize,
    'statistics': statistics,
    'tracks': tracks,
  };

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }
}

class ProjectExportService {
  final HiveSettingsProvider _settings;
  final TrackRepository _trackRepository;

  ProjectExportService(this._settings, this._trackRepository);

  /// Eksportuje projekt do pliku ZIP
  Future<File> exportProject(String? projectName) async {
    final archive = Archive();
    final checksums = <String, String>{};

    // 1. Eksportuj ustawienia siatki
    await _exportGridSettings(archive);

    // 2. Eksportuj wszystkie ścieżki
    final allTracks = _trackRepository.allTracks();
    await _exportTracks(archive, allTracks);

    // 3. Eksportuj nagrania i oblicz sumy kontrolne
    await _exportRecordings(archive, allTracks, checksums);

    // 4. Dodaj plik z sumami kontrolnymi
    if (checksums.isNotEmpty) {
      String checksumsJson;
      try {
        checksumsJson = jsonEncode(checksums);
      } catch (e) {
        debugPrint('[ProjectExport] ERROR encoding checksums to JSON: $e');
        debugPrint('[ProjectExport] Checksums map: $checksums');
        rethrow;
      }
      
      List<int> checksumsBytes;
      try {
        checksumsBytes = utf8.encode(checksumsJson);
      } catch (e) {
        debugPrint('[ProjectExport] ERROR encoding checksums JSON to UTF-8: $e');
        rethrow;
      }
      archive.addFile(
        ArchiveFile(
          'recordings/checksums.json',
          checksumsBytes.length,
          checksumsBytes,
        ),
      );
    }

    // 5. Generuj i dodaj metadata.json
    final metadata = await _generateMetadata(projectName, allTracks, checksums);
    String metadataJson;
    try {
      final metadataMap = metadata.toJson();
      metadataJson = jsonEncode(metadataMap);
      
      // Sprawdź czy są znaki kontrolne w JSON
      for (int i = 0; i < metadataJson.length; i++) {
        final char = metadataJson[i];
        final code = char.codeUnitAt(0);
        if (code < 32 && code != 9 && code != 10 && code != 13) {
          debugPrint('[ProjectExport] WARNING: Control character in metadata JSON at position $i: code $code (0x${code.toRadixString(16)})');
          debugPrint('[ProjectExport] JSON context around position $i: ${metadataJson.substring(i > 50 ? i - 50 : 0, i + 50 < metadataJson.length ? i + 50 : metadataJson.length)}');
        }
      }
    } catch (e) {
      debugPrint('[ProjectExport] ERROR encoding metadata to JSON: $e');
      debugPrint('[ProjectExport] Metadata object: ${metadata.toJson()}');
      rethrow;
    }
    
    List<int> metadataBytes;
    try {
      metadataBytes = utf8.encode(metadataJson);
    } catch (e) {
      debugPrint('[ProjectExport] ERROR encoding metadata JSON to UTF-8: $e');
      rethrow;
    }
    archive.addFile(
      ArchiveFile(
        'metadata.json',
        metadataBytes.length,
        metadataBytes,
      ),
    );

    // 6. Zapisz ZIP do pliku tymczasowego
    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);
    if (zipData == null) {
      throw Exception('Failed to encode ZIP archive');
    }

    // 7. Utwórz nazwę pliku
    final fileName = _generateFileName(projectName);
    final tempDir = await getTemporaryDirectory();
    final zipFile = File(path.join(tempDir.path, fileName));

    await zipFile.writeAsBytes(zipData);

    return zipFile;
  }

  Future<void> _exportGridSettings(Archive archive) async {
    final gridRows = _settings.getConfig(AppConfigFieldKey.gridRowsAmount);
    final gridCols = _settings.getConfig(AppConfigFieldKey.gridColsAmount);

    final settings = {
      'gridRowsAmount': gridRows,
      'gridColsAmount': gridCols,
    };

    String settingsJson;
    try {
      settingsJson = jsonEncode(settings);
    } catch (e) {
      debugPrint('[ProjectExport] ERROR encoding grid settings to JSON: $e');
      debugPrint('[ProjectExport] Settings map: $settings');
      rethrow;
    }
    
    List<int> settingsBytes;
    try {
      settingsBytes = utf8.encode(settingsJson);
    } catch (e) {
      debugPrint('[ProjectExport] ERROR encoding settings JSON to UTF-8: $e');
      rethrow;
    }
    archive.addFile(
      ArchiveFile(
        'settings/grid_settings.json',
        settingsBytes.length,
        settingsBytes,
      ),
    );
  }

  Future<void> _exportTracks(
    Archive archive,
    Set<Track> tracks,
  ) async {
    for (final track in tracks) {
      final trackMap = track.toMap();
      final trackId = track.id;
      // Konwertuj Map<TrackAdapterKey, dynamic> na Map<String, dynamic> dla JSON
      final trackMapJson = <String, dynamic>{};
      trackMap.forEach((key, value) {
        // Skip path - recordings are exported separately
        if (key == TrackAdapterKey.path) {
          return;
        }

        // Convert TrackId to list [row, col]
        if (key == TrackAdapterKey.trackId && value is TrackId) {
          trackMapJson[key.name] = value.toList();
        }
        // Convert Duration to milliseconds
        else if (key == TrackAdapterKey.playbackStartAtPosition &&
            value is Duration) {
          trackMapJson[key.name] = value.inMilliseconds;
        } else if (key == TrackAdapterKey.playbackEndAtPosition &&
            value is Duration) {
          trackMapJson[key.name] = value.inMilliseconds;
        } else if (key == TrackAdapterKey.name && value is String) {
          // Clean name from control characters
          String cleanName = value.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
          trackMapJson[key.name] = cleanName;
        } else {
          // Export all other fields, including null values
          // This ensures all metadata is preserved during import
          trackMapJson[key.name] = value;
        }
      });

      String trackJson;
      try {
        trackJson = jsonEncode(trackMapJson);
        // Sprawdź czy są znaki kontrolne w JSON
        for (int i = 0; i < trackJson.length; i++) {
          final char = trackJson[i];
          final code = char.codeUnitAt(0);
          if (code < 32 && code != 9 && code != 10 && code != 13) {
            debugPrint('[ProjectExport] WARNING: Control character in JSON at position $i: code $code (0x${code.toRadixString(16)})');
            debugPrint('[ProjectExport] JSON context around position $i: ${trackJson.substring(i > 20 ? i - 20 : 0, i + 20 < trackJson.length ? i + 20 : trackJson.length)}');
          }
        }
      } catch (e) {
        debugPrint('[ProjectExport] ERROR encoding track ${trackId.toString()} to JSON: $e');
        debugPrint('[ProjectExport] Track map: $trackMapJson');
        rethrow;
      }
      
      List<int> trackBytes;
      try {
        trackBytes = utf8.encode(trackJson);
      } catch (e) {
        debugPrint('[ProjectExport] ERROR encoding track JSON to UTF-8: $e');
        rethrow;
      }
      
      final fileName = 'track_${trackId.toString()}.json';
      archive.addFile(
        ArchiveFile(
          'tracks/$fileName',
          trackBytes.length,
          trackBytes,
        ),
      );
    }
  }

  Future<void> _exportRecordings(
    Archive archive,
    Set<Track> tracks,
    Map<String, String> checksums,
  ) async {
    for (final track in tracks) {
      if (track.path == null) continue;

      final file = File(track.path!);
      if (!file.existsSync()) continue;

      // Oblicz sumę kontrolną
      final fileBytes = await file.readAsBytes();
      final checksum = sha256.convert(fileBytes).toString();
      final fileName = path.basename(file.path);
      checksums[fileName] = checksum;

      // Dodaj plik do archiwum
      archive.addFile(
        ArchiveFile(
          'recordings/$fileName',
          fileBytes.length,
          fileBytes,
        ),
      );
    }
  }

  Future<ProjectExportMetadata> _generateMetadata(
    String? projectName,
    Set<Track> tracks,
    Map<String, String> checksums,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final exportDate = DateTime.now();

    final gridRows = _settings.getConfig(AppConfigFieldKey.gridRowsAmount);
    final gridCols = _settings.getConfig(AppConfigFieldKey.gridColsAmount);

    int totalRecordingsSize = 0;
    int tracksWithRecordings = 0;
    final tracksList = <Map<String, dynamic>>[];

    for (final track in tracks) {
      final hasRecording = track.path != null && File(track.path!).existsSync();
      int? recordingSize;
      String? recordingFormat;
      String? recordingChecksum;

      if (hasRecording) {
        final file = File(track.path!);
        recordingSize = await file.length();
        totalRecordingsSize += recordingSize;
        tracksWithRecordings++;

        final ext = path.extension(file.path).substring(1);
        recordingFormat = ext;

        final fileName = path.basename(file.path);
        recordingChecksum = checksums[fileName];
        
        // Zapisz nazwę pliku w metadanych dla łatwego dopasowania podczas importu
      }

      // Wyczyść nazwę z znaków kontrolnych przed dodaniem do JSON
      String cleanName = track.name.value;
      // Usuń znaki kontrolne (kody 0-31 oprócz tab, newline, carriage return)
      cleanName = cleanName.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
      
      
      String? recordingFileName;
      if (hasRecording && track.path != null) {
        recordingFileName = path.basename(track.path!);
      }
      
      tracksList.add({
        'id': track.id.toString(),
        'name': cleanName,
        'hasRecording': hasRecording,
        if (recordingSize != null) 'recordingSize': recordingSize,
        if (recordingFormat != null) 'recordingFormat': recordingFormat,
        if (recordingChecksum != null) 'recordingChecksum': recordingChecksum,
        if (recordingFileName != null) 'recordingFileName': recordingFileName,
      });
      
      // Sprawdź czy recordingFileName zostało dodane
      if (hasRecording && recordingFileName == null) {
        debugPrint('[ProjectExport] WARNING: Track ${track.id.toString()} has recording but recordingFileName is null!');
      }
    }

    return ProjectExportMetadata(
      version: '1.0',
      appVersion: packageInfo.version,
      exportDate: exportDate,
      projectName: projectName,
      gridSize: {
        'rows': gridRows,
        'cols': gridCols,
      },
      statistics: {
        'totalTracks': tracks.length,
        'tracksWithRecordings': tracksWithRecordings,
        'totalRecordingsSize': totalRecordingsSize,
        'totalRecordingsSizeFormatted': _formatSize(totalRecordingsSize),
      },
      tracks: tracksList,
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _generateFileName(String? projectName) {
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    String namePart = '';
    if (projectName != null && projectName.trim().isNotEmpty) {
      // Usuń nieprawidłowe znaki z nazwy pliku
      namePart = projectName
          .trim()
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(' ', '_');
      namePart = '_$namePart';
    }

    return 'tune_tangler_project${namePart}_$dateStr.zip';
  }
}
