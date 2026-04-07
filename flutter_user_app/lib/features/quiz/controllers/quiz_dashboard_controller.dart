import 'package:flutter/foundation.dart';
import '../../../core/api_service.dart';

class QuizDashboardController {
  bool isLoading = true;
  String? errorMessage;

  int overallAccuracy = 0;
  int totalAttempts = 0;
  List<double> trends = [];

  Future<void> init(VoidCallback onUpdate) async {
    isLoading = true;
    errorMessage = null;
    onUpdate();

    try {
      final data = await ApiService.getUserPerformanceStats();
      final Map<String, dynamic> pastExam = data['pastExam'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      final dynamic solvedVal = pastExam['solvedCount'];
      final int solved = (solvedVal is num) ? solvedVal.toInt() : 0;
      
      final dynamic correctVal = pastExam['correctCount'];
      final int correct = (correctVal is num) ? correctVal.toInt() : 0;
      
      totalAttempts = solved;
      
      if (solved > 0) {
        double acc = (correct / solved) * 100;
        overallAccuracy = acc.isFinite ? acc.round() : 0;
      } else {
        overallAccuracy = 0;
      }
      
      // Parse real trends from API if available
      final List<dynamic> recentTrends = (data['recentTrends'] as List<dynamic>?) ?? <dynamic>[];
      trends = recentTrends.map((dynamic tRaw) {
        final Map<String, dynamic> t = Map<String, dynamic>.from(tRaw as Map);
        final dynamic score = t['total_score'];
        if (score is num) return score.toDouble();
        return 0.0;
      }).toList();

      // Ensure at least 7 points for a stable chart (padding with 0s)
      while (trends.length < 7) {
        trends.insert(0, 0.0);
      }
      if (trends.length > 7) {
        trends = trends.sublist(trends.length - 7);
      }

      isLoading = false;
      onUpdate();
    } catch (e) {
      debugPrint('QuizDashboardController Error: $e');
      isLoading = false;
      errorMessage = e.toString();
      onUpdate();
    }
  }
}
