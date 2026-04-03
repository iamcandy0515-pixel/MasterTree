import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/stats_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final _statsRepo = StatsRepository();
  Map<String, dynamic> _stats = {
    'totalTrees': 0,
    'totalQuizzes': 0,
    'totalSimilarGroups': 0,
    'activeUsers': 0,
  };

  Map<String, dynamic> get stats => _stats;

  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signOut();
      return true;
    } catch (e) {
      debugPrint('Sign out error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _statsRepo.getDashboardStats();
      _stats = data;
    } catch (e) {
      debugPrint('Dashboard VM Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
