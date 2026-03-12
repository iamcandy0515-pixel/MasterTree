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

  static const Color primaryColor = Color(0xFF2BEE8C);
  static const Color backgroundDark = Color(0xFF102219);

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
          title: Text(
            '$userName 통계',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: '종합'),
              Tab(text: '수목퀴즈'),
              Tab(text: '기출문제'),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : vm.error != null
                ? _buildErrorView(vm.error!)
                : vm.stats == null
                    ? const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.white24)))
                    : TabBarView(
                        children: [
                          GeneralStatsTab(stats: vm.stats!),
                          ProgressStatsTab(
                            title: '수목 퀴즈 달성 현황',
                            data: vm.stats!['quiz'] ?? {},
                            accentColor: Colors.blueAccent,
                          ),
                          ProgressStatsTab(
                            title: '기출 문제 풀이 현황',
                            data: vm.stats!['pastExam'] ?? {},
                            accentColor: Colors.orangeAccent,
                          ),
                        ],
                      ),
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
