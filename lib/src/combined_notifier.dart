import 'package:flutter/foundation.dart';

class CombinedNotifier extends ValueNotifier<void> {
  CombinedNotifier(List<ValueListenable> notifiers) : super(null) {
    for (var notifier in notifiers) {
      notifier.addListener(() => notifyListeners());
    }
  }
}
