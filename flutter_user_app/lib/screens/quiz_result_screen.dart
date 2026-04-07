import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/screens/quiz_screen.dart';
import '../controllers/quiz_result_controller.dart';
import 'parts/result_title_section.dart';
import 'parts/result_stat_card.dart';

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
                      _buildHeader(context),
                      const Spacer(),
                      ResultTitleSection(
                        icon: _controller.titleIcon,
                        titleColor: _controller.titleColor,
                        title: _controller.title,
                        description: _controller.description,
                      ),
                      const SizedBox(height: 40),
                      _buildRechallengeButton(context),
                      const SizedBox(height: 8),
                      ResultStatCard(
                        solvedCount: widget.solvedCount,
                        correctCount: widget.correctCount,
                        avgHints: _controller.avgHints,
                        totalHints: widget.accumulatedHintCount,
                        borderColor: _controller.titleColor,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }

  Widget _buildRechallengeButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacement<void, void>(
              MaterialPageRoute<void>(builder: (BuildContext _) => const QuizScreen()),
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
