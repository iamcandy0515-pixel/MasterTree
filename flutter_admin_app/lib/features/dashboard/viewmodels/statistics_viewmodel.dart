import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/stats_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  final StatsRepository _repository = StatsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<dynamic> _users = [];
  List<dynamic> get users => _users; // 전체 리스트 (필요시)

  // 활동 유저와 비활동 유저 필터링 리스트
  List<dynamic> get activeUsersList =>
      _users.where((u) => u['is_active_tab'] == true).toList();
  List<dynamic> get inactiveUsersList =>
      _users.where((u) => u['is_active_tab'] == false).toList();

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getDetailedStats();
      // 'activeUsers' is the key returned by the backend for the user list
      // Backend already filters 'rejected' and sorts by recency
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
