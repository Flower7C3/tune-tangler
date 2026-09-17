import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../helper/project_io.dart';
import '../src/generated/app_localizations.dart';
import 'project_import_error.dart';

class ProjectImportValidator {
  final AppLocalizations _trans;

  ProjectImportValidator(this._trans);

  /// Validates project before import (without modifying data)
  Future<List<ProjectImportError>> validate(String zipPath) async {
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
      final missingFiles = ProjectIo.missingArchiveFiles(archive.files.map((f) => f.name));
      if (missingFiles.isNotEmpty) {
        errors.add(
          ProjectImportError(message: _trans.projectFileMissing(missingFiles.first), fileName: missingFiles.first),
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

      final missing = ProjectIo.missingKeys(metadata, ProjectIo.requiredMetadataKeys);
      if (missing.isNotEmpty) {
        errors.add(
          ProjectImportError(
            message: _trans.projectFileStructureError('metadata.json', missing.join(', ')),
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

      final missingFields = ProjectIo.missingKeys(settings, ProjectIo.requiredGridKeys);
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

      if (!ProjectIo.isValidGridSize(rows, cols)) {
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
          metadataJson = metadataJson.replaceAll(ProjectIo.controlChars, '');
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

}
