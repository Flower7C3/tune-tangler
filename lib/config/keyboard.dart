import 'package:flutter/services.dart';

class AppKeyboardKeyMap {
  static final Map<String, Map<String, String>> _keyboardKeysRows = {
    'A': {
      '1': keyboardKeyID([LogicalKeyboardKey.digit1]),
      '2': keyboardKeyID([LogicalKeyboardKey.digit2]),
      '3': keyboardKeyID([LogicalKeyboardKey.digit3]),
      '4': keyboardKeyID([LogicalKeyboardKey.digit4]),
      '5': keyboardKeyID([LogicalKeyboardKey.digit5]),
      '6': keyboardKeyID([LogicalKeyboardKey.digit6]),
      '7': keyboardKeyID([LogicalKeyboardKey.digit7]),
      '8': keyboardKeyID([LogicalKeyboardKey.digit8]),
      '9': keyboardKeyID([LogicalKeyboardKey.digit9]),
      '0': keyboardKeyID([LogicalKeyboardKey.digit0]),
    },
    'B': {
      'q': keyboardKeyID([LogicalKeyboardKey.keyQ]),
      'w': keyboardKeyID([LogicalKeyboardKey.keyW]),
      'e': keyboardKeyID([LogicalKeyboardKey.keyE]),
      'r': keyboardKeyID([LogicalKeyboardKey.keyR]),
      't': keyboardKeyID([LogicalKeyboardKey.keyT]),
      'y': keyboardKeyID([LogicalKeyboardKey.keyY]),
      'u': keyboardKeyID([LogicalKeyboardKey.keyU]),
      'i': keyboardKeyID([LogicalKeyboardKey.keyI]),
      'o': keyboardKeyID([LogicalKeyboardKey.keyO]),
      'p': keyboardKeyID([LogicalKeyboardKey.keyP]),
    },
    'C': {
      'a': keyboardKeyID([LogicalKeyboardKey.keyA]),
      's': keyboardKeyID([LogicalKeyboardKey.keyS]),
      'd': keyboardKeyID([LogicalKeyboardKey.keyD]),
      'f': keyboardKeyID([LogicalKeyboardKey.keyF]),
      'g': keyboardKeyID([LogicalKeyboardKey.keyG]),
      'h': keyboardKeyID([LogicalKeyboardKey.keyH]),
      'j': keyboardKeyID([LogicalKeyboardKey.keyJ]),
      'k': keyboardKeyID([LogicalKeyboardKey.keyK]),
      'l': keyboardKeyID([LogicalKeyboardKey.keyL]),
      ';': keyboardKeyID([LogicalKeyboardKey.semicolon]),
    },
    'D': {
      'z': keyboardKeyID([LogicalKeyboardKey.keyZ]),
      'x': keyboardKeyID([LogicalKeyboardKey.keyX]),
      'c': keyboardKeyID([LogicalKeyboardKey.keyC]),
      'v': keyboardKeyID([LogicalKeyboardKey.keyV]),
      'b': keyboardKeyID([LogicalKeyboardKey.keyB]),
      'n': keyboardKeyID([LogicalKeyboardKey.keyN]),
      'm': keyboardKeyID([LogicalKeyboardKey.keyM]),
      '.': keyboardKeyID([LogicalKeyboardKey.period]),
      ',': keyboardKeyID([LogicalKeyboardKey.comma]),
      '/': keyboardKeyID([LogicalKeyboardKey.slash]),
    },
    'E': {
      '!': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit1]),
      '@': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit2]),
      '#': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit3]),
      '\$': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit4]),
      '%': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit5]),
      '^': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit6]),
      '&': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit7]),
      '*': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit8]),
      '(': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit9]),
      ')': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit0]),
    },
    'F': {
      'Q': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyQ]),
      'W': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyW]),
      'E': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyE]),
      'R': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR]),
      'T': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyT]),
      'Y': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyY]),
      'U': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyU]),
      'I': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyI]),
      'O': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyO]),
      'P': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyP]),
    },
    'G': {
      'A': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyA]),
      'S': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyS]),
      'D': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyD]),
      'F': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyF]),
      'G': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyG]),
      'H': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyH]),
      'J': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyJ]),
      'K': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK]),
      'L': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyL]),
      ':': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.semicolon]),
    },
    'H': {
      'Z': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ]),
      'X': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyX]),
      'C': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyC]),
      'V': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV]),
      'B': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyB]),
      'N': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyN]),
      'M': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyM]),
      '<': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.period]),
      '>': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.comma]),
      '?': keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.slash]),
    },
  };

  static String trackKeyboardKeyName(String rowName, int colIndex) => _keyboardKeysRows[rowName]?.keys.elementAt(colIndex) ?? '';

  static Iterable<String> gridRowNames() => _keyboardKeysRows.keys;

  static Iterable<String> keyboardKeyNames() {
    var items = <String>[];
    _keyboardKeysRows.forEach((row, keys) => items.addAll(keys.keys));
    return items;
  }

  static Iterable<String> keyboardKeyCodes() {
    var items = <String>[];
    _keyboardKeysRows.forEach((row, keys) => items.addAll(keys.values));
    return items;
  }

  static String keyboardKeyID(List<LogicalKeyboardKey> keys) {
    List label = <String>[];
    for (var key in keys) {
      label.add(key.keyLabel.toString());
    }
    return label.toString();
  }

  static Map<String, String> keyboardKeys() {
    var keyboardKeys = <String, String>{};
    _keyboardKeysRows.forEach((row, keys) => keyboardKeys.addEntries(keys.entries));
    return keyboardKeys;
  }

  static String? findPressedKeyName(KeyDownEvent event) {
    List<LogicalKeyboardKey> keys = [];
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight)) {
      keys.add(LogicalKeyboardKey.shift);
    }
    keys.add(event.logicalKey);
    String keyId = AppKeyboardKeyMap.keyboardKeyID(keys);

    String keyName = AppKeyboardKeyMap.keyboardKeys()
        .entries
        .firstWhere((element) => (element.value == keyId), orElse: () => MapEntry('Unknown', ''))
        .key
        .toString();
    if (keyName == 'Unknown') {
      return null;
    }
    return keyName;
  }
}
