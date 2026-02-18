import 'package:hive/hive.dart';

part 'daily_record.g.dart';

/// Status of a prayer.
enum PrayerStatus { pending, onTime, late_, missed }

/// A single day's spiritual record.
@HiveType(typeId: 0)
class DailyRecord extends HiveObject {
  @HiveField(0)
  final String dateKey; // 'yyyy-MM-dd'

  @HiveField(1)
  Map<String, int> prayerStatuses; // PrayerName -> PrayerStatus index

  @HiveField(2)
  int quranPagesRead;

  @HiveField(3)
  int quranJuzCompleted;

  @HiveField(4)
  bool listenedToRecitation;

  @HiveField(5)
  int versesMemorized;

  @HiveField(6)
  bool readTafsir;

  @HiveField(7)
  Map<String, int> zikrCounts; // ZikrType -> count

  @HiveField(8)
  bool morningAdhkar;

  @HiveField(9)
  bool eveningAdhkar;

  @HiveField(10)
  bool personalDua;

  @HiveField(11)
  bool duaBeforeAfterEating;

  @HiveField(12)
  bool fastingCompleted;

  @HiveField(13)
  bool ateSuhoor;

  @HiveField(14)
  bool brokeWithDates;

  @HiveField(15)
  bool avoidedGossip;

  @HiveField(16)
  bool controlledAnger;

  @HiveField(17)
  bool loweredGaze;

  @HiveField(18)
  List<String> goodDeeds; // list of completed deed IDs

  @HiveField(19)
  String? reflectionNote;

  @HiveField(20)
  int khushuRating; // 1-5

  @HiveField(21)
  String? gratitudeNote;

  @HiveField(22)
  String? bestDeedNote;

  @HiveField(23)
  String? improvementNote;

  @HiveField(24)
  double? charityAmount;

  @HiveField(25)
  bool attendedLecture;

  @HiveField(26)
  bool readIslamicBook;

  @HiveField(27)
  bool sharedKnowledge;

  /// The last Quran page the user read — bookmark for the next session.
  /// Nullable for backward-compatibility with records written before this field existed.
  @HiveField(28)
  int? quranLastPage;

  DailyRecord({
    required this.dateKey,
    Map<String, int>? prayerStatuses,
    this.quranPagesRead = 0,
    this.quranLastPage,
    this.quranJuzCompleted = 0,
    this.listenedToRecitation = false,
    this.versesMemorized = 0,
    this.readTafsir = false,
    Map<String, int>? zikrCounts,
    this.morningAdhkar = false,
    this.eveningAdhkar = false,
    this.personalDua = false,
    this.duaBeforeAfterEating = false,
    this.fastingCompleted = false,
    this.ateSuhoor = false,
    this.brokeWithDates = false,
    this.avoidedGossip = false,
    this.controlledAnger = false,
    this.loweredGaze = false,
    List<String>? goodDeeds,
    this.reflectionNote,
    this.khushuRating = 0,
    this.gratitudeNote,
    this.bestDeedNote,
    this.improvementNote,
    this.charityAmount,
    this.attendedLecture = false,
    this.readIslamicBook = false,
    this.sharedKnowledge = false,
  }) : prayerStatuses =
           prayerStatuses ??
           {
             'fajr': 0,
             'dhuhr': 0,
             'asr': 0,
             'maghrib': 0,
             'isha': 0,
             'tarawih': 0,
             'tahajjud': 0,
             'duha': 0,
             'sunnahRawatib': 0,
           },
       zikrCounts = zikrCounts ?? {},
       goodDeeds = goodDeeds ?? [];

  /// Calculate the daily spiritual score (0-100).
  double get dailyScore {
    double score = 0;

    // Prayers (max 40 points)
    final prayerPoints = {
      'fajr': 8.0,
      'dhuhr': 6.0,
      'asr': 6.0,
      'maghrib': 6.0,
      'isha': 6.0,
      'tarawih': 5.0,
      'tahajjud': 3.0,
    };
    for (final entry in prayerPoints.entries) {
      final status = prayerStatuses[entry.key] ?? 0;
      if (status == PrayerStatus.onTime.index) {
        score += entry.value;
      } else if (status == PrayerStatus.late_.index) {
        score += entry.value * 0.5;
      }
    }

    // Quran (max 15 points)
    score += (quranPagesRead.clamp(0, 20) / 20) * 10;
    if (listenedToRecitation) score += 2;
    if (readTafsir) score += 3;

    // Zikr & Dua (max 15 points)
    if (morningAdhkar) score += 3;
    if (eveningAdhkar) score += 3;
    final subhanAllah = (zikrCounts['subhanAllah'] ?? 0).clamp(0, 33);
    final alhamdulillah = (zikrCounts['alhamdulillah'] ?? 0).clamp(0, 33);
    final allahuAkbar = (zikrCounts['allahuAkbar'] ?? 0).clamp(0, 33);
    score += ((subhanAllah + alhamdulillah + allahuAkbar) / 99) * 5;
    if (personalDua) score += 2;
    if (duaBeforeAfterEating) score += 2;

    // Fasting & Self-Discipline (max 15 points)
    if (fastingCompleted) score += 6;
    if (ateSuhoor) score += 2;
    if (avoidedGossip) score += 3;
    if (controlledAnger) score += 2;
    if (loweredGaze) score += 2;

    // Good Deeds (max 10 points)
    score += (goodDeeds.length.clamp(0, 5) / 5) * 8;
    if (charityAmount != null && charityAmount! > 0) score += 2;

    // Knowledge (max 5 points)
    if (attendedLecture) score += 2;
    if (readIslamicBook) score += 1.5;
    if (sharedKnowledge) score += 1.5;

    return score.clamp(0, 100);
  }

  /// Prayer completion percentage for the 5 obligatory prayers.
  double get prayerCompletionRate {
    int completed = 0;
    for (final name in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      final status = prayerStatuses[name] ?? 0;
      if (status == PrayerStatus.onTime.index ||
          status == PrayerStatus.late_.index) {
        completed++;
      }
    }
    return completed / 5;
  }
}
