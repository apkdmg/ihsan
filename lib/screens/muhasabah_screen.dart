import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/common_widgets.dart';

class MuhasabahScreen extends ConsumerStatefulWidget {
  const MuhasabahScreen({super.key});

  @override
  ConsumerState<MuhasabahScreen> createState() => _MuhasabahScreenState();
}

class _MuhasabahScreenState extends ConsumerState<MuhasabahScreen> {
  late TextEditingController _bestDeedController;
  late TextEditingController _improvementController;
  late TextEditingController _gratitudeController;
  late TextEditingController _reflectionController;
  int _selectedKhushu = 0;

  @override
  void initState() {
    super.initState();
    final record = ref.read(dailyRecordProvider);
    _bestDeedController = TextEditingController(text: record.bestDeedNote);
    _improvementController = TextEditingController(
      text: record.improvementNote,
    );
    _gratitudeController = TextEditingController(text: record.gratitudeNote);
    _reflectionController = TextEditingController(text: record.reflectionNote);
    _selectedKhushu = record.khushuRating;
  }

  @override
  void dispose() {
    _bestDeedController.dispose();
    _improvementController.dispose();
    _gratitudeController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(dailyRecordProvider.notifier)
        .saveReflection(
          bestDeed: _bestDeedController.text,
          improvement: _improvementController.text,
          gratitude: _gratitudeController.text,
          note: _reflectionController.text,
          khushu: _selectedKhushu,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reflection saved'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: const Text('Muhasabah'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Intro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Nightly self-reflection — take a moment to review your day.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Khushu rating
          const SectionHeader(
            title: 'Khushu in Prayer Today',
            icon: Icons.self_improvement,
          ),
          GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final level = i + 1;
                final selected = _selectedKhushu >= level;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedKhushu = level);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : AppColors.surfaceLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.gold
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            selected ? '⭐' : '☆',
                            style: TextStyle(fontSize: selected ? 22 : 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$level',
                        style: TextStyle(
                          color: selected ? AppColors.gold : AppColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Best deed
          const SectionHeader(title: 'Best Deed Today', icon: Icons.favorite),
          GlassCard(
            child: _buildTextField(
              _bestDeedController,
              'What was your best deed today?',
            ),
          ),

          // Gratitude
          const SectionHeader(title: 'Gratitude', icon: Icons.emoji_emotions),
          GlassCard(
            child: _buildTextField(
              _gratitudeController,
              'One thing you\'re grateful for today...',
            ),
          ),

          // Improvement
          const SectionHeader(
            title: 'Room for Growth',
            icon: Icons.trending_up,
          ),
          GlassCard(
            child: _buildTextField(
              _improvementController,
              'What can you improve tomorrow?',
            ),
          ),

          // Free reflection
          const SectionHeader(title: 'Free Reflection', icon: Icons.edit_note),
          GlassCard(
            child: _buildTextField(
              _reflectionController,
              'Any thoughts, feelings, or reflections...',
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDim),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
