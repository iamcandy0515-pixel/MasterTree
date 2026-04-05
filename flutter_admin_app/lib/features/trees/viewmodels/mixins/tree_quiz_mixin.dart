import 'package:flutter/material.dart';

mixin TreeQuizMixin on ChangeNotifier {
  final List<TextEditingController> distractorControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isAutoQuizEnabled = true;

  bool get isAutoQuizEnabled => _isAutoQuizEnabled;

  void initializeQuiz(List<String> distractors, bool isAutoQuiz) {
    for (final TextEditingController controller in distractorControllers) {
      controller.dispose();
    }
    distractorControllers.clear();
    
    if (distractors.isNotEmpty) {
      for (final String distractor in distractors) {
        distractorControllers.add(TextEditingController(text: distractor));
      }
    } else {
      // Default 3 empty distractors
      for (int i = 0; i < 3; i++) {
        distractorControllers.add(TextEditingController());
      }
    }
    _isAutoQuizEnabled = isAutoQuiz;
    notifyListeners();
  }

  void addDistractor() {
    distractorControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeDistractor(int index) {
    if (index >= 0 && index < distractorControllers.length && distractorControllers.length > 1) {
      distractorControllers[index].dispose();
      distractorControllers.removeAt(index);
      notifyListeners();
    }
  }

  void setAutoQuizEnabled(bool value) {
    _isAutoQuizEnabled = value;
    notifyListeners();
  }

  void clearQuiz() {
    for (final TextEditingController controller in distractorControllers) {
      controller.clear();
    }
    _isAutoQuizEnabled = true;
    notifyListeners();
  }

  void disposeQuiz() {
    for (final TextEditingController controller in distractorControllers) {
      controller.dispose();
    }
  }
}
