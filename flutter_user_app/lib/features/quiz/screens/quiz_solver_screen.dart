import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';
import '../controllers/quiz_solver_controller.dart';

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
    // ?붾㈃ ?댄깉 ???⑥? 寃곌낵 ?숆린???쒕룄
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
      // Done
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('?섍퀬?섏뀲?듬땲?? 紐⑤뱺 臾몄젣瑜???덉뒿?덈떎!')));
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
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                '臾몄젣瑜?遺덈윭?ㅼ? 紐삵뻽?듬땲??\n${_controller.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _controller.init(() => setState(() {})),
                child: const Text('?ㅼ떆 ?쒕룄'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Text(
            '???媛?ν븳 臾몄젣媛 ?놁뒿?덈떎.',
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
          '${widget.mode == 'random' ? '?쒕뜡 湲곗텧' : '?쎌젏 洹밸났'} (${_controller.currentQuestionIndex + 1}/${_controller.questions.length})',
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _controller.progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Number
                    Text(
                      'Question ${_controller.currentQuestionIndex + 1}.',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question Renderer (Math Support)
                    _buildContentRenderer(currentQ['content']),
                    const SizedBox(height: 32),

                    // Options List
                    ...List.generate((currentQ['options'] as List).length, (
                      index,
                    ) {
                      return _buildOptionCard(
                        index,
                        currentQ['options'][index],
                        currentQ['correct_index'],
                      );
                    }),

                    // Explanation Reveal
                    if (_controller.isAnswerSubmitted) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _controller.selectedOptionIndex ==
                                  currentQ['correct_index']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _controller.selectedOptionIndex ==
                                    currentQ['correct_index']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _controller.selectedOptionIndex ==
                                      currentQ['correct_index']
                                  ? '?럦 ?뺣떟?낅땲??'
                                  : '?쨺 ?ㅻ떟?낅땲??',
                              style: TextStyle(
                                color:
                                    _controller.selectedOptionIndex ==
                                        currentQ['correct_index']
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '?댁꽕',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentQ['explanation'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Zone
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _controller.selectedOptionIndex != null
                      ? AppColors.primary
                      : Colors.grey[800],
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _controller.selectedOptionIndex == null
                    ? null
                    : (_controller.isAnswerSubmitted
                          ? _nextQuestion
                          : _submitAnswer),
                child: Text(
                  _controller.isAnswerSubmitted ? '?ㅼ쓬 臾몄젣' : '?뺣떟 ?쒖텧',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentRenderer(String content) {
    if (content.contains('\$\$') || content.contains('\$')) {
      List<Widget> spans = [];
      final parts = content.split('\$\$');
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1) {
          spans.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Math.tex(
                  parts[i],
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.yellowAccent,
                  ),
                ),
              ),
            ),
          );
        } else {
          final inlineParts = parts[i].split('\$');
          List<InlineSpan> inlineSpans = [];
          for (int j = 0; j < inlineParts.length; j++) {
            if (j % 2 == 1) {
              inlineSpans.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Math.tex(
                    inlineParts[j],
                    textStyle: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            } else {
              inlineSpans.add(TextSpan(text: inlineParts[j]));
            }
          }
          spans.add(
            Text.rich(
              TextSpan(
                children: inlineSpans,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spans,
      );
    } else {
      return Text(
        content,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          height: 1.6,
        ),
      );
    }
  }

  Widget _buildOptionCard(int index, String text, int correctIndex) {
    bool isSelected = _controller.selectedOptionIndex == index;
    bool showCorrect = _controller.isAnswerSubmitted && index == correctIndex;
    bool showWrong =
        _controller.isAnswerSubmitted && isSelected && index != correctIndex;

    Color borderColor = Colors.white12;
    Color bgColor = AppColors.surfaceDark;

    if (_controller.isAnswerSubmitted) {
      if (showCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
      } else if (showWrong) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: _controller.isAnswerSubmitted
          ? null
          : () {
              setState(() {
                _controller.selectOption(index);
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || showCorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white24,
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isSelected ? AppColors.backgroundDark : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (showWrong) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

