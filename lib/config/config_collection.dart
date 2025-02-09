import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ConfigItemPropertyDomain {
  defaultProperty,
  foregroundColor,
  backgroundColor,
  progressColor,
  shortName,
  extension,
  info,
  details,
  icon,
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

  String text(dynamic value, {ConfigItemPropertyDomain domain = ConfigItemPropertyDomain.defaultProperty}) =>
      _getByValue(value).first.properties.whereType<ConfigItemTextProperty>().firstWhere((property) => (property.domain == domain)).text;

  IconData icon(dynamic value, {ConfigItemPropertyDomain domain = ConfigItemPropertyDomain.defaultProperty}) =>
      _getByValue(value).first.properties.whereType<ConfigItemIconProperty>().firstWhere((property) => (property.domain == domain)).icon;

  Color color(dynamic value, {required BuildContext context, ConfigItemPropertyDomain domain = ConfigItemPropertyDomain.defaultProperty}) =>
      _getByValue(value)
          .first
          .properties
          .whereType<ConfigItemColorProperty>()
          .firstWhere((property) => (property.domain == domain))
          .callback
          .call(context);

  String translate(dynamic value, {required AppLocalizations trans, ConfigItemPropertyDomain domain = ConfigItemPropertyDomain.defaultProperty}) =>
      _getByValue(value).firstOrNull == null
          ? ''
          : _getByValue(value)
              .first
              .properties
              .whereType<ConfigItemTranslatableProperty>()
              .firstWhere((property) => (property.domain == domain))
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
  ConfigItemPropertyDomain domain = ConfigItemPropertyDomain.defaultProperty;

  ConfigItemProperty(this.domain);
}

final class ConfigItemColorProperty extends ConfigItemProperty {
  final Function(BuildContext) callback;

  ConfigItemColorProperty(this.callback, {domain = ConfigItemPropertyDomain.defaultProperty}) : super(domain);
}

final class ConfigItemIconProperty extends ConfigItemProperty {
  final IconData icon;

  ConfigItemIconProperty(this.icon, {domain = ConfigItemPropertyDomain.defaultProperty}) : super(domain);
}

final class ConfigItemTextProperty extends ConfigItemProperty {
  final String text;

  ConfigItemTextProperty(this.text, {domain = ConfigItemPropertyDomain.defaultProperty}) : super(domain);
}

final class ConfigItemTranslatableProperty extends ConfigItemProperty {
  final Function(AppLocalizations) callback;

  ConfigItemTranslatableProperty(this.callback, {domain = ConfigItemPropertyDomain.defaultProperty}) : super(domain);
}

final class ConfigSliderValues {
  final double min;
  final double max;
  final int? divisions;

  ConfigSliderValues({required this.min, required this.max, this.divisions});
}
