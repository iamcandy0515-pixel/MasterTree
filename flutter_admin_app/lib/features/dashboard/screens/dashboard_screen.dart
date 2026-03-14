import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_list_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_group_management_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/user_check_screen.dart';
// Note: LogCheckScreen import removed since its shortcut is deleted
import 'package:flutter_admin_app/features/dashboard/screens/notification_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_sourcing_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/statistics_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/settings_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_management_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_extraction_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_extraction_step2_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_similar_management_screen.dart';
import 'package:flutter_admin_app/features/tree_registration/screens/tree_registration_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardContent> {
  // stich Colors
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);
  static const secondaryBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    print('🎯 [DashboardScreen] Dashboard is now displayed!');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardStats();
    });
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _handleSignOut() async {
    final vm = context.read<DashboardViewModel>();
    final success = await vm.signOut();
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: backgroundDark,
      bottomNavigationBar: vm.isLoading
          ? null
          : SafeArea(child: _buildBottomNav()),
      body: SafeArea(
        bottom: false,
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 1. Header
                  _buildHeader(context),
                  const Divider(color: Colors.white10, height: 1),

                  // 2. Statistics Info Section (Unified with User App Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTextStatsSection(vm),
                  ),

                  // 3. 2-Tab Layout (기출문제 / 수목관리)
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: primaryColor,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.description, size: 20),
                                text: '기출문제',
                              ),
                              Tab(
                                icon: Icon(Icons.nature, size: 20),
                                text: '수목관리',
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [_buildExamTab(), _buildTreeTab()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildExamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShortcutListItem(
            icon: Icons.auto_awesome_motion,
            label: '기출문제 추출(일괄)',
            subLabel: '범위 지정 및 AI 자동 분할 추출 (V2.6)',
            onTap: () {
              _navigateTo(const BulkExtractionScreen());
            },
            color: secondaryBlue,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.note_add_outlined,
            label: '기출문제 추출(건별)',
            subLabel: '파일 선택 후 한 문항씩 정밀 추출',
            onTap: () {
              _navigateTo(const QuizExtractionStep2Screen(selectedFiles: []));
            },
            color: secondaryBlue,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.psychology_outlined,
            label: '기출문제 유사문제 추출(일괄)',
            subLabel: '회차별 5개 단위 순차 유사도 분석 (V1.0)',
            onTap: () {
              _navigateTo(const BulkSimilarManagementScreen());
            },
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.quiz_outlined,
            label: '기출문제 일람',
            subLabel: 'AI 파싱 결과 및 오답 보기 검토',
            onTap: () => _navigateTo(const QuizManagementScreen()),
            color: secondaryBlue,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTreeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShortcutListItem(
            icon: Icons.add_task_outlined,
            label: '신규 수목 등록',
            subLabel: '부위별 이미지 및 성상 기반 등록 모듈',
            onTap: () => _navigateTo(const TreeRegistrationScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.add_a_photo,
            label: '수목 이미지 추출(수목별)',
            subLabel: '학습 데이터용 이미지 벌크 추가 및 구글 검색',
            onTap: () => _navigateTo(const TreeSourcingScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.schema,
            label: '비교 수목 일람',
            subLabel: '유사 수목 그룹 관리',
            onTap: () => _navigateTo(const TreeGroupManagementScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 6),
          _buildShortcutListItem(
            icon: Icons.nature_people,
            label: '수목도감 일람',
            subLabel: '데이터 베이스 편집 및 검색',
            onTap: () => _navigateTo(const TreeListScreen()),
            color: primaryColor,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: _handleSignOut,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.logout, color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관리 대시보드',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tree Master System',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _navigateTo(const NotificationScreen()),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white70,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceDark, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextStatsSection(DashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildTextStatItem('수목', vm.stats['totalTrees'] ?? 0, '종'),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildTextStatItem('기출', vm.stats['totalQuizzes'] ?? 0, '문'),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildTextStatItem(
              '유사',
              vm.stats['totalSimilarGroups'] ?? 0,
              '조합',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextStatItem(String label, int count, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 2),
        Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 12,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildShortcutListItem({
    required IconData icon,
    required String label,
    required String subLabel,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subLabel,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[700], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.95),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard, '홈', true, () {}),
          _buildNavItem(
            Icons.analytics_outlined,
            '통계',
            false,
            () => _navigateTo(const StatisticsScreen()),
          ),
          _buildNavItem(
            Icons.people_outlined,
            '사용자',
            false,
            () => _navigateTo(const UserCheckScreen()),
          ),
          _buildNavItem(
            Icons.settings_outlined,
            '설정',
            false,
            () => _navigateTo(const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey[600],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
