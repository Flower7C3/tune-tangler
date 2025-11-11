import 'package:flutter/material.dart';
import 'package:tune_tangler/config/app_icon.dart';

/// Typ ostrzeżenia audio
enum WarningType {
  fileSize('Rozmiar pliku'),
  duration('Długość nagrania'),
  sampleRate('Częstotliwość próbkowania'),
  bitRate('Bitrate'),
  channels('Kanały audio'),
  fileCorruption('Uszkodzenie pliku');

  const WarningType(this.displayName);
  final String displayName;
}

/// Poziom ważności ostrzeżenia
enum WarningSeverity {
  low('Niski', Colors.blue),
  medium('Średni', Colors.orange),
  high('Wysoki', Colors.red);

  const WarningSeverity(this.displayName, this.color);
  final String displayName;
  final Color color;
}

/// Ostrzeżenie dotyczące jakości audio
class AudioWarning {
  final WarningType type;
  final String message;
  final WarningSeverity severity;
  final String? suggestion;
  final DateTime timestamp;

  AudioWarning({
    required this.type,
    required this.message,
    required this.severity,
    this.suggestion,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AudioWarning(type: $type, message: $message, severity: $severity)';
  }

  /// Zwraca kolor ostrzeżenia na podstawie ważności
  Color getWarningColor() {
    switch (severity) {
      case WarningSeverity.high:
        return Colors.red[800]!;
      case WarningSeverity.medium:
        return Colors.orange[800]!;
      case WarningSeverity.low:
        return Colors.blue[800]!;
    }
  }

  /// Zwraca ikonę ostrzeżenia na podstawie typu
  IconData getWarningTypeIcon() {
    switch (type) {
      case WarningType.fileSize:
        return AppIcon.trackAudioSourceImported;
      case WarningType.duration:
        return AppIcon.trackDuration;
      case WarningType.sampleRate:
        return AppIcon.recordingSampleRate;
      case WarningType.bitRate:
        return AppIcon.recordingBitRate;
      case WarningType.channels:
        return AppIcon.recordingAudioMode;
      case WarningType.fileCorruption:
        return AppIcon.exception;
    }
  }

  /// Zwraca kolor dla listy ostrzeżeń na podstawie najwyższej ważności
  static Color getWarningColorForList(List<AudioWarning> warnings) {
    if (warnings.any((w) => w.severity == WarningSeverity.high)) {
      return Colors.red[800]!;
    } else if (warnings.any((w) => w.severity == WarningSeverity.medium)) {
      return Colors.orange[800]!;
    } else {
      return Colors.blue[800]!;
    }
  }
}
