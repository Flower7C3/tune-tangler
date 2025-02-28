import 'package:flutter/services.dart';

class AppKeyboardKeyMap {
  static final Map<String, Map<String, String>> _keyboardKeysRows = {
    'A': {
      '1': _keyboardKeyID([LogicalKeyboardKey.digit1]),
      '2': _keyboardKeyID([LogicalKeyboardKey.digit2]),
      '3': _keyboardKeyID([LogicalKeyboardKey.digit3]),
      '4': _keyboardKeyID([LogicalKeyboardKey.digit4]),
      '5': _keyboardKeyID([LogicalKeyboardKey.digit5]),
      '6': _keyboardKeyID([LogicalKeyboardKey.digit6]),
      '7': _keyboardKeyID([LogicalKeyboardKey.digit7]),
      '8': _keyboardKeyID([LogicalKeyboardKey.digit8]),
      '9': _keyboardKeyID([LogicalKeyboardKey.digit9]),
      '0': _keyboardKeyID([LogicalKeyboardKey.digit0]),
    },
    'B': {
      'q': _keyboardKeyID([LogicalKeyboardKey.keyQ]),
      'w': _keyboardKeyID([LogicalKeyboardKey.keyW]),
      'e': _keyboardKeyID([LogicalKeyboardKey.keyE]),
      'r': _keyboardKeyID([LogicalKeyboardKey.keyR]),
      't': _keyboardKeyID([LogicalKeyboardKey.keyT]),
      'y': _keyboardKeyID([LogicalKeyboardKey.keyY]),
      'u': _keyboardKeyID([LogicalKeyboardKey.keyU]),
      'i': _keyboardKeyID([LogicalKeyboardKey.keyI]),
      'o': _keyboardKeyID([LogicalKeyboardKey.keyO]),
      'p': _keyboardKeyID([LogicalKeyboardKey.keyP]),
    },
    'C': {
      'a': _keyboardKeyID([LogicalKeyboardKey.keyA]),
      's': _keyboardKeyID([LogicalKeyboardKey.keyS]),
      'd': _keyboardKeyID([LogicalKeyboardKey.keyD]),
      'f': _keyboardKeyID([LogicalKeyboardKey.keyF]),
      'g': _keyboardKeyID([LogicalKeyboardKey.keyG]),
      'h': _keyboardKeyID([LogicalKeyboardKey.keyH]),
      'j': _keyboardKeyID([LogicalKeyboardKey.keyJ]),
      'k': _keyboardKeyID([LogicalKeyboardKey.keyK]),
      'l': _keyboardKeyID([LogicalKeyboardKey.keyL]),
      ';': _keyboardKeyID([LogicalKeyboardKey.semicolon]),
    },
    'D': {
      'z': _keyboardKeyID([LogicalKeyboardKey.keyZ]),
      'x': _keyboardKeyID([LogicalKeyboardKey.keyX]),
      'c': _keyboardKeyID([LogicalKeyboardKey.keyC]),
      'v': _keyboardKeyID([LogicalKeyboardKey.keyV]),
      'b': _keyboardKeyID([LogicalKeyboardKey.keyB]),
      'n': _keyboardKeyID([LogicalKeyboardKey.keyN]),
      'm': _keyboardKeyID([LogicalKeyboardKey.keyM]),
      '.': _keyboardKeyID([LogicalKeyboardKey.period]),
      ',': _keyboardKeyID([LogicalKeyboardKey.comma]),
      '/': _keyboardKeyID([LogicalKeyboardKey.slash]),
    },
    'E': {
      '!': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit1]),
      '@': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit2]),
      '#': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit3]),
      '\$': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit4]),
      '%': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit5]),
      '^': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit6]),
      '&': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit7]),
      '*': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit8]),
      '(': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit9]),
      ')': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.digit0]),
    },
    'F': {
      'Q': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyQ]),
      'W': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyW]),
      'E': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyE]),
      'R': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR]),
      'T': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyT]),
      'Y': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyY]),
      'U': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyU]),
      'I': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyI]),
      'O': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyO]),
      'P': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyP]),
    },
    'G': {
      'A': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyA]),
      'S': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyS]),
      'D': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyD]),
      'F': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyF]),
      'G': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyG]),
      'H': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyH]),
      'J': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyJ]),
      'K': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK]),
      'L': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyL]),
      ':': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.semicolon]),
    },
    'H': {
      'Z': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ]),
      'X': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyX]),
      'C': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyC]),
      'V': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV]),
      'B': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyB]),
      'N': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyN]),
      'M': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.keyM]),
      '<': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.period]),
      '>': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.comma]),
      '?': _keyboardKeyID([LogicalKeyboardKey.shift, LogicalKeyboardKey.slash]),
    },
  };

  static String trackKeyboardKeyName(String rowName, int colIndex) => _keyboardKeysRows[rowName]?.keys.elementAt(colIndex) ?? '';

  static Iterable<String> gridRowNames() => _keyboardKeysRows.keys;

  static String gridRowName(int position) => gridRowNames().elementAt(position);

  static Iterable<String> keyboardKeyNames() {
    var items = <String>[];
    _keyboardKeysRows.forEach((row, keys) => items.addAll(keys.keys));
    return items.toList();
  }

  static String keyboardKeyName(int position) => keyboardKeyNames().elementAt(position);

  static Map<String, String> _keyboardKeys() {
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
    String keyId = AppKeyboardKeyMap._keyboardKeyID(keys);

    String keyName = AppKeyboardKeyMap._keyboardKeys()
        .entries
        .firstWhere((element) => (element.value == keyId), orElse: () => MapEntry('Unknown', ''))
        .key
        .toString();
    if (keyName == 'Unknown') {
      return null;
    }
    return keyName;
  }

  static String _keyboardKeyID(List<LogicalKeyboardKey> keys) {
    List label = <String>[];
    for (var key in keys) {
      label.add(key.keyLabel.toString());
    }
    return label.toString();
  }
}
