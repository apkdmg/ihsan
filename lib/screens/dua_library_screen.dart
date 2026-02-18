import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/islamic_data.dart';
import '../widgets/common_widgets.dart';

class DuaLibraryScreen extends StatelessWidget {
  const DuaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = IslamicData.duaLibrary.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: const Text('Dua Library'),
        centerTitle: true,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final category = categories[i];
          final duas = IslamicData.duaLibrary[category]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: category, icon: Icons.auto_awesome),
              ...duas.map((dua) => _DuaCard(dua: dua)),
            ],
          );
        },
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final Map<String, String> dua;

  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            dua['title']!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Arabic
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dua['arabic']!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                color: AppColors.goldLight,
                height: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Transliteration
          if (dua['transliteration'] != null) ...[
            Text(
              dua['transliteration']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Translation
          Text(
            dua['translation']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
