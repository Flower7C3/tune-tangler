#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main(List<String> args) {
  final script = VersionUpdater();
  
  if (args.contains('--patch')) {
    script.incrementPatchVersion();
  } else if (args.contains('--build')) {
    script.incrementBuildVersion();
  } else {
    print('Usage: dart scripts/version_update.dart --patch|--build');
    print('  --patch: Increment build version only (1.2.0+1 -> 1.2.0+2)');
    print('  --build: Increment build version only (1.2.0+1 -> 1.2.0+2)');
    exit(1);
  }
}

class VersionUpdater {
  static const String pubspecPath = 'pubspec.yaml';
  
  void incrementPatchVersion() {
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      print('Error: $pubspecPath not found!');
      exit(1);
    }
    
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('version:')) {
        final currentVersion = lines[i].split(':')[1].trim();
        print('Current version: $currentVersion');
        
        final parts = currentVersion.split('+');
        if (parts.length != 2) {
          print('Error: Invalid version format. Expected: X.Y.Z+N');
          exit(1);
        }
        
        final versionOnly = parts[0];
        final build = int.parse(parts[1]);
        
        final newBuild = build + 1;
        final newVersion = '$versionOnly+$newBuild';
        
        lines[i] = '  version: $newVersion';
        print('Version updated to: $newVersion (build: $build->$newBuild)');
        break;
      }
    }
    
    file.writeAsStringSync(lines.join('\n'));
  }
  
  void incrementBuildVersion() {
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      print('Error: $pubspecPath not found!');
      exit(1);
    }
    
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('version:')) {
        final currentVersion = lines[i].split(':')[1].trim();
        print('Current version: $currentVersion');
        
        final parts = currentVersion.split('+');
        if (parts.length != 2) {
          print('Error: Invalid version format. Expected: X.Y.Z+N');
          exit(1);
        }
        
        final version = parts[0];
        final build = int.parse(parts[1]);
        
        final newBuild = build + 1;
        final newVersion = '$version+$newBuild';
        
        lines[i] = '  version: $newVersion';
        print('Build version updated to: $newVersion');
        break;
      }
    }
    
    file.writeAsStringSync(lines.join('\n'));
  }
}
