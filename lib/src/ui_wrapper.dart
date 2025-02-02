import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:record/record.dart';
import 'package:tune_tangler/entity/track.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
import '../config/config_collection.dart';
import '../config/menu_item.dart';

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

  final double trackDetailsPadding1x = 16;
  final double trackDetailsPadding2x = 32;
  final double trackDetailsTitleFontSize = 24;
  final double trackItemMargin = 4;
  final double trackItemWidth = 70;
  final double trackPadding = 4;
  final double trackBorderRadius = 10;
  final double trackButtonTitleFontSize = 22.0;
  final double trackButtonRoundRadius = 3;
  final double trackButtonRoundSize = 18.0;
  final double trackButtonIconSize = 20.0;
  final double trackInfoSpeedFontSize = 10.0;
  final double trackInfoBalanceFontSize = 14.0;
  final double trackInfoIconSize = 12.0;
  final double trackInfoFontSize = 10.0;
  final double trackMenuIconSize = 20;
  final double trackMenuFontSize = 16;
  final double mediaPlayerIconSize = 24;
  final double mediaPlayerIconSize2x = 48;
  final double iconToTextOffset = 8;
  final double dividerSize = 16;

  final double settingsTitleFontSize = 20;
  final double settingsSubtitleIconSize = 12;
  final double settingsSubtitleFontSize = 12;

  final double footerFontSize = 12;

  BuildContext context;

  UIWrapper(this.context);

  ListTile statusIconTile(
    IconData icon,
    String text, {
    Color? iconColor,
    double? iconSize,
    Color? textColor,
    double? fontSize,
  }) =>
      ListTile(
        leading: Icon(icon, size: fontSize, color: iconColor),
        title: Text(text, style: TextStyle(color: textColor, fontSize: fontSize)),
      );

  Row statusIconRow(IconData icon, String text, {Color? iconColor, double? iconSize, Color? textColor, double? fontSize, double? separatorSize}) =>
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(icon, size: iconSize, color: iconColor),
        SizedBox(width: separatorSize),
        Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: fontSize))),
      ]);

  SizedBox trackDetailsLine(
    List<Widget> items, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  }) =>
      items.isEmpty
          ? SizedBox(child: null)
          : SizedBox(width: double.maxFinite, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: mainAxisAlignment, children: items));

  PopupMenuItem<String> topPopupMenuItem(
    TopMenuItem value,
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
        width: rowButtonIconSize + rowContainerPadding * 2,
        height: rowButtonIconSize + rowContainerPadding * 2,
        padding: EdgeInsets.all(rowContainerPadding),
        child: content,
      );

  PopupMenuItem rowPopupMenuItem(
    dynamic value,
    IconData icon,
    String title,
  ) =>
      PopupMenuItem<dynamic>(
        value: value,
        child: statusIconTile(icon, title, iconSize: rowMenuIconSize, fontSize: rowMenuFontSize),
      );

  PopupMenuItem<dynamic> rowMenuButton(
    dynamic value,
    IconData icon,
    String title, {
    required List<PopupMenuItem<dynamic>> Function() itemBuilder,
    required Function(dynamic selection) onSelected,
  }) =>
      PopupMenuItem(
        value: value,
        child: PopupMenuButton<dynamic>(
          onSelected: onSelected,
          child: statusIconTile(icon, title, iconSize: rowMenuIconSize, fontSize: rowMenuFontSize),
          itemBuilder: (BuildContext context) => itemBuilder(),
        ),
      );

  PopupMenuItem<TrackMenuItem> trackMenuItem(
    TrackMenuItem value,
    IconData icon,
    String title,
  ) =>
      PopupMenuItem<TrackMenuItem>(
        value: value,
        child: statusIconTile(icon, title, iconSize: trackMenuIconSize, fontSize: trackMenuFontSize),
      );

  void aboutDialog(
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

  Future<void> alertDialog(
    IconData icon,
    String titleText, {
    bool barrierDismissible = true,
    Widget? contentWidget,
    String? contentText,
    List<Widget>? actions,
    Function(dynamic result)? thenCallback,
  }) async {
    _dialogBuilder(
      DialogType.alert,
      icon,
      titleText,
      barrierDismissible: barrierDismissible,
      contentWidget: contentWidget,
      contentText: contentText,
      actions: actions,
      thenCallback: thenCallback,
    );
  }

  Future<void> listDialog(
    IconData icon,
    String titleText, {
    barrierDismissible = true,
    String? contentText,
    List<Widget>? actions,
    Function(dynamic result)? thenCallback,
  }) async =>
      _dialogBuilder(
        DialogType.list,
        icon,
        titleText,
        barrierDismissible: barrierDismissible,
        contentText: contentText,
        actions: actions,
        thenCallback: thenCallback,
      );

  void _dialogBuilder(
    type,
    IconData icon,
    String titleText, {
    bool barrierDismissible = true,
    Widget? contentWidget,
    String? contentText,
    List<Widget>? actions,
    Function(dynamic result)? thenCallback,
  }) async =>
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
          }).then(thenCallback ?? (result) {});

  String formatTime(
    int milliseconds, {
    String format = '{h}:{m}:{s}.{ds}',
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

  Widget _recordConfig(
    RecordConfig recordConfig,
    AppLocalizations trans,
  ) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        statusIconRow(AppIcon.recordingInputDevice,
            trans.recordingInputDeviceValue(recordConfig.device == null ? trans.defaultDevice : recordConfig.device!.label),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(AppIcon.recordingAudioEncoder,
            trans.recordingAudioEncoderValue(AppGlobalConfig.recordingAudioEncoder.translation(recordConfig.encoder.index.toDouble(), trans: trans)),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(AppIcon.recordingSampleRate,
            trans.recordingSampleRateValue(AppGlobalConfig.recordingSampleRate.valueFormatter(recordConfig.sampleRate.toDouble())),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(
            AppIcon.recordingBitRate, trans.recordingBitRateValue(AppGlobalConfig.recordingBitRate.valueFormatter(recordConfig.bitRate.toDouble())),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(AppIcon.recordingAudioGain, trans.recordingAutoGainValue(recordConfig.autoGain ? trans.yes : trans.no),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(AppIcon.recordingEchoCancel, trans.recordingEchoCancelValue(recordConfig.echoCancel ? trans.yes : trans.no),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
        statusIconRow(AppIcon.recordingNoiseSuppress, trans.recordingNoiseSuppressValue(recordConfig.noiseSuppress ? trans.yes : trans.no),
            iconSize: 16, fontSize: 14, separatorSize: iconToTextOffset),
      ]);

  void recordConfigDialog(
    String title, {
    required RecordConfig recordConfig,
    required AppLocalizations trans,
  }) {
    alertDialog(
      AppIcon.trackRecordingStart,
      title,
      contentWidget: _recordConfig(recordConfig, trans),
      actions: [
        primaryButton(trans.settingsChange, () async {
          Navigator.pop(context, 'trackRecordingStop');
          await Navigator.pushNamed(context, '/settings', arguments: 2);
        }),
      ],
    );
  }

  void toast(
    String text, {
    int duration = 2,
    IconData? icon,
    ToastType type = ToastType.success,
  }) {
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
      message.add(SizedBox(width: iconToTextOffset));
    }
    message.add(Flexible(child: Text(text, style: TextStyle(color: foregroundColor))));
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: backgroundColor),
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

  ButtonStyle circledButtonStyle() =>
      IconButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer);

  IconButton mediaPlayerButton(IconData icon, String tooltip, {VoidCallback? onPressed, double? iconSize}) => IconButton(
      onPressed: onPressed,
      style: circledButtonStyle(),
      icon: Icon(icon, size: iconSize ?? mediaPlayerIconSize, color: Theme.of(context).colorScheme.primary),
      tooltip: tooltip);

  Column helpSection(String title, List<Widget> content) {
    var items = <Widget>[];
    items.add(Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
    items.add(SizedBox(height: 6));
    items.addAll(content);
    items.add(SizedBox(height: 16));
    return Column(children: items);
  }

  Container helpTrackState(TrackState state, String message) => Container(
        padding: EdgeInsets.all(4),
        color: AppGlobalConfig.trackStateBackgroundColor.colorOrNull(state, context: context),
        child: statusIconTile(
          AppGlobalConfig.trackState.icon(state, defaultValue: Icons.error_outline_rounded),
          message,
          textColor: AppGlobalConfig.trackStateForegroundColor.colorOrNull(state, context: context),
        ),
      );

  Divider settingsTileDivider() => Divider(height: 0, thickness: 1, indent: 20, endIndent: 20, color: Colors.black);

  ListTile settingsTileTitle(title) => ListTile(title: Center(child: Text(title, style: TextStyle(fontSize: settingsTitleFontSize))));

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
          onTap: () {
            alertDialog(icon, dialogTitle, contentText: dialogInfo, actions: <Widget>[
              simpleButton(cancelLabel, () {
                Navigator.pop(context, cancelLabel);
              }),
              errorButton(saveLabel, () {
                Navigator.pop(context, saveLabel);
                toast(successAction(), icon: icon);
              }),
            ]);
          });

  ListTile listTileSlider(
    IconData icon,
    String listTitle,
    String dialogTitle,
    String dialogInfo,
    dynamic currentValue,
    double minValue,
    double maxValue,
    int divisions,
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
              ? trailingLabel(configCollection != null ? configCollection.valueFormatter(currentValue) : currentValue.toString())
              : null,
          onTap: () {
            showDialog(
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
                                    divisions: divisions.toInt(),
                                    label: ((configCollection == null)
                                        ? currentValue.toString()
                                        : ((trans.toString() != 'null' && trans != null)
                                            ? configCollection.translation(currentValue, trans: trans)
                                            : configCollection.valueFormatter(currentValue))),
                                    onChanged: (double newValue) {
                                      setModalState(() {
                                        currentValue = newValue;
                                      });
                                    }),
                                Text(configCollection != null ? configCollection.valueFormatter(currentValue) : currentValue.toString()),
                              ]),
                            ]),
                            actions: [
                              simpleButton(cancelLabel, () {
                                Navigator.pop(context, cancelLabel);
                              }),
                              primaryButton(saveLabel, () {
                                Navigator.pop(context, saveLabel);
                                toast(
                                    successAction(
                                      currentValue,
                                      ((configCollection == null)
                                          ? currentValue.toString()
                                          : ((trans.toString() != 'null' && trans != null)
                                              ? configCollection.translation(currentValue, trans: trans)
                                              : configCollection.valueFormatter(currentValue))),
                                    ),
                                    icon: icon);
                              }),
                            ])));
          });

  ListTile listTileRadio(
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
      subtitle.add(Text(listSubtitle, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    String translatedValue =
        (trans.toString() != 'null' && configCollection != null && trans != null) ? configCollection.translation(currentValue, trans: trans) : '';
    if (translatedValue != '') {
      subtitle.add(Text(translatedValue, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.toList()),
        trailing: (withTrailing == true && configCollection != null) ? trailingLabel(configCollection.valueFormatter(currentValue)) : null,
        onTap: () {
          showDialog(
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
                        label: ((configCollection == null)
                            ? currentValue.toString()
                            : ((trans.toString() != 'null' && trans != null)
                                ? configCollection.translation(currentValue, trans: trans)
                                : configCollection.valueFormatter(currentValue))),
                        onChanged: (double newValue) {
                          setModalState(() {
                            sliderValue = newValue;
                            currentValue = values[sliderValue.toInt()];
                          });
                        }),
                    Text(configCollection != null ? configCollection.valueFormatter(currentValue) : currentValue.toString()),
                  ]),
                ]),
                actions: [
                  simpleButton(cancelLabel, () {
                    Navigator.pop(context, cancelLabel);
                  }),
                  primaryButton(saveLabel, () {
                    Navigator.pop(context, saveLabel);
                    toast(
                        successAction(
                          currentValue,
                          ((configCollection == null)
                              ? currentValue.toString()
                              : ((trans.toString() != 'null' && trans != null)
                                  ? configCollection.translation(currentValue, trans: trans)
                                  : configCollection.valueFormatter(currentValue))),
                        ),
                        icon: icon);
                  }),
                ],
              ),
            ),
          );
        });
  }

  ListTile listTileSwitch(
    IconData icon,
    String listTitle, {
    String? subtitleText,
    required IconData disabledIcon,
    String? disabledLabel,
    required IconData enabledIcon,
    String? enabledLabel,
    required bool switchValue,
    required String? Function(bool value) successAction,
  }) {
    List<Widget> subtitle = [];
    if (subtitleText != null) {
      subtitle.add(Text(subtitleText, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    subtitle.add(Column(children: [
      if (disabledLabel != null) statusIconRow(disabledIcon, disabledLabel, iconSize: settingsSubtitleIconSize, fontSize: settingsSubtitleFontSize),
      if (enabledLabel != null) statusIconRow(enabledIcon, enabledLabel, iconSize: settingsSubtitleIconSize, fontSize: settingsSubtitleFontSize),
    ]));
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.toList()),
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
  }

  Flexible gridBuilder({
    required int itemCount,
    required Widget Function(dynamic context, dynamic index) itemBuilder,
  }) =>
      Flexible(
          child: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  maxCrossAxisExtent: 32,
                  mainAxisExtent: 32,
                ),
                padding: const EdgeInsets.all(0),
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              )));
}
