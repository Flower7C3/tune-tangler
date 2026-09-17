import 'package:flutter/services.dart';

/// Control (Windows/Linux) or Meta/Cmd (macOS) opens track details with a shortcut.
bool isTrackDetailsModifierPressed([Set<LogicalKeyboardKey>? pressed]) {
  final keys = pressed ?? HardwareKeyboard.instance.logicalKeysPressed;
  return keys.contains(LogicalKeyboardKey.controlLeft) ||
      keys.contains(LogicalKeyboardKey.controlRight) ||
      keys.contains(LogicalKeyboardKey.control) ||
      keys.contains(LogicalKeyboardKey.metaLeft) ||
      keys.contains(LogicalKeyboardKey.metaRight) ||
      keys.contains(LogicalKeyboardKey.meta);
}
