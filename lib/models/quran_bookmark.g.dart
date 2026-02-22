// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuranBookmarkAdapter extends TypeAdapter<QuranBookmark> {
  @override
  final int typeId = 3;

  @override
  QuranBookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranBookmark(
      id: fields[0] as String,
      surahNumber: fields[1] as int,
      ayahNumber: fields[2] as int,
      page: fields[3] as int,
      surahNameEn: fields[4] as String,
      label: fields[5] as String,
      createdAtMillis: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuranBookmark obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.ayahNumber)
      ..writeByte(3)
      ..write(obj.page)
      ..writeByte(4)
      ..write(obj.surahNameEn)
      ..writeByte(5)
      ..write(obj.label)
      ..writeByte(6)
      ..write(obj.createdAtMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranBookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
