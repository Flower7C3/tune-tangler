import 'package:tune_tangler/entity/track.dart';

import '../config/fields.dart';
import '../config/keyboard.dart';

class TrackRow {
  static String name(int rowIndex) => AppKeyboardKeyMap.gridRowNames().elementAt(rowIndex);
}

class TracksCollection {
  final dynamic Function(dynamic key, {AppConfigSpace space, dynamic defaultValue}) _settingsGet;

  late Map<String, Set<Track>> _collections;

  TracksCollection(this._settingsGet) {
    reset();
  }

  void reset() => _collections = {};

  Set<Track> all() => _lazyLoadCollection(-1);

  Set<Track> row(int rowIndex) => _lazyLoadCollection(rowIndex);

  Set<Track> _lazyLoadCollection(int rowIndex) {
    String name = rowIndex < 0 ? 'all' : TrackRow.name(rowIndex);
    if (!_collections.containsKey(name) || _collections[name]!.isEmpty) {
      int colsAmount = _settingsGet(AppConfigFieldKey.gridColsAmount);
      if (rowIndex < 0) {
        int rowsAmount = _settingsGet(AppConfigFieldKey.gridRowsAmount);
        for (int rowIndex = 0; rowIndex < rowsAmount; rowIndex++) {
          _lazyLoadRow(name, rowIndex, colsAmount);
        }
      } else {
        _lazyLoadRow(name, rowIndex, colsAmount);
      }
    }
    return _collections[name]!;
  }

  void _lazyLoadRow(String name, int rowIndex, int colsAmount) {
    for (int columnIndex = 0; columnIndex < colsAmount; columnIndex++) {
      _lazyLoadTrack(name, rowIndex, columnIndex);
    }
  }

  void _lazyLoadTrack(String name, int rowIndex, int columnIndex) {
    String trackId = Track.buildId(rowIndex, columnIndex);
    Track track = _settingsGet(trackId, space: AppConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));

    if (!_collections.containsKey(name)) {
      _collections[name] = {};
    }
    _collections[name]!.add(track);
  }
}
