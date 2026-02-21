import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/daily_record.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';

void showQuranLogSheet(
  BuildContext context,
  WidgetRef ref,
  DailyRecord record,
  UserProfile profile,
) {
  // Initial page the user was on before today's reading session started
  int currentCompletedPage =
      record.quranLastPage ?? ((profile.quranStartPage ?? 1) - 1);
  int baseCompletedPage = currentCompletedPage - record.quranPagesRead;

  // The page we are manipulating in the UI
  int targetCompletedPage = currentCompletedPage;

  final goal = profile.quranDailyGoal;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final pagesReadToday = targetCompletedPage >= baseCompletedPage
            ? targetCompletedPage - baseCompletedPage
            : 0;

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.menu_book, color: AppColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Log Quran Reading',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 24),

              // ── Pages read today ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Completed Page',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'What page did you just finish?',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (targetCompletedPage > baseCompletedPage) {
                                setSheetState(() => targetCompletedPage--);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: targetCompletedPage > baseCompletedPage
                                    ? AppColors.textSecondary
                                    : AppColors.textDim.withOpacity(0.3),
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 44),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: Text(
                              '$targetCompletedPage',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (targetCompletedPage < 604) {
                                setSheetState(() => targetCompletedPage++);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Auto-calculated "Pages read today" ──
              if (pagesReadToday > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Pages read today (Goal: $goal)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$pagesReadToday',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (pagesReadToday > 0) const SizedBox(height: 12),

              const SizedBox(height: 16),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (targetCompletedPage > 0 || pagesReadToday > 0) {
                      ref
                          .read(dailyRecordProvider.notifier)
                          .setQuranPages(pagesReadToday);

                      ref
                          .read(dailyRecordProvider.notifier)
                          .setQuranLastPage(targetCompletedPage);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.backgroundPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _showPageNumberDialog(
  BuildContext context,
  int currentPage,
  ValueChanged<int> onSet,
) {
  final controller = TextEditingController(
    text: currentPage > 0 ? '$currentPage' : '',
  );
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Go to page',
        style: TextStyle(color: AppColors.gold, fontSize: 18),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 22),
        decoration: InputDecoration(
          hintText: '1 – 604',
          hintStyle: const TextStyle(color: AppColors.textDim),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.gold),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textDim),
          ),
        ),
        TextButton(
          onPressed: () {
            final val = int.tryParse(controller.text);
            if (val != null && val > 0 && val <= 604) {
              onSet(val);
              Navigator.pop(ctx);
            }
          },
          child: const Text(
            'Confirm',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
