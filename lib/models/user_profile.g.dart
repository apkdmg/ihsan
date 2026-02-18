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
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return UserProfile(
      name: fields[0] as String? ?? '',
      zoneCode: fields[1] as String? ?? 'WLY01',
      zoneName: fields[2] as String? ?? 'Kuala Lumpur',
      quranDailyGoal: fields[3] as int? ?? 20,
      ramadanStartDate: fields[4] as String? ?? '',
      currentStreak: fields[5] as int? ?? 0,
      longestStreak: fields[6] as int? ?? 0,
      onboardingComplete: fields[7] as bool? ?? false,
      latitude: fields[8] as double?,
      longitude: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.longitude);
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
