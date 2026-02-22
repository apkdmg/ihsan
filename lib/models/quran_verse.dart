class QuranVerse {
  final int id;
  final int juz;
  final int surahNumber;
  final String surahNameEn;
  final String surahNameAr;
  final int page;
  final int lineStart;
  final int lineEnd;
  final int ayahNumber;
  final String ayahText;
  final String ayahTextEmlaey;

  const QuranVerse({
    required this.id,
    required this.juz,
    required this.surahNumber,
    required this.surahNameEn,
    required this.surahNameAr,
    required this.page,
    required this.lineStart,
    required this.lineEnd,
    required this.ayahNumber,
    required this.ayahText,
    required this.ayahTextEmlaey,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      id: json['id'] as int,
      juz: json['jozz'] as int,
      surahNumber: json['sura_no'] as int,
      surahNameEn: json['sura_name_en'] as String,
      surahNameAr: json['sura_name_ar'] as String,
      page: json['page'] as int,
      lineStart: json['line_start'] as int,
      lineEnd: json['line_end'] as int,
      ayahNumber: json['aya_no'] as int,
      ayahText: json['aya_text'] as String,
      ayahTextEmlaey: json['aya_text_emlaey'] as String,
    );
  }
}
