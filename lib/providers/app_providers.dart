import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import '../models/user_profile.dart';

// ── Hive box names ──
const String _dailyRecordsBox = 'daily_records';
const String _userProfileBox = 'user_profile';

// ── User Profile Provider ──
final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends Notifier<UserProfile> {
  Box<UserProfile>? _box;

  @override
  UserProfile build() {
    _init();
    return UserProfile();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<UserProfile>(_userProfileBox);
    var saved = _box?.get('profile');
    if (saved != null) {
      // Migrate: clear the old hardcoded default so Hijri auto-detection kicks in
      if (saved.ramadanStartDate == '2026-02-18') {
        saved.ramadanStartDate = '';
        await _box?.put('profile', saved);
      }
      state = saved;
    }
  }

  Future<void> update(UserProfile Function(UserProfile) updater) async {
    state = updater(state);
    await _box?.put('profile', state);
  }

  Future<void> completeOnboarding({
    required String name,
    required String zoneCode,
    required String zoneName,
    required int quranGoal,
    double? lat,
    double? lng,
  }) async {
    state = UserProfile(
      name: name,
      zoneCode: zoneCode,
      zoneName: zoneName,
      quranDailyGoal: quranGoal,
      onboardingComplete: true,
      latitude: lat,
      longitude: lng,
    );
    await _box?.put('profile', state);
  }
}

// ── Daily Record Provider ──
final dailyRecordProvider = NotifierProvider<DailyRecordNotifier, DailyRecord>(
  DailyRecordNotifier.new,
);

/// Provides the record for any given date key.
final recordForDateProvider = FutureProvider.family<DailyRecord, String>((
  ref,
  dateKey,
) async {
  final notifier = ref.read(dailyRecordProvider.notifier);
  return notifier.getOrCreate(dateKey);
});

/// Provides an existing record for a date key without creating one.
final existingRecordForDateProvider =
    FutureProvider.family<DailyRecord?, String>((ref, dateKey) async {
      final notifier = ref.read(dailyRecordProvider.notifier);
      return notifier.getExisting(dateKey);
    });

class DailyRecordNotifier extends Notifier<DailyRecord> {
  Box<DailyRecord>? _box;
  bool _initialized = false;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  DailyRecord build() {
    _init();
    return DailyRecord(dateKey: _todayKey);
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _box = await Hive.openBox<DailyRecord>(_dailyRecordsBox);
    _initialized = true;
  }

  Future<void> _init() async {
    await _ensureInitialized();
    state = await getOrCreate(_todayKey);
  }

  Future<DailyRecord> getOrCreate(String dateKey) async {
    await _ensureInitialized();
    var record = _box?.get(dateKey);
    if (record == null) {
      record = DailyRecord(dateKey: dateKey);
      await _box?.put(dateKey, record);
    }
    return record;
  }

  Future<DailyRecord?> getExisting(String dateKey) async {
    await _ensureInitialized();
    return _box?.get(dateKey);
  }

  Future<void> loadDate(String dateKey) async {
    state = await getOrCreate(dateKey);
  }

  Future<void> loadToday() async {
    await loadDate(_todayKey);
  }

  Future<void> _save() async {
    await _box?.put(state.dateKey, state);
  }

  DailyRecord _copyWith({
    int? quranPagesRead,
    int? quranLastPage,
    int? quranJuzCompleted,
    bool? listenedToRecitation,
    int? versesMemorized,
    bool? readTafsir,
    Map<String, int>? zikrCounts,
    Map<String, int>? prayerStatuses,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? personalDua,
    bool? duaBeforeAfterEating,
    bool? fastingCompleted,
    bool? ateSuhoor,
    bool? brokeWithDates,
    bool? avoidedGossip,
    bool? controlledAnger,
    bool? loweredGaze,
    List<String>? goodDeeds,
    String? reflectionNote,
    int? khushuRating,
    String? gratitudeNote,
    String? bestDeedNote,
    String? improvementNote,
    double? charityAmount,
    bool? attendedLecture,
    bool? readIslamicBook,
    bool? sharedKnowledge,
  }) {
    return DailyRecord(
      dateKey: state.dateKey,
      prayerStatuses: prayerStatuses ?? Map.from(state.prayerStatuses),
      quranPagesRead: quranPagesRead ?? state.quranPagesRead,
      quranLastPage: quranLastPage ?? state.quranLastPage ?? 0,
      quranJuzCompleted: quranJuzCompleted ?? state.quranJuzCompleted,
      listenedToRecitation: listenedToRecitation ?? state.listenedToRecitation,
      versesMemorized: versesMemorized ?? state.versesMemorized,
      readTafsir: readTafsir ?? state.readTafsir,
      zikrCounts: zikrCounts ?? Map.from(state.zikrCounts),
      morningAdhkar: morningAdhkar ?? state.morningAdhkar,
      eveningAdhkar: eveningAdhkar ?? state.eveningAdhkar,
      personalDua: personalDua ?? state.personalDua,
      duaBeforeAfterEating: duaBeforeAfterEating ?? state.duaBeforeAfterEating,
      fastingCompleted: fastingCompleted ?? state.fastingCompleted,
      ateSuhoor: ateSuhoor ?? state.ateSuhoor,
      brokeWithDates: brokeWithDates ?? state.brokeWithDates,
      avoidedGossip: avoidedGossip ?? state.avoidedGossip,
      controlledAnger: controlledAnger ?? state.controlledAnger,
      loweredGaze: loweredGaze ?? state.loweredGaze,
      goodDeeds: goodDeeds ?? List.from(state.goodDeeds),
      reflectionNote: reflectionNote ?? state.reflectionNote,
      khushuRating: khushuRating ?? state.khushuRating,
      gratitudeNote: gratitudeNote ?? state.gratitudeNote,
      bestDeedNote: bestDeedNote ?? state.bestDeedNote,
      improvementNote: improvementNote ?? state.improvementNote,
      charityAmount: charityAmount ?? state.charityAmount,
      attendedLecture: attendedLecture ?? state.attendedLecture,
      readIslamicBook: readIslamicBook ?? state.readIslamicBook,
      sharedKnowledge: sharedKnowledge ?? state.sharedKnowledge,
    );
  }

