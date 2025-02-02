import 'package:record/record.dart';

import '../config/config.dart';
import '../entity/track_row.dart';

abstract interface class ScreenInterface {
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;
  final AudioRecorder audioRecorder;
  final TracksCollection tracksList;

  ScreenInterface({
    required this.settingsGet,
    required this.settingsSet,
    required this.audioRecorder,
    required this.tracksList,
  });
}
