import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/daily_record.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class DailyTrackerScreen extends ConsumerWidget {
  const DailyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(dailyRecordProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.backgroundPrimary,
            title: const Text('Daily Tracker'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircularScoreRing(
                  progress: record.dailyScore / 100,
                  size: 36,
                  strokeWidth: 3,
                  label: '${record.dailyScore.round()}',
                ),
              ),
            ],
          ),

          // ── PRAYERS ──
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Salah', icon: Icons.mosque_rounded),
          ),
          SliverToBoxAdapter(child: _buildPrayerSection(context, record, ref)),

          // ── QURAN ──
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Quran', icon: Icons.menu_book_rounded),
          ),
          SliverToBoxAdapter(child: _buildQuranSection(context, record, ref)),

          // ── ZIKR & DUA ──
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Zikr & Dua',
              icon: Icons.favorite_rounded,
            ),
          ),
          SliverToBoxAdapter(child: _buildZikrSection(context, record, ref)),

          // ── FASTING & SELF-DISCIPLINE ──
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Fasting & Self-Discipline',
              icon: Icons.self_improvement_rounded,
            ),
          ),
          SliverToBoxAdapter(child: _buildFastingSection(context, record, ref)),

          // ── GOOD DEEDS ──
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Good Deeds & Charity',
              icon: Icons.volunteer_activism_rounded,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildGoodDeedsSection(context, record, ref),
          ),

          // ── KNOWLEDGE ──
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Knowledge & Learning',
              icon: Icons.school_rounded,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildKnowledgeSection(context, record, ref),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPrayerSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    // (name, key, icon)
    final prayers = [
      ('Maghrib', 'maghrib', Icons.wb_cloudy_rounded),
      ('Isha', 'isha', Icons.nights_stay_rounded),
      ('Tarawih', 'tarawih', Icons.auto_awesome_rounded),
      ('Tahajjud', 'tahajjud', Icons.bedtime_rounded),
      ('Fajr', 'fajr', Icons.wb_twilight_rounded),
      ('Duha', 'duha', Icons.flare_rounded),
      ('Dhuhr', 'dhuhr', Icons.wb_sunny_rounded),
      ('Asr', 'asr', Icons.light_mode_rounded),
    ];

    return GlassCard(
      child: Column(
        children: prayers.map((p) {
          final statusIndex = record.prayerStatuses[p.$2] ?? 0;
          final status = PrayerStatus.values[statusIndex];
          return _PrayerTile(
            name: p.$1,
            icon: p.$3,
            status: status,
            onStatusChange: (newStatus) {
              ref
                  .read(dailyRecordProvider.notifier)
                  .setPrayerStatus(p.$2, newStatus);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuranSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    return GlassCard(
      child: Column(
        children: [
          _ToggleTile(
            title: 'Listened to Recitation',
            icon: Icons.headphones_rounded,
            value: record.listenedToRecitation,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('listenedToRecitation'),
          ),
          _ToggleTile(
            title: 'Read Tafsir / Translation',
            icon: Icons.translate_rounded,
            value: record.readTafsir,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('readTafsir'),
          ),
        ],
      ),
    );
  }

  Widget _buildZikrSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    final zikrItems = [
      ('SubhanAllah', 'subhanAllah', 33),
      ('Alhamdulillah', 'alhamdulillah', 33),
      ('Allahu Akbar', 'allahuAkbar', 33),
      ('La ilaha illallah', 'laIlahaIllallah', 100),
      ('Istighfar', 'istighfar', 100),
      ('Salawat', 'salawat', 100),
    ];

    return GlassCard(
      child: Column(
        children: [
          ...zikrItems.map((z) {
            final count = record.zikrCounts[z.$2] ?? 0;
            final target = z.$3;
            final complete = count >= target;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    complete
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: complete ? AppColors.success : AppColors.textDim,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      z.$1,
                      style: TextStyle(
                        color: complete
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontWeight: complete
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: complete
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count / $target',
                      style: TextStyle(
                        color: complete
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppColors.surfaceLight, height: 20),
          _ToggleTile(
            title: 'Morning Adhkar',
            icon: Icons.wb_twilight_rounded,
            value: record.morningAdhkar,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('morningAdhkar'),
          ),
          _ToggleTile(
            title: 'Evening Adhkar',
            icon: Icons.wb_cloudy_rounded,
            value: record.eveningAdhkar,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('eveningAdhkar'),
          ),
          _ToggleTile(
            title: 'Personal Dua',
            icon: Icons.waving_hand_rounded,
            value: record.personalDua,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('personalDua'),
          ),
          _ToggleTile(
            title: 'Dua Before/After Eating',
            icon: Icons.restaurant_rounded,
            value: record.duaBeforeAfterEating,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('duaBeforeAfterEating'),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    return GlassCard(
      child: Column(
        children: [
          _ToggleTile(
            title: 'Completed Fast',
            icon: Icons.nights_stay_rounded,
            value: record.fastingCompleted,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('fastingCompleted'),
          ),
          _ToggleTile(
            title: 'Ate Suhoor',
            icon: Icons.free_breakfast_rounded,
            value: record.ateSuhoor,
            onChanged: () =>
                ref.read(dailyRecordProvider.notifier).toggleField('ateSuhoor'),
          ),
          _ToggleTile(
            title: 'Broke Fast with Dates',
            icon: Icons.spa_rounded,
            value: record.brokeWithDates,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('brokeWithDates'),
          ),
          const Divider(color: AppColors.surfaceLight, height: 20),
          _ToggleTile(
            title: 'Avoided Gossip & Backbiting',
            icon: Icons.do_not_disturb_on_rounded,
            value: record.avoidedGossip,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('avoidedGossip'),
          ),
          _ToggleTile(
            title: 'Controlled Anger',
            icon: Icons.sentiment_satisfied_rounded,
            value: record.controlledAnger,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('controlledAnger'),
          ),
          _ToggleTile(
            title: 'Lowered Gaze',
            icon: Icons.visibility_off_rounded,
            value: record.loweredGaze,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('loweredGaze'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodDeedsSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    // (label, key, icon)
    final deeds = [
      ('Gave Charity (Sadaqah)', 'charity', Icons.monetization_on_rounded),
      ('Helped Someone', 'helped', Icons.handshake_rounded),
      ('Fed Someone Iftar', 'fedIftar', Icons.dinner_dining_rounded),
      ('Visited the Sick', 'visitedSick', Icons.local_hospital_rounded),
      ('Smiled at Someone', 'smiled', Icons.sentiment_very_satisfied_rounded),
      ('Reconciled with Someone', 'reconciled', Icons.people_rounded),
      ('Taught Someone', 'taught', Icons.cast_for_education_rounded),
      ('Made Dua for Others', 'duaForOthers', Icons.waving_hand_rounded),
      (
        'Called/Visited Parents',
        'calledParents',
        Icons.family_restroom_rounded,
      ),
    ];

    return GlassCard(
      child: Column(
        children: deeds.map((d) {
          final done = record.goodDeeds.contains(d.$2);
          return _ToggleTile(
            title: d.$1,
            icon: d.$3,
            value: done,
            onChanged: () =>
                ref.read(dailyRecordProvider.notifier).toggleGoodDeed(d.$2),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKnowledgeSection(
    BuildContext context,
    DailyRecord record,
    WidgetRef ref,
  ) {
    return GlassCard(
      child: Column(
        children: [
          _ToggleTile(
            title: 'Attended Lecture / Class',
            icon: Icons.school_rounded,
            value: record.attendedLecture,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('attendedLecture'),
          ),
          _ToggleTile(
            title: 'Read Islamic Book / Article',
            icon: Icons.menu_book_rounded,
            value: record.readIslamicBook,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('readIslamicBook'),
          ),
          _ToggleTile(
            title: 'Shared Knowledge',
            icon: Icons.share_rounded,
            value: record.sharedKnowledge,
            onChanged: () => ref
                .read(dailyRecordProvider.notifier)
                .toggleField('sharedKnowledge'),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Tiles ──

class _ToggleTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final VoidCallback onChanged;

  const _ToggleTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? AppColors.gold : AppColors.textDim,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: value
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppColors.gold
                      : AppColors.textDim.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.gold,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final PrayerStatus status;
  final ValueChanged<PrayerStatus> onStatusChange;

  const _PrayerTile({
    required this.name,
    required this.icon,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Status chips
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusChip(
                iconData: Icons.check_rounded,
                tooltip: 'On Time',
                active: status == PrayerStatus.onTime,
                color: AppColors.prayerOnTime,
                onTap: () => onStatusChange(
                  status == PrayerStatus.onTime
                      ? PrayerStatus.pending
                      : PrayerStatus.onTime,
                ),
              ),
              const SizedBox(width: 4),
              _StatusChip(
                iconData: Icons.schedule_rounded,
                tooltip: 'Late',
                active: status == PrayerStatus.late_,
                color: AppColors.prayerLate,
                onTap: () => onStatusChange(
                  status == PrayerStatus.late_
                      ? PrayerStatus.pending
                      : PrayerStatus.late_,
                ),
              ),
              const SizedBox(width: 4),
              _StatusChip(
                iconData: Icons.close_rounded,
                tooltip: 'Missed',
                active: status == PrayerStatus.missed,
                color: AppColors.prayerMissed,
                onTap: () => onStatusChange(
                  status == PrayerStatus.missed
                      ? PrayerStatus.pending
                      : PrayerStatus.missed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData iconData;
  final String tooltip;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.iconData,
    required this.tooltip,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active
                  ? color
                  : AppColors.surfaceLight.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Icon(
              iconData,
              size: 15,
              color: active ? color : AppColors.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
