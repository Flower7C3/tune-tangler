class ProjectIo {
  static final RegExp controlChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]');
  static final RegExp unsafeFileChars = RegExp(r'[<>:"/\\|?*]');

  static String stripControlChars(String value) =>
      value.replaceAll(controlChars, '');

  static String sanitizeFileName(String value) =>
      value.replaceAll(unsafeFileChars, '_');

  static String projectZipName(String? projectName, DateTime now) {
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    var namePart = '';
    if (projectName != null && projectName.trim().isNotEmpty) {
      namePart = sanitizeFileName(projectName.trim()).replaceAll(' ', '_');
      namePart = '_$namePart';
    }

    return 'tune_tangler_project${namePart}_$dateStr.zip';
  }

  static const metadataPath = 'metadata.json';
  static const gridSettingsPath = 'settings/grid_settings.json';
  static const requiredMetadataKeys = ['version', 'gridSize', 'tracks'];
  static const requiredGridKeys = ['gridRowsAmount', 'gridColsAmount'];

  static List<String> missingArchiveFiles(Iterable<String> names) {
    final set = names.toSet();
    return [
      if (!set.contains(metadataPath)) metadataPath,
      if (!set.contains(gridSettingsPath)) gridSettingsPath,
    ];
  }

  static List<String> missingKeys(Map<String, dynamic> map, List<String> required) =>
      required.where((key) => !map.containsKey(key)).toList();

  static bool isValidGridSize(int? rows, int? cols) =>
      rows != null && cols != null && rows >= 1 && cols >= 1;
}
