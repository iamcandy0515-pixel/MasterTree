import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/stats_repository.dart';

class UserDetailViewModel extends ChangeNotifier {
  final StatsRepository _repository = StatsRepository();
  final String userId;

  UserDetailViewModel(this.userId);

  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _categoryStats = [];
  List<Map<String, dynamic>> _examStats = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get stats => _stats;
  List<Map<String, dynamic>> get categoryStats => _categoryStats;
  List<Map<String, dynamic>> get examStats => _examStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getUserPerformanceStats(userId),
        _repository.getTreeCategoryStats(userId),
        _repository.getExamSessionStats(userId),
      ]);

      _stats = results[0] as Map<String, dynamic>;
      _categoryStats = results[1] as List<Map<String, dynamic>>;
      _examStats = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
