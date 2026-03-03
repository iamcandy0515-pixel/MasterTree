import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/tree_list_screen.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/similar_species_list_screen.dart';
import 'package:flutter_user_app/screens/login_screen.dart';
import 'package:flutter_user_app/screens/past_exam_list_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

import '../controllers/hub_controller.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  final HubController _controller = HubController();

  @override
  void initState() {
    super.initState();
    _controller.initializeAuth(onUpdate: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide.none,
              vertical: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            icon: Icons.menu_book,
                            title: '수목 도감',
                            subtitle: '전체 수목 리스트 및 상세 정보',
                            context: context,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TreeListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMenuCard(
                            icon: Icons.school,
                            title: '수목 / 퀴즈',
                            subtitle: '단계별 퀴즈를 통한 지식 습득',
                            context: context,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMenuCard(
                            icon: Icons.history_edu,
                            title: '기출 / 학습',
                            subtitle: '년도별/회차별 기출문제 풀이',
                            context: context,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PastExamListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMenuCard(
                            icon: Icons.compare_arrows,
                            title: '유사(혼돈)수목',
                            subtitle: '헷갈리기 쉬운 유사 수목 정밀 분석',
                            context: context,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SimilarSpeciesListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildGuideSection(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.forest, color: AppColors.primary, size: 32),
          ),
          const Text(
            '사용자 대시보드',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.textLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.base),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDesign.glassBlur,
            sigmaY: AppDesign.glassBlur,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(AppRadius.base),
              // Border removed as requested
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection() {
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
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDesign.glassBlur,
          sigmaY: AppDesign.glassBlur,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _BottomNavItem(
                icon: Icons.grid_view,
                label: '허브',
                isActive: true,
              ),
              const _BottomNavItem(icon: Icons.search, label: '검색'),
              _BottomNavItem(
                icon: Icons.analytics,
                label: '통계',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserStatsScreen()),
                ),
              ),
              const _BottomNavItem(icon: Icons.settings, label: '설정'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.white24,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white24,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
