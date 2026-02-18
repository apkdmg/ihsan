import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waktu_solat_lib/waktu_solat_lib.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';

// ── Strongly-typed prayer data used by the UI ──
class TodayPrayerTimes {
  final DateTime imsak;
  final DateTime fajr;
  final DateTime syuruk;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String hijriDate;
  final String zoneCode;
  final DateTime fetchedAt;

  const TodayPrayerTimes({
    required this.imsak,
    required this.fajr,
    required this.syuruk,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.zoneCode,
    required this.fetchedAt,
  });

  /// Which prayer is next, based on current time.
  String get nextPrayerName {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return 'Fajr';
    if (now.isBefore(dhuhr)) return 'Dhuhr';
    if (now.isBefore(asr)) return 'Asr';
    if (now.isBefore(maghrib)) return 'Maghrib';
    if (now.isBefore(isha)) return 'Isha';
    return 'Fajr'; // Tomorrow's Fajr
  }

  /// Time remaining until next prayer.
  Duration get timeToNextPrayer {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return fajr.difference(now);
    if (now.isBefore(dhuhr)) return dhuhr.difference(now);
    if (now.isBefore(asr)) return asr.difference(now);
    if (now.isBefore(maghrib)) return maghrib.difference(now);
    if (now.isBefore(isha)) return isha.difference(now);
    // Tomorrow's Fajr (approximate + 24h)
    return fajr.add(const Duration(days: 1)).difference(now);
  }

  /// True if currently in fasting hours (between Imsak → Maghrib).
  bool get isFastingTime {
    final now = DateTime.now();
    return now.isAfter(imsak) && now.isBefore(maghrib);
  }

  /// Duration until Iftar (Maghrib) or Suhoor (Imsak).
  Duration get fastingCountdown {
    final now = DateTime.now();
    if (now.isBefore(imsak)) {
      return imsak.difference(now); // Time until suhoor ends
    } else if (now.isBefore(maghrib)) {
      return maghrib.difference(now); // Time until iftar
    } else {
      // After maghrib — show tomorrow's imsak estimate (approx same time)
      return imsak.add(const Duration(days: 1)).difference(now);
    }
  }

  /// Formatted time string for a prayer.
  String formattedTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  /// List of all 5 obligatory prayer times for display.
  List<({String name, DateTime time, String formatted})>
  get obligatoryPrayers => [
    (name: 'Fajr', time: fajr, formatted: formattedTime(fajr)),
    (name: 'Dhuhr', time: dhuhr, formatted: formattedTime(dhuhr)),
    (name: 'Asr', time: asr, formatted: formattedTime(asr)),
    (name: 'Maghrib', time: maghrib, formatted: formattedTime(maghrib)),
    (name: 'Isha', time: isha, formatted: formattedTime(isha)),
  ];

  /// All times including imsak and syuruk.
  List<({String name, DateTime time, String formatted})> get allTimes => [
    (name: 'Imsak', time: imsak, formatted: formattedTime(imsak)),
    (name: 'Fajr', time: fajr, formatted: formattedTime(fajr)),
    (name: 'Syuruk', time: syuruk, formatted: formattedTime(syuruk)),
    (name: 'Dhuhr', time: dhuhr, formatted: formattedTime(dhuhr)),
    (name: 'Asr', time: asr, formatted: formattedTime(asr)),
    (name: 'Maghrib', time: maghrib, formatted: formattedTime(maghrib)),
    (name: 'Isha', time: isha, formatted: formattedTime(isha)),
  ];

  // ── Hijri Date & Ramadan Logic ──

