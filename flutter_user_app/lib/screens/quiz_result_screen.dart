import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import '../controllers/quiz_result_controller.dart';

class QuizResultScreen extends StatefulWidget {
  final int correctCount;
  final int accumulatedHintCount;
  final int solvedCount;

  const QuizResultScreen({
    super.key,
    required this.correctCount,
    required this.accumulatedHintCount,
    required this.solvedCount,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final QuizResultController _controller = QuizResultController();

  @override
  void initState() {
    super.initState();
    _controller.initFromStats(
      correctCount: widget.correctCount,
      accumulatedHintCount: widget.accumulatedHintCount,
      solvedCount: widget.solvedCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double avgHints = widget.solvedCount > 0
        ? (widget.accumulatedHintCount / widget.solvedCount)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const Spacer(),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        _controller.titleIcon,
                        size: 80,
                        color: _controller.titleColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _controller.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _controller.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const QuizScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              '다시 도전',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _controller.titleColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              '총 풀어본 문제',
                              '${widget.solvedCount} 문제',
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildStatRow(
                              '정답 개수',
                              '${widget.correctCount} 개',
                              valueColor: AppColors.primary,
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildStatRow(
                              '평균 사용 힌트',
                              '${avgHints.toStringAsFixed(1)} 개',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '(총 힌트 사용횟수: ${widget.accumulatedHintCount})',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
