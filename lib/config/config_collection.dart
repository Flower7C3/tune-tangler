import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ConfigItemPropertyName {
  defaultProperty,
  foregroundColor,
  backgroundColor,
  progressColor,
}

final class ConfigCollection {
  final List<ConfigItem> items;

  final dynamic defaultValue;

  ConfigCollection(
    this.items, {
    this.defaultValue,
    this.format = _defaultValueFormatter,
    this.decode = _defaultValueDecoder,
  });

  Iterable<T> values<T>() => items.map((item) => item.value as T);

  valueAt<T>(int index) => values().elementAt(index);

  Iterable<ConfigItem> _getByValue(dynamic value) => items.where((item) => item.value == value);

  String text(dynamic value, {ConfigItemPropertyName name = ConfigItemPropertyName.defaultProperty}) =>
      _getByValue(value).first.properties.whereType<ConfigItemTextProperty>().firstWhere((property) => (property.name == name)).text;

  IconData icon(dynamic value, {ConfigItemPropertyName name = ConfigItemPropertyName.defaultProperty}) =>
      _getByValue(value).first.properties.whereType<ConfigItemIconProperty>().firstWhere((property) => (property.name == name)).icon;

  Color color(dynamic value, {required BuildContext context, ConfigItemPropertyName name = ConfigItemPropertyName.defaultProperty}) =>
      _getByValue(value)
          .first
          .properties
          .whereType<ConfigItemColorProperty>()
          .firstWhere((property) => (property.name == name))
          .callback
          .call(context);

  String translate(dynamic value, {required AppLocalizations trans, ConfigItemPropertyName name = ConfigItemPropertyName.defaultProperty}) =>
      _getByValue(value)
          .first
          .properties
          .whereType<ConfigItemTranslatableProperty>()
          .firstWhere((property) => (property.name == name))
          .callback
          .call(trans);

  final dynamic Function(dynamic value) format;
  final dynamic Function(dynamic value) decode;

  static dynamic _defaultValueFormatter(dynamic value) => value.toString();

  static dynamic _defaultValueDecoder(dynamic value) => value;
}

final class SliderConfigCollection extends ConfigCollection {
  final ConfigSliderValues sliderValues;

  SliderConfigCollection(
    super.items, {
    super.defaultValue,
    super.format,
    super.decode,
    required this.sliderValues,
  });
}

final class ConfigItem<T> {
  final T value;
  final List<ConfigItemProperty> properties;

  ConfigItem(this.value, {required this.properties});
}

abstract final class ConfigItemProperty {
  ConfigItemPropertyName name = ConfigItemPropertyName.defaultProperty;

  ConfigItemProperty(this.name);
}

final class ConfigItemColorProperty extends ConfigItemProperty {
  final Function(BuildContext) callback;

  ConfigItemColorProperty(this.callback, {name = ConfigItemPropertyName.defaultProperty}) : super(name);
}

final class ConfigItemIconProperty extends ConfigItemProperty {
  final IconData icon;

  ConfigItemIconProperty(this.icon, {name = ConfigItemPropertyName.defaultProperty}) : super(name);
}

final class ConfigItemTextProperty extends ConfigItemProperty {
  final String text;

  ConfigItemTextProperty(this.text, {name = ConfigItemPropertyName.defaultProperty}) : super(name);
}

final class ConfigItemTranslatableProperty extends ConfigItemProperty {
  final Function(AppLocalizations) callback;

  ConfigItemTranslatableProperty(this.callback, {name = ConfigItemPropertyName.defaultProperty}) : super(name);
}

final class ConfigSliderValues {
  final double min;
  final double max;
  final int divisions;

  ConfigSliderValues(this.min, this.max, this.divisions);
}
