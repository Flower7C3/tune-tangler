import '../config/keyboard.dart';
import '../config/keyboard_layout_preset.dart';

class TrackRow {
  static String name(int rowIndex, {KeyboardLayoutPreset? preset}) =>
      AppKeyboardKeyMap.gridRowName(rowIndex, preset: preset);
}
