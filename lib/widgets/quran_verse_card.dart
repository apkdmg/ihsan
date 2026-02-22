import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../providers/quran_providers.dart';

class QuranVerseCard extends StatelessWidget {
  final int verseNumber;
  final String? arabicText;
  final String? translationText;
  final String? footnotes;
  final QuranReadingMode mode;
  final double textScale;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;

  const QuranVerseCard({
    super.key,
    required this.verseNumber,
    this.arabicText,
    this.translationText,
    this.footnotes,
    required this.mode,
    this.textScale = 1.0,
    this.isBookmarked = false,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse number header
            Row(
              children: [
                _VerseNumberBadge(number: verseNumber),
                const Spacer(),
                if (onBookmarkTap != null)
                  GestureDetector(
                    onTap: onBookmarkTap,
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? AppColors.gold : AppColors.textDim,
                      size: 22,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Arabic text
            if (mode == QuranReadingMode.arabicFocus ||
                mode == QuranReadingMode.regular)
              if (arabicText != null) ...[
                Text(
                  arabicText!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'HafsSmart',
                    fontSize: (28 * textScale).toDouble(),
                    color: AppColors.goldLight,
                    height: 2.0,
                  ),
                ),
                if (mode == QuranReadingMode.regular)
                  const SizedBox(height: 16),
              ],

            // Translation text
            if (mode == QuranReadingMode.translationFocus ||
                mode == QuranReadingMode.regular)
              if (translationText != null && translationText!.isNotEmpty) ...[
                Text(
                  translationText!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: (16 * textScale).toDouble(),
                    height: 1.6,
                  ),
                ),
                // Footnotes
                if (footnotes != null && footnotes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    footnotes!,
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: (13 * textScale).toDouble(),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
          ],
        ),
      ),
    );
  }
}

class _VerseNumberBadge extends StatelessWidget {
  final int number;
  const _VerseNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
