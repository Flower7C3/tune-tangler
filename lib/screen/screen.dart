import 'package:record/record.dart';

import '../config/fields.dart';
import '../entity/track_row.dart';

abstract interface class ScreenInterface {
  final dynamic Function(dynamic key, {AppConfigSpace space, dynamic defaultValue}) settingsGet;
  final void Function(dynamic key, dynamic value, {AppConfigSpace space, bool updateState}) settingsSet;
  final AudioRecorder audioRecorder;
  final TracksCollection tracksList;

  ScreenInterface({
    required this.settingsGet,
    required this.settingsSet,
    required this.audioRecorder,
    required this.tracksList,
  });
}
