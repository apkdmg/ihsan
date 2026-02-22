import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String zoneCode; // JAKIM zone code e.g., 'SGR01'

  @HiveField(2)
  String zoneName; // Human-readable e.g., 'Selangor - Gombak'

  @HiveField(3)
  int quranDailyGoal; // pages per day

  @HiveField(4)
  String ramadanStartDate; // yyyy-MM-dd

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  int longestStreak;

  @HiveField(7)
  bool onboardingComplete;

  @HiveField(8)
  double? latitude;

  @HiveField(9)
  double? longitude;

  @HiveField(10)
  int? quranStartPage;

  @HiveField(11)
  String? preferredTranslationKey;

  @HiveField(12)
  int? quranStopSurah;

  @HiveField(13)
  int? quranStopAyah;

  @HiveField(14)
  int? quranStopPage;

  UserProfile({
    this.name = '',
    this.zoneCode = 'WLY01',
    this.zoneName = 'Kuala Lumpur',
    this.quranDailyGoal = 20,
    this.ramadanStartDate = '', // auto-detected from Hijri date
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.onboardingComplete = false,
    this.latitude,
    this.longitude,
    this.quranStartPage = 1,
    this.preferredTranslationKey = 'english_saheeh',
    this.quranStopSurah,
    this.quranStopAyah,
    this.quranStopPage,
  });

  /// Get the current day of Ramadan (1-30).
  /// Returns 1 if ramadanStartDate is not yet set.
  int get currentRamadanDay {
    if (ramadanStartDate.isEmpty) return 1;
    try {
      final start = DateTime.parse(ramadanStartDate);
      final now = DateTime.now();
      final diff = now.difference(start).inDays + 1;
      return diff.clamp(1, 30);
    } catch (_) {
      return 1;
    }
  }

  /// Get the current Ramadan week (1-4).
  int get currentWeek {
    return ((currentRamadanDay - 1) ~/ 7) + 1;
  }

  /// Current coaching phase key.
  String get coachingPhase {
    final week = currentWeek;
    if (week <= 1) return 'week1';
    if (week <= 2) return 'week2';
    if (week <= 3) return 'week3';
    return 'week4';
  }

  /// Whether we are currently within the 30-day Ramadan window.
  bool get isRamadanActive {
    if (ramadanStartDate.isEmpty) return false;
    try {
      final start = DateTime.parse(ramadanStartDate);
      final end = start.add(const Duration(days: 29)); // Day 1 → Day 30
      final today = DateTime.now();
      return !today.isBefore(start) && !today.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  /// Approximate Gregorian date of the next Ramadan.
  /// Populated automatically from the Hijri date in the prayer times API.
  /// Returns null if prayer times haven't been fetched yet.
  DateTime? get nextRamadanEstimate {
    if (ramadanStartDate.isEmpty) return null;
    try {
      return DateTime.parse(ramadanStartDate);
    } catch (_) {
      return null;
    }
  }

  /// Days until next Ramadan. Negative means we're inside Ramadan.
  int get daysUntilRamadan {
    final next = nextRamadanEstimate;
    if (next == null) return -1;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return next.difference(today).inDays;
  }
}
