import 'package:flutter/material.dart';
import '../../trees/repositories/tree_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  List<dynamic> get examStats => List<dynamic>.from(_stats['exams'] ?? []);
  List<dynamic> get activeUserList =>
      List<dynamic>.from(_stats['activeUsers'] ?? []);
  List<dynamic> get topWrongTrees =>
      List<dynamic>.from(_stats['topWrongTrees'] ?? []);
  Map<String, int> get updateSummary =>
      Map<String, int>.from(_stats['updateSummary'] ?? {});

  Map<String, dynamic> get globalStats =>
      Map<String, dynamic>.from(_stats['globalStats'] ?? {});

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getDetailedStats();
      _stats = data;
    } catch (e) {
      _error = '통계 정보를 불러오는 중 오류가 발생했습니다.';
      debugPrint('Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
