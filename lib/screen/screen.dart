import '../config/config.dart';

abstract interface class ScreenInterface {
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;

  const ScreenInterface({required this.settingsGet, required this.settingsSet});
}
