import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waktu_solat_lib/waktu_solat_lib.dart' as waktu_solat;
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _nameController = TextEditingController();
  int _quranGoal = 20;
  int _quranStartPage = 1;
  String _selectedZoneCode = 'WLY01';
  String _selectedZoneName = 'Kuala Lumpur';

  List<waktu_solat.ZoneInfo> _zones = [];
  bool _loadingZones = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() => _loadingZones = true);
    try {
      final client = waktu_solat.WaktuSolatClient();
      final zones = await client.getZones();
      setState(() {
        _zones = zones;
        _loadingZones = false;
      });
    } catch (e) {
      setState(() => _loadingZones = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    ref
        .read(userProfileProvider.notifier)
        .completeOnboarding(
          name: _nameController.text.isNotEmpty
              ? _nameController.text
              : 'Muslim',
          zoneCode: _selectedZoneCode,
          zoneName: _selectedZoneName,
          quranGoal: _quranGoal,
          quranStartPage: _quranStartPage,
        );
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.gold
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(context),
                  _buildNamePage(context),
                  _buildZonePage(context),
                  _buildGoalPage(context),
                  _buildStartPagePage(context),
                ],
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.backgroundPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < 4 ? 'Continue' : 'Begin Ramadan Journey',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Crescent moon icon
          Icon(
            Icons.mosque,
            size: 80,
            color: AppColors.gold.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 32),
          Text(
            'إحسان',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
              shadows: [
                Shadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ihsan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your companion for spiritual excellence during Ramadan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Track your ibadah, build consistency,\nand grow closer to Allah.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDim,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: AppColors.gold, size: 48),
          const SizedBox(height: 24),
          Text(
            'What\'s your name?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this to personalize your experience.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: const TextStyle(color: AppColors.textDim),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonePage(BuildContext context) {
    // Group zones by state
    final groupedZones = <String, List<waktu_solat.ZoneInfo>>{};
    for (final z in _zones) {
      groupedZones.putIfAbsent(z.negeri, () => []).add(z);
    }
    final states = groupedZones.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.location_on, color: AppColors.gold, size: 48),
          const SizedBox(height: 16),
          Text(
            'Select Your Zone',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'For accurate prayer times (JAKIM)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_loadingZones)
            const CircularProgressIndicator(color: AppColors.gold)
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: states.length,
                itemBuilder: (context, i) {
                  final state = states[i];
                  final zones = groupedZones[state]!;
                  return ExpansionTile(
                    title: Text(
                      state,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    iconColor: AppColors.gold,
                    collapsedIconColor: AppColors.textDim,
                    children: zones.map((z) {
                      final selected = z.jakimCode == _selectedZoneCode;
                      return ListTile(
                        title: Text(
                          z.daerah,
                          style: TextStyle(
                            color: selected
                                ? AppColors.gold
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.gold,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedZoneCode = z.jakimCode;
                            _selectedZoneName = '${z.negeri} - ${z.daerah}';
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(BuildContext context) {
    final pagesForKhatam = (604 / 30).ceil(); // ~20 pages/day
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, color: AppColors.gold, size: 48),
          const SizedBox(height: 24),
          Text(
            'Quran Reading Goal',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How many pages per day?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'For full Khatam: ~$pagesForKhatam pages/day',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoalButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quranGoal > 1) {
                    setState(() => _quranGoal--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '$_quranGoal',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _GoalButton(
                icon: Icons.add,
                filled: true,
                onTap: () {
                  setState(() => _quranGoal++);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('pages / day', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          // Presets
          Wrap(
            spacing: 8,
            children: [5, 10, 20, 30].map((p) {
              final selected = _quranGoal == p;
              return GestureDetector(
                onTap: () => setState(() => _quranGoal = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : AppColors.surfaceLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.gold : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    '$p pages',
                    style: TextStyle(
                      color: selected
                          ? AppColors.gold
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPagePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark, color: AppColors.gold, size: 48),
          const SizedBox(height: 24),
          Text(
            'Starting Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Where are you starting from?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Page 1 to start a new Khatam',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoalButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quranStartPage > 1) {
                    setState(() => _quranStartPage--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '$_quranStartPage',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _GoalButton(
                icon: Icons.add,
                filled: true,
                onTap: () {
                  if (_quranStartPage < 604) {
                    setState(() => _quranStartPage++);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Page Number', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          // Presets
          Wrap(
            spacing: 8,
            children: [1, 100, 200, 300].map((p) {
              final selected = _quranStartPage == p;
              return GestureDetector(
                onTap: () => setState(() => _quranStartPage = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : AppColors.surfaceLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.gold : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'Page $p',
                    style: TextStyle(
                      color: selected
                          ? AppColors.gold
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GoalButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _GoalButton({
    required this.icon,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.goldGradient : null,
          color: filled ? null : AppColors.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: filled ? AppColors.backgroundPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
