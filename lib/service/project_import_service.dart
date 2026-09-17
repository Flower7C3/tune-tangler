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
import '../helper/project_io.dart';
import '../helper/track_trim.dart';
import '../repository/track_repository.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';
import 'project_import_error.dart';
import 'project_import_validator.dart';

export 'project_import_error.dart';

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
              final cleanName = ProjectIo.stripControlChars(originalName);
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
        String cleanedJson = metadataJson.replaceAll(ProjectIo.controlChars, '');
        metadata = jsonDecode(cleanedJson) as Map<String, dynamic>;

        // Clean names in tracks
        if (metadata.containsKey('tracks') && metadata['tracks'] is List) {
          final tracks = metadata['tracks'] as List<dynamic>;
          for (var track in tracks) {
            if (track is Map<String, dynamic> && track.containsKey('name')) {
              final originalName = track['name'] as String?;
              if (originalName != null) {
                final cleanName = ProjectIo.stripControlChars(originalName);
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

  Future<List<ProjectImportError>> validateProject(String zipPath) =>
      ProjectImportValidator(_trans).validate(zipPath);

  /// Imports project from ZIP file (only after successful validation)
  Future<List<ProjectImportError>> importProject(
    String zipPath, {
    void Function(double progress)? onProgress,
  }) async {
    void report(double p) => onProgress?.call(p.clamp(0.0, 1.0));

    final errors = <ProjectImportError>[];

    try {
      report(0.02);
      final file = File(zipPath);
      final bytes = await file.readAsBytes();
      report(0.08);
      final archive = ZipDecoder().decodeBytes(bytes);
      report(0.12);

      // 1. Delete all current recordings BEFORE importing tracks
      // (to avoid conflicts with existing tracks)
      _trackRepository.deleteTracksRecordings(_trackRepository.allTracks());
      report(0.16);

      // 2. Import grid settings
      await _importGridSettings(archive);
      report(0.20);

      // 3. Reset tracks collection (cache)
      _trackRepository.resetTracksCollection();

      // 5. Import all tracks BEFORE recordings
      // (so tracks exist in repository when we assign recordings to them)
      await _importTracks(
        archive,
        errors,
        onTrackProgress: (completed, total) {
          if (total > 0) {
            report(0.20 + 0.38 * completed / total);
          }
        },
      );
      report(0.58);

      // 6. Import recordings with verification
      // (now tracks already exist, so we can find them and assign recordings to them)
      await _importRecordings(
        archive,
        errors,
        onRecordingProgress: (completed, total) {
          if (total > 0) {
            report(0.58 + 0.40 * completed / total);
          }
        },
      );
      report(1.0);
    } catch (e, stackTrace) {
      debugPrint('[ProjectImport] Exception during import: $e');
      debugPrint('[ProjectImport] Stack trace: $stackTrace');
      errors.add(ProjectImportError(message: 'Import error: $e'));
    }

    return errors;
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

  Future<void> _importTracks(
    Archive archive,
    List<ProjectImportError> errors, {
    void Function(int completed, int total)? onTrackProgress,
  }) async {
    // Map to store playback positions for each track (to be used in _importRecordings)
    final trackPlaybackPositions = <String, Map<String, Duration>>{};
    final tracksDir = archive.files
        .where((file) => file.name.startsWith('tracks/') && file.name.endsWith('.json'))
        .toList();
    final totalTracks = tracksDir.length;

    for (var i = 0; i < tracksDir.length; i++) {
      final trackFile = tracksDir[i];
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
      } finally {
        if (totalTracks > 0) {
          onTrackProgress?.call(i + 1, totalTracks);
        }
      }
    }

    // Store playback positions in class variable for use in _importRecordings
    _trackPlaybackPositions = trackPlaybackPositions;
  }

  Future<void> _importRecordings(
    Archive archive,
    List<ProjectImportError> errors, {
    void Function(int completed, int total)? onRecordingProgress,
  }) async {
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
          String cleanedJson = metadataJson.replaceAll(ProjectIo.controlChars, '');
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
    final totalRecordings = recordingsDir.length;

    final appDir = await getApplicationDocumentsDirectory();

    for (var i = 0; i < recordingsDir.length; i++) {
      final recordingFile = recordingsDir[i];
      try {
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
        newFileName = ProjectIo.sanitizeFileName(newFileName);

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
        await targetTrack.setPath(
          newFilePath,
          preserveDuration: false,
          preservePlaybackPositions: true,
          clearMetadata: false,
        );

        final actualDuration = targetTrack.duration.value;
        final finalPlaybackStartAtPosition = TrackTrim.clampStart(
          savedPlaybackStartAtPosition,
          savedPlaybackEndAtPosition,
        );
        final finalPlaybackEndAtPosition = TrackTrim.clampEnd(
          savedPlaybackEndAtPosition,
          finalPlaybackStartAtPosition,
          actualDuration,
        );

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
        } finally {
          if (totalRecordings > 0) {
            onRecordingProgress?.call(i + 1, totalRecordings);
          }
        }
      } catch (e, stackTrace) {
        debugPrint('[ProjectImport] Exception importing recording ${recordingFile.name}: $e');
        debugPrint('[ProjectImport] Stack trace: $stackTrace');
        errors.add(ProjectImportError(message: 'Failed to import recording: $e', fileName: recordingFile.name));
      }
    }
  }
}
