import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  get typeId => 102;

  @override
  Locale read(BinaryReader reader) {
    final parts = reader.readString().split('-');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer.writeString(obj.toLanguageTag());
  }
}
