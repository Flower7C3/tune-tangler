import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tune_tangler/entity/track.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/config_collection.dart';
import '../config/menu_item_enums.dart';
import '../src/generated/app_localizations.dart';

enum DialogType {
  alert,
  list,
}

class UIHelper {
  static final double gridGap = 4;
  static final double iconSizeMultiplier = 1.2;

  BuildContext context;

  UIHelper(this.context);

  Container get dragHandle => Container(
        padding: EdgeInsets.only(top: Theme.of(context).textTheme.titleSmall!.fontSize!),
        child: Center(
          child: Container(
            width: Theme.of(context).textTheme.displayLarge!.fontSize!,
            height: Theme.of(context).textTheme.displayLarge!.fontSize! / 10,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(Theme.of(context).textTheme.displayLarge!.fontSize! / 10),
            ),
          ),
        ),
      );

  ListTile statusWidgetTile(
    Widget widget,
    String text, {
    Color? textColor,
    double? fontSize,
  }) =>
      ListTile(leading: widget, title: Text(text, style: TextStyle(color: textColor, fontSize: fontSize)));

  ListTile statusIconTile(
    IconData icon,
    String text, {
    Color? iconColor,
    double? iconSize,
    Color? textColor,
    double? fontSize,
  }) =>
      statusWidgetTile(Icon(icon, size: fontSize, color: iconColor), text, textColor: textColor, fontSize: fontSize);

  ListTile statusTextTile(
    String icon,
    String text, {
    Color? iconColor,
    double? iconSize,
    Color? textColor,
    double? fontSize,
  }) =>
      statusWidgetTile(Text(icon, style: TextStyle(color: iconColor, fontSize: iconSize)), text, textColor: textColor, fontSize: fontSize);

  Widget statusIconRow(
    IconData icon,
    String text, {
    Color? iconColor,
    double? iconSize,
    Color? textColor,
    double? fontSize,
    double? separatorSize,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    IconAlignment iconAlignment = IconAlignment.start,
    bool wrapExpanded = true,
  }) =>
      Row(mainAxisAlignment: mainAxisAlignment, children: [
        if (iconAlignment == IconAlignment.start) Icon(icon, size: iconSize, color: iconColor),
        if (iconAlignment == IconAlignment.start) SizedBox(width: separatorSize),
        (wrapExpanded == true)
            ? Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: fontSize)))
            : Text(text, style: TextStyle(color: textColor, fontSize: fontSize)),
        if (iconAlignment == IconAlignment.end) SizedBox(width: separatorSize),
        if (iconAlignment == IconAlignment.end) Icon(icon, size: iconSize, color: iconColor),
      ]);

  SingleChildScrollView trackDetailsTabElement(List<Widget> items) =>
      SingleChildScrollView(padding: EdgeInsets.all(gridGap * 4), child: Column(children: items));

  Container trackDetailsBox(List<Widget> items, {Color? backgroundColor}) => Container(
      margin: EdgeInsets.only(bottom: gridGap * 4),
      padding: EdgeInsets.all(gridGap * 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Theme.of(context).textTheme.displayLarge!.fontSize! / 10),
      ),
      child: Column(children: items));

  SizedBox trackDetailsLine(
    List<Widget> items, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  }) =>
      SizedBox(width: double.maxFinite, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: mainAxisAlignment, children: items));

  PopupMenuItem<String> topTrackMenuItem(
    AllTracksMenuItem value,
    IconData icon,
    String text, {
    bool? checked,
  }) =>
      PopupMenuItem(
          value: value.toString(),
          child: ListTile(
            leading: Icon(icon),
            title: Text(text),
            trailing: (checked == null) ? null : Icon((checked == true) ? Symbols.check_box_rounded : Symbols.square_rounded),
          ));

  Container rowButton(Widget content) => Container(
        margin: EdgeInsets.all(0),
        width: Theme.of(context).textTheme.displaySmall!.fontSize! * 0.9,
        height: Theme.of(context).textTheme.displaySmall!.fontSize! * 0.9,
        padding: EdgeInsets.all(gridGap),
        child: content,
      );

  PopupMenuItem<T> popupMenuItem<T>(
    T value,
    IconData icon,
    String title,
  ) =>
      PopupMenuItem<T>(
        value: value,
        child: statusIconTile(icon, title),
      );

  PopupMenuItem<dynamic> popupMenuButton(
    dynamic value,
    IconData icon,
    String title, {
    required List<PopupMenuItem<dynamic>> Function() itemBuilder,
    required Function(dynamic selection) onSelected,
  }) =>
      PopupMenuItem<dynamic>(
        value: value,
        child: PopupMenuButton<dynamic>(
          itemBuilder: (BuildContext context) => itemBuilder(),
          onSelected: onSelected,
          child: statusIconTile(icon, title),
        ),
      );

  void aboutDialog(
    PackageInfo packageInfo,
    List<Widget> content, {
    String? applicationName,
    String? applicationVersion,
    String? applicationLegalese,
    Widget? applicationIcon,
  }) =>
      showAboutDialog(
        context: context,
        applicationName: applicationName ?? packageInfo.appName,
        applicationVersion: applicationVersion ?? "${packageInfo.version} (${packageInfo.buildNumber})",
        applicationLegalese: applicationLegalese,
        applicationIcon: applicationIcon,
        children: content.toList(),
      );

  void alertDialog(
    IconData icon,
    String titleText, {
    bool barrierDismissible = true,
    Widget? contentWidget,
    String? contentText,
    List<Widget>? actions,
  }) =>
      _dialogBuilder(
        DialogType.alert,
        icon,
        titleText,
        barrierDismissible: barrierDismissible,
        contentWidget: contentWidget,
        contentText: contentText,
        actions: actions,
      );

  void listDialog(
    IconData icon,
    String titleText, {
    barrierDismissible = true,
    String? contentText,
    List<Widget>? actions,
  }) =>
      _dialogBuilder(
        DialogType.list,
        icon,
        titleText,
        barrierDismissible: barrierDismissible,
        contentText: contentText,
        actions: actions,
      );

  void _dialogBuilder(
    type,
    IconData icon,
    String titleText, {
    bool barrierDismissible = true,
    Widget? contentWidget,
    String? contentText,
    List<Widget>? actions,
  }) =>
      showDialog(
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
                    title: statusIconTile(icon, titleText),
                    content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: content.toList()),
                    actions: actions ?? <Widget>[]);
              case DialogType.list:
                var title = <Widget>[];
                title.add(statusIconTile(icon, titleText));
                if (contentText != null) {
                  title.add(SizedBox(height: 8));
                  title.add(Text(
                    contentText,
                    style: TextStyle(fontSize: 14),
                  ));
                }
                return SimpleDialog(
                    title: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: title.toList()),
                    children: actions);
              default:
                throw Exception('Dialog type not implemented.');
            }
          });

  String formatTime(
    int milliseconds, {
    String format = '{h}:{m}:{s}.{cs}',
  }) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final deciSecond = (((duration.inMilliseconds % 1000) / 100) % 10).toInt().toString();
    final centiSecond = ((duration.inMilliseconds % 1000) / 10).toInt().toString().padLeft(2, '0');
    final milliSecond = ((duration.inMilliseconds % 1000)).toInt().toString().padLeft(3, '0');
    return format
        .replaceAll('{h}', hours)
        .replaceAll('{m}', minutes)
        .replaceAll('{s}', seconds)
        .replaceAll('{ds}', deciSecond)
        .replaceAll('{cs}', centiSecond)
        .replaceAll('{ms}', milliSecond)
        .replaceAll('{MS}', duration.inMilliseconds.toString());
  }

  void toast(
    String text, {
    int duration = 2,
    IconData? icon,
    ToastType type = ToastType.success,
  }) {
    if (text.isEmpty || text == '') {
      return;
    }
    Color foregroundColor;
    Color backgroundColor;
    switch (type) {
      case ToastType.success:
        foregroundColor = Theme.of(context).colorScheme.secondary;
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        break;
      case ToastType.error:
        foregroundColor = Theme.of(context).colorScheme.error;
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        break;
    }
    var message = <Widget>[];
    if (icon != null) {
      message.add(Icon(icon, color: foregroundColor, size: 16));
      message.add(SizedBox(width: gridGap * 2));
    }
    message.add(Flexible(child: Text(text, style: TextStyle(color: foregroundColor))));
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: backgroundColor),
              padding: EdgeInsets.symmetric(vertical: gridGap * 2, horizontal: gridGap * 4),
              child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: message.toList()),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: duration), () => overlayEntry.remove());
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
        child: Text(text, style: TextStyle(color: Colors.white)),
      ));

  Widget trailingStatus(String text, IconData icon, type) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: switch (type) {
            ToastType.success => Theme.of(context).colorScheme.secondary,
            ToastType.error => Theme.of(context).colorScheme.error,
            _ => Theme.of(context).colorScheme.tertiary,
          },
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(8),
        child: Text(text,
            style: TextStyle(
                color: switch (type) {
              ToastType.success => Theme.of(context).colorScheme.secondaryContainer,
              ToastType.error => Theme.of(context).colorScheme.errorContainer,
              _ => Theme.of(context).colorScheme.tertiary,
            })),
      ));

  ButtonStyle circledButtonStyle({OutlinedBorder? borderStyle}) => IconButton.styleFrom(
        shape: borderStyle ?? CircleBorder(),
        padding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      );

  Container mediaPlayerButton(
    IconData icon,
    String tooltip, {
    VoidCallback? onPressed,
    double? iconSize,
    double? boxSize,
    OutlinedBorder? borderStyle,
  }) =>
      Container(
          margin: EdgeInsets.zero,
          width: boxSize,
          height: boxSize,
          padding: EdgeInsets.all(gridGap),
          child: IconButton(
            style: circledButtonStyle(borderStyle: borderStyle),
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            iconSize: iconSize ?? Theme.of(context).textTheme.headlineSmall!.fontSize,
            padding: EdgeInsets.zero,
            tooltip: tooltip,
            onPressed: onPressed,
          ));

  Container helpTrackState(TrackState state, String message) => Container(
        padding: EdgeInsets.zero,
        color: AppGlobalConfig.trackState.color(state, context: context, domain: ConfigItemPropertyDomain.backgroundColor),
        child: statusIconTile(
          AppGlobalConfig.trackState.icon(state),
          message,
          textColor: AppGlobalConfig.trackState.color(state, context: context, domain: ConfigItemPropertyDomain.foregroundColor),
        ),
      );

  Divider settingsTileDivider() => Divider(height: 0, thickness: 1, indent: 20, endIndent: 20, color: Theme.of(context).colorScheme.inversePrimary);

  ListTile listTileReset(
    IconData icon,
    String listTitle,
    String dialogTitle,
    String dialogInfo,
    String cancelLabel,
    String saveLabel,
    Function() successAction,
  ) =>
      ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        onTap: () => alertDialogReset(icon, dialogTitle, dialogInfo, cancelLabel, saveLabel, successAction),
      );

  void alertDialogReset(
    IconData icon,
    String dialogTitle,
    String dialogInfo,
    String cancelLabel,
    String saveLabel,
    Function() successAction,
  ) =>
      alertDialog(icon, dialogTitle, contentText: dialogInfo, actions: <Widget>[
        simpleButton(cancelLabel, () => Navigator.pop(context, cancelLabel)),
        errorButton(saveLabel, () {
          Navigator.pop(context, saveLabel);
          toast(successAction(), icon: icon);
        }),
      ]);

  ListTile listTileSlider(
    IconData icon,
    String listTitle,
    String dialogTitle,
    String dialogInfo,
    dynamic currentValue,
    double minValue,
    double maxValue,
    int? divisions,
    String cancelLabel,
    String saveLabel, {
    required String Function(double value, String formattedValue) successAction,
    bool withTrailing = true,
    ConfigCollection? configCollection,
    AppLocalizations? trans,
  }) =>
      ListTile(
          leading: Icon(icon),
          title: Text(listTitle),
          trailing: (withTrailing == true)
              ? trailingLabel(configCollection != null ? configCollection.format(currentValue) : currentValue.toString())
              : null,
          onTap: () => showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) => AlertDialog(
                          title: statusIconTile(icon, dialogTitle),
                          content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(dialogInfo),
                            Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Slider(
                                  value: currentValue,
                                  min: minValue,
                                  max: maxValue,
                                  divisions: divisions?.toInt(),
                                  label: _translateOrFormat(currentValue, configCollection, trans),
                                  onChanged: (double newValue) {
                                    setModalState(() {
                                      currentValue = newValue;
                                    });
                                  }),
                              Text(_format(currentValue, configCollection)),
                            ]),
                          ]),
                          actions: [
                            simpleButton(cancelLabel, () => Navigator.pop(context, cancelLabel)),
                            primaryButton(saveLabel, () {
                              Navigator.pop(context, saveLabel);
                              toast(successAction(currentValue, _translateOrFormat(currentValue, configCollection, trans)), icon: icon);
                            }),
                          ]))));

  SliderThemeData balanceSliderThemeData(BuildContext context) => SliderTheme.of(context).copyWith(
        activeTrackColor: Theme.of(context).colorScheme.primary.withAlpha(12),
        inactiveTrackColor: Theme.of(context).colorScheme.primary.withAlpha(12),
        trackHeight: 6,
        trackShape: RectangularSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.always,
        activeTickMarkColor: Theme.of(context).colorScheme.primary.withAlpha(54),
        inactiveTickMarkColor: Theme.of(context).colorScheme.primary.withAlpha(54),
      );

  void alertDialogSlider(
    IconData icon,
    String dialogTitle,
    String dialogInfo,
    dynamic currentValue,
    double minValue,
    double maxValue,
    int? divisions,
    String cancelLabel,
    String saveLabel, {
    required String Function(double value, String formattedValue) successAction,
    bool withTrailing = true,
    ConfigCollection? configCollection,
    AppLocalizations? trans,
    SliderThemeData? sliderTheme,
    ConfigItemPropertyDomain? tileLeading,
    ConfigItemPropertyDomain? tileTrailing,
  }) =>
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) => AlertDialog(
                      title: statusIconTile(icon, dialogTitle),
                      content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(dialogInfo),
                        if (configCollection != null && tileLeading != null && tileTrailing != null)
                          ListTile(
                            leading: Text(configCollection.text(currentValue, domain: tileLeading)),
                            trailing: Text(configCollection.text(currentValue, domain: tileTrailing)),
                            minVerticalPadding: 0,
                          ),
                        if (tileLeading != null && tileTrailing != null)
                          SliderTheme(
                              data: sliderTheme ?? SliderThemeData(),
                              child: Slider(
                                  value: currentValue,
                                  min: minValue,
                                  max: maxValue,
                                  divisions: divisions?.toInt(),
                                  label: _translateOrFormat(currentValue, configCollection, trans),
                                  onChanged: (double newValue) {
                                    setModalState(() {
                                      currentValue = newValue;
                                    });
                                  })),
                        if (tileLeading == null && tileTrailing == null)
                          Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                            SliderTheme(
                                data: sliderTheme ?? SliderThemeData(),
                                child: Slider(
                                    value: currentValue,
                                    min: minValue,
                                    max: maxValue,
                                    divisions: divisions?.toInt(),
                                    label: _translateOrFormat(currentValue, configCollection, trans),
                                    onChanged: (double newValue) {
                                      setModalState(() {
                                        currentValue = newValue;
                                      });
                                    })),
                            Text(_format(currentValue, configCollection)),
                          ]),
                      ]),
                      actions: [
                        simpleButton(cancelLabel, () {
                          Navigator.pop(context, cancelLabel);
                        }),
                        primaryButton(saveLabel, () {
                          Navigator.pop(context, saveLabel);
                          toast(successAction(currentValue, _translateOrFormat(currentValue, configCollection, trans)), icon: icon);
                        }),
                      ])));

  ListTile listTileRadioDialog(
    IconData icon,
    String listTitle,
    String? listSubtitle,
    String dialogTitle,
    String dialogInfo,
    dynamic currentValue,
    List<dynamic> values,
    String cancelLabel,
    String saveLabel, {
    required String Function(dynamic value, String formattedValue) successAction,
    bool withTrailing = true,
    ConfigCollection? configCollection,
    AppLocalizations? trans,
  }) {
    double sliderValue = values.indexOf(currentValue).toDouble();

    List<Widget> subtitle = [];
    if (listSubtitle != null) {
      subtitle.add(Text(listSubtitle, style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize)));
    }
    String translatedValue =
        (trans.toString() != 'null' && configCollection != null && trans != null) ? configCollection.translate(currentValue, trans: trans) : '';
    if (translatedValue != '') {
      subtitle.add(Text(translatedValue, style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize)));
    }
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: (subtitle.isNotEmpty)
            ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.toList())
            : null,
        trailing: (withTrailing == true && configCollection != null) ? trailingLabel(configCollection.format(currentValue)) : null,
        onTap: () => showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) => AlertDialog(
                      title: statusIconTile(icon, dialogTitle),
                      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Text(dialogInfo),
                        Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Slider(
                              value: sliderValue,
                              min: 0,
                              max: (values.length - 1).toDouble(),
                              divisions: (values.length - 1),
                              label: _translateOrFormat(currentValue, configCollection, trans),
                              onChanged: (double newValue) {
                                setModalState(() {
                                  sliderValue = newValue;
                                  currentValue = values[sliderValue.toInt()];
                                });
                              }),
                          Text(_format(currentValue, configCollection)),
                        ]),
                      ]),
                      actions: [
                        simpleButton(cancelLabel, () {
                          Navigator.pop(context, cancelLabel);
                        }),
                        primaryButton(saveLabel, () {
                          Navigator.pop(context, saveLabel);
                          toast(successAction(currentValue, _translateOrFormat(currentValue, configCollection, trans)), icon: icon);
                        }),
                      ],
                    ))));
  }

  Widget listTileButtons(
    IconData icon,
    String listTitle,
    dynamic currentValue,
    List<dynamic> values, {
    bool trailingValueIcon = false,
    bool translateChoiceChip = false,
    bool useAvatar = false,
    String? helpMessage,
    List<Widget>? helpWidgets,
    required String Function(dynamic value, String formattedValue) successAction,
    ConfigCollection? configCollection,
    AppLocalizations? trans,
  }) =>
      ExpansionTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: Text(_translateOrFormat(currentValue, configCollection, trans)),
        childrenPadding: EdgeInsets.only(left: gridGap * 3),
        trailing: trailingValueIcon ? Icon(configCollection?.icon(currentValue)) : null,
        children: [
          Wrap(
            spacing: gridGap,
            children: List.generate(
              values.length,
              (index) => ChoiceChip(
                label:
                    Text(translateChoiceChip ? _translateOrFormat(values[index], configCollection, trans) : _format(values[index], configCollection)),
                showCheckmark: false,
                avatar: useAvatar ? Icon(configCollection?.icon(values[index])) : null,
                selected: values[index] == currentValue,
                onSelected: (bool selected) {
                  if (selected) {
                    dynamic selectedValue = values[index];
                    toast(successAction(selectedValue, _translateOrFormat(selectedValue, configCollection, trans)), icon: icon);
                  }
                },
              ),
            ),
          ),
          if (helpMessage != null)
            Padding(padding: EdgeInsets.symmetric(vertical: gridGap), child: Text(helpMessage, style: Theme.of(context).textTheme.labelMedium)),
          if (helpWidgets != null)
            Padding(
                padding: EdgeInsets.symmetric(vertical: gridGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: gridGap,
                  children: helpWidgets,
                ))
        ],
      );

  ListTile listTileColorPicker(
    IconData icon,
    String listTitle, {
    String? listSubtitle,
    required String dialogTitle,
    required String dialogInfo,
    required Color currentValue,
    required List<Color> values,
    required String Function(dynamic value, String formattedValue) successAction,
    ConfigCollection? configCollection,
    AppLocalizations? trans,
  }) =>
      ListTile(
          leading: Icon(icon),
          title: Text(listTitle),
          subtitle: listSubtitle == null ? null : Text(listSubtitle),
          trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: currentValue,
                borderRadius: BorderRadius.circular(24),
              )),
          onTap: () => alertDialog(AppIcon.screenThemeColor, dialogTitle,
              contentText: dialogInfo,
              contentWidget: gridBuilder(
                  itemCount: values.length,
                  itemBuilder: (context, index) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: values[index],
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          dynamic selectedValue = values[index];
                          Navigator.pop(context);
                          toast(successAction(selectedValue, _translateOrFormat(selectedValue, configCollection, trans)), icon: icon);
                        },
                        child: null,
                      ))));

  ListTile listTileSwitch(
    IconData icon,
    String listTitle, {
    String? subtitleText,
    required IconData disabledIcon,
    String? disabledLabel,
    required IconData enabledIcon,
    String? enabledLabel,
    required bool switchValue,
    required String Function(bool value) successAction,
  }) {
    List<Widget> subtitle = [];
    if (subtitleText != null) {
      subtitle.add(Text(subtitleText, style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize)));
    }
    if (disabledLabel != null || enabledLabel != null) {
      subtitle.add(Column(children: [
        if (disabledLabel != null)
          statusIconRow(disabledIcon, disabledLabel,
              iconSize: Theme.of(context).textTheme.labelSmall!.fontSize! * iconSizeMultiplier,
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
        if (enabledLabel != null)
          statusIconRow(enabledIcon, enabledLabel,
              iconSize: Theme.of(context).textTheme.labelSmall!.fontSize!, fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
      ]));
    }
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: (subtitle.isNotEmpty)
            ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.toList())
            : null,
        trailing: Switch(
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                (Set<WidgetState> states) => Icon(switchValue ? enabledIcon : disabledIcon, color: Colors.white)),
            trackColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
            trackOutlineColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: Theme.of(context).colorScheme.primary,
            value: switchValue,
            onChanged: (bool value) => toast(successAction(value), icon: value ? enabledIcon : disabledIcon)));
  }

  ListTile listTileListDialog(
    IconData icon,
    String listTitle, {
    String? listSubtitle,
    required String dialogTitle,
    required String currentValue,
    required List<SimpleDialogOption> options,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        trailing: trailingLabel(currentValue),
        subtitle: (listSubtitle == null) ? null : Text(listSubtitle),
        onTap: () => listDialog(AppIcon.language, dialogTitle, actions: options.toList()),
      );

  String _translateOrFormat(dynamic value, ConfigCollection? configCollection, AppLocalizations? trans) => ((configCollection == null)
      ? value.toString()
      : ((trans.toString() != 'null' && trans != null) ? configCollection.translate(value, trans: trans) : configCollection.format(value)));

  String _format(dynamic value, ConfigCollection? configCollection) =>
      ((configCollection == null) ? value.toString() : configCollection.format(value));

  Flexible gridBuilder({
    required int itemCount,
    required Widget Function(dynamic context, dynamic index) itemBuilder,
    int? rowSize,
  }) =>
      Flexible(
          child: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: (rowSize == null)
                    ? SliverGridDelegateWithMaxCrossAxisExtent(
                        crossAxisSpacing: gridGap * 4,
                        mainAxisSpacing: gridGap * 4,
                        maxCrossAxisExtent: gridGap * 8,
                        mainAxisExtent: gridGap * 8,
                      )
                    : SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: gridGap * 2,
                        mainAxisSpacing: gridGap * 2,
                        mainAxisExtent: gridGap * 8,
                        crossAxisCount: rowSize,
                      ),
                padding: const EdgeInsets.all(0),
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              )));

  Widget drawerTitle(IconData icon, String title) => Container(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer),
      child: statusIconTile(
        icon,
        title,
        iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * iconSizeMultiplier,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        iconColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.secondary,
      ));

  Text buildRichText(
    String template, {
    required Map<String, dynamic> data,
    double iconSize = 16,
  }) {
    List<InlineSpan> spans = [];
    RegExp exp = RegExp(r'\$\[(.*?)\]');
    List<String> parts = template.split(exp);

    int matchIndex = 0;
    for (String part in parts) {
      spans.add(TextSpan(text: part));
      if (matchIndex < exp.allMatches(template).length) {
        String key = exp.allMatches(template).elementAt(matchIndex).group(1)!;
        if (data.containsKey(key)) {
          if (data[key] is IconData) {
            spans.add(WidgetSpan(
              child: Icon(data[key], size: iconSize),
            ));
          } else {
            spans.add(TextSpan(text: data[key].toString()));
          }
        }
        matchIndex++;
      }
    }

    return Text.rich(TextSpan(children: spans));
  }
}
