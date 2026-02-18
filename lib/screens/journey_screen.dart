import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/theme/app_colors.dart';
import '../models/daily_record.dart';
import '../providers/app_providers.dart';
import '../services/prayer_times_service.dart';
import '../widgets/common_widgets.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final prayerTimes = prayerTimesAsync.whenOrNull(data: (d) => d);

    // Derive Ramadan state from prayer times Hijri date (Maghrib-aware)
    final dayOfRamadan = prayerTimes?.ramadanDay ?? 0;
    final ramadanStart =
        prayerTimes?.nextRamadanStartGregorian ?? profile.ramadanStartDate;

    // Watch provider to trigger rebuilds on changes
    ref.watch(dailyRecordProvider);
    final notifier = ref.read(dailyRecordProvider.notifier);
    final ramadanRecords = notifier.getRamadanRecords(ramadanStart);

    // Calculate stats
    int completedDays = 0;
    double totalScore = 0;
    int totalPages = 0;
    int totalPrayers = 0;
    double totalCharity = 0;
    List<double> scores = [];

    for (int i = 0; i < 30; i++) {
      final r = ramadanRecords[i];
      if (r != null) {
        final score = r.dailyScore;
        scores.add(score);
        if (score > 0) completedDays++;
        totalScore += score;
        totalPages += r.quranPagesRead;
        for (final entry in r.prayerStatuses.entries) {
          if (entry.value == PrayerStatus.onTime.index ||
              entry.value == PrayerStatus.late_.index) {
            totalPrayers++;
          }
        }
        totalCharity += r.charityAmount ?? 0;
      } else {
        scores.add(0);
      }
    }

    final avgScore = completedDays > 0 ? totalScore / completedDays : 0.0;
    final overallProgress = dayOfRamadan / 30;

    // Determine spiritual level
    final levelInfo = _getLevel(completedDays, avgScore);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.backgroundPrimary,
            title: const Text('Ramadan Journey'),
            centerTitle: true,
          ),

          // Overall progress
          SliverToBoxAdapter(
            child: _buildOverallCard(
              context,
              profile,
              overallProgress,
              avgScore,
              dayOfRamadan,
            ),
          ),

          // 30-day grid
          SliverToBoxAdapter(
            child: const SectionHeader(
              title: 'Daily Progress',
              icon: Icons.calendar_month,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildDayGrid(context, ramadanRecords, dayOfRamadan),
          ),

          // Weekly streaks
          SliverToBoxAdapter(
            child: const SectionHeader(
              title: 'Weekly Streaks',
              icon: Icons.local_fire_department,
            ),
          ),
          SliverToBoxAdapter(child: _buildWeeklyStreaks(context, scores)),

          // Spiritual level
          SliverToBoxAdapter(
            child: const SectionHeader(
              title: 'Spiritual Level',
              icon: Icons.emoji_events,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildLevelCard(context, levelInfo, completedDays, avgScore),
          ),

          // Score trend
          SliverToBoxAdapter(
            child: const SectionHeader(
              title: 'Score Trend',
              icon: Icons.trending_up,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildScoreChart(context, scores, dayOfRamadan),
          ),

          // Cumulative stats
          SliverToBoxAdapter(
            child: const SectionHeader(
              title: 'Cumulative Stats',
              icon: Icons.bar_chart,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildStatsGrid(
              context,
              totalPrayers,
              totalPages,
              totalCharity,
              completedDays,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildOverallCard(
    BuildContext context,
    profile,
    double progress,
    double avgScore,
    int dayOfRamadan,
  ) {
    return GlassCard(
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Row(
        children: [
          CircularScoreRing(
            progress: progress,
            size: 80,
            strokeWidth: 6,
            label: '${(progress * 100).round()}%',
            sublabel: 'Complete',
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayOfRamadan of 30',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Average Score: ${avgScore.round()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalMessage(dayOfRamadan),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGrid(
    BuildContext context,
    List<DailyRecord?> records,
    int currentDay,
  ) {
    return GlassCard(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(30, (i) {
          final day = i + 1;
          final r = records[i];
          final score = r?.dailyScore ?? 0;
          final isCurrent = day == currentDay;
          final isPast = day < currentDay;
          final isFuture = day > currentDay;

          Color bgColor;
          Color textColor;
          if (isFuture) {
            bgColor = AppColors.surfaceLight.withValues(alpha: 0.15);
            textColor = AppColors.textDim;
          } else if (score >= 75) {
            bgColor = AppColors.gold.withValues(alpha: 0.3);
            textColor = AppColors.goldLight;
          } else if (score >= 50) {
            bgColor = AppColors.gold.withValues(alpha: 0.15);
            textColor = AppColors.gold;
          } else if (isPast && score > 0) {
            bgColor = AppColors.surfaceLight.withValues(alpha: 0.3);
            textColor = AppColors.textSecondary;
          } else {
            bgColor = AppColors.surfaceLight.withValues(alpha: 0.15);
            textColor = AppColors.textDim;
          }

          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: isCurrent
                  ? Border.all(color: AppColors.gold, width: 2)
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isPast && score > 0)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: score >= 75
                          ? AppColors.gold
                          : score >= 50
                          ? AppColors.goldDim
                          : AppColors.textDim,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeeklyStreaks(BuildContext context, List<double> scores) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (weekIndex) {
          final start = weekIndex * 7;
          final end = (start + 7).clamp(0, 30);
          int activeDays = 0;
          for (int i = start; i < end; i++) {
            if (scores[i] > 0) activeDays++;
          }
          final weekDays = end - start;
          final isPerfect = activeDays == weekDays && activeDays > 0;

          return Column(
            children: [
              CircularScoreRing(
                progress: weekDays > 0 ? activeDays / weekDays : 0,
                size: 56,
                strokeWidth: 4,
                label: '$activeDays/$weekDays',
                color: isPerfect ? AppColors.goldLight : null,
              ),
              const SizedBox(height: 6),
              Text(
                'Week ${weekIndex + 1}',
                style: TextStyle(
                  color: isPerfect ? AppColors.gold : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isPerfect ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (isPerfect) const Text('🔥', style: TextStyle(fontSize: 14)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    _LevelInfo level,
    int days,
    double avg,
  ) {
    final levels = _allLevels;
    return GlassCard(
      child: Row(
        children: levels.map((l) {
          final isActive = l.name == level.name;
          final isPast = levels.indexOf(l) < levels.indexOf(level);
          return Expanded(
            child: Column(
              children: [
                Text(l.emoji, style: TextStyle(fontSize: isActive ? 32 : 24)),
                const SizedBox(height: 4),
                Text(
                  l.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.gold
                        : isPast
                        ? AppColors.success
                        : AppColors.textDim,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (isPast)
                  const Icon(
                    Icons.check_circle,
                    size: 12,
                    color: AppColors.success,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScoreChart(
    BuildContext context,
    List<double> scores,
    int currentDay,
  ) {
    final spots = <FlSpot>[];
    for (int i = 0; i < currentDay && i < scores.length; i++) {
      spots.add(FlSpot(i.toDouble(), scores[i]));
    }

    if (spots.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 150,
          child: Center(
            child: Text(
              'Track your first day to see trends',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.surfaceLight.withValues(alpha: 0.2),
                  strokeWidth: 0.5,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 25,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      'D${value.toInt() + 1}',
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 29,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.gold,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: AppColors.gold,
                      strokeWidth: 0,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.3),
                      AppColors.gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    int prayers,
    int pages,
    double charity,
    int days,
  ) {
    final stats = [
      ('🕌', 'Prayers', '$prayers'),
      ('📖', 'Pages', '$pages'),
      ('💰', 'Charity', charity > 0 ? 'RM ${charity.toStringAsFixed(0)}' : '—'),
      ('📅', 'Active Days', '$days'),
    ];

    return GlassCard(
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Column(
              children: [
                Text(s.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  s.$3,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  s.$2,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMotivationalMessage(int day) {
    if (day <= 7)
      return 'Every journey begins with a single step. You\'re building your foundation.';
    if (day <= 14)
      return 'You\'re building momentum. Keep pushing beyond your comfort zone.';
    if (day <= 21)
      return 'Deepen your connection. Focus on the quality of your worship.';
    return 'The final sprint! Seek Laylat al-Qadr with all your heart.';
  }
}

class _LevelInfo {
  final String name;
  final String emoji;
  final int minDays;
  final double minAvg;

  const _LevelInfo(this.name, this.emoji, this.minDays, this.minAvg);
}

final _allLevels = [
  const _LevelInfo('Seed', '🌱', 0, 0),
  const _LevelInfo('Sapling', '🌿', 10, 60),
  const _LevelInfo('Tree', '🌳', 20, 70),
  const _LevelInfo('Star', '⭐', 25, 80),
  const _LevelInfo('Crescent', '🌙', 30, 85),
];

_LevelInfo _getLevel(int days, double avg) {
  _LevelInfo current = _allLevels.first;
  for (final level in _allLevels) {
    if (days >= level.minDays && avg >= level.minAvg) {
      current = level;
    }
  }
  return current;
}
