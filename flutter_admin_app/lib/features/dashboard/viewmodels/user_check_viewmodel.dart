import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/user_repository.dart';

class UserCheckViewModel extends ChangeNotifier {
  final _repo = UserRepository();

  List<Map<String, String>> _allUsers = [];
  List<Map<String, String>> _filteredUsers = [];
  bool _isLoading = false;

  UserCheckViewModel() {
    loadUsers();
  }

  bool get isLoading => _isLoading;
  List<Map<String, String>> get users => _filteredUsers;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final usersData = await _repo.getUsers();
      _allUsers = usersData.map((u) {
        return {
          'name': u['name']?.toString() ?? '사용자',
          'email': u['email']?.toString() ?? '',
          'role': u['role']?.toString() ?? 'User',
          'lastLogin': _formatDate(u['lastLogin']?.toString()),
        };
      }).toList();
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '기록 없음';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers
          .where(
            (user) =>
                (user['name']?.contains(query) ?? false) ||
                (user['email']?.contains(query) ?? false),
          )
          .toList();
    }
    notifyListeners();
  }
}
