import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/tree_list_screen.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import 'package:flutter_user_app/screens/similar_species_list_screen.dart';
import 'package:flutter_user_app/screens/login_screen.dart';
import 'package:flutter_user_app/screens/past_exam_list_screen.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

import 'package:flutter_user_app/core/supabase_service.dart';
import '../controllers/hub_controller.dart';
import 'hub/widgets/hub_header.dart';
import 'hub/widgets/hub_menu_card.dart';
import 'hub/widgets/hub_guide_section.dart';
import 'hub/widgets/hub_bottom_nav.dart';

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
    _controller.initializeAuth(onUpdate: () {
      if (mounted) {
        setState(() {});
        // After initialization, if not logged in, redirect to login
        if (!_controller.isLoading && !SupabaseService.isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  void _onLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _onStatsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserStatsScreen()),
    );
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
                  HubHeader(onLogout: _onLogout),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          HubMenuCard(
                            icon: Icons.menu_book,
                            title: '수목 도감',
                            subtitle: '전체 수목 리스트 및 상세 정보',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TreeListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          HubMenuCard(
                            icon: Icons.school,
                            title: '수목 / 퀴즈',
                            subtitle: '단계별 퀴즈를 통한 지식 습득',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          HubMenuCard(
                            icon: Icons.history_edu,
                            title: '기출 / 학습',
                            subtitle: '연도별 회차별 기출문제 대비',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PastExamListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          HubMenuCard(
                            icon: Icons.compare_arrows,
                            title: '유사(혼동)수목',
                            subtitle: '헷갈리기 쉬운 유사 수목 정밀 분석',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SimilarSpeciesListScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const HubGuideSection(),
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
                child: HubBottomNav(onStatsTap: _onStatsTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

