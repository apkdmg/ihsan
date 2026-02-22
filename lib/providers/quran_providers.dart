import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/quran_verse.dart';
import '../models/quran_translation.dart';
import '../models/quran_bookmark.dart';
import '../models/user_profile.dart';
import '../services/quran_service.dart';

// ── Reading mode ──
enum QuranReadingMode { translationFocus, arabicFocus, regular }

// ── Service ──
final quranServiceProvider = Provider<QuranService>((ref) => QuranService());

// ── Reading mode state ──
class _ReadingModeNotifier extends Notifier<QuranReadingMode> {
  @override
  QuranReadingMode build() => QuranReadingMode.translationFocus;

  void set(QuranReadingMode mode) => state = mode;
}

final quranReadingModeProvider =
    NotifierProvider<_ReadingModeNotifier, QuranReadingMode>(
  _ReadingModeNotifier.new,
);

// ── Selected translation key (synced with UserProfile) ──
class _TranslationKeyNotifier extends Notifier<String> {
  @override
  String build() {
    // Read initial value from persisted UserProfile
    final box = Hive.box<UserProfile>('user_profile');
    final profile = box.get('profile');
    return profile?.preferredTranslationKey ?? 'english_saheeh';
  }

  void set(String key) => state = key;
}

final selectedTranslationKeyProvider =
    NotifierProvider<_TranslationKeyNotifier, String>(
  _TranslationKeyNotifier.new,
);

// ── Arabic verses for a surah ──
final surahVersesProvider =
    FutureProvider.family<List<QuranVerse>, int>((ref, surahNumber) async {
  final service = ref.read(quranServiceProvider);
  return service.getVersesForSurah(surahNumber);
});

// ── Translation for a surah ──
final surahTranslationProvider = FutureProvider.family<CachedTranslation,
    ({String key, int surah})>((ref, params) async {
  final service = ref.read(quranServiceProvider);
  return service.fetchSurahTranslation(
    translationKey: params.key,
    surahNumber: params.surah,
  );
});

// ── Available translations list ──
final translationListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(quranServiceProvider);
  return service.fetchTranslationList();
});

// ── Bookmarks ──
const String _bookmarksBox = 'quran_bookmarks';

final quranBookmarksProvider =
    NotifierProvider<QuranBookmarksNotifier, List<QuranBookmark>>(
  QuranBookmarksNotifier.new,
);

class QuranBookmarksNotifier extends Notifier<List<QuranBookmark>> {
  Box<QuranBookmark>? _box;

  @override
  List<QuranBookmark> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    _box = await Hive.openBox<QuranBookmark>(_bookmarksBox);
    state = _box!.values.toList()
      ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required int page,
    required String surahNameEn,
    String label = '',
  }) async {
    if (_box == null) await _init();
    final bookmark = QuranBookmark(
      id: const Uuid().v4(),
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      surahNameEn: surahNameEn,
      label: label,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _box!.put(bookmark.id, bookmark);
    state = _box!.values.toList()
      ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
  }

  Future<void> removeBookmark(String id) async {
    if (_box == null) await _init();
    await _box!.delete(id);
    state = _box!.values.toList()
      ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return state.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
  }
}
