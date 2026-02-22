import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../core/constants/quran_data.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/arabic_text_helper.dart';
import '../models/quran_verse.dart';
import '../providers/app_providers.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_display_settings_sheet.dart';
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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _scrolledToInitial = false;
  int _currentPage = 0;
  List<QuranVerse>? _cachedVerses;

  /// PUA-encoded Bismillah from HafsSmart font (Al-Fatiha ayah 1 text).
  static const String _bismillahText =
      '\u200f\ue8db \u200f\ue338\u200f\ue48e \u200f\ue338\u200f\ue0af\u200f\ue238\u200f\ue903 \u200f\ue338\u200f\ue0af\u200f\ue238\u200f\ue045\u200f\ue1c0\u200f\ue2e5 \u200f\ue95a';

  SurahInfo get _surahInfo => QuranSurahData.surahs[widget.surahNumber - 1];

  /// Show Bismillah for all surahs except Al-Fatiha (1) and At-Taubah (9).
  bool get _hasBismillah => widget.surahNumber != 1 && widget.surahNumber != 9;

  void _scrollToAyah(int ayahNumber) {
    final listIndex = _ayahToListIndex(ayahNumber);
    _itemScrollController.scrollTo(
      index: listIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Build a flat list of items: bismillah, verses interleaved with page dividers, footer.
  /// Each entry is either a verse, a page divider, the bismillah, or the footer.
  List<_ListItem> _buildListItems(List<QuranVerse> verses) {
    final items = <_ListItem>[];

    if (_hasBismillah) {
      items.add(const _ListItem.bismillah());
    }

    for (int i = 0; i < verses.length; i++) {
      // Insert page divider before this verse if its page differs from the previous verse
      if (i > 0 && verses[i].page != verses[i - 1].page) {
        items.add(_ListItem.pageDivider(verses[i - 1].page));
      }
      items.add(_ListItem.verse(i));
    }

    items.add(const _ListItem.footer());
    return items;
  }

  /// Convert ayah number to list index (accounting for bismillah + page dividers).
  int _ayahToListIndex(int ayahNumber) {
    if (_cachedVerses == null) return 0;
    final items = _buildListItems(_cachedVerses!);
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == _ListItemType.verse &&
          _cachedVerses![items[i].verseIndex!].ayahNumber == ayahNumber) {
        return i;
      }
    }
    return 0;
  }

  /// Derive current mushaf page from visible list items.
  void _onPositionsChanged(List<QuranVerse> verses, List<_ListItem> items) {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || verses.isEmpty) return;

    // Find the topmost visible verse
    final sorted = positions.toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    for (final pos in sorted) {
      if (pos.index < items.length) {
        final item = items[pos.index];
        if (item.type == _ListItemType.verse) {
          final page = verses[item.verseIndex!].page;
          if (page != _currentPage) {
            setState(() => _currentPage = page);
          }
          return;
        }
      }
    }
  }

  void _scrollToPage(
    List<QuranVerse> verses,
    List<_ListItem> items,
    int targetPage,
  ) {
    // Find the first verse on the target page
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == _ListItemType.verse) {
        final verse = verses[items[i].verseIndex!];
        if (verse.page == targetPage) {
          _itemScrollController.scrollTo(
            index: i,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
          return;
        }
      }
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textDim),
            ),
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
    final isAlreadyBookmarked = ref
        .read(quranBookmarksProvider.notifier)
        .isBookmarked(widget.surahNumber, ayahNumber);

    if (isAlreadyBookmarked) {
      // Find and remove
      final bookmarks = ref.read(quranBookmarksProvider);
      final existing = bookmarks.firstWhere(
        (b) =>
            b.surahNumber == widget.surahNumber && b.ayahNumber == ayahNumber,
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textDim),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(quranBookmarksProvider.notifier)
                  .addBookmark(
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

  void _showDisplaySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const QuranDisplaySettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(quranReadingModeProvider);
    final translationKey = ref.watch(selectedTranslationKeyProvider);
    final textScale = ref.watch(textScaleProvider);
    final bookmarks = ref.watch(quranBookmarksProvider);
    final stopPoint = ref.watch(quranStopPointProvider);

    final versesAsync = ref.watch(surahVersesProvider(widget.surahNumber));
    final translationAsync = ref.watch(
      surahTranslationProvider((
        key: translationKey,
        surah: widget.surahNumber,
      )),
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
              _currentPage > 0
                  ? 'Page $_currentPage'
                  : ArabicTextHelper.reshape(_surahInfo.nameAr),
              textDirection: _currentPage > 0
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              style: TextStyle(
                fontFamily: _currentPage > 0
                    ? null
                    : 'KFGQPC Uthman Taha Naskh',
                fontFeatures: _currentPage > 0
                    ? null
                    : const [
                        FontFeature.enable('liga'),
                        FontFeature.enable('rlig'),
                        FontFeature.enable('calt'),
                        FontFeature.enable('ccmp'),
                      ],
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size, size: 20),
            onPressed: _showDisplaySettings,
            tooltip: 'Display Settings',
          ),
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
          _cachedVerses = verses;
          final items = _buildListItems(verses);

          // Listen for scroll position changes
          _itemPositionsListener.itemPositions.removeListener(() {});
          _itemPositionsListener.itemPositions.addListener(() {
            _onPositionsChanged(verses, items);
          });

          // Set initial page
          if (_currentPage == 0 && verses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_currentPage == 0 && verses.isNotEmpty) {
                setState(() => _currentPage = verses.first.page);
              }
            });
          }

          // Scroll to initial ayah after first build
          if (!_scrolledToInitial && widget.initialAyah != null) {
            _scrolledToInitial = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToAyah(widget.initialAyah!);
            });
          }

          return Column(
            children: [
              // Page navigation bar
              _PageNavBar(
                currentPage: _currentPage,
                onPrevPage: () {
                  if (_currentPage > 1) {
                    _scrollToPage(verses, items, _currentPage - 1);
                  }
                },
                onNextPage: () {
                  if (_currentPage < 604) {
                    _scrollToPage(verses, items, _currentPage + 1);
                  }
                },
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    switch (item.type) {
                      case _ListItemType.bismillah:
                        return _BismillahHeader(textScale: textScale);

                      case _ListItemType.pageDivider:
                        return _PageDivider(pageNumber: item.pageNumber!);

                      case _ListItemType.footer:
                        return _SurahNavFooter(
                          surahNumber: widget.surahNumber,
                          onPrevious: widget.surahNumber > 1
                              ? () => _navigateToSurah(widget.surahNumber - 1)
                              : null,
                          onNext: widget.surahNumber < 114
                              ? () => _navigateToSurah(widget.surahNumber + 1)
                              : null,
                        );

                      case _ListItemType.verse:
                        final verse = verses[item.verseIndex!];
                        String? translationText;
                        String? footnoteText;
                        if (mode != QuranReadingMode.arabicFocus) {
                          translationAsync.whenData((t) {
                            if (item.verseIndex! < t.verses.length) {
                              translationText = t.verses[item.verseIndex!];
                              footnoteText = t.footnotes[item.verseIndex!];
                            }
                          });
                        }

                        final isMarked = bookmarks.any(
                          (b) =>
                              b.surahNumber == widget.surahNumber &&
                              b.ayahNumber == verse.ayahNumber,
                        );

                        final isStop =
                            stopPoint?.surah == widget.surahNumber &&
                            stopPoint?.ayah == verse.ayahNumber;

                        return QuranVerseCard(
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
                          isStopPoint: isStop,
                          onStopPointTap: () {
                            // Instant UI update via in-memory provider
                            ref
                                .read(quranStopPointProvider.notifier)
                                .set(
                                  QuranStopPoint(
                                    surah: widget.surahNumber,
                                    ayah: verse.ayahNumber,
                                    page: verse.page,
                                  ),
                                );
                            // Persist asynchronously
                            ref.read(userProfileProvider.notifier).update((p) {
                              p.quranStopSurah = widget.surahNumber;
                              p.quranStopAyah = verse.ayahNumber;
                              p.quranStopPage = verse.page;
                              return p;
                            });
                          },
                        );
                    }
                  },
                ),
              ),
            ],
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BismillahHeader extends StatelessWidget {
  final double textScale;

  const _BismillahHeader({required this.textScale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Text(
          _QuranReaderScreenState._bismillahText,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'HafsSmart',
            fontSize: (28 * textScale).toDouble(),
            color: AppColors.gold,
            height: 2.0,
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

// ── List Item Model ──

enum _ListItemType { bismillah, verse, pageDivider, footer }

class _ListItem {
  final _ListItemType type;
  final int? verseIndex;
  final int? pageNumber;

  const _ListItem._({required this.type, this.verseIndex, this.pageNumber});

  const _ListItem.bismillah() : this._(type: _ListItemType.bismillah);
  const _ListItem.footer() : this._(type: _ListItemType.footer);
  _ListItem.verse(int index)
    : this._(type: _ListItemType.verse, verseIndex: index);
  _ListItem.pageDivider(int page)
    : this._(type: _ListItemType.pageDivider, pageNumber: page);
}

// ── Page Divider ──

class _PageDivider extends StatelessWidget {
  final int pageNumber;
  const _PageDivider({required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.surfaceLight.withValues(alpha: 0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'End of Page $pageNumber',
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.surfaceLight.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page Navigation Bar ──

class _PageNavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  const _PageNavBar({
    required this.currentPage,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPage == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceLight.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: currentPage > 1 ? onPrevPage : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left,
                size: 22,
                color: currentPage > 1
                    ? AppColors.gold
                    : AppColors.textDim.withValues(alpha: 0.3),
              ),
            ),
          ),
          Text(
            'Page $currentPage',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          GestureDetector(
            onTap: currentPage < 604 ? onNextPage : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_right,
                size: 22,
                color: currentPage < 604
                    ? AppColors.gold
                    : AppColors.textDim.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
