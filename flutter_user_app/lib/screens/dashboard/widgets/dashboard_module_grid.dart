import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../tree_list_screen.dart';
import '../../quiz_screen.dart';
import '../../past_exam_list_screen.dart';
import '../../similar_species_list_screen.dart';

class DashboardModuleGrid extends StatelessWidget {
  const DashboardModuleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            '학습 모듈',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              _buildMenuCard(
                context,
                '기출 / 학습',
                '기출 문제를 풀고 실전 감각을 익히세요',
                Icons.history_edu,
                Colors.blueAccent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PastExamListScreen()),
                ),
              ),
              const SizedBox(height: 8),
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
        ),
        const SizedBox(height: 16),
        _buildGuideSection(),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 가이드',
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            _buildGuideItem('매일 새로운 퀴즈를 풀어 학습 성취도를 높이세요.'),
            const SizedBox(height: 8),
            _buildGuideItem('유사종 비교 데이터를 활용해 식별 능력을 향상시킬 수 있습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
