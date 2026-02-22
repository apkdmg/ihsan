import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/quran_data.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/arabic_text_helper.dart';
import '../providers/app_providers.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_display_settings_sheet.dart';
import 'quran_reader_screen.dart';

class QuranSurahListScreen extends ConsumerStatefulWidget {
  const QuranSurahListScreen({super.key});

  @override
  ConsumerState<QuranSurahListScreen> createState() =>
      _QuranSurahListScreenState();
}

class _QuranSurahListScreenState extends ConsumerState<QuranSurahListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openReader(int surahNumber, {int? initialAyah}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuranReaderScreen(
              surahNumber: surahNumber,
              initialAyah: initialAyah,
            ),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(opacity: curve, child: child),
          );
        },
      ),
    );
  }

  void _showTranslationPicker() {
    // Invalidate to force a fresh fetch each time the picker opens
    ref.invalidate(translationListProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _TranslationPickerSheet(
          scrollController: scrollController,
          onSelected: (key) {
            ref.read(selectedTranslationKeyProvider.notifier).set(key);
            // Persist to UserProfile
            ref
                .read(userProfileProvider.notifier)
                .update((p) => p..preferredTranslationKey = key);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showGoToPage() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Go to Page',
          style: TextStyle(color: AppColors.gold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '1 - ${QuranSurahData.totalPages}',
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
            onPressed: () async {
              final page = int.tryParse(controller.text);
              if (page == null ||
                  page < 1 ||
                  page > QuranSurahData.totalPages) {
                return;
              }
              Navigator.pop(context);
              final service = ref.read(quranServiceProvider);
              final verse = await service.getFirstVerseOnPage(page);
              if (verse != null && mounted) {
                _openReader(verse.surahNumber, initialAyah: verse.ayahNumber);
              }
            },
            child: const Text('Go', style: TextStyle(color: AppColors.gold)),
          ),
        ],
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
    final textScale = ref.watch(textScaleProvider);
    final bookmarks = ref.watch(quranBookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: const Text('Quran', style: TextStyle(color: AppColors.gold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size, size: 20),
            onPressed: _showDisplaySettings,
            tooltip: 'Display Settings',
          ),
          IconButton(
            icon: const Icon(Icons.translate, size: 20),
            onPressed: _showTranslationPicker,
            tooltip: 'Change translation',
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textDim,
          tabs: const [
            Tab(text: 'Surahs'),
            Tab(text: 'Page'),
            Tab(text: 'Bookmarks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Surah list tab
          _SurahListTab(
            textScale: textScale,
            onSurahTap: (number) => _openReader(number),
          ),
          // Go to page tab
          _GoToPageTab(onGoToPage: _showGoToPage),
          // Bookmarks tab
          _BookmarksTab(
            bookmarks: bookmarks,
            onBookmarkTap: (b) =>
                _openReader(b.surahNumber, initialAyah: b.ayahNumber),
            onBookmarkDelete: (id) =>
                ref.read(quranBookmarksProvider.notifier).removeBookmark(id),
          ),
        ],
      ),
    );
  }
}

class _SurahListTab extends StatelessWidget {
  final double textScale;
  final void Function(int surahNumber) onSurahTap;

  const _SurahListTab({required this.textScale, required this.onSurahTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: QuranSurahData.surahs.length,
      itemBuilder: (context, index) {
        final surah = QuranSurahData.surahs[index];
        return _SurahCard(
          surah: surah,
          textScale: textScale,
          onTap: () => onSurahTap(surah.number),
        );
      },
    );
  }
}

class _SurahCard extends StatelessWidget {
  final SurahInfo surah;
  final double textScale;
  final VoidCallback onTap;

  const _SurahCard({
    required this.surah,
    required this.textScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.number}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 14),
            // English name + verse count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameEn,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.verseCount} verses  •  ${surah.type}',
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              ArabicTextHelper.reshape(surah.nameAr),
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'KFGQPC Uthman Taha Naskh',
                fontFamilyFallback: const ['Courier', 'monospace'],
                fontFeatures: const [
                  FontFeature.enable('liga'),
                  FontFeature.enable('rlig'),
                  FontFeature.enable('calt'),
                  FontFeature.enable('ccmp'),
                ],
                fontSize: (20 * textScale).toDouble(),
                color: AppColors.goldLight,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoToPageTab extends StatelessWidget {
  final VoidCallback onGoToPage;

  const _GoToPageTab({required this.onGoToPage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: AppColors.gold.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Navigate to a specific page',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Pages 1 - ${QuranSurahData.totalPages}',
            style: const TextStyle(color: AppColors.textDim, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onGoToPage,
            icon: const Icon(Icons.search),
            label: const Text('Go to Page'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.backgroundPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  final List bookmarks;
  final void Function(dynamic bookmark) onBookmarkTap;
  final void Function(String id) onBookmarkDelete;

  const _BookmarksTab({
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onBookmarkDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.gold.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookmarks yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the bookmark icon while reading to save your place',
              style: TextStyle(color: AppColors.textDim, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final b = bookmarks[index];
        return Dismissible(
          key: Key(b.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete, color: AppColors.error),
          ),
          onDismissed: (_) => onBookmarkDelete(b.id),
          child: GestureDetector(
            onTap: () => onBookmarkTap(b),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${b.surahNameEn} - Ayah ${b.ayahNumber}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (b.label.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            b.label,
                            style: const TextStyle(
                              color: AppColors.textDim,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    'p.${b.page}',
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TranslationPickerSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final void Function(String key) onSelected;

  const _TranslationPickerSheet({
    required this.scrollController,
    required this.onSelected,
  });

  @override
  ConsumerState<_TranslationPickerSheet> createState() =>
      _TranslationPickerSheetState();
}

class _TranslationPickerSheetState
    extends ConsumerState<_TranslationPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final translationList = ref.watch(translationListProvider);

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textDim,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Translation',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search translations...',
              hintStyle: const TextStyle(color: AppColors.textDim),
              prefixIcon: const Icon(Icons.search, color: AppColors.textDim),
              filled: true,
              fillColor: AppColors.backgroundPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: translationList.when(
            data: (translations) {
              final filtered = _search.isEmpty
                  ? translations
                  : translations.where((t) {
                      final name = (t['title'] ?? '').toString().toLowerCase();
                      final lang = (t['language_iso_code'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(_search) || lang.contains(_search);
                    }).toList();

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  final key = (t['key'] ?? '').toString();
                  final name = (t['title'] ?? key).toString();
                  final lang = (t['language_iso_code'] ?? '').toString();

                  return ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      lang,
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => widget.onSelected(key),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textDim,
                      size: 18,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load translations.\n$e',
                      style: const TextStyle(color: AppColors.textDim),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(translationListProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.backgroundPrimary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
