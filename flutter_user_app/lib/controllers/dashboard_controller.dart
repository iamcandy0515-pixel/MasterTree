import 'package:flutter/foundation.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController {
  // Mock data - for future API integration
  double progress = 0.45;
  int masteredCount = 12;

  // 통계 데이터 (ValueNotifier를 사용한 부분 리빌드 지원)
  final ValueNotifier<Map<String, int>> statsNotifier = ValueNotifier({
    'treeCount': 0,
    'quizCount': 0,
    'similarCount': 0,
  });

  // 네비게이션 상태
  int currentIndex = 0;

  Future<void> init(Function onUpdate) async {
    // 1. 로컬 캐시 먼저 로드
    await _loadCachedStats();
    onUpdate();

    // 2. 서버에서 최신 정보 가져오기
    try {
      final stats = await ApiService.getUserStats();
      statsNotifier.value = {
        'treeCount': stats['totalTrees'] ?? 0,
        'quizCount': stats['totalQuizzes'] ?? 0,
        'similarCount': stats['totalSimilarGroups'] ?? 0,
      };

      await _saveStatsToCache();
      // onUpdate(); // statsNotifier가 있으므로 전체 화면 리빌드 불필요할 수 있지만 안전을 위해 유지 가능
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    }
  }

  Future<void> _loadCachedStats() async {
    final prefs = await SharedPreferences.getInstance();
    statsNotifier.value = {
      'treeCount': prefs.getInt('cache_total_trees') ?? 0,
      'quizCount': prefs.getInt('cache_total_quizzes') ?? 0,
      'similarCount': prefs.getInt('cache_total_similar') ?? 0,
    };
  }

  Future<void> _saveStatsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = statsNotifier.value;
    await prefs.setInt('cache_total_trees', data['treeCount'] ?? 0);
    await prefs.setInt('cache_total_quizzes', data['quizCount'] ?? 0);
    await prefs.setInt('cache_total_similar', data['similarCount'] ?? 0);
  }

  void dispose() {
    statsNotifier.dispose();
  }
}
