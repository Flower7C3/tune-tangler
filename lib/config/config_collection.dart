import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigCollection {
  final List<ConfigItem> items;

  final dynamic defaultValue;
  final dynamic Function(dynamic value) valueFormatter;
  final dynamic Function(dynamic value) valueDecoder;

  ConfigCollection(
    this.items, {
    this.defaultValue,
    this.valueFormatter = _defaultValueFormatter,
    this.valueDecoder = _defaultValueDecoder,
  });

  Iterable<T> values<T>() => items.map((item) => item.value as T);

  valueAt<T>(int index) => values().elementAt(index);

  Iterable<String?> get names => items.map((item) => item.name);

  Iterable<IconData?> get icons => items.map((item) => item.icon);

  Iterable<ConfigItem> get(dynamic value) => items.where((item) => item.value == value);

  String name(dynamic value) => get(value).first.name.toString();

  IconData icon(dynamic value, {IconData defaultValue = Icons.add}) => iconOrNull(value) ?? defaultValue;

  IconData? iconOrNull(dynamic value) => get(value).first.icon;

  String translation(dynamic value, {required AppLocalizations trans, String? defaultValue}) =>
      translationOrNull(value, trans: trans) ?? (defaultValue ?? '');

  String? translationOrNull(dynamic value, {required AppLocalizations trans}) => get(value).first.translation?.call(trans);

  Color color(dynamic value, {required BuildContext context, required Color defaultValue}) => colorOrNull(value, context: context) ?? defaultValue;

  Color? colorOrNull(dynamic value, {required BuildContext context}) => get(value).first.color?.call(context);

  static dynamic _defaultValueFormatter(dynamic value) => value.toString();

  static dynamic _defaultValueDecoder(dynamic value) => value;
}

class SliderConfigCollection extends ConfigCollection {
  final ConfigSliderValues sliderValues;

  SliderConfigCollection(
    super.items, {
    super.defaultValue,
    super.valueFormatter,
    super.valueDecoder,
    required this.sliderValues,
  });
}

class ConfigItem {
  final dynamic value;
  final IconData? icon;
  final String? name;
  final String Function(AppLocalizations)? translation;
  final Color Function(BuildContext)? color;

  ConfigItem(this.value, {this.icon, this.name, this.translation, this.color});
}

class ConfigSliderValues {
  final double min;
  final double max;
  final int divisions;

  ConfigSliderValues(this.min, this.max, this.divisions);
}
