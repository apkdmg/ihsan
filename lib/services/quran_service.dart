import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quran_verse.dart';
import '../models/quran_translation.dart';

class QuranService {
  static const String _assetPath = 'assets/data/hafs_smart_v8.json';
  static const String _translationCacheBox = 'quran_translations';
  static const String _translationListBox = 'quran_translation_list';
  static const String _baseUrl = 'https://quranenc.com/api/v1';

  /// Translations that work on QuranEnc but are missing from their list API.
  static const List<Map<String, dynamic>> _extraTranslations = [
    {
      'key': 'malay_basumayyah',
      'title': 'Malay translation - Basmeih',
      'language_iso_code': 'ms',
    },
  ];

  List<QuranVerse>? _cachedVerses;

  /// Load all 6236 verses from the bundled JSON asset.
  /// Parsed once and cached in memory for the app session.
  Future<List<QuranVerse>> loadArabicText() async {
    if (_cachedVerses != null) return _cachedVerses!;

    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedVerses = jsonList
        .map((e) => QuranVerse.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedVerses!;
  }

  /// Get verses for a specific surah.
  Future<List<QuranVerse>> getVersesForSurah(int surahNumber) async {
    final allVerses = await loadArabicText();
    return allVerses.where((v) => v.surahNumber == surahNumber).toList();
  }

  /// Get the first verse on a specific page.
  Future<QuranVerse?> getFirstVerseOnPage(int pageNumber) async {
    final allVerses = await loadArabicText();
    try {
      return allVerses.firstWhere((v) => v.page == pageNumber);
    } catch (_) {
      return null;
    }
  }

  /// Fetch available translation list from QuranEnc.
  /// Cached in Hive with 7-day staleness.
  /// Parse cached or fetched translation list JSON, handling both
  /// raw array and `{"translations": [...]}` wrapper formats.
  List<Map<String, dynamic>> _parseTranslationList(String jsonStr) {
    final decoded = json.decode(jsonStr);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    if (decoded is Map && decoded.containsKey('translations')) {
      return (decoded['translations'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }
    throw const FormatException('Unexpected translation list format');
  }

  /// Merge _extraTranslations into the list, avoiding duplicates by key.
  List<Map<String, dynamic>> _withExtras(List<Map<String, dynamic>> list) {
    final existingKeys = list.map((t) => t['key']).toSet();
    final extras = _extraTranslations
        .where((t) => !existingKeys.contains(t['key']))
        .toList();
    return [...extras, ...list];
  }

  Future<List<Map<String, dynamic>>> fetchTranslationList() async {
    final box = await Hive.openBox<String>(_translationListBox);
    final cachedJson = box.get('list');
    final cachedAt = box.get('cached_at');

    if (cachedJson != null && cachedAt != null) {
      final age = DateTime.now().millisecondsSinceEpoch - int.parse(cachedAt);
      if (age < 7 * 24 * 60 * 60 * 1000) {
        try {
          return _withExtras(_parseTranslationList(cachedJson));
        } catch (_) {
          // Stale/corrupt cache — clear it and re-fetch below
          await box.delete('list');
          await box.delete('cached_at');
        }
      }
    }

    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/translations/list'));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch translation list');
      }

      final list = _parseTranslationList(response.body);
      // Always store as a clean JSON array
      await box.put('list', json.encode(list));
      await box.put(
        'cached_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      return _withExtras(list);
    } catch (e) {
      // Fallback to stale cache
      if (cachedJson != null) {
        try {
          return _withExtras(_parseTranslationList(cachedJson));
        } catch (_) {
          // Cache is corrupt, nothing to fall back to
        }
      }
      rethrow;
    }
  }

  /// Fetch translation for a surah. Uses Hive cache first.
  Future<CachedTranslation> fetchSurahTranslation({
    required String translationKey,
    required int surahNumber,
  }) async {
    final box =
        await Hive.openBox<CachedTranslation>(_translationCacheBox);
    final cacheKey = '${translationKey}_$surahNumber';

    final cached = box.get(cacheKey);
    if (cached != null && !cached.isStale) {
      return cached;
    }

    try {
      final url =
          '$_baseUrl/translation/sura/$translationKey/$surahNumber';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        if (cached != null) return cached;
        throw Exception('Failed to fetch translation: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<dynamic> verseList =
          (data is Map ? data['result'] : data) as List<dynamic>;

      final verses = <String>[];
      final footnotes = <String>[];
      for (final v in verseList) {
        verses.add((v['translation'] as String?) ?? '');
        footnotes.add((v['footnotes'] as String?) ?? '');
      }

      final translation = CachedTranslation(
        translationKey: translationKey,
        surahNumber: surahNumber,
        verses: verses,
        footnotes: footnotes,
        cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );

      await box.put(cacheKey, translation);
      return translation;
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }
}
