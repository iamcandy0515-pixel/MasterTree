import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../tree_list_screen.dart';
import '../../quiz_screen.dart';
import '../../past_exam_list_screen.dart';
import '../../similar_species_list_screen.dart';
import 'parts/module_menu_card.dart';
import 'parts/module_guide_section.dart';

class DashboardModuleGrid extends StatelessWidget {
  const DashboardModuleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modules = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': '수목도감 일람',
        'subtitle': '모든 수목 정보를 확인하세요',
        'icon': Icons.menu_book,
        'color': AppColors.primary,
        'screen': const TreeListScreen(),
      },
      <String, dynamic>{
        'title': '수목 / 퀴즈',
        'subtitle': '오늘의 퀴즈로 실력을 테스트하세요',
        'icon': Icons.school,
        'color': Colors.orangeAccent,
        'screen': const QuizScreen(),
      },
      <String, dynamic>{
        'title': '기출 / 학습',
        'subtitle': '기출 문제를 풀고 실전 감각을 익히세요',
        'icon': Icons.history_edu,
        'color': Colors.blueAccent,
        'screen': const PastExamListScreen(),
      },
      <String, dynamic>{
        'title': '비교 수목 일람',
        'subtitle': '헷갈리는 수목들을 비교 학습하세요',
        'icon': Icons.compare_arrows,
        'color': Colors.purpleAccent,
        'screen': const SimilarSpeciesListScreen(),
      },
    ];

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
            children: modules.map((Map<String, dynamic> m) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ModuleMenuCard(
                title: m['title'] as String,
                subtitle: m['subtitle'] as String,
                icon: m['icon'] as IconData,
                color: m['color'] as Color,
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext context) => m['screen'] as Widget),
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const ModuleGuideSection(),
      ],
    );
  }
}
