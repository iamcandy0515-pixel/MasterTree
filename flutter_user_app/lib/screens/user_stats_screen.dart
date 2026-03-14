import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/design_system.dart';

class UserStatsScreen extends StatefulWidget {
  final int initialIndex;
  const UserStatsScreen({super.key, this.initialIndex = 0});

  @override
  State<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 통계 화면 진입 시 보류 중인 데이터가 있다면 동기화 후 조회
      await ApiService.syncPendingAttempts();
      final data = await ApiService.getUserPerformanceStats();
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
                  _buildOverallTab(),
                  _buildQuizTab(),
                  _buildPastExamTab(),
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
          Text(
            '오류가 발생했습니다.\n로그인 상태를 확인해주세요.',
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

  Widget _buildOverallTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatCard(
            '수목 퀴즈 학습 요약',
            _stats!['quiz'],
            AppColors.primary,
            Icons.school,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            '기출 문제 학습 요약',
            _stats!['pastExam'],
            Colors.orangeAccent,
            Icons.history_edu,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailedStatSection(
            '수목 식별 퀴즈 성과',
            _stats!['quiz'],
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPastExamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailedStatSection(
            '기출 문제 학습 성과',
            _stats!['pastExam'],
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatSection(
    String title,
    Map<String, dynamic> data,
    Color accentColor,
  ) {
    return Column(
      children: [
        _buildStatCard(title, data, accentColor, Icons.analytics),
        const SizedBox(height: 20),
        // 향후 여기에 과목별/유형별 더 상세한 통계 리스트 추가 가능
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final user = _stats!['user'];
    final name = user?['name'] ?? '사용자';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $name님!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '오늘도 한 걸음 더 성장하셨네요. 💪',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                  '진행률 ($solved / $total)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
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
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('정답', '$correct', Colors.greenAccent),
              _buildSimpleStat('오답', '$wrong', Colors.redAccent),
              _buildSimpleStat(
                '정답률',
                '${accuracy.toStringAsFixed(0)}%',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
