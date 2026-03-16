import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../past_exam_list_screen.dart';

class DashboardExamTab extends StatelessWidget {
  const DashboardExamTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          _buildGuideSection(),
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
                '기출문제 대비',
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem('최신 기출 문항부터 차례대로 학습해보세요.'),
          const SizedBox(height: 8),
          _buildGuideItem('모든 문제에 상세 해설과 함께 제공합니다.'),
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
}

