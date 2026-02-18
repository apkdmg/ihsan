import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

class ZikrCounterScreen extends ConsumerStatefulWidget {
  const ZikrCounterScreen({super.key});

  @override
  ConsumerState<ZikrCounterScreen> createState() => _ZikrCounterScreenState();
}

class _ZikrCounterScreenState extends ConsumerState<ZikrCounterScreen>
    with TickerProviderStateMixin {
  int _currentModeIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _modes = [
    _ZikrMode(
      'SubhanAllah',
      'subhanAllah',
      'سبحان الله',
      'Glory be to Allah',
      33,
    ),
    _ZikrMode(
      'Alhamdulillah',
      'alhamdulillah',
      'الحمد لله',
      'All praise is for Allah',
      33,
    ),
    _ZikrMode(
      'Allahu Akbar',
      'allahuAkbar',
      'الله أكبر',
      'Allah is Greatest',
      33,
    ),
    _ZikrMode(
      'La ilaha illallah',
      'laIlahaIllallah',
      'لا إله إلا الله',
      'None worthy of worship but Allah',
      100,
    ),
    _ZikrMode(
      'Istighfar',
      'istighfar',
      'أستغفر الله',
      'I seek forgiveness from Allah',
      100,
    ),
    _ZikrMode(
      'Salawat',
      'salawat',
      'اللهم صل على محمد',
      'O Allah, send blessings upon Muhammad ﷺ',
      100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    final mode = _modes[_currentModeIndex];
    final record = ref.read(dailyRecordProvider);
    final currentCount = record.zikrCounts[mode.key] ?? 0;
    final isTargetReached = currentCount + 1 == mode.target;

    // Haptic + Audio feedback (iPads lack Taptic Engine, so audio is the fallback)
    if (isTargetReached) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } else {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    }

    // Pulse animation
    _pulseController.forward().then((_) => _pulseController.reverse());

    // Increment
    ref.read(dailyRecordProvider.notifier).incrementZikr(mode.key);

    // Auto-advance to next mode when target reached
    if (isTargetReached && _currentModeIndex < _modes.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _currentModeIndex++;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(dailyRecordProvider);
    final mode = _modes[_currentModeIndex];
    final count = record.zikrCounts[mode.key] ?? 0;
    final progress = (count / mode.target).clamp(0.0, 1.0);
    final isComplete = count >= mode.target;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasbih',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: AppColors.gold),
                  ),
                  // Reset button
                  IconButton(
                    onPressed: () {
                      ref
                          .read(dailyRecordProvider.notifier)
                          .resetZikr(mode.key);
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.textDim),
                    tooltip: 'Reset counter',
                  ),
                ],
              ),
            ),

            // Mode selector
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _modes.length,
                itemBuilder: (context, i) {
                  final m = _modes[i];
                  final mCount = record.zikrCounts[m.key] ?? 0;
                  final mComplete = mCount >= m.target;
                  final selected = i == _currentModeIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _currentModeIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.gold.withValues(alpha: 0.15)
                              : mComplete
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.surfaceLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.gold
                                : mComplete
                                ? AppColors.success.withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mComplete)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                              ),
                            Text(
                              m.name,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.gold
                                    : mComplete
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main counter area
            Expanded(
              child: GestureDetector(
                onTap: isComplete ? null : _onTap,
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Arabic text
                      Text(
                        mode.arabic,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 36,
                          color: isComplete
                              ? AppColors.success
                              : AppColors.goldLight,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              color:
                                  (isComplete
                                          ? AppColors.success
                                          : AppColors.gold)
                                      .withValues(alpha: 0.3),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mode.meaning,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Progress ring with count
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 6,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.surfaceLight.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, _) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 6,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(
                                    isComplete
                                        ? AppColors.success
                                        : AppColors.gold,
                                  ),
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: isComplete
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              Text(
                                '/ ${mode.target}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),
                      if (!isComplete)
                        Text(
                          'Tap anywhere to count',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textDim),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Completed!',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZikrMode {
  final String name;
  final String key;
  final String arabic;
  final String meaning;
  final int target;

  const _ZikrMode(this.name, this.key, this.arabic, this.meaning, this.target);
}
