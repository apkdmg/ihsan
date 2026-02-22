import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/islamic_data.dart';
import '../core/constants/quran_data.dart';
import '../core/utils/arabic_text_helper.dart';
import '../models/daily_record.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../providers/quran_providers.dart';
import '../services/prayer_times_service.dart';
import '../widgets/common_widgets.dart';
import 'adhkar_screen.dart';
import 'quran_reader_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // Refresh countdown display
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(dailyRecordProvider.notifier).reloadIfDayChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(dailyRecordProvider);
    final profile = ref.watch(userProfileProvider);
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final prayerTimes = prayerTimesAsync.whenOrNull(data: (d) => d);

    // Derive Ramadan state from the Hijri date in prayer times (Maghrib-aware)
    final isRamadan = prayerTimes?.isRamadan ?? false;
    final dayOfRamadan = prayerTimes?.ramadanDay ?? 1;

    // Feed Maghrib time to the daily record provider for Islamic day boundary
    if (prayerTimes != null) {
      ref
          .read(dailyRecordProvider.notifier)
          .updateMaghribTime(prayerTimes.maghrib);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header
          SliverToBoxAdapter(
            child: _buildHeader(
              context,
              profile,
              record,
              isRamadan,
              dayOfRamadan,
            ),
          ),
          // Prayer Times Card (actual API data)
          SliverToBoxAdapter(
            child: _buildPrayerTimesCard(context, prayerTimesAsync),
          ),

          if (!isRamadan) ...[
            // Not Ramadan — show countdown
            SliverToBoxAdapter(
              child: _buildRamadanCountdownCard(context, prayerTimes),
            ),
          ] else ...[
            // Ramadan is active — show full tracker
            SliverToBoxAdapter(child: _buildPrayerRow(context, record)),
            SliverToBoxAdapter(
              child: _buildAdhkarCard(context, prayerTimesAsync),
            ),
            SliverToBoxAdapter(
              child: _buildFastingCard(context, prayerTimesAsync),
            ),
            SliverToBoxAdapter(
              child: _buildQuranCard(context, record, profile),
            ),
            SliverToBoxAdapter(
              child: _buildDailyVerseCard(context, dayOfRamadan),
            ),
            SliverToBoxAdapter(child: _buildHadithCard(context, dayOfRamadan)),
            SliverToBoxAdapter(child: _buildCoachingCard(context, profile)),
          ],

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildRamadanCountdownCard(
    BuildContext context,
    TodayPrayerTimes? prayerTimes,
  ) {
    final days = prayerTimes?.daysUntilRamadan ?? -1;
    final nextDateStr = prayerTimes?.nextRamadanStartGregorian;
    DateTime? nextDate;
    if (nextDateStr != null) {
      try {
        nextDate = DateTime.parse(nextDateStr);
      } catch (_) {}
    }
    final hasEstimate = nextDate != null && days >= 0;

    // When Ramadan starts at tonight's Maghrib (days == 1), show hours instead
    final bool showHours = hasEstimate && days <= 1 && prayerTimes != null;
    Duration? timeUntilMaghrib;
    if (showHours) {
      timeUntilMaghrib = prayerTimes.maghrib.difference(DateTime.now());
      if (timeUntilMaghrib.isNegative) timeUntilMaghrib = null;
    }

    // Build display values
    final String countdownValue;
    final String countdownUnit;
    final String subtitleText;

    if (showHours && timeUntilMaghrib != null) {
      final h = timeUntilMaghrib.inHours;
      final m = timeUntilMaghrib.inMinutes % 60;
      countdownValue = h > 0 ? '${h}h ${m}m' : '$m';
      countdownUnit = h > 0 ? '' : 'min';
      subtitleText = 'Starts tonight at Maghrib';
    } else if (hasEstimate) {
      countdownValue = '$days';
      countdownUnit = days == 1 ? 'day' : 'days';
      subtitleText = 'Estimated start: ${_formatDate(nextDate)}';
    } else {
      countdownValue = '--';
      countdownUnit = '';
      subtitleText = 'Calculating from prayer times...';
    }

    return GlassCard(
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Column(
        children: [
          // ── Crescent + title ──
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('☽', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ramadan is Coming',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitleText,
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Countdown display ──
          if (hasEstimate) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  countdownValue,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                if (countdownUnit.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      countdownUnit,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'until the blessed month',
              style: TextStyle(color: AppColors.textDim, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (1 - (days / 354)).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use this time to prepare your heart and habits',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            // No estimate yet — fresh install, no prayer times fetched
            const Text(
              'Open the app after setting up your location\nto get an accurate countdown.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildHeader(
    BuildContext context,
    UserProfile profile,
    DailyRecord record,
    bool isRamadan,
    int dayOfRamadan,
  ) {
    final score = record.dailyScore;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF152238), AppColors.backgroundPrimary],
        ),
      ),
      child: Column(
        children: [
          // App title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ArabicTextHelper.reshape('إحسان'),
                      style: TextStyle(
                        fontFamily: 'KFGQPC Uthman Taha Naskh',
                        fontFamilyFallback: const ['Courier', 'monospace'],
                        fontFeatures: const [
                          FontFeature.enable('liga'),
                          FontFeature.enable('rlig'),
                          FontFeature.enable('calt'),
                          FontFeature.enable('ccmp'),
                        ],
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        shadows: [
                          Shadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isRamadan
                          ? 'Day $dayOfRamadan of 30'
                          : 'Ramadan coming soon',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Mosque icon
                // App Logo
                // App Logo (Scaled to remove border)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF152238),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.2,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Daily Score Ring
          CircularScoreRing(
            progress: score / 100,
            size: 140,
            strokeWidth: 10,
            label: '${score.round()}%',
            sublabel: 'Daily Score',
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreMessage(score),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return 'MashAllah! Excellent day! ✨';
    if (score >= 75) return 'Great progress! Keep going 💪';
    if (score >= 50) return 'Good effort. Every deed counts 🌿';
    if (score >= 25) return 'Keep building. Small steps matter 🌱';
    return 'Start your day with Bismillah ☀️';
  }

  // ── NEW: Prayer Times Card (from API) ──
  Widget _buildPrayerTimesCard(
    BuildContext context,
    AsyncValue<TodayPrayerTimes?> timesAsync,
  ) {
    return timesAsync.when(
      loading: () => GlassCard(
        child: SizedBox(
          height: 60,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading prayer times...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textDim),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (_, __) => GlassCard(
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Unable to load prayer times. Check your connection.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textDim),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(prayerTimesProvider.notifier).refresh(),
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
      data: (times) {
        if (times == null) return const SizedBox.shrink();

        final nextPrayer = times.nextPrayerName;
        final timeToNext = times.timeToNextPrayer;
        final hours = timeToNext.inHours;
        final minutes = timeToNext.inMinutes.remainder(60);
        final seconds = timeToNext.inSeconds.remainder(60);

        return GlassCard(
          borderColor: AppColors.gold.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Next prayer highlight
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 18,
                      color: AppColors.backgroundPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next: $nextPrayer',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (times.hijriDate.isNotEmpty)
                          Text(
                            times.hijriDate,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textDim),
                          ),
                      ],
                    ),
                  ),
                  // Countdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // All 5 prayer times row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: times.obligatoryPrayers.map((p) {
                  final isNext = p.name == nextPrayer;
                  final isPast = p.time.isBefore(DateTime.now());
                  return Column(
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          color: isNext
                              ? AppColors.gold
                              : isPast
                              ? AppColors.textDim
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isNext
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.formatted,
                        style: TextStyle(
                          color: isNext
                              ? AppColors.gold
                              : isPast
                              ? AppColors.textDim
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: isNext
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerRow(BuildContext context, DailyRecord record) {
    final prayers = [
      ('Maghrib', 'maghrib', Icons.nights_stay_outlined),
      ('Isha', 'isha', Icons.dark_mode),
      ('Fajr', 'fajr', Icons.wb_twilight),
      ('Dhuhr', 'dhuhr', Icons.wb_sunny),
      ('Asr', 'asr', Icons.wb_sunny_outlined),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                'Prayer Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.gold),
              ),
              const Spacer(),
              Text(
                '${(record.prayerCompletionRate * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: prayers.map((p) {
              final status =
                  PrayerStatus.values[record.prayerStatuses[p.$2] ?? 0];
              return _PrayerIcon(
                name: p.$1,
                icon: p.$3,
                status: status,
                onTap: () {
                  final next = PrayerStatus.values[(status.index + 1) % 4];
                  ref
                      .read(dailyRecordProvider.notifier)
                      .setPrayerStatus(p.$2, next);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniToggle(
                context,
                'Tarawih',
                Icons.nightlight_round,
                (record.prayerStatuses['tarawih'] ?? 0) ==
                    PrayerStatus.onTime.index,
                () => ref
                    .read(dailyRecordProvider.notifier)
                    .setPrayerStatus(
                      'tarawih',
                      (record.prayerStatuses['tarawih'] ?? 0) ==
                              PrayerStatus.onTime.index
                          ? PrayerStatus.pending
                          : PrayerStatus.onTime,
                    ),
              ),
              const SizedBox(width: 12),
              _buildMiniToggle(
                context,
                'Tahajjud',
                Icons.bedtime,
                (record.prayerStatuses['tahajjud'] ?? 0) ==
                    PrayerStatus.onTime.index,
                () => ref
                    .read(dailyRecordProvider.notifier)
                    .setPrayerStatus(
                      'tahajjud',
                      (record.prayerStatuses['tahajjud'] ?? 0) ==
                              PrayerStatus.onTime.index
                          ? PrayerStatus.pending
                          : PrayerStatus.onTime,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniToggle(
    BuildContext context,
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.surfaceLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppColors.gold.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppColors.gold : AppColors.textDim,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.gold : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── NEW: Adhkar Quick Access Card ──
  Widget _buildAdhkarCard(
    BuildContext context,
    AsyncValue<TodayPrayerTimes?> timesAsync,
  ) {
    bool isMorning = true; // Default to morning
    String title = 'Morning Adhkar';
    String subtitle = 'Fajr to Dhuhr';
    IconData icon = Icons.wb_twilight;

    final times = timesAsync.whenOrNull(data: (t) => t);
    if (times != null) {
      final now = DateTime.now();
      // Logic: Morning Adhkar is recommended from Fajr until Dhuhr (or Maghrib for some scholars, but we use Fajr-Asr window).
      // Evening Adhkar is from Asr until Isha/Fajr.
      if (now.isAfter(times.asr) || now.isBefore(times.fajr)) {
        isMorning = false;
        title = 'Evening Adhkar';
        subtitle = 'Asr to Fajr';
        icon = Icons.nights_stay;
      }
    } else {
      // Fallback logic based on hour if API is loading/fails (approximate)
      final hour = DateTime.now().hour;
      if (hour >= 15 || hour < 5) {
        // 3 PM to 5 AM
        isMorning = false;
        title = 'Evening Adhkar';
        subtitle = 'Daily Remembrance';
        icon = Icons.nights_stay;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdhkarScreen(isMorning: isMorning),
          ),
        );
      },
      child: GlassCard(
        borderColor: AppColors.gold.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFA67C00), // Darker gold for contrast
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.backgroundPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fasting Card — now uses real prayer times ──
  Widget _buildFastingCard(
    BuildContext context,
    AsyncValue<TodayPrayerTimes?> timesAsync,
  ) {
    // Use real data if available, otherwise fallback
    Duration countdown;
    bool isFasting;
    String label;

    final times = timesAsync.whenOrNull(data: (t) => t);
    if (times != null) {
      countdown = times.fastingCountdown;
      isFasting = times.isFastingTime;
      final now = DateTime.now();
      if (now.isBefore(times.imsak)) {
        label = 'Time until Suhoor ends';
      } else if (now.isBefore(times.maghrib)) {
        label = 'Time until Iftar';
      } else {
        label = 'Time until Suhoor ends';
      }
    } else {
      // Fallback to approximate
      final now = DateTime.now();
      final maghrib = DateTime(now.year, now.month, now.day, 19, 25);
      final fajr = DateTime(now.year, now.month, now.day, 5, 45);
      if (now.isBefore(fajr)) {
        countdown = fajr.difference(now);
        isFasting = false;
        label = 'Time until Suhoor ends';
      } else if (now.isBefore(maghrib)) {
        countdown = maghrib.difference(now);
        isFasting = true;
        label = 'Time until Iftar';
      } else {
        countdown = fajr.add(const Duration(days: 1)).difference(now);
        isFasting = false;
        label = 'Time until Suhoor ends';
      }
    }

    final hours = countdown.inHours;
    final minutes = countdown.inMinutes.remainder(60);
    final seconds = countdown.inSeconds.remainder(60);

    return GlassCard(
      borderColor: isFasting ? AppColors.gold.withValues(alpha: 0.2) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isFasting ? AppColors.goldGradient : null,
              color: isFasting ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFasting ? Icons.nightlight_round : Icons.restaurant,
              color: isFasting
                  ? AppColors.backgroundPrimary
                  : AppColors.textDim,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFasting ? 'Fasting' : 'Eating Window',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isFasting ? AppColors.gold : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranCard(
    BuildContext context,
    DailyRecord record,
    UserProfile profile,
  ) {
    final pagesRead = record.quranPagesRead;
    int currentCompletedPage =
        record.quranLastPage ?? ((profile.quranStartPage ?? 1) - 1);
    final baseCompletedPage = currentCompletedPage - pagesRead;
    final goal = profile.quranDailyGoal;
    final progress = goal > 0 ? (pagesRead / goal).clamp(0.0, 1.0) : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                'Quran',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.gold),
              ),
              const Spacer(),
              if (pagesRead >= goal && goal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Goal hit',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Progress bar ──
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pagesRead / $goal',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Bookmark chip + Log button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left: Up Next (Clickable to open reader at stop point) ──
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // Open in Arabic mode for focused reading
                    ref
                        .read(quranReadingModeProvider.notifier)
                        .set(QuranReadingMode.arabicFocus);
                    final stopSurah = profile.quranStopSurah;
                    final stopAyah = profile.quranStopAyah;
                    if (stopSurah != null && stopAyah != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuranReaderScreen(
                            surahNumber: stopSurah,
                            initialAyah: stopAyah,
                          ),
                        ),
                      );
                    } else {
                      // Resolve page to first ayah for users who log manually
                      final nextPage = currentCompletedPage + 1;
                      final service = ref.read(quranServiceProvider);
                      final verse = await service.getFirstVerseOnPage(nextPage);
                      if (verse != null && context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuranReaderScreen(
                              surahNumber: verse.surahNumber,
                              initialAyah: verse.ayahNumber,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Continue reading',
                              style: TextStyle(
                                color: AppColors.textDim,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _buildUpNextLabel(profile, currentCompletedPage),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: Interactive Quick Logger ──
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.surfaceLight.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentCompletedPage > baseCompletedPage) {
                          ref
                              .read(dailyRecordProvider.notifier)
                              .updateQuranLog(
                                pagesRead - 1,
                                currentCompletedPage - 1,
                              );
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 20,
                          color: currentCompletedPage > baseCompletedPage
                              ? AppColors.gold
                              : AppColors.textDim.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$currentCompletedPage',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (currentCompletedPage < 604) {
                          ref
                              .read(dailyRecordProvider.notifier)
                              .updateQuranLog(
                                pagesRead + 1,
                                currentCompletedPage + 1,
                              );
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildUpNextLabel(UserProfile profile, int currentCompletedPage) {
    final stopSurah = profile.quranStopSurah;
    final stopAyah = profile.quranStopAyah;
    final stopPage = profile.quranStopPage;

    if (stopSurah != null && stopAyah != null && stopPage != null) {
      final surahName = QuranSurahData.surahs[stopSurah - 1].nameEn;
      return 'Pg $stopPage · $surahName · Ayah $stopAyah';
    }
    return 'Page ${currentCompletedPage + 1}';
  }

  Widget _buildDailyVerseCard(BuildContext context, int dayOfRamadan) {
    final verseIndex = (dayOfRamadan - 1) % IslamicData.dailyVerses.length;
    final verse = IslamicData.dailyVerses[verseIndex];

    return GlassCard(
      borderColor: AppColors.gold.withValues(alpha: 0.15),
      child: Column(
        children: [
          Text(
            ArabicTextHelper.reshape(verse['arabic']!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'KFGQPC Uthman Taha Naskh',
              fontFamilyFallback: ['Courier', 'monospace'],
              fontFeatures: [
                FontFeature.enable('liga'),
                FontFeature.enable('rlig'),
                FontFeature.enable('calt'),
                FontFeature.enable('ccmp'),
              ],
              fontSize: 26,
              color: AppColors.goldLight,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceLight, height: 1),
          const SizedBox(height: 12),
          Text(
            verse['translation']!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${verse['reference']}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.gold),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, int dayOfRamadan) {
    final index = (dayOfRamadan - 1) % IslamicData.dailyHadiths.length;
    final hadith = IslamicData.dailyHadiths[index];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote,
                color: AppColors.textDim,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Daily Hadith',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textDim,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${hadith['text']}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${hadith['source']}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textDim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingCard(BuildContext context, UserProfile profile) {
    final phase = IslamicData.coachingPhases[profile.coachingPhase]!;

    return GlassCard(
      borderColor: AppColors.gold.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.backgroundPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Days ${phase['days']}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            phase['message'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final PrayerStatus status;
  final VoidCallback onTap;

  const _PrayerIcon({
    required this.name,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case PrayerStatus.onTime:
        return AppColors.prayerOnTime;
      case PrayerStatus.late_:
        return AppColors.prayerLate;
      case PrayerStatus.missed:
        return AppColors.prayerMissed;
      case PrayerStatus.pending:
        return AppColors.prayerUpcoming;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case PrayerStatus.onTime:
        return Icons.check_circle;
      case PrayerStatus.late_:
        return Icons.watch_later;
      case PrayerStatus.missed:
        return Icons.cancel;
      case PrayerStatus.pending:
        return icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor.withValues(
                alpha: status == PrayerStatus.pending ? 0.15 : 0.2,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusColor.withValues(alpha: 0.4),
                width: status == PrayerStatus.pending ? 0 : 1.5,
              ),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: status == PrayerStatus.pending
                  ? AppColors.textDim
                  : _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
