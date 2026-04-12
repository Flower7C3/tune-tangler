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
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class ProjectImportError {
  final String message;
  final String? fileName;
  final bool isWarning;

  ProjectImportError({required this.message, this.fileName, this.isWarning = false});
}

class ProjectImportService {
  final HiveSettingsProvider _settings;
  final TrackRepository _trackRepository;
  final AppLocalizations _trans;

  // Store playback positions from _importTracks for use in _importRecordings
  Map<String, Map<String, Duration>> _trackPlaybackPositions = {};

  ProjectImportService(this._settings, this._trackRepository, this._trans);

  /// Gets project preview from ZIP file
  Future<Map<String, dynamic>> getProjectPreview(String zipPath) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw Exception('Project file not found');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find metadata.json
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
      throw Exception(_trans.projectMetadataEncodingError);
    }

    Map<String, dynamic> metadata;
    try {
      metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      // Clean track names from control characters (for preview)
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
      // Try to clean control characters and parse again
      try {
        String cleanedJson = metadataJson.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
        metadata = jsonDecode(cleanedJson) as Map<String, dynamic>;

        // Clean names in tracks
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
        throw Exception(_trans.projectMetadataParseError);
      }
    }

    return metadata;
  }

  /// Validates project before import (without modifying data)
  Future<List<ProjectImportError>> validateProject(String zipPath) async {
    final errors = <ProjectImportError>[];

    try {
      final file = File(zipPath);
      if (!file.existsSync()) {
        errors.add(ProjectImportError(message: 'Project file not found'));
        return errors;
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Basic structure validation
      if (archive.findFile('metadata.json') == null) {
        errors.add(ProjectImportError(message: _trans.projectFileMissing('metadata.json'), fileName: 'metadata.json'));
        return errors;
      }
      if (archive.findFile('settings/grid_settings.json') == null) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileMissing('settings/grid_settings.json'),
            fileName: 'settings/grid_settings.json',
          ),
        );
        return errors;
      }

      // 2. Validate metadata.json
      await _validateMetadata(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 3. Validate grid_settings.json
      await _validateGridSettings(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 4. Validate all track files
      await _validateTracks(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }

      // 5. Validate recordings (checksums, lengths, matching to tracks)
      await _validateRecordings(archive, errors);
      if (errors.isNotEmpty) {
        return errors;
      }
    } catch (e, stackTrace) {
      debugPrint('[ProjectImport] Exception during validation: $e');
      debugPrint('[ProjectImport] Stack trace: $stackTrace');
      errors.add(ProjectImportError(message: 'Validation error: $e'));
    }

    return errors;
  }

  /// Imports project from ZIP file (only after successful validation)
  Future<List<ProjectImportError>> importProject(String zipPath) async {
    final errors = <ProjectImportError>[];

    try {
      final file = File(zipPath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Delete all current recordings BEFORE importing tracks
      // (to avoid conflicts with existing tracks)
      _trackRepository.deleteTracksRecordings(_trackRepository.allTracks());

      // 2. Import grid settings
      await _importGridSettings(archive);

      // 3. Reset tracks collection (cache)
      _trackRepository.resetTracksCollection();

      // 5. Import all tracks BEFORE recordings
      // (so tracks exist in repository when we assign recordings to them)
      await _importTracks(archive, errors);

      // 6. Import recordings with verification
      // (now tracks already exist, so we can find them and assign recordings to them)
      await _importRecordings(archive, errors);
    } catch (e, stackTrace) {
      debugPrint('[ProjectImport] Exception during import: $e');
      debugPrint('[ProjectImport] Stack trace: $stackTrace');
      errors.add(ProjectImportError(message: 'Import error: $e'));
    }

    return errors;
  }

  Future<void> _validateMetadata(Archive archive, List<ProjectImportError> errors) async {
    final metadataFile = archive.findFile('metadata.json');
    if (metadataFile == null) {
      errors.add(ProjectImportError(message: _trans.projectFileMissing('metadata.json'), fileName: 'metadata.json'));
      return;
    }

    try {
      final metadataBytes = metadataFile.content as List<int>;
      final metadataJson = utf8.decode(metadataBytes, allowMalformed: false);
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      // Check required fields
      if (!metadata.containsKey('version')) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileStructureError('metadata.json', 'version'),
            fileName: 'metadata.json',
          ),
        );
      }
      if (!metadata.containsKey('gridSize')) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileStructureError('metadata.json', 'gridSize'),
            fileName: 'metadata.json',
          ),
        );
      }
      if (!metadata.containsKey('tracks')) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileStructureError('metadata.json', 'tracks'),
            fileName: 'metadata.json',
          ),
        );
      }
    } catch (e) {
      debugPrint('[ProjectImport] ERROR in metadata.json: $e');
      String errorMessage;
      if (e.toString().contains('FormatException') ||
          e.toString().contains('Missing extension byte') ||
          e.toString().contains('Invalid UTF-8')) {
        errorMessage = _trans.projectFileEncodingError('metadata.json');
      } else if (e.toString().contains('Unexpected character') || e.toString().contains('Expected')) {
        errorMessage = _trans.projectFileParseError('metadata.json');
      } else {
        errorMessage = _trans.projectMetadataCorrupted;
      }
      errors.add(ProjectImportError(message: errorMessage, fileName: 'metadata.json'));
    }
  }

  Future<void> _validateGridSettings(Archive archive, List<ProjectImportError> errors) async {
    final settingsFile = archive.findFile('settings/grid_settings.json');
    if (settingsFile == null) {
      errors.add(
        ProjectImportError(
          message: _trans.projectFileMissing('settings/grid_settings.json'),
          fileName: 'settings/grid_settings.json',
        ),
      );
      return;
    }

    try {
      final settingsBytes = settingsFile.content as List<int>;
      final settingsJson = utf8.decode(settingsBytes, allowMalformed: false);
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      final missingFields = <String>[];
      if (!settings.containsKey('gridRowsAmount')) {
        missingFields.add('gridRowsAmount');
      }
      if (!settings.containsKey('gridColsAmount')) {
        missingFields.add('gridColsAmount');
      }

      if (missingFields.isNotEmpty) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileStructureError('settings/grid_settings.json', missingFields.join(', ')),
            fileName: 'settings/grid_settings.json',
          ),
        );
        return;
      }

      final rows = settings['gridRowsAmount'] as int?;
      final cols = settings['gridColsAmount'] as int?;

      if (rows == null || cols == null || rows < 1 || cols < 1) {
        String details = 'gridRowsAmount=${rows ?? 'null'}, gridColsAmount=${cols ?? 'null'}';
        errors.add(
          ProjectImportError(
            message: _trans.projectFileInvalidValue('settings/grid_settings.json', details),
            fileName: 'settings/grid_settings.json',
          ),
        );
      }
    } catch (e) {
      debugPrint('[ProjectImport] ERROR parsing grid_settings.json: $e');
      String errorMessage;
      if (e.toString().contains('FormatException') ||
          e.toString().contains('Missing extension byte') ||
          e.toString().contains('Invalid UTF-8')) {
        errorMessage = _trans.projectFileEncodingError('settings/grid_settings.json');
      } else if (e.toString().contains('Unexpected character') || e.toString().contains('Expected')) {
        errorMessage = _trans.projectFileParseError('settings/grid_settings.json');
      } else {
        errorMessage = _trans.projectFileParseError('settings/grid_settings.json');
      }
      errors.add(ProjectImportError(message: errorMessage, fileName: 'settings/grid_settings.json'));
    }
  }

  Future<void> _validateTracks(Archive archive, List<ProjectImportError> errors) async {
    final tracksDir = archive.files.where((file) => file.name.startsWith('tracks/') && file.name.endsWith('.json'));

    for (final trackFile in tracksDir) {
      try {
        final trackBytes = trackFile.content as List<int>;
        final trackJson = utf8.decode(trackBytes);
        final trackMapJson = jsonDecode(trackJson) as Map<String, dynamic>;

        // Check required fields
        if (!trackMapJson.containsKey('trackId')) {
          errors.add(
            ProjectImportError(
              message: _trans.projectFileStructureError(trackFile.name, 'trackId'),
              fileName: trackFile.name,
            ),
          );
          continue;
        }

        final trackIdList = trackMapJson['trackId'] as List<dynamic>?;
        if (trackIdList == null || trackIdList.length != 2) {
          errors.add(
            ProjectImportError(
              message: _trans.projectFileInvalidValue(trackFile.name, 'trackId musi być tablicą z 2 elementami'),
              fileName: trackFile.name,
            ),
          );
          continue;
        }
      } catch (e) {
        debugPrint('[ProjectImport] ERROR validating track file ${trackFile.name}: $e');
        String errorMessage;
        if (e.toString().contains('FormatException') ||
            e.toString().contains('Missing extension byte') ||
            e.toString().contains('Invalid UTF-8')) {
          errorMessage = _trans.projectFileEncodingError(trackFile.name);
        } else if (e.toString().contains('Unexpected character') || e.toString().contains('Expected')) {
          errorMessage = _trans.projectFileParseError(trackFile.name);
        } else {
          errorMessage = _trans.projectFileParseError(trackFile.name);
        }
        errors.add(ProjectImportError(message: errorMessage, fileName: trackFile.name));
      }
    }
  }

  Future<void> _validateRecordings(Archive archive, List<ProjectImportError> errors) async {
    // Load checksums
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
        debugPrint('[ProjectImport] ERROR parsing checksums.json: $e');
        String errorMessage;
        if (e.toString().contains('FormatException') ||
            e.toString().contains('Missing extension byte') ||
            e.toString().contains('Invalid UTF-8')) {
          errorMessage = _trans.projectFileEncodingError('recordings/checksums.json');
        } else {
          errorMessage = _trans.projectFileParseError('recordings/checksums.json');
        }
        errors.add(ProjectImportError(message: errorMessage, fileName: 'recordings/checksums.json'));
        return;
      }
    }

    // Load metadata for mapping and lengths
    final metadataFile = archive.findFile('metadata.json');
    final trackDurations = <String, int>{};
    final trackIdToFileName = <String, String>{};

    if (metadataFile != null) {
      try {
        final metadataBytes = metadataFile.content as List<int>;
        String metadataJson = utf8.decode(metadataBytes, allowMalformed: false);

        // Try to clean control characters if needed
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
                debugPrint(
                  '[ProjectImport] WARNING: Track $trackId has recording but no recordingFileName in metadata',
                );
              }
            }
          }
        }
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] ERROR parsing metadata.json for recordings validation: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        String errorMessage;
        if (e.toString().contains('FormatException') ||
            e.toString().contains('Missing extension byte') ||
            e.toString().contains('Invalid UTF-8')) {
          errorMessage = _trans.projectMetadataEncodingError;
        } else if (e.toString().contains('Unexpected character') || e.toString().contains('Expected')) {
          errorMessage = _trans.projectMetadataParseError;
        } else {
          errorMessage = _trans.projectMetadataCorrupted;
        }
        errors.add(ProjectImportError(message: errorMessage));
        return;
      }
    } else {
      debugPrint('[ProjectImport] WARNING: metadata.json not found in archive for validation');
    }

    // First check if all recordings listed in metadata exist in archive
    final recordingsInArchive = archive.files
        .where((file) => file.name.startsWith('recordings/') && file.name != 'recordings/checksums.json')
        .map((file) => path.basename(file.name))
        .toSet();

    // Check if all recordings from metadata exist in archive
    for (final entry in trackIdToFileName.entries) {
      final trackId = entry.key;
      final fileName = entry.value;
      if (!recordingsInArchive.contains(fileName)) {
        errors.add(ProjectImportError(message: _trans.projectRecordingNotFound, fileName: fileName));
        debugPrint('[ProjectImport] Recording file not found in archive: $fileName (trackId: $trackId)');
      }
    }

    final recordingsDir = archive.files
        .where((file) => file.name.startsWith('recordings/') && file.name != 'recordings/checksums.json')
        .toList();

    for (final recordingFile in recordingsDir) {
      try {
        final fileName = path.basename(recordingFile.name);
        final fileBytes = recordingFile.content as List<int>;

        // Verify checksum
        if (checksums.containsKey(fileName)) {
          final expectedChecksum = checksums[fileName]!;
          final actualChecksum = sha256.convert(fileBytes).toString();
          if (actualChecksum != expectedChecksum) {
            debugPrint(
              '[ProjectImport] Checksum mismatch for $fileName: expected $expectedChecksum, got $actualChecksum',
            );
            errors.add(ProjectImportError(message: _trans.projectChecksumMismatch(fileName), fileName: fileName));
            continue;
          }
          debugPrint('[ProjectImport] Checksum verified for $fileName');
        } else {}

        // Check if file has corresponding track in metadata
        bool foundInMetadata = false;

        // If mapping is empty, try to find by trackId in filename
        if (trackIdToFileName.isEmpty) {
          final nameWithoutExt = path.basenameWithoutExtension(fileName);
          // Check if name starts with trackId (format: trackId.timestamp.ext)
          for (final entry in trackDurations.entries) {
            final trackId = entry.key;
            if (nameWithoutExt == trackId || nameWithoutExt.startsWith('$trackId.')) {
              foundInMetadata = true;
              // Check length
              final expectedSize = entry.value;
              if (fileBytes.length != expectedSize) {
                debugPrint(
                  '[ProjectImport] File size mismatch for $fileName: expected $expectedSize, got ${fileBytes.length}',
                );
                errors.add(
                  ProjectImportError(message: 'File size mismatch for recording', fileName: fileName, isWarning: true),
                );
              } else {}
              break;
            }
          }
        } else {
          // Normal matching through mapping
          for (final entry in trackIdToFileName.entries) {
            final trackId = entry.key;
            final mappedFileName = entry.value;
            if (mappedFileName == fileName) {
              foundInMetadata = true;
              // Check length
              if (trackDurations.containsKey(trackId)) {
                final expectedSize = trackDurations[trackId]!;
                if (fileBytes.length != expectedSize) {
                  debugPrint(
                    '[ProjectImport] File size mismatch for $fileName: expected $expectedSize, got ${fileBytes.length}',
                  );
                  errors.add(
                    ProjectImportError(
                      message: 'File size mismatch for recording',
                      fileName: fileName,
                      isWarning: true,
                    ),
                  );
                } else {}
              }
              break;
            }
          }
        }

        if (!foundInMetadata) {
          debugPrint('[ProjectImport] Recording file $fileName not found in metadata mapping');
          errors.add(ProjectImportError(message: 'Recording file not found in metadata', fileName: fileName));
        }
      } catch (e) {
        errors.add(ProjectImportError(message: 'Failed to validate recording file: $e', fileName: recordingFile.name));
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

    if (settings.containsKey('keyboardLayoutPreset')) {
      await _settings.setConfig(
        AppConfigFieldKey.keyboardLayoutPreset,
        settings['keyboardLayoutPreset'],
      );
    }
    if (settings.containsKey('gridRowsAmount')) {
      await _settings.setConfig(AppConfigFieldKey.gridRowsAmount, 0);
      await Future.delayed(Duration(milliseconds: 100));
      await _settings.setConfig(AppConfigFieldKey.gridRowsAmount, settings['gridRowsAmount']);
    }
    if (settings.containsKey('gridColsAmount')) {
      await _settings.setConfig(AppConfigFieldKey.gridColsAmount, 0);
      await Future.delayed(Duration(milliseconds: 100));
      await _settings.setConfig(AppConfigFieldKey.gridColsAmount, settings['gridColsAmount']);
    }
    await _settings.reload();
  }

  Future<void> _importTracks(Archive archive, List<ProjectImportError> errors) async {
    // Map to store playback positions for each track (to be used in _importRecordings)
    final trackPlaybackPositions = <String, Map<String, Duration>>{};
    final tracksDir = archive.files
        .where((file) => file.name.startsWith('tracks/') && file.name.endsWith('.json'))
        .toList();

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
          // Check if there are control characters
          for (int i = 0; i < trackJson.length; i++) {
            final char = trackJson[i];
            final code = char.codeUnitAt(0);
            if (code < 32 && code != 9 && code != 10 && code != 13) {
              debugPrint(
                '[ProjectImport] Found control character at position $i: code $code (0x${code.toRadixString(16)})',
              );
            }
          }
          rethrow;
        }

        // Convert Map<String, dynamic> to Map<TrackAdapterKey, dynamic>
        final trackMap = <TrackAdapterKey, dynamic>{};
        trackMapJson.forEach((key, value) {
          final adapterKey = TrackAdapterKey.values.firstWhere(
            (e) => e.name == key,
            orElse: () => throw Exception('Unknown TrackAdapterKey: $key'),
          );
          trackMap[adapterKey] = value;
        });

        // Convert list [row, col] back to TrackId
        final trackIdList = trackMap[TrackAdapterKey.trackId] as List<dynamic>;
        final trackId = TrackId(trackIdList[0] as int, trackIdList[1] as int);
        trackMap[TrackAdapterKey.trackId] = trackId;

        // Convert milliseconds back to Duration
        Duration? playbackStartAtPosition;
        Duration? playbackEndAtPosition;
        if (trackMap[TrackAdapterKey.playbackStartAtPosition] != null) {
          final ms = trackMap[TrackAdapterKey.playbackStartAtPosition] as int;
          playbackStartAtPosition = Duration(milliseconds: ms);
          trackMap[TrackAdapterKey.playbackStartAtPosition] = playbackStartAtPosition;
        }
        if (trackMap[TrackAdapterKey.playbackEndAtPosition] != null) {
          final ms = trackMap[TrackAdapterKey.playbackEndAtPosition] as int;
          playbackEndAtPosition = Duration(milliseconds: ms);
          trackMap[TrackAdapterKey.playbackEndAtPosition] = playbackEndAtPosition;
        }

        // Store playback positions for use in _importRecordings
        final trackIdStr = trackId.toString();
        trackPlaybackPositions[trackIdStr] = {
          'start': playbackStartAtPosition ?? Duration(),
          'end': playbackEndAtPosition ?? Duration(),
        };

        // Remove path from map before fromMap(), so setPath() doesn't try to set non-existent file
        // Track.fromMap() will call setPath(null, clearMetadata: false) which preserves metadata
        trackMap[TrackAdapterKey.path] = null;

        // Create track from map (without path)
        // Track.fromMap() uses setPath(..., clearMetadata: false) to preserve metadata
        final track = Track.fromMap(trackMap);

        _trackRepository.save(track);
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] Exception importing track ${trackFile.name}: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(
          ProjectImportError(message: 'Failed to import track: ${trackFile.name} - $e', fileName: trackFile.name),
        );
      }
    }

    // Store playback positions in class variable for use in _importRecordings
    _trackPlaybackPositions = trackPlaybackPositions;
  }

  Future<void> _importRecordings(Archive archive, List<ProjectImportError> errors) async {
    // Load checksums
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

    // Load metadata for file lengths and trackId -> fileName mapping
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
        // Try to clean control characters and parse again
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

    final recordingsDir = archive.files
        .where((file) => file.name.startsWith('recordings/') && file.name != 'recordings/checksums.json')
        .toList();

    final appDir = await getApplicationDocumentsDirectory();

    for (final recordingFile in recordingsDir) {
      try {
        final fileName = path.basename(recordingFile.name);
        final fileBytes = recordingFile.content as List<int>;

        // Verify checksum
        if (checksums.containsKey(fileName)) {
          final expectedChecksum = checksums[fileName]!;
          final actualChecksum = sha256.convert(fileBytes).toString();
          if (actualChecksum != expectedChecksum) {
            debugPrint(
              '[ProjectImport] Checksum mismatch for $fileName: expected $expectedChecksum, got $actualChecksum',
            );
            errors.add(ProjectImportError(message: 'Checksum mismatch', fileName: fileName));
            continue;
          }
          debugPrint('[ProjectImport] Checksum verified for $fileName');
        } else {}

        // Find track for this file
        final allTracks = _trackRepository.allTracks();
        Track? targetTrack;

        // Method 1: Use mapping from metadata.json (trackId -> fileName)
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

        // Method 2: Search by filename in track.path (if track already has path)
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

        // Method 3: If track not found, try to find by ID from filename
        // Filename may be in format {trackId}.{timestamp}.{ext} or {trackId}.{ext}
        if (targetTrack == null) {
          final nameWithoutExt = path.basenameWithoutExtension(fileName);
          for (final track in allTracks) {
            final trackIdStr = track.id.toString();
            // Check if filename starts with trackId (may be format trackId.timestamp.ext)
            if (nameWithoutExt == trackIdStr || nameWithoutExt.startsWith('$trackIdStr.')) {
              targetTrack = track;
              break;
            }
          }
        }

        if (targetTrack == null) {
          debugPrint('[ProjectImport] ERROR: Track not found for recording file $fileName');
          debugPrint('[ProjectImport] Available track IDs: ${allTracks.map((t) => t.id.toString()).join(", ")}');
          errors.add(ProjectImportError(message: 'Track not found for recording', fileName: fileName));
          continue;
        }

        // Save file with original filename from metadata if available, otherwise use filename from ZIP
        // This preserves custom filenames that may have been used in the original project
        final trackIdStr = targetTrack.id.toString();
        String newFileName;
        if (trackIdToFileName.containsKey(trackIdStr)) {
          // Use original filename from metadata
          newFileName = trackIdToFileName[trackIdStr]!;
        } else {
          // Fallback: use filename from ZIP (may be different from standard trackId.ext format)
          newFileName = fileName;
        }

        // Sanitize filename to prevent invalid characters
        // Replace invalid characters with underscore (same as in export)
        newFileName = newFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

        final newFilePath = path.join(appDir.path, newFileName);
        final savedFile = File(newFilePath);
        await savedFile.writeAsBytes(fileBytes);

        // Verify file length
        final fileSize = await savedFile.length();
        final trackId = targetTrack.id.toString();
        if (trackDurations.containsKey(trackId)) {
          final expectedSize = trackDurations[trackId]!;
          if (fileSize != expectedSize) {
            // Reset playback positions
            targetTrack.resetPlaybackStartAtPosition();
            targetTrack.resetPlaybackEndAtPosition();
            _trackRepository.save(targetTrack);

            errors.add(ProjectImportError(message: 'File length mismatch', fileName: fileName, isWarning: true));
          }
        }

        // Get playback positions from imported data (stored in _importTracks)
        // Use original values from JSON, not from track (which may have been reset)
        final trackIdForPositions = targetTrack.id.toString();
        Duration savedPlaybackStartAtPosition;
        Duration savedPlaybackEndAtPosition;
        if (_trackPlaybackPositions.containsKey(trackIdForPositions)) {
          final positions = _trackPlaybackPositions[trackIdForPositions]!;
          savedPlaybackStartAtPosition = positions['start']!;
          savedPlaybackEndAtPosition = positions['end']!;
        } else {
          // Fallback: use values from track (should not happen if import is correct)
          savedPlaybackStartAtPosition = targetTrack.playbackStartAtPosition.value;
          savedPlaybackEndAtPosition = targetTrack.playbackEndAtPosition.value;
          debugPrint(
            '[ProjectImport] WARNING: No playback positions found in imported data for track $trackIdForPositions, using values from track',
          );
        }

        // Set path in track
        // setPath() is asynchronous - sets state to processing, then ready/idle
        // We use preserveDuration: false to set duration from file (needed for correct durationAfterCut calculation)
        // We use preservePlaybackPositions: true to not overwrite positions during setPath()
        // We use clearMetadata: false to preserve audioSource, audioEncoder, sampleRate, bitRate
        // After setPath() completes, we will manually set positions from imported data
        targetTrack.setPath(
          newFilePath,
          preserveDuration: false, // Allow setPath() to set duration from file
          preservePlaybackPositions: true,
          clearMetadata: false, // Preserve metadata imported in _importTracks
        );

        // Wait for setPath() to complete (state will change from processing to ready/idle)
        // setPath() sets state to processing, then asynchronously to ready/idle
        // Check state every 100ms, maximum 5 seconds (50 attempts)
        const int maxAttempts = 50;
        const int delayMs = 100;
        int attempts = 0;

        // Wait a moment for setPath() to set state to processing
        await Future.delayed(Duration(milliseconds: 50));

        // Check if state is processing - if yes, wait for change
        // If not, setPath() may have already completed or was not called
        if (targetTrack.state.value == TrackState.processing) {
          // Wait for state change from processing to ready/idle/empty
          while (targetTrack.state.value == TrackState.processing && attempts < maxAttempts) {
            await Future.delayed(Duration(milliseconds: delayMs));
            attempts++;
            // Check if state has changed (no longer processing)
            if (targetTrack.state.value != TrackState.processing) {
              break;
            }
          }

          // If still processing after maxAttempts, it's a timeout
          if (targetTrack.state.value == TrackState.processing && attempts >= maxAttempts) {
            debugPrint(
              '[ProjectImport] WARNING: setPath() did not complete within ${maxAttempts * delayMs / 1000}s for track ${targetTrack.id.toString()}, state: ${targetTrack.state.value}',
            );
            // Add error to list, but continue import
            errors.add(
              ProjectImportError(
                message: 'Track ${targetTrack.id.toString()} did not finish loading within timeout',
                fileName: fileName,
                isWarning: true,
              ),
            );
          }
        }

        // After setPath() completes, set playback positions from imported data
        // (preservePlaybackPositions: true means setPath() doesn't set positions)
        // Make sure playbackEndAtPosition doesn't exceed duration from file
        final actualDuration = targetTrack.duration.value;
        final finalPlaybackStartAtPosition = savedPlaybackStartAtPosition;
        final finalPlaybackEndAtPosition = savedPlaybackEndAtPosition.inMilliseconds > actualDuration.inMilliseconds
            ? actualDuration
            : savedPlaybackEndAtPosition;

        targetTrack.setPlaybackStartAtPosition(finalPlaybackStartAtPosition);
        targetTrack.setPlaybackEndAtPosition(finalPlaybackEndAtPosition);

        // Save track to Hive
        _trackRepository.save(targetTrack);

        // IMPORTANT: After saving track to Hive, view uses track from cache
        // Cache loads tracks through _settings.getTrack(), which returns NEW instance from Hive
        // ValueListenableBuilder uses old instance from cache, which is not updated
        // We must reset cache to force reloading tracks from Hive
        // But that's not enough - we must also refresh view through _settings.reload()
        // (which increments version and calls notifyListeners())
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] Exception importing recording ${recordingFile.name}: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(ProjectImportError(message: 'Failed to import recording: $e', fileName: recordingFile.name));
      }
    }
  }
}
