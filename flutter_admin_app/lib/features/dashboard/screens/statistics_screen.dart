import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/statistics_viewmodel.dart';
import 'user_detail_stats_screen.dart';

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
  static const Color surfaceDark = Color(0xFF1A2E24);
  static const Color textLight = Colors.white70;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticsViewModel>();

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          '관리 상세 통계',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: vm.loadStats,
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : vm.error != null
          ? Center(
              child: Text(
                vm.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. Global Summary
                  _buildGlobalSummaryCards(vm.globalStats),
                  const SizedBox(height: 32),

                  // 1. Exam Stats
                  _buildSectionHeader('기출문제 등록 현황 (년도/회차별)'),
                  const SizedBox(height: 12),
                  _buildExamStatsCard(vm.examStats),

                  const SizedBox(height: 32),

                  // 2. Active Users
                  _buildSectionHeader('현재 활동 중인 유저 (최근 7일)'),
                  const SizedBox(height: 12),
                  _buildActiveUsersCard(vm.activeUserList),

                  const SizedBox(height: 32),

                  // 3. Quiz Insights
                  _buildSectionHeader('학습 성취도 (퀴즈 오답률 Top 5)'),
                  const SizedBox(height: 12),
                  _buildTopWrongTreesCard(vm.topWrongTrees),

                  const SizedBox(height: 32),

                  // 4. Update Summary
                  _buildSectionHeader('최근 업데이트 요약 (최근 7일)'),
                  const SizedBox(height: 12),
                  _buildUpdateSummaryCard(vm.updateSummary),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildGlobalSummaryCards(Map<String, dynamic> global) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('시스템 전체 학습 데이터 현황'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryBox(
              '수목종',
              global['totalTrees'] ?? 0,
              Colors.greenAccent,
            ),
            const SizedBox(width: 12),
            _buildSummaryBox(
              '유사수목',
              global['totalSimilar'] ?? 0,
              Colors.orangeAccent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryBox(
              '기출문제',
              global['totalQuizzes'] ?? 0,
              Colors.blueAccent,
            ),
            const SizedBox(width: 12),
            _buildSummaryBox(
              '활동유저',
              global['activeUserCount'] ?? 0,
              Colors.purpleAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryBox(String label, int count, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamStatsCard(List<dynamic> exams) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: exams.isEmpty
          ? const _EmptyState(message: '등록된 기출문제가 없습니다.')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exams.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final exam = exams[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    '${exam['year']}년 ${exam['round']}회차 - ${exam['title']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${exam['question_count']}개',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildActiveUsersCard(List<dynamic> users) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: users.isEmpty
          ? const _EmptyState(message: '최근 활동 중인 유저가 없습니다.')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                final lastLogin = DateTime.tryParse(
                  user['last_login'] ?? '',
                )?.toLocal();
                final timeStr = lastLogin != null
                    ? DateFormat('yyyy.MM.dd HH:mm').format(lastLogin)
                    : '-';

                return ListTile(
                  dense: true,
                  onTap: () {
                    if (user['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailStatsScreen(
                            userId: user['id'],
                            userName: user['name'] ?? '알 수 없음',
                          ),
                        ),
                      );
                    }
                  },
                  leading: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  title: Text(
                    user['name'] ?? '알 수 없음',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user['email'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white12,
                        size: 16,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTopWrongTreesCard(List<dynamic> topWrong) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: topWrong.isEmpty
          ? const _EmptyState(message: '오답 데이터가 충분하지 않습니다.')
          : Column(
              children: topWrong.map((item) {
                final details = item['details'];
                return ExpansionTile(
                  dense: true,
                  iconColor: primaryColor,
                  collapsedIconColor: Colors.white54,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? '알 수 없음',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${item['count']}회 오답',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (details != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white10),
                            _buildInfoRow(
                              '학명',
                              details['scientific_name'] ?? '-',
                            ),
                            _buildInfoRow('과명', details['family_name'] ?? '-'),
                            const SizedBox(height: 4),
                            Text(
                              details['description'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '수목 상세 정보가 없습니다.',
                          style: TextStyle(color: Colors.white30, fontSize: 11),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSummaryCard(Map<String, int> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('수목', summary['trees'] ?? 0, Colors.greenAccent),
          _buildSummaryItem('기출', summary['quizzes'] ?? 0, Colors.blueAccent),
          _buildSummaryItem('유사', summary['similar'] ?? 0, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white24, fontSize: 13),
        ),
      ),
    );
  }
}
