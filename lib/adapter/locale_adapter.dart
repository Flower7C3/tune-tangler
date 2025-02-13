import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  get typeId => 102;

  @override
  Locale read(BinaryReader reader) {
    final index = reader.readString().split('-');
    return Locale(index[0], index[1]);
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer.writeString(obj.toLanguageTag());
  }
}
