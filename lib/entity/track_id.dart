import '../config/keyboard.dart';
import 'track_row.dart';

class TrackId {
  final int _rowIndex;
  final int _colIndex;

  TrackId(this._rowIndex, this._colIndex);

  /// Stable Hive / export id (`A1`, `B2`, …). Both keyboard layouts use A–H
  /// row letters, so this must not read Hive.
  @override
  String toString() =>
      '${String.fromCharCode(0x41 + _rowIndex)}${_colIndex + 1}';

  List<int> toList() => [_rowIndex, _colIndex];

  String get keyboardKey => AppKeyboardKeyMap.trackKeyboardKeyName(
    TrackRow.name(_rowIndex),
    _colIndex,
  );
}
