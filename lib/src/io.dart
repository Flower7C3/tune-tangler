import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tune_tangler/src/track.dart';

import 'config.dart';

class IO {
  BuildContext context;

  IO(this.context);

  Row footerInfo(icon, text) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 12), Text(text, style: TextStyle(fontSize: 12))]);

  PopupMenuItem<String> menuItem(String value, String text, IconData icon, {bool? checked}) {
    var menu = <Widget>[];
    menu.add(Row(children: [Icon(icon, size: 16), Text(text, style: TextStyle(fontSize: 16))]));
    if (checked != null) {
      menu.add(Icon((checked == true) ? Symbols.check_box_rounded : Symbols.square_rounded, size: 16));
    }
    return PopupMenuItem(value: value, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: menu.toList()));
  }

  aboutDialog(
    PackageInfo packageInfo,
    List<Widget> content, {
    applicationName,
    applicationVersion,
    applicationLegalese,
    applicationIcon,
  }) {
    showAboutDialog(
        context: context,
        applicationName: applicationName ?? packageInfo.appName,
        applicationVersion: applicationVersion ?? packageInfo.version,
        applicationLegalese: applicationLegalese,
        applicationIcon: applicationIcon ?? Icon(Icons.dashboard_customize_rounded),
        children: content.toList());
  }

  Future<void> alertDialog(IconData icon, String titleText,
      {barrierDismissible = true, Widget? contentWidget, String? contentText, actions, thenCallback}) async {
    _dialogBuilder(DialogType.alert, icon, titleText,
        contentWidget: contentWidget, contentText: contentText, actions: actions, barrierDismissible: barrierDismissible, thenCallback: thenCallback);
  }

  Future<void> listDialog(IconData icon, String titleText, {barrierDismissible = true, String? contentText, actions, thenCallback}) async =>
      _dialogBuilder(DialogType.list, icon, titleText,
          contentText: contentText, actions: actions, barrierDismissible: barrierDismissible, thenCallback: thenCallback);

  Future<void> _dialogBuilder(type, IconData icon, String titleText,
          {bool barrierDismissible = true, Widget? contentWidget, String? contentText, actions, thenCallback}) async =>
      await showDialog(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            switch (type) {
              case DialogType.alert:
                var content = <Widget>[];
                if (contentText != null) {
                  content.add(Text(contentText));
                }
                if (contentText != null && contentWidget != null) {
                  content.add(SizedBox(height: 16));
                }
                if (contentWidget != null) {
                  content.add(contentWidget);
                }
                return AlertDialog(
                    title: ListTile(
                      leading: Icon(icon),
                      title: Text(titleText),
                    ),
                    content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: content.toList()),
                    actions: actions ?? <Widget>[]);
              case DialogType.list:
                var title = <Widget>[];
                title.add(ListTile(
                  leading: Icon(icon),
                  title: Text(titleText),
                ));
                if (contentText != null) {
                  title.add(SizedBox(height: 8));
                  title.add(Text(
                    contentText,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ));
                }
                return SimpleDialog(
                    title: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: title.toList()),
                    children: actions);
              default:
                throw Exception('Dialog type not implemented.');
            }
          }).then(thenCallback ?? (result) {});

  void toast(String text, {int duration = 2, IconData? icon, Color? backgroundColor, Color? foregroundColor}) {
    var message = <Widget>[];
    if (icon != null) {
      message.add(Icon(icon, color: foregroundColor ?? Theme.of(context).colorScheme.secondary, size: 16));
      message.add(SizedBox(width: 8));
    }
    message.add(Flexible(child: Text(text, style: TextStyle(color: foregroundColor ?? Theme.of(context).colorScheme.secondary))));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        dismissDirection: DismissDirection.none,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration),
        content: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50), color: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer),
                child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: message.toList())))));
  }

  TextButton simpleButton(String text, VoidCallback? onPressed) => TextButton(onPressed: onPressed, child: Text(text));

  TextButton errorButton(String text, VoidCallback? onPressed) => TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
        foregroundColor: Theme.of(context).colorScheme.error,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
      onPressed: onPressed,
      child: Text(text));

  TextButton primaryButton(String text, VoidCallback? onPressed) => TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: onPressed,
      child: Text(text));

  TextButton secondaryButton(String text, VoidCallback? onPressed) => TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      onPressed: onPressed,
      child: Text(text));

  Switch primarySwitch(IconData icon, bool value, {onChanged}) => Switch(
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) => Icon(icon, color: Colors.white)),
        trackColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
        trackOutlineColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveThumbColor: Theme.of(context).colorScheme.primary,
        value: value,
        onChanged: onChanged ?? (bool value) {},
      );

  Widget trailingLabel(text) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(4),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(8),
          child: Text(text, style: TextStyle(color: Colors.white))));

  IconButton mediaPlayerButton(IconData icon, String tooltip, VoidCallback? onPressed, {double iconSize = 24}) => IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      icon: Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
      tooltip: tooltip);

  ElevatedButton mediaPlayerTextButton(IconData icon, String text, VoidCallback? onPressed, {double iconSize = 24}) => ElevatedButton(
      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      onPressed: onPressed,
      child: Row(children: [
        Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: iconSize)),
      ]));

  helpSection(String title, List<Widget> content) {
    var items = <Widget>[];
    items.add(Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
    items.add(SizedBox(height: 6));
    items.addAll(content);
    items.add(SizedBox(height: 16));
    return Column(children: items);
  }

  helpTrackState(TrackState state, String message) {
    return Container(
        padding: EdgeInsets.all(4),
        color: Config.trackStateBackgroundColor(context)[state],
        child: Row(children: [
          Icon(Config.trackStateIcon(context)[state], size: 12),
          SizedBox(width: 4),
          Text(message, style: TextStyle(color: Config.trackStateForegroundColor(context)[state]))
        ]));
  }
}

enum DialogType {
  alert,
  list,
}
