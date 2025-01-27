import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tune_tangler/entity/track.dart';

import '../config/menu_item.dart';
import '../config/config.dart';

enum DialogType {
  alert,
  list,
}

class UIWrapper {
  final double gridFirstColumnWidth = 40;

  final double rowButtonIconSize = 24;
  final double rowContainerPadding = 3;
  final double rowMenuIconSize = 20;
  final double rowMenuFontSize = 16;

  final double trackDetailsPadding = 32;
  final double trackDetailsTitleFontSize = 24;
  final double trackItemMargin = 4;
  final double trackItemWidth = 70;
  final double trackPadding = 4;
  final double trackBorderRadius = 10;
  final double trackButtonFontSize = 26.0;
  final double trackButtonRoundRadius = 3;
  final double trackButtonRoundSize = 18.0;
  final double trackButtonIconSize = 20.0;
  final double trackMenuIconSize = 20;
  final double trackMenuFontSize = 16;
  final double mediaPlayerIconSize = 24;
  final double mediaPlayerIconSize2x = 48;

  final double settingsTitleFontSize = 20;
  final double settingsSubtitleIconSize = 12;
  final double settingsSubtitleFontSize = 12;

  BuildContext context;

  UIWrapper(this.context);

  Row footerInfoLine(IconData icon, String text) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 12), Text(text, style: TextStyle(fontSize: 14))]);

  Row trackInfoLine(IconData icon, String text, Color foregroundColor) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 12, color: foregroundColor), Text(text, style: TextStyle(fontSize: 14))]);

  PopupMenuItem<String> topPopupMenuItem(TopMenuItem value, IconData icon, String text, {bool? checked}) {
    return PopupMenuItem(
        value: value.toString(),
        child: ListTile(
          leading: Icon(icon),
          title: Text(text),
          trailing: (checked == null) ? null : Icon((checked == true) ? Symbols.check_box_rounded : Symbols.square_rounded),
        ));
  }

  PopupMenuItem rowPopupMenuItem(dynamic value, IconData icon, String title) => PopupMenuItem<dynamic>(
      value: value,
      child: ListTile(
        leading: Icon(icon, size: rowMenuIconSize),
        title: Text(title, style: TextStyle(fontSize: rowMenuFontSize)),
        contentPadding: EdgeInsets.zero,
      ));

  PopupMenuItem<dynamic> rowMenuButton(
      dynamic value, IconData icon, String title, List<PopupMenuItem<dynamic>> Function() itemBuilder, Function(dynamic selection) onSelected) {
    return PopupMenuItem(
        value: value,
        child: PopupMenuButton<dynamic>(
            onSelected: onSelected,
            child: ListTile(
              leading: Icon(icon, size: rowMenuIconSize),
              title: Text(title, style: TextStyle(fontSize: rowMenuFontSize)),
              contentPadding: EdgeInsets.zero,
            ),
            itemBuilder: (BuildContext context) => itemBuilder()));
  }

  PopupMenuItem<TrackMenuItem> trackMenuItem(TrackMenuItem value, IconData icon, String title) => PopupMenuItem<TrackMenuItem>(
      value: value,
      child: ListTile(
        leading: Icon(icon, size: trackMenuIconSize),
        title: Text(title, style: TextStyle(fontSize: trackMenuFontSize)),
        contentPadding: EdgeInsets.zero,
      ));

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
    ScaffoldMessenger.of(context).clearSnackBars();
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
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), color: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer),
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

  ButtonStyle circledButtonStyle() =>
      IconButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer);

  IconButton mediaPlayerButton(IconData icon, String tooltip, VoidCallback? onPressed, {double? iconSize}) => IconButton(
      onPressed: onPressed,
      style: circledButtonStyle(),
      icon: Icon(icon, size: iconSize ?? mediaPlayerIconSize, color: Theme.of(context).colorScheme.primary),
      tooltip: tooltip);

  helpSection(String title, List<Widget> content) {
    var items = <Widget>[];
    items.add(Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
    items.add(SizedBox(height: 6));
    items.addAll(content);
    items.add(SizedBox(height: 16));
    return Column(children: items);
  }

  helpTrackState(TrackState state, String message) => Container(
      padding: EdgeInsets.all(4),
      color: Config.trackStateBackgroundColors(context)[state],
      child: Row(children: [
        Icon(Config.trackStateIcons(context)[state], size: 12),
        SizedBox(width: 4),
        Text(message, style: TextStyle(color: Config.trackStateForegroundColors(context)[state]))
      ]));

  Divider settingsTileDivider() => Divider(height: 0, thickness: 1, indent: 20, endIndent: 20, color: Colors.black);

  ListTile settingsTileTitle(title) => ListTile(title: Center(child: Text(title, style: TextStyle(fontSize: settingsTitleFontSize))));

  ListTile listTileReset(
          IconData icon, String listTitle, String dialogTitle, String dialogInfo, String cancelLabel, String saveLabel, Function() successAction) =>
      ListTile(
          leading: Icon(icon),
          title: Text(listTitle),
          onTap: () {
            alertDialog(icon, dialogTitle, contentText: dialogInfo, actions: <Widget>[
              simpleButton(cancelLabel, () {
                Navigator.of(context).pop(cancelLabel);
              }),
              errorButton(saveLabel, () {
                Navigator.of(context).pop(saveLabel);
                toast(successAction(), icon: icon);
              }),
            ]);
          });

  ListTile listTileSlider(
      IconData icon,
      String listTitle,
      String dialogTitle,
      String dialogInfo,
      double currentValue,
      double minValue,
      double maxValue,
      int divisions,
      String Function(double value) labelFormatter,
      String cancelLabel,
      String saveLabel,
      String Function(double value, String formattedValue) successAction,
      {bool withTrailing = true}) {
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        trailing: (withTrailing == true) ? trailingLabel(currentValue.round().toString()) : null,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) => AlertDialog(
                          title: ListTile(
                            leading: Icon(icon),
                            title: Text(dialogTitle),
                          ),
                          content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(dialogInfo),
                            Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Slider(
                                  value: currentValue,
                                  min: minValue,
                                  max: maxValue,
                                  divisions: divisions.toInt(),
                                  label: labelFormatter(currentValue),
                                  onChanged: (double newValue) {
                                    setModalState(() {
                                      currentValue = newValue;
                                    });
                                  }),
                              Text(labelFormatter(currentValue)),
                            ]),
                          ]),
                          actions: [
                            simpleButton(cancelLabel, () {
                              Navigator.of(context).pop(cancelLabel);
                            }),
                            primaryButton(saveLabel, () {
                              Navigator.of(context).pop(saveLabel);
                              toast(successAction(currentValue, labelFormatter(currentValue)), icon: icon);
                            }),
                          ])));
        });
  }

  ListTile listTileSwitch(IconData icon, String listTitle, IconData disabledIcon, String disabledLabel, IconData enabledIcon, String enabledLabel,
          bool switchValue, String? Function(bool value) successAction) =>
      ListTile(
          leading: Icon(icon),
          title: Text(listTitle),
          subtitle: Row(children: [
            Icon(disabledIcon, size: settingsSubtitleIconSize),
            Text(disabledLabel, style: TextStyle(fontSize: settingsSubtitleFontSize)),
            Text(' '),
            Icon(enabledIcon, size: settingsSubtitleIconSize),
            Text(enabledLabel, style: TextStyle(fontSize: settingsSubtitleFontSize)),
          ]),
          trailing: Switch(
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                  (Set<WidgetState> states) => Icon(switchValue ? enabledIcon : disabledIcon, color: Colors.white)),
              trackColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
              trackOutlineColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Theme.of(context).colorScheme.primary,
              value: switchValue,
              onChanged: (bool value) {
                String? message = successAction(value);
                if (message != null) {
                  toast(message, icon: value ? enabledIcon : disabledIcon);
                }
              }));

  Flexible gridBuilder({required int itemCount, required Widget Function(dynamic context, dynamic index) itemBuilder, int columnsCount = 4}) {
    return Flexible(
        child: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnsCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              padding: const EdgeInsets.all(0),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            )));
  }

  SizedBox trackDetailsLine(List<Widget> items) => SizedBox(
      width: double.maxFinite,
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items));
}
