import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

import 'package:flutter_user_app/screens/tree_list_screen.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/past_exam_list_screen.dart';
import 'package:flutter_user_app/screens/similar_species_list_screen.dart';
import 'package:flutter_user_app/screens/login_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

import 'package:flutter_user_app/controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.init(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            _buildHeader(context),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Statistics Info Section (Centered & Larger)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTextStatsSection(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Quick Menu Section (Slim Cards)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildQuickMenu(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      floating: true,
      pinned: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      title: const Text(
        'MasterTree User',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
          icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학습 모듈',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context,
          '수목 도감',
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
          '유사(혼돈)수목',
          '헷갈리는 수목들을 비교 학습하세요',
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
    );
  }

  Widget _buildGuideSection() {
    return Container(
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

  Widget _buildTextStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextStatItem('수목', _controller.treeCount, '종'),
            _buildStatDivider(),
            _buildTextStatItem('기출', _controller.quizCount, '문'),
            _buildStatDivider(),
            _buildTextStatItem('유사', _controller.similarCount, '조합'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStatItem(String label, int count, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 12,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: _controller.currentIndex,
        onTap: (index) {
          setState(() {
            _controller.currentIndex = index;
          });

          // Navigation logic
          if (index == 1) {
            // 수목도감
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TreeListScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          } else if (index == 2) {
            // 수목/퀴즈
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          } else if (index == 3) {
            // 통계 (개인 통계 화면으로 이동)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserStatsScreen()),
            ).then((_) => setState(() => _controller.currentIndex = 0));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '수목도감'),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: '수목/퀴즈',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
        ],
      ),
    );
  }
}
