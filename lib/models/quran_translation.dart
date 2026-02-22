import 'package:hive/hive.dart';

part 'quran_translation.g.dart';

@HiveType(typeId: 2)
class CachedTranslation extends HiveObject {
  @HiveField(0)
  final String translationKey;

  @HiveField(1)
  final int surahNumber;

  @HiveField(2)
  final List<String> verses;

  @HiveField(3)
  final List<String> footnotes;

  @HiveField(4)
  final int cachedAtMillis;

  CachedTranslation({
    required this.translationKey,
    required this.surahNumber,
    required this.verses,
    required this.footnotes,
    required this.cachedAtMillis,
  });

  String get cacheKey => '${translationKey}_$surahNumber';

  bool get isStale {
    final age = DateTime.now().millisecondsSinceEpoch - cachedAtMillis;
    return age > 30 * 24 * 60 * 60 * 1000;
  }
}