  // ── Prayer Methods ──
  Future<void> setPrayerStatus(String prayer, PrayerStatus status) async {
    final statuses = Map<String, int>.from(state.prayerStatuses);
    statuses[prayer] = status.index;
    state = _copyWith(prayerStatuses: statuses);
    await _save();
  }

  // ── Quran ──
  Future<void> setQuranPages(int pages) async {
    state = _copyWith(quranPagesRead: pages);
    await _save();
  }

  Future<void> setQuranLastPage(int page) async {
    state = _copyWith(quranLastPage: page);
    await _save();
  }

  // ── Zikr ──
  Future<void> incrementZikr(String type) async {
    final counts = Map<String, int>.from(state.zikrCounts);
    counts[type] = (counts[type] ?? 0) + 1;
    state = _copyWith(zikrCounts: counts);
    await _save();
  }

  Future<void> resetZikr(String type) async {
    final counts = Map<String, int>.from(state.zikrCounts);
    counts[type] = 0;
    state = _copyWith(zikrCounts: counts);
    await _save();
  }

  // ── Toggle fields ──
  Future<void> toggleField(String field) async {
    switch (field) {
      case 'morningAdhkar':
        state = _copyWith(morningAdhkar: !state.morningAdhkar);
      case 'eveningAdhkar':
        state = _copyWith(eveningAdhkar: !state.eveningAdhkar);
      case 'personalDua':
        state = _copyWith(personalDua: !state.personalDua);
      case 'duaBeforeAfterEating':
        state = _copyWith(duaBeforeAfterEating: !state.duaBeforeAfterEating);
      case 'fastingCompleted':
        state = _copyWith(fastingCompleted: !state.fastingCompleted);
      case 'ateSuhoor':
        state = _copyWith(ateSuhoor: !state.ateSuhoor);
      case 'brokeWithDates':
        state = _copyWith(brokeWithDates: !state.brokeWithDates);
      case 'avoidedGossip':
        state = _copyWith(avoidedGossip: !state.avoidedGossip);
      case 'controlledAnger':
        state = _copyWith(controlledAnger: !state.controlledAnger);
      case 'loweredGaze':
        state = _copyWith(loweredGaze: !state.loweredGaze);
      case 'listenedToRecitation':
        state = _copyWith(listenedToRecitation: !state.listenedToRecitation);
      case 'readTafsir':
        state = _copyWith(readTafsir: !state.readTafsir);
      case 'attendedLecture':
        state = _copyWith(attendedLecture: !state.attendedLecture);
      case 'readIslamicBook':
        state = _copyWith(readIslamicBook: !state.readIslamicBook);
      case 'sharedKnowledge':
        state = _copyWith(sharedKnowledge: !state.sharedKnowledge);
    }
    await _save();
  }

  // ── Good Deeds ──
  Future<void> toggleGoodDeed(String deedId) async {
    final deeds = List<String>.from(state.goodDeeds);
    if (deeds.contains(deedId)) {
      deeds.remove(deedId);
    } else {
      deeds.add(deedId);
    }
    state = _copyWith(goodDeeds: deeds);
    await _save();
  }

  // ── Reflection ──
  Future<void> saveReflection({
    String? note,
    int? khushu,
    String? gratitude,
    String? bestDeed,
    String? improvement,
  }) async {
    state = _copyWith(
      reflectionNote: note,
      khushuRating: khushu,
      gratitudeNote: gratitude,
      bestDeedNote: bestDeed,
      improvementNote: improvement,
    );
    await _save();
  }

  Future<void> setCharity(double amount) async {
    state = _copyWith(charityAmount: amount);
    await _save();
  }

  // ── History ──
  List<DailyRecord> getRecordsForRange(int days) {
    final records = <DailyRecord>[];
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final record = _box?.get(key);
      if (record != null) {
        records.add(record);
      }
    }
    return records;
  }

  /// Get all records for the current Ramadan (30 days).
  List<DailyRecord?> getRamadanRecords(String startDate) {
    final start = DateTime.parse(startDate);
    final records = <DailyRecord?>[];
    for (int i = 0; i < 30; i++) {
      final date = start.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      records.add(_box?.get(key));
    }
    return records;
  }
}
