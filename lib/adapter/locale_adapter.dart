import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  final typeId = 1;

  @override
  Locale read(BinaryReader reader) {
    final index = reader.readString();
    var tmp = index.split('-');
    var locale = Locale(tmp[0], tmp[1]);
    return locale;
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer.writeString(obj.toLanguageTag());
  }
}
