// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_translation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedTranslationAdapter extends TypeAdapter<CachedTranslation> {
  @override
  final int typeId = 2;

  @override
  CachedTranslation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedTranslation(
      translationKey: fields[0] as String,
      surahNumber: fields[1] as int,
      verses: (fields[2] as List).cast<String>(),
      footnotes: (fields[3] as List).cast<String>(),
      cachedAtMillis: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedTranslation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.translationKey)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.verses)
      ..writeByte(3)
      ..write(obj.footnotes)
      ..writeByte(4)
      ..write(obj.cachedAtMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedTranslationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