  /// Parsed Hijri year, month, day. Returns null on parse failure.
  (int year, int month, int day)? get hijriParts {
    try {
      final parts = hijriDate.split('-');
      if (parts.length < 3) return null;
      return (int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return null;
    }
  }

  /// Whether current time is past Maghrib (Islamic day has transitioned).
  bool get isAfterMaghrib => DateTime.now().isAfter(maghrib);

  /// The effective Hijri month, accounting for Maghrib day transition.
  /// After Maghrib, the Islamic day advances:
  ///   - Sha'ban 30 after Maghrib → Ramadan 1
  ///   - Ramadan 29 after Maghrib → could be Ramadan 30 or Shawwal 1
  int? get effectiveHijriMonth {
    final parsed = hijriParts;
    if (parsed == null) return null;
    final (_, hMonth, hDay) = parsed;
    if (!isAfterMaghrib) return hMonth;

    // After Maghrib: determine if the Islamic day has moved to the next month.
    // The API day tells us the real month length (if API says day 30, month has 30 days).
    // Standard Hijri months have 29 or 30 days. If hDay == 30 or hDay == 29,
    // we can't be 100% sure it's the last day unless hDay == 30 (definitely last).
    // For hDay == 29, the month might have 30 days. We conservatively only advance
    // when hDay == 30 (guaranteed last day).
    if (hDay >= 30) {
      return (hMonth % 12) + 1; // next month, wrapping 12 → 1
    }
    return hMonth;
  }

  /// The effective Hijri day, accounting for Maghrib day transition.
  int? get effectiveHijriDay {
    final parsed = hijriParts;
    if (parsed == null) return null;
    final (_, hMonth, hDay) = parsed;
    if (!isAfterMaghrib) return hDay;

    if (hDay >= 30) return 1; // rolled over to next month day 1
    return hDay + 1; // same month, next day
  }

  /// Whether we are currently in Ramadan.
  /// Uses the effective Hijri date (after Maghrib = next Islamic day).
  bool get isRamadan => effectiveHijriMonth == 9;

  /// Which day of Ramadan (1-30). Returns null if not Ramadan.
  int? get ramadanDay {
    if (!isRamadan) return null;
    return effectiveHijriDay;
  }

  /// Days until Ramadan 1, computed directly from the Hijri date.
  /// Returns 0 if we're in Ramadan.
  /// Uses the API Hijri date (before Maghrib) or effective date (after Maghrib).
  int get daysUntilRamadan {
    final parsed = hijriParts;
    if (parsed == null) return -1;

    final hMonth = effectiveHijriMonth ?? parsed.$2;
    final hDay = effectiveHijriDay ?? parsed.$3;

    if (hMonth == 9) return 0; // We're in Ramadan

    if (hMonth < 9) {
      // Count days remaining in current month + intermediate months
      // For current month length: use the max of tabular and API day
      // (if API says day 30, the month clearly has 30 days)
      final tabular = hMonth.isOdd ? 30 : 29;
      final currentMonthLength = tabular < hDay ? hDay : tabular;
      int days = currentMonthLength - hDay; // remaining in current month
      // Add full months between current+1 and Sha'ban (month 8)
      for (int m = hMonth + 1; m <= 8; m++) {
        days += m.isOdd ? 30 : 29;
      }
      return days + 1; // +1 to land on Ramadan Day 1
    } else {
      // hMonth > 9: Ramadan passed, count to NEXT year's Ramadan
      final tabular = hMonth.isOdd ? 30 : 29;
      final currentMonthLength = tabular < hDay ? hDay : tabular;
      int days = currentMonthLength - hDay;
      // Remaining months this Hijri year
      for (int m = hMonth + 1; m <= 12; m++) {
        days += m.isOdd ? 30 : 29;
      }
      // All months of next year up to Sha'ban
      for (int m = 1; m <= 8; m++) {
        days += m.isOdd ? 30 : 29;
      }
      return days + 1;
    }
  }

  /// Estimated Gregorian date of the next Ramadan Day 1.
  /// Computed as today + daysUntilRamadan.
  String? get nextRamadanStartGregorian {
    final days = daysUntilRamadan;
    if (days < 0) return null;
    if (days == 0 && isRamadan) {
      // Back-calculate the Gregorian date when Ramadan started
      final day = ramadanDay ?? 1;
      final ramadanDay1 = DateTime.now().subtract(Duration(days: day - 1));
      return DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(ramadanDay1.year, ramadanDay1.month, ramadanDay1.day));
    }
    final today = DateTime.now();
    final gregorianDate = DateTime(today.year, today.month, today.day);
    final ramadanDay1 = gregorianDate.add(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(ramadanDay1);
  }

  /// Alias for backward compatibility.
  String? get ramadanStartGregorian => nextRamadanStartGregorian;
}

// ── Cache box name ──
const String _cacheBox = 'prayer_times_cache';

// ── Riverpod provider ──
final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, TodayPrayerTimes?>(
      PrayerTimesNotifier.new,
    );

class PrayerTimesNotifier extends AsyncNotifier<TodayPrayerTimes?> {
  final WaktuSolatClient _client = WaktuSolatClient();

  @override
  Future<TodayPrayerTimes?> build() async {
    final profile = ref.watch(userProfileProvider);
    if (!profile.onboardingComplete || profile.zoneCode.isEmpty) return null;
    return _fetchForToday(profile.zoneCode);
  }

  /// Updates [userProfileProvider] with the detected Ramadan start date.
  /// Called for both cached and fresh API results.
  void _updateRamadanStartIfNeeded(TodayPrayerTimes result) {
    final detectedStart = result.ramadanStartGregorian;
    if (detectedStart == null) return;
    final profile = ref.read(userProfileProvider);
    if (profile.ramadanStartDate == detectedStart) return;
    ref
        .read(userProfileProvider.notifier)
        .update(
          (p) => UserProfile(
            name: p.name,
            zoneCode: p.zoneCode,
            zoneName: p.zoneName,
            quranDailyGoal: p.quranDailyGoal,
            ramadanStartDate: detectedStart,
            currentStreak: p.currentStreak,
            longestStreak: p.longestStreak,
            onboardingComplete: p.onboardingComplete,
            latitude: p.latitude,
            longitude: p.longitude,
          ),
        );
  }

