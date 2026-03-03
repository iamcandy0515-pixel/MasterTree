import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_detail_viewmodel.dart';

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
  static const Color surfaceDark = Color(0xFF1A2E24);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserDetailViewModel>();

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: Text(
          '$userName 통계',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: backgroundDark,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : vm.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '에러: ${vm.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          : vm.stats == null
          ? const Center(
              child: Text(
                '데이터가 없습니다.',
                style: TextStyle(color: Colors.white24),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(vm.stats!['user']),
                  const SizedBox(height: 24),
                  _buildPerformanceCard(
                    '수목 퀴즈 학습 현황',
                    vm.stats!['quiz'],
                    Colors.blueAccent,
                    Icons.school,
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceCard(
                    '기출 문제 학습 현황',
                    vm.stats!['pastExam'],
                    Colors.orangeAccent,
                    Icons.history_edu,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic>? user) {
    if (user == null) return const SizedBox();
    final lastSignIn = user['lastSignIn'] != null
        ? DateFormat(
            'yyyy.MM.dd HH:mm',
          ).format(DateTime.parse(user['lastSignIn']).toLocal())
        : '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            backgroundColor: primaryColor,
            radius: 28,
            child: Icon(Icons.person, color: backgroundDark, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            user['name'] ?? userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['email'] ?? '',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, color: Colors.white24, size: 14),
              const SizedBox(width: 8),
              Text(
                '최종 로그인: $lastSignIn',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(
    String title,
    Map<String, dynamic> data,
    Color accentColor,
    IconData icon,
  ) {
    final int total = data['totalCount'] ?? 0;
    final int solved = data['solvedCount'] ?? 0;
    final int correct = data['correctCount'] ?? 0;
    final int wrong = data['wrongCount'] ?? 0;
    final double progress = total > 0 ? solved / total : 0.0;
    final double accuracy = solved > 0 ? (correct / solved) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
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
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '진행도 ($solved / $total)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem('정답 개수', '$correct', Colors.greenAccent),
              const SizedBox(width: 12),
              _buildStatItem('오답 개수', '$wrong', Colors.redAccent),
              const SizedBox(width: 12),
              _buildStatItem(
                '정답률',
                '${accuracy.toStringAsFixed(1)}%',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
