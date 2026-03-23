import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'quiz_solver_screen.dart';
import '../controllers/quiz_dashboard_controller.dart';

class QuizDashboardScreen extends StatefulWidget {
  const QuizDashboardScreen({super.key});

  @override
  State<QuizDashboardScreen> createState() => _QuizDashboardScreenState();
}

class _QuizDashboardScreenState extends State<QuizDashboardScreen> {
  final QuizDashboardController _controller = QuizDashboardController();

  @override
  void initState() {
    super.initState();
    _controller.init(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_controller.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                '통계를 불러오지 못했습니다.\n${_controller.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _controller.init(() => setState(() {})),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          '기출문제 퀴즈 (통계)',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccuracyCard(),
            const SizedBox(height: 24),
            _buildTrendsChart(),
            const SizedBox(height: 24),
            const Text(
              '모드 선택',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              '랜덤 기출문제 풀기',
              '무작위로 10문제를 뽑아 스피디하게 풉니다.',
              Icons.shuffle,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuizSolverScreen(mode: 'random'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildModeButton(
              context,
              '취약점 집중 공략',
              '내가 가장 많이 틀렸던 유형 위주로 학습합니다.',
              Icons.healing,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuizSolverScreen(mode: 'weakness'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildModeButton(
              context,
              '나의 오답 노트',
              '이전에 틀렸던 문제를 다시 확인하고 복습합니다.',
              Icons.menu_book,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('오답 노트 화면으로 이동합니다..')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                '전체 정답률',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.overallAccuracy}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(height: 50, width: 1, color: Colors.white24),
          Column(
            children: [
              const Text(
                '풀이 문제 수',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.totalAttempts}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 7일 성적 추이',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(_controller.trends.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        _controller.trends[index],
                      );
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

