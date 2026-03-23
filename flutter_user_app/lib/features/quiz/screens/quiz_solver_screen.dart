import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import '../controllers/quiz_solver_controller.dart';
import '../widgets/quiz_content_renderer.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_explanation_card.dart';

class QuizSolverScreen extends StatefulWidget {
  final String mode;

  const QuizSolverScreen({super.key, required this.mode});

  @override
  State<QuizSolverScreen> createState() => _QuizSolverScreenState();
}

class _QuizSolverScreenState extends State<QuizSolverScreen> {
  late QuizSolverController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizSolverController(mode: widget.mode);
    _controller.init(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // 화면 이탈 시 보류된 결과 동기화 시도
    ApiService.syncPendingAttempts();
    super.dispose();
  }

  void _submitAnswer() {
    setState(() {
      _controller.submitAnswer();
    });
  }

  void _nextQuestion() {
    if (_controller.nextQuestion()) {
      setState(() {});
    } else {
      // 모든 문제를 풀었을 때 처리
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수고하셨습니다! 모든 문제를 풀었습니다.')),
      );
    }
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
      return _buildErrorView();
    }

    if (_controller.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Text(
            '현재 가능한 문제가 없습니다.',
            style: TextStyle(color: AppColors.textLight),
          ),
        ),
      );
    }

    final currentQ = _controller.currentQuestion;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          '${widget.mode == 'random' ? '랜덤 기출' : '약점 극복'} (${_controller.currentQuestionIndex + 1}/${_controller.questions.length})',
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _controller.progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${_controller.currentQuestionIndex + 1}.',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QuizContentRenderer(content: currentQ['content']),
                    const SizedBox(height: 32),
                    ...List.generate((currentQ['options'] as List).length, (index) {
                      return QuizOptionCard(
                        index: index,
                        text: currentQ['options'][index],
                        isSelected: _controller.selectedOptionIndex == index,
                        isAnswerSubmitted: _controller.isAnswerSubmitted,
                        correctIndex: currentQ['correct_index'],
                        onTap: () => setState(() => _controller.selectOption(index)),
                      );
                    }),
                    if (_controller.isAnswerSubmitted) ...[
                      const SizedBox(height: 32),
                      QuizExplanationCard(
                        isCorrect: _controller.selectedOptionIndex == currentQ['correct_index'],
                        explanation: currentQ['explanation'],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              '문제를 불러오지 못했습니다.\n${_controller.errorMessage}',
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _controller.selectedOptionIndex != null ? AppColors.primary : Colors.grey[800],
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _controller.selectedOptionIndex == null
            ? null
            : (_controller.isAnswerSubmitted ? _nextQuestion : _submitAnswer),
        child: Text(
          _controller.isAnswerSubmitted ? '다음 문제' : '정답 제출',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
