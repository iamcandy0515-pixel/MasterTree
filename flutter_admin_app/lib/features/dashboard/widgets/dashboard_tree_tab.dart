import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/widgets/dashboard_shortcut_item.dart';
import 'package:flutter_admin_app/features/tree_registration/screens/tree_registration_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_sourcing_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_group_management_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_list_screen.dart';

class DashboardTreeTab extends StatelessWidget {
  const DashboardTreeTab({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardShortcutItem(
            icon: Icons.add_task_outlined,
            label: '신규 수목 등록',
            subLabel: '부위별 이미지 및 성상 기반 등록 모듈',
            onTap: () => _navigateTo(context, const TreeRegistrationScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.add_a_photo,
            label: '수목 이미지 추출(수목별)',
            subLabel: '학습 데이터용 이미지 벌크 추가 및 구글 검색',
            onTap: () => _navigateTo(context, const TreeSourcingScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.schema,
            label: '비교 수목 일람',
            subLabel: '유사 수목 그룹 관리',
            onTap: () => _navigateTo(context, const TreeGroupManagementScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          DashboardShortcutItem(
            icon: Icons.nature_people,
            label: '수목도감 일람',
            subLabel: '데이터 베이스 편집 및 검색',
            onTap: () => _navigateTo(context, const TreeListScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
