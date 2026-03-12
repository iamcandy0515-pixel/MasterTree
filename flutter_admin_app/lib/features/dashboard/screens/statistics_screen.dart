import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../widgets/user_stats_list_item.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel()..loadStats(),
      child: const _StatisticsContent(),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent();

  static const Color primaryColor = Color(0xFF2BEE8C);
  static const Color backgroundDark = Color(0xFF102219);


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticsViewModel>();

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          '사용자별 통계 목록',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: vm.loadStats,
          ),
        ],
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(StatisticsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            vm.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (vm.users.isEmpty) {
      return const Center(
        child: Text(
          '등록된 사용자가 없습니다.',
          style: TextStyle(color: Colors.white24),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vm.users.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        return UserStatsListItem(user: vm.users[index]);
      },
    );
  }
}
