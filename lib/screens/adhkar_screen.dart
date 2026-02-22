import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/adhkar_data.dart';
import '../core/utils/arabic_text_helper.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

// Global state for Arabic text scaling (accessibility)
class TextScaleNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  void increase() {
    if (state < 2.0) state += 0.2;
  }

  void decrease() {
    if (state > 0.8) state -= 0.2;
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(
  TextScaleNotifier.new,
);

class AdhkarScreen extends ConsumerStatefulWidget {
  final bool isMorning;

  const AdhkarScreen({super.key, required this.isMorning});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> {
  late final List<Map<String, dynamic>> _adhkarList;
  late final List<int> _counts;

  @override
  void initState() {
    super.initState();
    _adhkarList = widget.isMorning
        ? AdhkarData.morningAdhkar
        : AdhkarData.eveningAdhkar;
    _counts = List.filled(_adhkarList.length, 0);
  }

  void _incrementCount(int index, int target) {
    if (_counts[index] < target) {
      setState(() {
        _counts[index]++;
      });

      if (_counts[index] == target) {
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
      } else {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = ref.watch(textScaleProvider);
    final title = widget.isMorning ? 'Morning Adhkar' : 'Evening Adhkar';

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: Text(title, style: const TextStyle(color: AppColors.gold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          // Text Size Accessibility Toggle
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              ref.read(textScaleProvider.notifier).decrease();
            },
            tooltip: 'Decrease text size',
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              ref.read(textScaleProvider.notifier).increase();
            },
            tooltip: 'Increase text size',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _adhkarList.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == _adhkarList.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(dailyRecordProvider.notifier)
                      .setAdhkarComplete(widget.isMorning, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.isMorning ? "Morning" : "Evening"} Adhkar marked as complete!',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.backgroundPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Complete & Update Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final adhkar = _adhkarList[index];
          final target = adhkar['repetitions'] as int;
          final currentCount = _counts[index];
          final isComplete = currentCount >= target;

          return GestureDetector(
            onTap: isComplete ? null : () => _incrementCount(index, target),
            child: GlassCard(
              borderColor: isComplete
                  ? AppColors.success.withValues(alpha: 0.5)
                  : AppColors.gold.withValues(alpha: 0.1),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        adhkar['title'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: isComplete
                                  ? AppColors.success
                                  : AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Arabic Text (Scaled for accessibility)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isComplete
                                ? AppColors.success.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          ArabicTextHelper.reshape(adhkar['arabic']),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily:
                                'KFGQPC Uthman Taha Naskh', // Ensure Uthmanic font is used
                            fontFamilyFallback: const ['Courier', 'monospace'],
                            fontFeatures: const [
                              FontFeature.enable('liga'),
                              FontFeature.enable('rlig'),
                              FontFeature.enable('calt'),
                              FontFeature.enable('ccmp'),
                            ],
                            fontSize: (28 * textScale).toDouble(),
                            color: isComplete
                                ? AppColors.success
                                : AppColors.goldLight,
                            height: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Transliteration (Scaled slightly)
                      Text(
                        adhkar['transliteration'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          fontSize:
                              (textScale == 1.0
                                      ? 14.0
                                      : 14 * (1 + (textScale - 1) * 0.5))
                                  .toDouble(), // Safe cast
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Translation (Scaled slightly)
                      Text(
                        adhkar['translation'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontSize:
                              (textScale == 1.0
                                      ? 14.0
                                      : 14 * (1 + (textScale - 1) * 0.5))
                                  .toDouble(), // Safe cast
                        ),
                      ),
                      if (adhkar['source'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Source: ${adhkar['source']}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textDim,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                        ),
                      ],

                      // Spacing for target counter
                      if (target > 1) const SizedBox(height: 40),
                    ],
                  ),

                  // Repetition Counter
                  if (target > 1)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isComplete
                                ? AppColors.success
                                : AppColors.gold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isComplete) ...[
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              isComplete
                                  ? 'Complete'
                                  : '$currentCount / $target',
                              style: TextStyle(
                                color: isComplete
                                    ? AppColors.success
                                    : AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
