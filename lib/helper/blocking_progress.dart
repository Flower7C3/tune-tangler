import 'package:flutter/material.dart';

/// Blocking modal used by export, import, and processed share.
class BlockingProgress {
  BlockingProgress._();

  static Future<void> yieldForPaint() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 32));
  }

  static void close(BuildContext? dialogContext, {String? logTag}) {
    if (dialogContext == null || !dialogContext.mounted) return;
    try {
      final nav = Navigator.of(dialogContext, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    } catch (e) {
      if (logTag != null) {
        debugPrint('[$logTag] Could not close dialog: $e');
      }
    }
  }

  static void show({
    required BuildContext context,
    required WidgetBuilder builder,
    required void Function(BuildContext dialogContext) onContext,
  }) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        onContext(dialogContext);
        return builder(dialogContext);
      },
    );
  }

  static Widget determinate({
    required double value,
    required String label,
    List<Widget>? actions,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final v = value.clamp(0.0, 1.0);
        final pct = (v * 100).round().clamp(0, 100);
        final theme = Theme.of(context);
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: v <= 0 ? 0.04 : v,
                        child: ColoredBox(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$pct%',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          actions: actions,
        );
      },
    );
  }

  static Widget indeterminate({required String label}) {
    return Builder(
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}
