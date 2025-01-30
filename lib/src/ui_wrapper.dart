import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tune_tangler/entity/track.dart';

import '../config/app_icon.dart';
import '../config/config.dart';
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
  final double trackDetailsTitleFontSize = 32;
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

  final double settingsTitleFontSize = 20;
  final double settingsSubtitleIconSize = 12;
  final double settingsSubtitleFontSize = 12;

  BuildContext context;

  UIWrapper(this.context);

  Row recordingInfoLine(IconData icon, String text) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, size: 16),
        SizedBox(width: iconToTextOffset),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
      ]);

  Row trackInfoLine(IconData icon, String text, Color foregroundColor) => Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Icon(icon, size: trackInfoIconSize, color: foregroundColor), Text(text, style: TextStyle(fontSize: trackInfoFontSize))]);

  SizedBox trackDetailsLine(List<Widget> items, {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center}) => items.isEmpty
      ? SizedBox(child: null)
      : SizedBox(width: double.maxFinite, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: mainAxisAlignment, children: items));

  SizedBox trackDetailsInfo(IconData icon, String text) => trackDetailsLine([
        Icon(icon, size: 16),
        SizedBox(width: iconToTextOffset),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
      ]);

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

  PopupMenuItem<dynamic> rowMenuButton(dynamic value, IconData icon, String title,
      {required List<PopupMenuItem<dynamic>> Function() itemBuilder, required Function(dynamic selection) onSelected}) {
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
      {bool barrierDismissible = true,
      Widget? contentWidget,
      String? contentText,
      List<Widget>? actions,
      Function()? preCallback,
      Function(dynamic result)? thenCallback}) async {
    _dialogBuilder(DialogType.alert, icon, titleText,
        contentWidget: contentWidget,
        contentText: contentText,
        actions: actions,
        barrierDismissible: barrierDismissible,
        preCallback: preCallback,
        thenCallback: thenCallback);
  }

  Future<void> listDialog(IconData icon, String titleText,
          {barrierDismissible = true,
          String? contentText,
          List<Widget>? actions,
          Function()? preCallback,
          Function(dynamic result)? thenCallback}) async =>
      _dialogBuilder(DialogType.list, icon, titleText,
          contentText: contentText, actions: actions, barrierDismissible: barrierDismissible, preCallback: preCallback, thenCallback: thenCallback);

  Future<void> _dialogBuilder(type, IconData icon, String titleText,
          {bool barrierDismissible = true,
          Widget? contentWidget,
          String? contentText,
          List<Widget>? actions,
          Function()? preCallback,
          Function(dynamic result)? thenCallback}) async =>
      await showDialog(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            if (preCallback != null) {
              preCallback();
            }
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

  String formatTime(int milliseconds, {String format = '{h}:{m}:{s}.{ds}'}) {
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

  void recordingDialog(String title,
      {required String audioEncoderText,
      required String sampleRateText,
      required String bitRateText,
      required String cancelLabel,
      required String autoGainText,
      required String echoCancelText,
      required String noiseSuppressText,
      required Function() onCancel,
      required String saveLabel,
      required Function() onSave,
      required Function() onDismiss}) {
    int clock = 0;
    Timer? timer;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startTimer() {
              timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
                setState(() {
                  clock++;
                });
              });
            }

            if (timer == null) {
              startTimer();
            }
            return AlertDialog(
              title: ListTile(
                leading: Icon(Icons.graphic_eq),
                title: Text(title),
              ),
              content: Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                recordingInfoLine(AppIcon.recordingAudioEncoder, audioEncoderText),
                recordingInfoLine(AppIcon.recordingSampleRate, sampleRateText),
                recordingInfoLine(AppIcon.recordingBitRate, bitRateText),
                recordingInfoLine(AppIcon.recordingAudioGain, autoGainText),
                recordingInfoLine(AppIcon.recordingEchoCancel, echoCancelText),
                recordingInfoLine(AppIcon.recordingNoiseSuppress, noiseSuppressText),
                SizedBox(height: 16),
                LinearProgressIndicator(),
                SizedBox(height: 16),
                Text(formatTime(clock * 100)),
              ])),
              actions: [
                errorButton(cancelLabel, () {
                  Navigator.pop(context, 'trackRecordingCancel');
                  onCancel();
                }),
                primaryButton(saveLabel, () {
                  Navigator.pop(context, 'trackRecordingStop');
                  onSave();
                }),
              ],
            );
          },
        );
      },
    ).then((status) {
      timer?.cancel();
      if (status == null) {
        onDismiss();
      }
    });
  }

  void toast(String text, {int duration = 2, IconData? icon, ToastType type = ToastType.success}) {
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
          child: Text(text, style: TextStyle(color: Colors.white))));

  ButtonStyle circledButtonStyle() =>
      IconButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer);

  IconButton mediaPlayerButton(IconData icon, String tooltip, {VoidCallback? onPressed, double? iconSize}) => IconButton(
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
      color: AppGlobalConfig.trackStateBackgroundColors(context)[state],
      child: Row(children: [
        Icon(AppGlobalConfig.trackStateIcons()[state], size: 12),
        SizedBox(width: iconToTextOffset),
        Text(message, style: TextStyle(color: AppGlobalConfig.trackStateForegroundColors(context)[state]))
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
    double currentValue,
    double minValue,
    double maxValue,
    int divisions,
    String cancelLabel,
    String saveLabel, {
    required String Function(double value, String formattedValue) successAction,
    required String Function(double value) valueFormatter,
    String Function(double value, AppLocalizations trans)? valueTranslator,
    AppLocalizations? trans,
    bool withTrailing = true,
  }) {
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        trailing: (withTrailing == true) ? trailingLabel(valueFormatter(currentValue)) : null,
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
                                  label:
                                      (trans.toString() != 'null' && valueTranslator.toString() != 'null' && valueTranslator != null && trans != null)
                                          ? valueTranslator(currentValue, trans)
                                          : valueFormatter(currentValue),
                                  onChanged: (double newValue) {
                                    setModalState(() {
                                      currentValue = newValue;
                                    });
                                  }),
                              Text(valueFormatter(currentValue)),
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
                                      (trans.toString() != 'null' && valueTranslator.toString() != 'null' && valueTranslator != null && trans != null)
                                          ? valueTranslator(currentValue, trans)
                                          : valueFormatter(currentValue)),
                                  icon: icon);
                            }),
                          ])));
        });
  }

  ListTile listTileRadio(
    IconData icon,
    String listTitle,
    String? listSubtitle,
    String dialogTitle,
    String dialogInfo,
    double currentValue,
    List<double> values,
    String cancelLabel,
    String saveLabel, {
    required String Function(double value, String formattedValue) successAction,
    bool withTrailing = true,
    required String Function(double value) valueFormatter,
    String Function(double value, AppLocalizations trans)? valueTranslator,
    AppLocalizations? trans,
  }) {
    double sliderValue = values.indexOf(currentValue).toDouble();

    List<Widget> subtitle = [];
    if (listSubtitle != null) {
      subtitle.add(Text(listSubtitle, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    String translatedValue = (trans.toString() != 'null' && valueTranslator.toString() != 'null' && valueTranslator != null && trans != null)
        ? valueTranslator(currentValue, trans)
        : valueFormatter(currentValue);
    if (translatedValue != '') {
      subtitle.add(Text(translatedValue, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    return ListTile(
        leading: Icon(icon),
        title: Text(listTitle),
        subtitle: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: subtitle.toList()),
        trailing: (withTrailing == true) ? trailingLabel(valueFormatter(currentValue)) : null,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) => AlertDialog(
                          title: ListTile(
                            leading: Icon(icon),
                            title: Text(dialogTitle),
                          ),
                          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Text(dialogInfo),
                            Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Slider(
                                  value: sliderValue,
                                  min: 0,
                                  max: (values.length - 1).toDouble(),
                                  divisions: (values.length - 1),
                                  label:
                                      (trans.toString() != 'null' && valueTranslator.toString() != 'null' && valueTranslator != null && trans != null)
                                          ? valueTranslator(currentValue, trans)
                                          : valueFormatter(currentValue),
                                  onChanged: (double newValue) {
                                    setModalState(() {
                                      sliderValue = newValue;
                                      currentValue = values[sliderValue.toInt()];
                                    });
                                  }),
                              Text(valueFormatter(currentValue)),
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
                                      (trans.toString() != 'null' && valueTranslator.toString() != 'null' && valueTranslator != null && trans != null)
                                          ? valueTranslator(currentValue, trans)
                                          : valueFormatter(currentValue)),
                                  icon: icon);
                            }),
                          ])));
        });
  }

  ListTile listTileSwitch(IconData icon, String listTitle, IconData disabledIcon, String disabledLabel, IconData enabledIcon, String enabledLabel,
      bool switchValue, String? Function(bool value) successAction,
      {String? subtitleText}) {
    List<Widget> subtitle = [];
    if (subtitleText != null) {
      subtitle.add(Text(subtitleText, style: TextStyle(fontSize: settingsSubtitleFontSize)));
    }
    subtitle.add(Row(children: [
      Icon(disabledIcon, size: settingsSubtitleIconSize),
      Text(disabledLabel, style: TextStyle(fontSize: settingsSubtitleFontSize)),
      Text(' '),
      Icon(enabledIcon, size: settingsSubtitleIconSize),
      Text(enabledLabel, style: TextStyle(fontSize: settingsSubtitleFontSize)),
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
}
