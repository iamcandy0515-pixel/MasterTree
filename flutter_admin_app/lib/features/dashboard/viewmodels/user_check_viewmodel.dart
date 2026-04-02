import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/user_repository.dart';

class UserCheckViewModel extends ChangeNotifier {
  final _repo = UserRepository();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  String _currentStatus = 'pending';

  UserCheckViewModel() {
    loadUsers('pending');
  }

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get users => _filteredUsers;
  String get currentStatus => _currentStatus;

  Future<void> loadUsers(String status) async {
    _currentStatus = status;
    _isLoading = true;
    notifyListeners();
    try {
      final usersData = await _repo.getUsers(status: status);
      _allUsers = usersData.map((u) {
        final role = u['role']?.toString() ?? 'User';
        final name = u['name']?.toString() ?? '사용자';
        final prefix = role == 'Master' || role == 'Admin' ? '[관] ' : '[사] ';

        return {
          'id': u['id']?.toString() ?? '',
          'name': '$prefix$name',
          'email': u['email']?.toString() ?? '',
          'phone': u['phone']?.toString(),
          'role': role,
          'status': u['status']?.toString() ?? 'pending',
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

  Future<void> updateStatus(String userId, String newStatus) async {
    try {
      await _repo.updateUserStatus(userId, newStatus);
      // Remove from current list and refresh
      loadUsers(_currentStatus);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> approveUser(String userId) => updateStatus(userId, 'approved');
  Future<void> rejectUser(String userId) => updateStatus(userId, 'rejected');
  Future<void> pendingUser(String userId) => updateStatus(userId, 'pending');

  Future<void> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      loadUsers(_currentStatus);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '기록 없음';
    try {
      final date = DateTime.parse(dateStr).toLocal();
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
                (user['name']?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (user['email']?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    }
    notifyListeners();
  }
}
