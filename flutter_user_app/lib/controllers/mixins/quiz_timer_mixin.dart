import 'dart:async';

mixin QuizTimerMixin {
  Timer? hintTimer;
  Timer? descriptionTimer;

  void startHintTimer(Duration duration, Function() onComplete) {
    hintTimer?.cancel();
    hintTimer = Timer(duration, onComplete);
  }

  void startDescriptionTimer(Duration duration, Function() onComplete) {
    descriptionTimer?.cancel();
    descriptionTimer = Timer(duration, onComplete);
  }

  void cancelTimers() {
    hintTimer?.cancel();
    descriptionTimer?.cancel();
  }
}
