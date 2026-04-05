import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/stats_repository.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/system_settings_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final StatsRepository _statsRepo = StatsRepository();
  final SystemSettingsRepository _settingsRepo = SystemSettingsRepository();
  Map<String, dynamic> _stats = <String, dynamic>{
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
      debugPrint('Sign out error: ');
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
      final Map<String, dynamic> data = await _statsRepo.getDashboardStats();
      _stats = data;
    } catch (e) {
      debugPrint('Dashboard VM Error: ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartAdminServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _settingsRepo.restartAdminServer();
    } catch (_) {
      // Ignore
    } finally {
      // Wait for server to come back potentially? Or just stop loading.
      await Future.delayed(const Duration(seconds: 3));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartUserServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _settingsRepo.restartUserServer();
    } catch (e) {
      debugPrint('Restart User Server Error: ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
