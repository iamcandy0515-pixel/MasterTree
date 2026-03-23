import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/models/quiz_model.dart';
import 'package:flutter_user_app/repositories/quiz_repository.dart';
import 'mixins/quiz_timer_mixin.dart';
import 'mixins/quiz_state_mixin.dart';

class QuizController with QuizTimerMixin, QuizStateMixin {
  final QuizRepository _repository = QuizRepository();

  // Getters
  int get solvedCount => selectedAnswer != null ? currentIndex + 1 : currentIndex;
  QuizQuestion get currentQuestion => questions.isNotEmpty ? questions[currentIndex] : _getDummyQuestion();

  String get currentHintText {
    final text = currentQuestion.hints[selectedHint];
    if (text == null || text.trim().isEmpty || text == '정보 없음') {
      return '해당 힌트 정보가 없습니다.';
    }
    return text;
  }

  Future<void> initialize(VoidCallback onUpdate) async {
    isLoading = true;
    onUpdate();
    
    questions = await _repository.fetchQuizzes();
    
    isLoading = false;
    onUpdate();
  }

  // Pre-fetching for superior mobile UX (Better Proposal)
  void precacheQuizImages(BuildContext context) {
    if (context.mounted) {
      for (var q in questions) {
        if (q.imageUrl.isNotEmpty) {
          precacheImage(NetworkImage(q.imageUrl), context);
        }
      }
    }
  }

  void selectHint(String hint, VoidCallback onUpdate) {
    if (!viewedHints.contains(hint)) {
      accumulatedHintCount++;
    }
    selectedHint = hint;
    showHintMessage = true;
    viewedHints.add(hint);
    onUpdate();

    startHintTimer(const Duration(seconds: 3), () {
      showHintMessage = false;
      onUpdate();
    });
  }

  void hideHintMessage(VoidCallback onUpdate) {
    showHintMessage = false;
    hintTimer?.cancel();
    onUpdate();
  }

  void hideDescription(VoidCallback onUpdate) {
    showDescription = false;
    descriptionTimer?.cancel();
    onUpdate();
  }

  void selectAnswer(int answerIndex, VoidCallback onUpdate) {
    if (selectedAnswer != null) return;
    selectedAnswer = answerIndex;
    isCorrect = (answerIndex == currentQuestion.correctAnswerIndex);

    if (isCorrect) {
      correctCount++;
      showDescription = true;
      startDescriptionTimer(const Duration(seconds: 5), () {
        showDescription = false;
        onUpdate();
      });
    }

    _repository.saveAttempt(
      treeId: currentQuestion.id,
      isCorrect: isCorrect,
      userAnswer: answerIndex,
    );

    onUpdate();
  }

  void nextQuestion(VoidCallback onUpdate) {
    if (hasNext) {
      currentIndex++;
      resetState();
      onUpdate();
    }
  }

  void retry(VoidCallback onUpdate) {
    resetState();
    onUpdate();
  }

  void dispose() {
    cancelTimers();
  }

  QuizQuestion _getDummyQuestion() {
    return QuizQuestion(
      id: 0,
      imageUrl: '',
      description: '',
      correctAnswerIndex: 0,
      options: [''],
      hints: {},
    );
  }
}
