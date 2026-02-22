import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

class QuranDisplaySettingsSheet extends ConsumerWidget {
  const QuranDisplaySettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(textScaleProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Display Settings',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Text Size',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => ref.read(textScaleProvider.notifier).decrease(),
                      icon: const Icon(Icons.text_decrease, color: AppColors.textPrimary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${(textScale * 100).toInt()}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => ref.read(textScaleProvider.notifier).increase(),
                      icon: const Icon(Icons.text_increase, color: AppColors.textPrimary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
