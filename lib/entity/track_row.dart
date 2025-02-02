import 'package:flutter/cupertino.dart';
import 'package:tune_tangler/entity/track.dart';

import '../config/keyboard.dart';

class TrackRow {
  static String name(int rowIndex) => AppKeyboardKeyMap.gridRowNames().elementAt(rowIndex);
}

class TracksCollection {
  Map<String, Set<Track>> _collections = {};

  String _allKeyName() => 'all';

  String _rowKeyName(int rowIndex) => 'row_${rowIndex.toString()}';

  void _add(String name, Track track) {
    if (!_collections.containsKey(name)) {
      _collections[name] = {};
    }
    _collections[name]!.add(track);
  }

  void addAll(Track track) {
    _add(_allKeyName(), track);
  }

  void addRow(int rowIndex, Track track) {
    _add(_rowKeyName(rowIndex), track);
  }

  Set<Track> _get(String name) => _collections[name] ?? {};

  Set<Track> all() => _get(_allKeyName());

  Set<Track> row(int rowIndex) => _get(_rowKeyName(rowIndex));

  void reset() {
    _collections = {};
  }
}
