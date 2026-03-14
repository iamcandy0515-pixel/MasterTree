import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../tree_list_screen.dart';
import '../../quiz_screen.dart';
import '../../similar_species_list_screen.dart';

class DashboardTreeTab extends StatelessWidget {
  const DashboardTreeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            '수목도감 일람',
            '모든 수목 정보를 확인하세요',
            Icons.menu_book,
            AppColors.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TreeListScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(
            context,
            '수목 / 퀴즈',
            '오늘의 퀴즈로 실력을 테스트하세요',
            Icons.school,
            Colors.orangeAccent,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuCard(
            context,
            '비교 수목 일람',
            '헷갈리는 수목들을 비교 학습하세요',
            Icons.compare_arrows,
            Colors.purpleAccent,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimilarSpeciesListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
