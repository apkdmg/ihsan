// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      zoneCode: fields[1] as String,
      zoneName: fields[2] as String,
      quranDailyGoal: fields[3] as int,
      ramadanStartDate: fields[4] as String,
      currentStreak: fields[5] as int,
      longestStreak: fields[6] as int,
      onboardingComplete: fields[7] as bool,
      latitude: fields[8] as double?,
      longitude: fields[9] as double?,
      quranStartPage: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.zoneCode)
      ..writeByte(2)
      ..write(obj.zoneName)
      ..writeByte(3)
      ..write(obj.quranDailyGoal)
      ..writeByte(4)
      ..write(obj.ramadanStartDate)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.longestStreak)
      ..writeByte(7)
      ..write(obj.onboardingComplete)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.longitude)
      ..writeByte(10)
      ..write(obj.quranStartPage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
