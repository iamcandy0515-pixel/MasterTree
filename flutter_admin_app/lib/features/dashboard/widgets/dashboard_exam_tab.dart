import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/widgets/dashboard_shortcut_item.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_extraction_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_extraction_step2_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_similar_management_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_management_screen.dart';

class DashboardExamTab extends StatelessWidget {
  const DashboardExamTab({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    const secondaryBlue = Color(0xFF3B82F6);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShortcutItem(
            icon: Icons.auto_awesome_motion,
            label: '기출문제 추출(일괄)',
            subLabel: '범위 지정 및 AI 자동 분할 추출 (V2.6)',
            onTap: () => _navigateTo(context, const BulkExtractionScreen()),
            color: secondaryBlue,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.note_add_outlined,
            label: '기출문제 추출(건별)',
            subLabel: '파일 선택 후 한 문항씩 정밀 추출',
            onTap: () => _navigateTo(
              context,
              const QuizExtractionStep2Screen(selectedFiles: []),
            ),
            color: secondaryBlue,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.psychology_outlined,
            label: '기출문제 유사문제 추출(일괄)',
            subLabel: '회차별 5개 단위 순차 유사도 분석 (V1.0)',
            onTap: () => _navigateTo(context, const BulkSimilarManagementScreen()),
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.quiz_outlined,
            label: '기출문제 일람',
            subLabel: 'AI 파싱 결과 및 오답 보기 검토',
            onTap: () => _navigateTo(context, const QuizManagementScreen()),
            color: secondaryBlue,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
