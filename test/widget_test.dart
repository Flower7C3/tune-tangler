import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tune_tangler/adapter/track_audio_source.dart';
import 'package:tune_tangler/config/keyboard.dart';
import 'package:tune_tangler/config/keyboard_layout_preset.dart';
import 'package:tune_tangler/entity/track.dart';
import 'package:tune_tangler/helper/keyboard_modifier.dart';
import 'package:tune_tangler/helper/project_io.dart';
import 'package:tune_tangler/helper/track_trim.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';

void main() {
  group('TrackAudioSource', () {
    test('values and adapter type id', () {
      expect(TrackAudioSource.values, [
        TrackAudioSource.recording,
        TrackAudioSource.file,
      ]);
      expect(TrackAudioSourceAdapter().typeId, 117);
    });
  });

  group('TrackId', () {
    test('stable id without Hive', () {
      expect(TrackId(0, 0).toList(), [0, 0]);
      expect(TrackId(1, 3).toList(), [1, 3]);
      expect(TrackId(0, 0).toString(), 'A1');
      expect(TrackId(1, 3).toString(), 'B4');
      expect(TrackId(5, 3).toString(), 'F4');
    });
  });

  group('KeyboardLayoutPreset', () {
    test('fromStored falls back to qwerty', () {
      expect(KeyboardLayoutPreset.fromStored('grid24'), KeyboardLayoutPreset.grid24);
      expect(KeyboardLayoutPreset.fromStored('nope'), KeyboardLayoutPreset.qwerty);
      expect(KeyboardLayoutPreset.fromStored(null), KeyboardLayoutPreset.qwerty);
    });

    test('row names without Hive', () {
      expect(AppKeyboardKeyMap.gridRowName(0, preset: KeyboardLayoutPreset.qwerty), 'A');
      expect(AppKeyboardKeyMap.gridRowName(5, preset: KeyboardLayoutPreset.grid24), 'F');
      expect(
        AppKeyboardKeyMap.trackKeyboardKeyName('A', 0, preset: KeyboardLayoutPreset.qwerty),
        '1',
      );
    });

    test('coerceGridInt', () {
      expect(KeyboardLayoutPreset.coerceGridInt(6), 6);
      expect(KeyboardLayoutPreset.coerceGridInt(4.9), 4);
      expect(KeyboardLayoutPreset.coerceGridInt('8'), 8);
      expect(KeyboardLayoutPreset.coerceGridInt('x'), 2);
    });
  });

  group('ProjectIo', () {
    test('strips control chars and unsafe file names', () {
      expect(ProjectIo.stripControlChars('ok\u0001name'), 'okname');
      expect(ProjectIo.sanitizeFileName('a/b:c?.wav'), 'a_b_c_.wav');
    });

    test('project zip name', () {
      final when = DateTime(2026, 9, 17, 10, 21, 5);
      expect(
        ProjectIo.projectZipName('My Band', when),
        'tune_tangler_project_My_Band_20260917_102105.zip',
      );
      expect(
        ProjectIo.projectZipName('bad/name:x', when),
        'tune_tangler_project_bad_name_x_20260917_102105.zip',
      );
      expect(
        ProjectIo.projectZipName('  ', when),
        'tune_tangler_project_20260917_102105.zip',
      );
    });
  });

  group('keyboard modifier', () {
    test('Control or Meta opens details', () {
      expect(isTrackDetailsModifierPressed({LogicalKeyboardKey.controlLeft}), isTrue);
      expect(isTrackDetailsModifierPressed({LogicalKeyboardKey.metaLeft}), isTrue);
      expect(isTrackDetailsModifierPressed({LogicalKeyboardKey.shiftLeft}), isFalse);
      expect(isTrackDetailsModifierPressed({}), isFalse);
    });
  });

  group('TrackTrim', () {
    test('clamps start and end', () {
      expect(TrackTrim.clampStart(const Duration(seconds: -1), const Duration(seconds: 10)), Duration.zero);
      expect(
        TrackTrim.clampStart(const Duration(seconds: 12), const Duration(seconds: 10)),
        const Duration(seconds: 10),
      );
      expect(
        TrackTrim.clampEnd(const Duration(seconds: 3), const Duration(seconds: 5), const Duration(seconds: 20)),
        const Duration(seconds: 5),
      );
      expect(
        TrackTrim.clampEnd(const Duration(seconds: 30), const Duration(seconds: 5), const Duration(seconds: 20)),
        const Duration(seconds: 20),
      );
    });
  });

  group('project ZIP structure', () {
    Archive zipOf(Map<String, String> files) {
      final archive = Archive();
      files.forEach((name, body) {
        final bytes = utf8.encode(body);
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
      });
      return archive;
    }

    test('reports missing required files', () {
      expect(
        ProjectIo.missingArchiveFiles(zipOf({'tracks/A1.json': '{}'}).files.map((f) => f.name)),
        [ProjectIo.metadataPath, ProjectIo.gridSettingsPath],
      );
      expect(
        ProjectIo.missingArchiveFiles(
          zipOf({
            ProjectIo.metadataPath: '{}',
            ProjectIo.gridSettingsPath: '{}',
          }).files.map((f) => f.name),
        ),
        isEmpty,
      );
    });

    test('metadata and grid keys', () {
      expect(
        ProjectIo.missingKeys({'version': '1'}, ProjectIo.requiredMetadataKeys),
        ['gridSize', 'tracks'],
      );
      expect(
        ProjectIo.missingKeys({
          'gridRowsAmount': 6,
          'gridColsAmount': 4,
        }, ProjectIo.requiredGridKeys),
        isEmpty,
      );
      expect(ProjectIo.isValidGridSize(6, 4), isTrue);
      expect(ProjectIo.isValidGridSize(0, 4), isFalse);
      expect(ProjectIo.isValidGridSize(null, 4), isFalse);
    });
  });

  group('help text scale', () {
    test('clamps large system scale', () {
      final scaled = UIHelper.helpTextScaler(const TextScaler.linear(2.5));
      expect(scaled.scale(10), 16);
      expect(UIHelper.helpTextScaler(const TextScaler.linear(0.5)).scale(10), 10);
    });
  });

  group('track swap states', () {
    test('blocks recording, playing, processing', () {
      expect(TrackRepository.canSwapTrackStates(TrackState.idle, TrackState.empty), isTrue);
      expect(TrackRepository.canSwapTrackStates(TrackState.paused, TrackState.idle), isTrue);
      expect(TrackRepository.canSwapTrackStates(TrackState.recording, TrackState.idle), isFalse);
      expect(TrackRepository.canSwapTrackStates(TrackState.idle, TrackState.playing), isFalse);
      expect(TrackRepository.canSwapTrackStates(TrackState.processing, TrackState.empty), isFalse);
    });
  });
}
