import 'package:hive/hive.dart';

part 'quran_bookmark.g.dart';

@HiveType(typeId: 3)
class QuranBookmark extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int surahNumber;

  @HiveField(2)
  final int ayahNumber;

  @HiveField(3)
  final int page;

  @HiveField(4)
  final String surahNameEn;

  @HiveField(5)
  final String label;

  @HiveField(6)
  final int createdAtMillis;

  QuranBookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.surahNameEn,
    this.label = '',
    required this.createdAtMillis,
  });

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
}
