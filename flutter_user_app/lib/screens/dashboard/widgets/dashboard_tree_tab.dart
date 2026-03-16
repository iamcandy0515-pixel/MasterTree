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
            '수목도감 열람',
            '모든 수목 정보를 확인하세요.',
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
            '오늘의 퀴즈로 실력을 테스트하세요.',
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
            '비교 수목 열람',
            '헷갈리는 수목들을 비교 학습하세요.',
            Icons.compare_arrows,
            Colors.purpleAccent,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimilarSpeciesListScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideSection(),
        ],
      ),
    );
  }

  Widget _buildGuideSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined, 
                color: AppColors.primary.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                '수목학습 가이드',
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem('수목의 특징적인 동정 포인트를 위주로 익혀보세요.'),
          const SizedBox(height: 8),
          _buildGuideItem('유사한 수목들을 비교하며 차이점을 파악하는 것이 중요합니다.'),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, color: AppColors.primary.withOpacity(0.5), size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textMuted.withOpacity(0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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