  Future<TodayPrayerTimes?> _fetchForToday(String zoneCode) async {
    final today = DateTime.now();
    final cacheKey = '${zoneCode}_${DateFormat('yyyy-MM-dd').format(today)}';

    // Check cache first
    final box = await Hive.openBox<Map>(_cacheBox);
    final cached = box.get(cacheKey);
    if (cached != null) {
      try {
        final result = _fromCache(cached.cast<String, dynamic>());
        // Run Ramadan detection even on cached results so profile updates on startup
        _updateRamadanStartIfNeeded(result);
        return result;
      } catch (_) {
        // Cache corrupted — fetch fresh
      }
    }

    // Fetch from API
    try {
      final prayerTime = await _client.getPrayerTimeByDate(zoneCode, today);
      if (prayerTime == null) return null;

      final result = _fromApiResponse(prayerTime, zoneCode);
      _updateRamadanStartIfNeeded(result);

      // Cache the result
      await box.put(cacheKey, _toCache(result));

      // Clean old cache entries (keep only last 3 days)
      final keys = box.keys.toList();
      for (final key in keys) {
        if (key != cacheKey) {
          final parts = (key as String).split('_');
          if (parts.length >= 2) {
            try {
              final date = DateTime.parse(parts.last);
              if (today.difference(date).inDays > 3) {
                await box.delete(key);
              }
            } catch (_) {}
          }
        }
      }

      return result;
    } on WaktuSolatApiException {
      // Network error — return cached if available, else null
      return null;
    }
  }

  /// Force refresh prayer times.
  Future<void> refresh() async {
    final profile = ref.read(userProfileProvider);
    if (profile.zoneCode.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchForToday(profile.zoneCode));
  }

  TodayPrayerTimes _fromApiResponse(PrayerTime pt, String zoneCode) {
    return TodayPrayerTimes(
      imsak: DateTime.fromMillisecondsSinceEpoch((pt.imsak ?? 0) * 1000),
      fajr: DateTime.fromMillisecondsSinceEpoch((pt.fajr ?? 0) * 1000),
      syuruk: DateTime.fromMillisecondsSinceEpoch((pt.syuruk ?? 0) * 1000),
      dhuhr: DateTime.fromMillisecondsSinceEpoch((pt.dhuhr ?? 0) * 1000),
      asr: DateTime.fromMillisecondsSinceEpoch((pt.asr ?? 0) * 1000),
      maghrib: DateTime.fromMillisecondsSinceEpoch((pt.maghrib ?? 0) * 1000),
      isha: DateTime.fromMillisecondsSinceEpoch((pt.isha ?? 0) * 1000),
      hijriDate: pt.hijri,
      zoneCode: zoneCode,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _toCache(TodayPrayerTimes t) => {
    'imsak': t.imsak.millisecondsSinceEpoch,
    'fajr': t.fajr.millisecondsSinceEpoch,
    'syuruk': t.syuruk.millisecondsSinceEpoch,
    'dhuhr': t.dhuhr.millisecondsSinceEpoch,
    'asr': t.asr.millisecondsSinceEpoch,
    'maghrib': t.maghrib.millisecondsSinceEpoch,
    'isha': t.isha.millisecondsSinceEpoch,
    'hijri': t.hijriDate,
    'zone': t.zoneCode,
    'fetchedAt': t.fetchedAt.millisecondsSinceEpoch,
  };

  TodayPrayerTimes _fromCache(Map<String, dynamic> m) => TodayPrayerTimes(
    imsak: DateTime.fromMillisecondsSinceEpoch(m['imsak'] as int),
    fajr: DateTime.fromMillisecondsSinceEpoch(m['fajr'] as int),
    syuruk: DateTime.fromMillisecondsSinceEpoch(m['syuruk'] as int),
    dhuhr: DateTime.fromMillisecondsSinceEpoch(m['dhuhr'] as int),
    asr: DateTime.fromMillisecondsSinceEpoch(m['asr'] as int),
    maghrib: DateTime.fromMillisecondsSinceEpoch(m['maghrib'] as int),
    isha: DateTime.fromMillisecondsSinceEpoch(m['isha'] as int),
    hijriDate: m['hijri'] as String,
    zoneCode: m['zone'] as String,
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(m['fetchedAt'] as int),
  );
}
