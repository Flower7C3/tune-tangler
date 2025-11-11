import 'dart:io';

import 'package:tune_tangler/entity/track.dart';
import 'package:tune_tangler/src/generated/app_localizations.dart';
import 'package:tune_tangler/src/warnings/audio_warning.dart';

/// Serwis sprawdzający jakość audio w ścieżkach
class AudioQualityChecker {
  /// Sprawdza ścieżkę pod kątem potencjalnych problemów
  static List<AudioWarning> checkTrack(Track track, AppLocalizations trans) {
    List<AudioWarning> warnings = [];

    // Sprawdź rozmiar pliku
    if (track.path != null) {
      final file = File(track.path!);
      if (file.existsSync()) {
        final sizeInMB = file.lengthSync() / (1024 * 1024);

        if (sizeInMB > 100) {
          warnings.add(
            AudioWarning(
              type: WarningType.fileSize,
              message: trans.audioWarningFileSizeVeryLarge(
                sizeInMB.toStringAsFixed(1),
              ),
              severity: WarningSeverity.high,
              suggestion: trans.audioWarningSuggestionCompress,
            ),
          );
        } else if (sizeInMB > 50) {
          warnings.add(
            AudioWarning(
              type: WarningType.fileSize,
              message: trans.audioWarningFileSizeLarge(
                sizeInMB.toStringAsFixed(1),
              ),
              severity: WarningSeverity.medium,
              suggestion: trans.audioWarningSuggestionPerformance,
            ),
          );
        }
      } else {
        warnings.add(
          AudioWarning(
            type: WarningType.fileCorruption,
            message: trans.audioWarningFileNotExists,
            severity: WarningSeverity.high,
            suggestion: trans.audioWarningSuggestionCheckFile,
          ),
        );
      }
    }

    // Sprawdź długość nagrania
    if (track.duration.value.inMinutes > 10) {
      warnings.add(
        AudioWarning(
          type: WarningType.duration,
          message: trans.audioWarningDurationLong(
            track.duration.value.inMinutes.toString(),
          ),
          severity: WarningSeverity.medium,
          suggestion: trans.audioWarningSuggestionInterfaceDelays,
        ),
      );
    } else if (track.duration.value.inMinutes > 5) {
      warnings.add(
        AudioWarning(
          type: WarningType.duration,
          message: trans.audioWarningDurationMedium(
            track.duration.value.inMinutes.toString(),
          ),
          severity: WarningSeverity.low,
          suggestion: trans.audioWarningSuggestionMultiTrackPerformance,
        ),
      );
    }

    // Sprawdź częstotliwość próbkowania
    if (track.sampleRate != null) {
      if (track.sampleRate! != 44100 && track.sampleRate! != 48000) {
        warnings.add(
          AudioWarning(
            type: WarningType.sampleRate,
            message: trans.audioWarningSampleRateNonStandard(
              track.sampleRate.toString(),
            ),
            severity: WarningSeverity.low,
            suggestion: trans.audioWarningSuggestionCompatibility,
          ),
        );
      }
    }

    // Sprawdź bitrate
    if (track.bitRate != null) {
      if (track.bitRate! > 320) {
        warnings.add(
          AudioWarning(
            type: WarningType.bitRate,
            message: trans.audioWarningBitRateHigh(track.bitRate.toString()),
            severity: WarningSeverity.low,
            suggestion: trans.audioWarningSuggestionFileSize,
          ),
        );
      } else if (track.bitRate! < 128) {
        warnings.add(
          AudioWarning(
            type: WarningType.bitRate,
            message: trans.audioWarningBitRateLow(track.bitRate.toString()),
            severity: WarningSeverity.medium,
            suggestion: trans.audioWarningSuggestionAudioQuality,
          ),
        );
      }
    }

    // Sprawdź kanały
    if (track.audioSource != null) {
      // Dla mikrofonu stereo może być problemem
      if (track.audioSource!.index == 0) {
        // microphone
        warnings.add(
          AudioWarning(
            type: WarningType.channels,
            message: trans.audioWarningChannelsMicrophone,
            severity: WarningSeverity.low,
            suggestion: trans.audioWarningSuggestionChannelSettings,
          ),
        );
      }
    }

    return warnings;
  }

  /// Sprawdza wszystkie ścieżki w liście
  static Map<Track, List<AudioWarning>> checkAllTracks(
    List<Track> tracks,
    AppLocalizations trans,
  ) {
    Map<Track, List<AudioWarning>> results = {};

    for (final track in tracks) {
      results[track] = checkTrack(track, trans);
    }

    return results;
  }

  /// Zwraca liczbę ostrzeżeń o wysokiej ważności
  static int getHighSeverityCount(List<AudioWarning> warnings) {
    return warnings.where((w) => w.severity == WarningSeverity.high).length;
  }

  /// Zwraca liczbę ostrzeżeń o średniej ważności
  static int getMediumSeverityCount(List<AudioWarning> warnings) {
    return warnings.where((w) => w.severity == WarningSeverity.medium).length;
  }

  /// Zwraca liczbę ostrzeżeń o niskiej ważności
  static int getLowSeverityCount(List<AudioWarning> warnings) {
    return warnings.where((w) => w.severity == WarningSeverity.low).length;
  }
}
