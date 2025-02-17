import 'dart:io';

void main(List<String> arguments) {
  bool updatePatch = false;
  bool updateBuildNumber = false;

  for (var arg in arguments) {
    switch (arg) {
      case '--patch':
        updatePatch = true;
        break;
      case '--build':
        updateBuildNumber = true;
        break;
    }
  }

  final file = File('pubspec.yaml');
  final lines = file.readAsLinesSync();

  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('version:')) {
      continue;
    }
    final parts = lines[i].split(':');
    if (parts.length != 2) {
      continue;
    }
    List<String> versionParts = parts[1].split('+');
    List<String> versionNumbers = versionParts[0].split('.');
    int? major = int.tryParse(versionNumbers[0]);
    int? minor = int.tryParse(versionNumbers[1]);
    int? patch = int.tryParse(versionNumbers[2]);
    int? buildNumber = int.tryParse(versionParts[1]);
    if (patch == null || buildNumber == null) {
      continue;
    }
    if (updatePatch) {
      patch++;
    }
    if (updateBuildNumber) {
      buildNumber++;
    }
    final newVersion = 'version: $major.$minor.$patch+$buildNumber';
    lines[i] = newVersion;

    break;
  }

  file.writeAsStringSync(lines.join('\n'));
}
