import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

class HubGuideSection extends StatelessWidget {
  const HubGuideSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppRadius.base),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '학습 가이드',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          const _GuideItem(text: '매일 새로운 퀴즈를 통해 학습 성취도를 높이세요.'),
          const SizedBox(height: 8),
          const _GuideItem(text: '유사종 비교 데이터를 활용해 식별 능력을 향상시킬 수 있습니다.'),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String text;

  const _GuideItem({required this.text});

  @override
  Widget build(BuildContext context) {
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
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
