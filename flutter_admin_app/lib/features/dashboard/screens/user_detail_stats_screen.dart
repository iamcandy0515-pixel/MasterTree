import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_detail_viewmodel.dart';
import '../widgets/user_detail_tabs.dart';

class UserDetailStatsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserDetailStatsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDetailViewModel(userId)..loadStats(),
      child: _UserDetailStatsContent(userName: userName),
    );
  }
}

class _UserDetailStatsContent extends StatelessWidget {
  final String userName;
  const _UserDetailStatsContent({required this.userName});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserDetailViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          backgroundColor: backgroundDark,
          elevation: 0,
          title: const Text(
            '상세 학습 통계',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white38,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: '종합'),
              Tab(text: '수목퀴즈'),
              Tab(text: '기출문제'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: vm.loadStats,
            ),
          ],
        ),
        body: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : vm.error != null
            ? _buildErrorView(vm.error!)
            : vm.stats == null
            ? const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(color: Colors.white24),
                ),
              )
            : TabBarView(
                children: [
                  GeneralStatsTab(stats: vm.stats!),
                  _buildSubTab(
                    '수목 식별 퀴즈 성과',
                    vm.stats!['quiz'],
                    primaryColor,
                    Icons.school,
                  ),
                  _buildSubTab(
                    '기출 문제 학습 성과',
                    vm.stats!['pastExam'],
                    Colors.orangeAccent,
                    Icons.history_edu,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubTab(String title, dynamic data, Color color, IconData icon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StatCard(
            title: title,
            data: (data as Map<String, dynamic>?) ?? <String, dynamic>{},
            accentColor: color,
            icon: icon,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '에러: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
