import '../config/config.dart';

class TrackRow {
  static String name(int rowIndex) => AppGlobalConfig.gridRowNames().elementAt(rowIndex);
}
