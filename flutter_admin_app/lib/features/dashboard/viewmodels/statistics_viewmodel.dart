import 'package:flutter/material.dart';
import '../../trees/repositories/tree_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<dynamic> _users = [];
  List<dynamic> get users => _users;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getDetailedStats();
      // 'activeUsers' is the key returned by the backend for the user list
      _users = List<dynamic>.from(data['activeUsers'] ?? []);
    } catch (e) {
      _error = '사용자 목록을 불러오는 중 오류가 발생했습니다.';
      debugPrint('Error loading user list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
