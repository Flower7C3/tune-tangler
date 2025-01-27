import '../config/config.dart';

class TrackRow {
  static String name(int rowIndex) => Config.gridRowNames().elementAt(rowIndex);
}
