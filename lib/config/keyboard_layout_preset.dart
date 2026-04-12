/// Physical keyboard / shortcut layout presets.
enum KeyboardLayoutPreset {
  qwerty,
  grid24;

  static const int grid24Rows = 6;
  static const int grid24Cols = 4;

  static KeyboardLayoutPreset fromStored(Object? raw) {
    final name = raw?.toString();
    return KeyboardLayoutPreset.values.firstWhere(
      (e) => e.name == name,
      orElse: () => KeyboardLayoutPreset.qwerty,
    );
  }

  /// Hive / JSON may store grid dimensions as [double] or other [num].
  static int coerceGridInt(Object? value, {int fallback = 2}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    return fallback;
  }
}
