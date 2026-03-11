import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_list_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_group_management_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/user_check_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/log_check_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/notification_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_sourcing_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/statistics_screen.dart';
import 'package:flutter_admin_app/features/dashboard/screens/settings_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_management_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_extraction_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/quiz_extraction_step2_screen.dart';
import 'package:flutter_admin_app/features/quiz_management/screens/bulk_similar_management_screen.dart';

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

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Statistics Info Section (Unified with User App Style)
                          _buildTextStatsSection(vm),

                          const SizedBox(height: 12),

                          // 3. Shortcuts (Grid)
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '바로가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildSmallHeaderButton(
                                icon: Icons.person_search,
                                label: '사용자',
                                onTap: () =>
                                    _navigateTo(const UserCheckScreen()),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 1,
                                height: 12,
                                color: Colors.white10,
                              ),
                              const SizedBox(width: 4),
                              _buildSmallHeaderButton(
                                icon: Icons.terminal,
                                label: '로그',
                                onTap: () =>
                                    _navigateTo(const LogCheckScreen()),
                                color: primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Column(
                            children: [
                              _buildShortcutListItem(
                                icon: Icons.auto_awesome_motion,
                                label: '기출문제 일괄 추출 (PDF)',
                                subLabel: '범위 지정 및 AI 자동 분할 추출 (V2.6)',
                                onTap: () {
                                  _navigateTo(const BulkExtractionScreen());
                                },
                                color: primaryColor,
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.note_add_outlined,
                                label: '기출문제 추출 (건별)',
                                subLabel: '파일 선택 후 한 문항씩 정밀 추출',
                                onTap: () {
                                  _navigateTo(
                                    const QuizExtractionStep2Screen(selectedFiles: []),
                                  );
                                },
                                color: primaryColor,
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.psychology_outlined,
                                label: '기출 유사문제 추출',
                                subLabel: '회차별 5개 단위 순차 유사도 분석 (V1.0)',
                                onTap: () {
                                  _navigateTo(
                                    const BulkSimilarManagementScreen(),
                                  );
                                },
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.quiz_outlined,
                                label: '기출문제 현황',
                                subLabel: 'AI 파싱 결과 및 오답 보기 검토',
                                onTap: () =>
                                    _navigateTo(const QuizManagementScreen()),
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.nature_people,
                                label: '수목 관리',
                                subLabel: '데이터 베이스 편집 및 추가',
                                onTap: () =>
                                    _navigateTo(const TreeListScreen()),
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.add_a_photo,
                                label: '수목 이미지 소싱 관리',
                                subLabel: '학습 데이터용 이미지 벌크 추가 및 검토',
                                onTap: () =>
                                    _navigateTo(const TreeSourcingScreen()),
                              ),
                              const SizedBox(height: 6),
                              _buildShortcutListItem(
                                icon: Icons.schema,
                                label: '비교 수목 리스트',
                                subLabel: '유사 수목 그룹 관리',
                                onTap: () => _navigateTo(
                                  const TreeGroupManagementScreen(),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextStatItem('수목', vm.stats['totalTrees'] ?? 0, '종'),
          _buildStatDivider(),
          _buildTextStatItem('기출', vm.stats['totalQuizzes'] ?? 0, '문'),
          _buildStatDivider(),
          _buildTextStatItem('유사', vm.stats['totalSimilarGroups'] ?? 0, '조합'),
        ],
      ),
    );
  }

  Widget _buildTextStatItem(String label, int count, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
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

  Widget _buildSmallHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.grey,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Icons.storage_rounded,
            '수목DB',
            false,
            () => _navigateTo(const TreeListScreen()),
          ),
          _buildNavItem(
            Icons.analytics_outlined,
            '통계',
            false,
            () => _navigateTo(const StatisticsScreen()),
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
