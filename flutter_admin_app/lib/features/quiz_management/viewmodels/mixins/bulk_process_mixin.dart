import 'package:flutter/foundation.dart';
import '../services/quiz_extraction_service.dart';

mixin BulkProcessMixin on ChangeNotifier {
  final QuizExtractionService extractionService = QuizExtractionService();
  bool isLoadingStatus = false;
  bool isCancelledFlag = false;
  String statusMessageText = '';

  void cancelExtractionFlag() {
    isCancelledFlag = true;
    statusMessageText = '추출 중단 요청됨...';
    notifyListeners();
  }

  void resetExtractionStatus() {
    isLoadingStatus = false;
    isCancelledFlag = false;
    statusMessageText = '';
  }

  void updateStatusMessage(String message) {
    statusMessageText = message;
    notifyListeners();
  }

  void showExtractionResultMsg(
    int extractedCount,
    int totalToExtract,
    Function(String) onMessage,
  ) {
    if (extractedCount == totalToExtract) {
      statusMessageText = '추출 완료';
      onMessage('🎊 모든 문항($extractedCount건) 추출이 완료되었습니다!');
    } else {
      statusMessageText = '추출 완료 (일부 누락)';
      onMessage('⚠️ 추출 완료 (성공: $extractedCount, 목표: $totalToExtract).');
    }
    notifyListeners();
  }
}
