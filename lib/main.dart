import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'models/daily_record.dart';
import 'models/user_profile.dart';
import 'models/quran_translation.dart';
import 'models/quran_bookmark.dart';
import 'providers/app_providers.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/daily_tracker_screen.dart';
import 'screens/zikr_counter_screen.dart';
import 'screens/journey_screen.dart';
import 'screens/dua_library_screen.dart';
import 'screens/muhasabah_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/quran_surah_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DailyRecordAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(CachedTranslationAdapter());
  Hive.registerAdapter(QuranBookmarkAdapter());
  await NotificationService.init();

  runApp(const ProviderScope(child: IhsanApp()));
}

class IhsanApp extends ConsumerWidget {
  const IhsanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate notification scheduling when prayer times change
    ref.watch(notificationServiceProvider);

    return MaterialApp(
      title: 'Ihsan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends ConsumerStatefulWidget {
  const _AppGate();

  @override
  ConsumerState<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<_AppGate> {
  bool _showOnboarding = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final profile = ref.read(userProfileProvider);
    if (mounted) {
      setState(() {
        _showOnboarding = !profile.onboardingComplete;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () {
          // Request notification permissions after onboarding
          NotificationService.requestPermissions();
          setState(() => _showOnboarding = false);
        },
      );
    }

    return const _MainShell();
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    DailyTrackerScreen(),
    ZikrCounterScreen(),
    JourneyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceLight.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.checklist_outlined,
                  activeIcon: Icons.checklist,
                  label: 'Track',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.pending_outlined,
                  activeIcon: Icons.blur_circular,
                  label: 'Tasbih',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Journey',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                // More menu — with animated transitions for subpages
                _MoreButton(
                  onQuranTap: () => Navigator.push(
                    context,
                    _SlideUpRoute(child: const QuranSurahListScreen()),
                  ),
                  onDuaTap: () => Navigator.push(
                    context,
                    _SlideUpRoute(child: const DuaLibraryScreen()),
                  ),
                  onMuhasabahTap: () => Navigator.push(
                    context,
                    _SlideUpRoute(child: const MuhasabahScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated page route ──
class _SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _SlideUpRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
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
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon swap with scale
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: isActive ? AppColors.gold : AppColors.textDim,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.gold : AppColors.textDim,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 2),
                width: isActive ? 4 : 0,
                height: isActive ? 4 : 0,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onQuranTap;
  final VoidCallback onDuaTap;
  final VoidCallback onMuhasabahTap;

  const _MoreButton({required this.onQuranTap, required this.onDuaTap, required this.onMuhasabahTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PopupMenuButton<String>(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, -170),
        onSelected: (value) {
          if (value == 'quran') onQuranTap();
          if (value == 'dua') onDuaTap();
          if (value == 'muhasabah') onMuhasabahTap();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'quran',
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Quran',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'dua',
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Dua Library',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'muhasabah',
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Muhasabah',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.more_horiz, color: AppColors.textDim, size: 24),
              const SizedBox(height: 2),
              const Text(
                'More',
                style: TextStyle(color: AppColors.textDim, fontSize: 10),
              ),
              const SizedBox(height: 6), // Spacer for dot alignment
            ],
          ),
        ),
      ),
    );
  }
}
