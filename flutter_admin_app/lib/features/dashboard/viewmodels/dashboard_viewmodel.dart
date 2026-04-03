import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/stats_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final _statsRepo = StatsRepository();

  Map<String, dynamic> _stats = {
    'totalTrees': 0,
    'publishedTrees': 0,
    'totalUsers': 0,
    'activeUsers': 0,
    'totalQuizzes': 0,
    'totalSimilarGroups': 0,
  };

  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  /// MEM (Manual Entry Mapping) - Nuclear Cast 2.0
  Map<String, dynamic> _forceCast(dynamic data) {
    if (data is! Map) return <String, dynamic>{};
    // Survive minified JS crashes by explicit entry-by-entry mapping
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  /// DTC (Direct Token Channel) Sign Out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      try { await Supabase.instance.client.auth.signOut(); } catch (_) {}
      debugPrint('✅ [DashboardVM] Signed out & DTC cleared');
    } catch (e) {
      debugPrint('❌ [DashboardVM] SignOut error: $e');
    }
  }

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dynamic rawData = await _statsRepo.getDashboardStats();
      
      // 🔥 [Nuclear Cast 2.0] Direct mapping of entries
      _stats = _forceCast(rawData);
      
      debugPrint('✅ [DashboardVM] stats loaded');
    } catch (e) {
      debugPrint('❌ [DashboardVM] error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
