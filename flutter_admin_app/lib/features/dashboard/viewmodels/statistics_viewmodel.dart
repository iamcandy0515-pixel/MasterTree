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

  List<dynamic> get _allActivityUsers =>
      List<dynamic>.from(_stats['activeUsers'] ?? []);

  List<dynamic> get activeUserList => _allActivityUsers.where((u) {
        final lastLoginStr = u['last_login']?.toString();
        if (lastLoginStr == null) return false;
        final lastLogin = DateTime.tryParse(lastLoginStr);
        if (lastLogin == null) return false;
        return DateTime.now().difference(lastLogin).inDays <= 7;
      }).toList();

  List<dynamic> get inactiveUserList => _allActivityUsers.where((u) {
        final lastLoginStr = u['last_login']?.toString();
        if (lastLoginStr == null) return true;
        final lastLogin = DateTime.tryParse(lastLoginStr);
        if (lastLogin == null) return true;
        return DateTime.now().difference(lastLogin).inDays > 7;
      }).toList();

  List<dynamic> get examStats => List<dynamic>.from(_stats['exams'] ?? []);
  List<dynamic> get topWrongTrees =>
      List<dynamic>.from(_stats['topWrongTrees'] ?? []);
  Map<String, int> get updateSummary =>
      Map<String, int>.from(_stats['updateSummary'] ?? {});

  Map<String, dynamic> get globalStats {
    final global = Map<String, dynamic>.from(_stats['globalStats'] ?? {});
    global['activeUserCount'] = activeUserList.length;
    return global;
  }

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
