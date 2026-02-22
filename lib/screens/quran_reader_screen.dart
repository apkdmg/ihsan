import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/quran_data.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/arabic_text_helper.dart';
import '../providers/app_providers.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_verse_card.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int? initialAyah;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _scrolledToInitial = false;

  SurahInfo get _surahInfo =>
      QuranSurahData.surahs[widget.surahNumber - 1];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _verseKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }
  }

  void _showGoToAyah(int maxAyah) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Go to Ayah',
          style: TextStyle(color: AppColors.gold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '1 - $maxAyah',
            hintStyle: const TextStyle(color: AppColors.textDim),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.gold),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () {
              final ayah = int.tryParse(controller.text);
              if (ayah == null || ayah < 1 || ayah > maxAyah) return;
              Navigator.pop(context);
              // Wait a frame for the dialog to close
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToAyah(ayah);
              });
            },
            child: const Text('Go', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showBookmarkDialog(int ayahNumber, int page, String surahNameEn) {
    final controller = TextEditingController();
    final isAlreadyBookmarked =
        ref.read(quranBookmarksProvider.notifier).isBookmarked(
              widget.surahNumber,
              ayahNumber,
            );

    if (isAlreadyBookmarked) {
      // Find and remove
      final bookmarks = ref.read(quranBookmarksProvider);
      final existing = bookmarks.firstWhere(
        (b) =>
            b.surahNumber == widget.surahNumber &&
            b.ayahNumber == ayahNumber,
      );
      ref.read(quranBookmarksProvider.notifier).removeBookmark(existing.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark removed'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Add Bookmark',
          style: TextStyle(color: AppColors.gold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Label (optional)',
            hintStyle: const TextStyle(color: AppColors.textDim),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.gold),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () {
              ref.read(quranBookmarksProvider.notifier).addBookmark(
                    surahNumber: widget.surahNumber,
                    ayahNumber: ayahNumber,
                    page: page,
                    surahNameEn: surahNameEn,
                    label: controller.text.trim(),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmark added'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _navigateToSurah(int surahNumber) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuranReaderScreen(surahNumber: surahNumber),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(quranReadingModeProvider);
    final translationKey = ref.watch(selectedTranslationKeyProvider);
    final textScale = ref.watch(textScaleProvider);
    final bookmarks = ref.watch(quranBookmarksProvider);

    final versesAsync = ref.watch(surahVersesProvider(widget.surahNumber));
    final translationAsync = ref.watch(
      surahTranslationProvider(
        (key: translationKey, surah: widget.surahNumber),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          children: [
            Text(
              _surahInfo.nameEn,
              style: const TextStyle(color: AppColors.gold, fontSize: 16),
            ),
            Text(
              ArabicTextHelper.reshape(_surahInfo.nameAr),
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'KFGQPC Uthman Taha Naskh',
                fontFeatures: [
                  FontFeature.enable('liga'),
                  FontFeature.enable('rlig'),
                  FontFeature.enable('calt'),
                  FontFeature.enable('ccmp'),
                ],
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_numbered, size: 20),
            onPressed: () => _showGoToAyah(_surahInfo.verseCount),
            tooltip: 'Go to ayah',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _ModeToggle(
            mode: mode,
            onChanged: (m) =>
                ref.read(quranReadingModeProvider.notifier).set(m),
          ),
        ),
      ),
      body: versesAsync.when(
        data: (verses) {
          // Scroll to initial ayah after first build
          if (!_scrolledToInitial && widget.initialAyah != null) {
            _scrolledToInitial = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToAyah(widget.initialAyah!);
            });
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
            itemCount: verses.length + 1, // +1 for nav footer
            itemBuilder: (context, index) {
              if (index == verses.length) {
                return _SurahNavFooter(
                  surahNumber: widget.surahNumber,
                  onPrevious: widget.surahNumber > 1
                      ? () => _navigateToSurah(widget.surahNumber - 1)
                      : null,
                  onNext: widget.surahNumber < 114
                      ? () => _navigateToSurah(widget.surahNumber + 1)
                      : null,
                );
              }

              final verse = verses[index];
              final verseKey =
                  _verseKeys.putIfAbsent(verse.ayahNumber, () => GlobalKey());

              String? translationText;
              String? footnoteText;
              if (mode != QuranReadingMode.arabicFocus) {
                translationAsync.whenData((t) {
                  if (index < t.verses.length) {
                    translationText = t.verses[index];
                    footnoteText = t.footnotes[index];
                  }
                });
              }

              final isMarked = bookmarks.any(
                (b) =>
                    b.surahNumber == widget.surahNumber &&
                    b.ayahNumber == verse.ayahNumber,
              );

              return KeyedSubtree(
                key: verseKey,
                child: QuranVerseCard(
                  verseNumber: verse.ayahNumber,
                  arabicText: mode != QuranReadingMode.translationFocus
                      ? verse.ayahText
                      : null,
                  translationText: translationText,
                  footnotes: footnoteText,
                  mode: mode,
                  textScale: textScale,
                  isBookmarked: isMarked,
                  onBookmarkTap: () => _showBookmarkDialog(
                    verse.ayahNumber,
                    verse.page,
                    verse.surahNameEn,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Failed to load Quran data.\n$e',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final QuranReadingMode mode;
  final ValueChanged<QuranReadingMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _ModeChip(
            label: 'Translation',
            icon: Icons.translate,
            isSelected: mode == QuranReadingMode.translationFocus,
            onTap: () => onChanged(QuranReadingMode.translationFocus),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: 'Arabic',
            icon: Icons.menu_book,
            isSelected: mode == QuranReadingMode.arabicFocus,
            onTap: () => onChanged(QuranReadingMode.arabicFocus),
          ),
          const SizedBox(width: 8),
          _ModeChip(
            label: 'Both',
            icon: Icons.view_agenda,
            isSelected: mode == QuranReadingMode.regular,
            onTap: () => onChanged(QuranReadingMode.regular),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.2)
                : AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.gold : AppColors.textDim,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.gold : AppColors.textDim,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahNavFooter extends StatelessWidget {
  final int surahNumber;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _SurahNavFooter({
    required this.surahNumber,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          if (onPrevious != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(
                  QuranSurahData.surahs[surahNumber - 2].nameEn,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          const SizedBox(width: 12),
          if (onNext != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNext,
                icon: Text(
                  QuranSurahData.surahs[surahNumber].nameEn,
                  overflow: TextOverflow.ellipsis,
                ),
                label: const Icon(Icons.arrow_forward, size: 16),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
