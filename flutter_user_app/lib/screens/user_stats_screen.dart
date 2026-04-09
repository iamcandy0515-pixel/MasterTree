import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/design_system.dart';
import 'user_stats/tabs/overall_stats_tab.dart';
import 'user_stats/tabs/quiz_stats_tab.dart';
import 'user_stats/tabs/past_exam_stats_tab.dart';

class UserStatsScreen extends StatefulWidget {
  final int initialIndex;
  const UserStatsScreen({super.key, this.initialIndex = 0});

  @override
  State<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _categoryStats = [];
  List<Map<String, dynamic>> _examStats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.syncPendingAttempts();
      
      final results = await Future.wait([
        ApiService.getUserPerformanceStats(),
        ApiService.getTreeCategoryStats(),
        ApiService.getExamSessionStats(),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _categoryStats = results[1] as List<Map<String, dynamic>>;
        _examStats = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "$e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text(
            '나의 학습 통계',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: '종합'),
              Tab(text: '수목퀴즈'),
              Tab(text: '기출문제'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textMuted),
              onPressed: _loadStats,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
            ? _buildErrorView()
            : _stats == null
            ? const Center(child: Text('데이터를 불러올 수 없습니다.'))
            : TabBarView(
                children: [
                  OverallStatsTab(stats: _stats!),
                  QuizStatsTab(stats: _stats!, categories: _categoryStats),
                  PastExamStatsTab(stats: _stats!, exams: _examStats),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            '오류가 발생했습니다.\n로그인 상태를 확인해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadStats,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('다시 시도', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
