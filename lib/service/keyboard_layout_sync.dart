import '../config/app_config_fields.dart';
import '../config/keyboard_layout_preset.dart';
import '../wrapper/hive_service.dart';

/// Ensures persisted grid size matches the active keyboard preset (e.g. 6×4 for [grid24]).
class KeyboardLayoutSync {
  static Future<void> ensureGridMatchesPreset() async {
    if (KeyboardLayoutPreset.fromStored(
          HiveService.get(AppConfigFieldKey.keyboardLayoutPreset),
        ) !=
        KeyboardLayoutPreset.grid24) {
      return;
    }
    final rows = KeyboardLayoutPreset.coerceGridInt(HiveService.get(AppConfigFieldKey.gridRowsAmount));
    final cols = KeyboardLayoutPreset.coerceGridInt(HiveService.get(AppConfigFieldKey.gridColsAmount));
    if (rows != KeyboardLayoutPreset.grid24Rows || cols != KeyboardLayoutPreset.grid24Cols) {
      await HiveService.set(AppConfigFieldKey.gridRowsAmount, KeyboardLayoutPreset.grid24Rows);
      await HiveService.set(AppConfigFieldKey.gridColsAmount, KeyboardLayoutPreset.grid24Cols);
    }
  }
}
