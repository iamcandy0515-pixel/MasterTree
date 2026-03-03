import 'package:flutter_user_app/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController {
  // Mock data - for future API integration
  double progress = 0.45;
  int masteredCount = 12;

  // 통계 데이터
  int treeCount = 0;
  int quizCount = 0;
  int similarCount = 0;

  // 네비게이션 상태
  int currentIndex = 0;

  final List<Map<String, String>> trees = [
    {'nameKr': '소나무', 'nameEn': 'Pinus densiflora', 'status': 'completed'},
    {'nameKr': '참나무', 'nameEn': 'Quercus robur', 'status': 'locked'},
    {'nameKr': '단풍나무', 'nameEn': 'Acer palmatum', 'status': 'completed'},
    {'nameKr': '자작나무', 'nameEn': 'Betula pendula', 'status': 'new'},
  ];

  final List<String> avatars = [
    'https://picsum.photos/id/10/100/100',
    'https://picsum.photos/id/11/100/100',
    'https://picsum.photos/id/12/100/100',
  ];

  final List<String> categories = ['전체 수목', '안 푼 수목', '북마크', '토착종'];

  Future<void> init(Function onUpdate) async {
    // 1. 로컬 캐시 먼저 로드
    await _loadCachedStats();
    onUpdate();

    // 2. 서버에서 최신 정보 가져오기
    try {
      final stats = await ApiService.getUserStats();
      treeCount = stats['totalTrees'] ?? 0;
      quizCount = stats['totalQuizzes'] ?? 0;
      similarCount = stats['totalSimilarGroups'] ?? 0;

      await _saveStatsToCache();
      onUpdate();
    } catch (e) {
      // 에러 발생 시 캐시된 데이터 유지
    }
  }

  Future<void> _loadCachedStats() async {
    final prefs = await SharedPreferences.getInstance();
    treeCount = prefs.getInt('cache_total_trees') ?? 0;
    quizCount = prefs.getInt('cache_total_quizzes') ?? 0;
    similarCount = prefs.getInt('cache_total_similar') ?? 0;
  }

  Future<void> _saveStatsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cache_total_trees', treeCount);
    await prefs.setInt('cache_total_quizzes', quizCount);
    await prefs.setInt('cache_total_similar', similarCount);
  }
}
