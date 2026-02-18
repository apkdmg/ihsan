// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 0;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return DailyRecord(
      dateKey: fields[0] as String,
      prayerStatuses: (fields[1] as Map?)?.cast<String, int>(),
      quranPagesRead: fields[2] as int? ?? 0,
      quranLastPage: fields[28] as int? ?? 0,
      quranJuzCompleted: fields[3] as int? ?? 0,
      listenedToRecitation: fields[4] as bool? ?? false,
      versesMemorized: fields[5] as int? ?? 0,
      readTafsir: fields[6] as bool? ?? false,
      zikrCounts: (fields[7] as Map?)?.cast<String, int>(),
      morningAdhkar: fields[8] as bool? ?? false,
      eveningAdhkar: fields[9] as bool? ?? false,
      personalDua: fields[10] as bool? ?? false,
      duaBeforeAfterEating: fields[11] as bool? ?? false,
      fastingCompleted: fields[12] as bool? ?? false,
      ateSuhoor: fields[13] as bool? ?? false,
      brokeWithDates: fields[14] as bool? ?? false,
      avoidedGossip: fields[15] as bool? ?? false,
      controlledAnger: fields[16] as bool? ?? false,
      loweredGaze: fields[17] as bool? ?? false,
      goodDeeds: (fields[18] as List?)?.cast<String>(),
      reflectionNote: fields[19] as String?,
      khushuRating: fields[20] as int? ?? 0,
      gratitudeNote: fields[21] as String?,
      bestDeedNote: fields[22] as String?,
      improvementNote: fields[23] as String?,
      charityAmount: fields[24] as double?,
      attendedLecture: fields[25] as bool? ?? false,
      readIslamicBook: fields[26] as bool? ?? false,
      sharedKnowledge: fields[27] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.prayerStatuses)
      ..writeByte(2)
      ..write(obj.quranPagesRead)
      ..writeByte(3)
      ..write(obj.quranJuzCompleted)
      ..writeByte(4)
      ..write(obj.listenedToRecitation)
      ..writeByte(5)
      ..write(obj.versesMemorized)
      ..writeByte(6)
      ..write(obj.readTafsir)
      ..writeByte(7)
      ..write(obj.zikrCounts)
      ..writeByte(8)
      ..write(obj.morningAdhkar)
      ..writeByte(9)
      ..write(obj.eveningAdhkar)
      ..writeByte(10)
      ..write(obj.personalDua)
      ..writeByte(11)
      ..write(obj.duaBeforeAfterEating)
      ..writeByte(12)
      ..write(obj.fastingCompleted)
      ..writeByte(13)
      ..write(obj.ateSuhoor)
      ..writeByte(14)
      ..write(obj.brokeWithDates)
      ..writeByte(15)
      ..write(obj.avoidedGossip)
      ..writeByte(16)
      ..write(obj.controlledAnger)
      ..writeByte(17)
      ..write(obj.loweredGaze)
      ..writeByte(18)
      ..write(obj.goodDeeds)
      ..writeByte(19)
      ..write(obj.reflectionNote)
      ..writeByte(20)
      ..write(obj.khushuRating)
      ..writeByte(21)
      ..write(obj.gratitudeNote)
      ..writeByte(22)
      ..write(obj.bestDeedNote)
      ..writeByte(23)
      ..write(obj.improvementNote)
      ..writeByte(24)
      ..write(obj.charityAmount)
      ..writeByte(25)
      ..write(obj.attendedLecture)
      ..writeByte(26)
      ..write(obj.readIslamicBook)
      ..writeByte(27)
      ..write(obj.sharedKnowledge)
      ..writeByte(28)
      ..write(obj.quranLastPage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
