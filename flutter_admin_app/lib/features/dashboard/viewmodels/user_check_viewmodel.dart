import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/user_repository.dart';

class UserCheckViewModel extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  List<Map<String, dynamic>> _allUsers = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _filteredUsers = <Map<String, dynamic>>[];
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
      final List<Map<String, dynamic>> usersData = await _repo.getUsers(status: status);
      _allUsers = usersData.map((u) {
        final String role = (u['role'] ?? 'User').toString();
        final String rawName = (u['name'] ?? '사용자').toString();
        final String prefix = (role == 'Master' || role == 'Admin') ? '[관] ' : '[사] ';
        final String name = '$prefix$rawName';

        return <String, dynamic>{
          'id': (u['id'] ?? '').toString(),
          'name': name,
          'email': (u['email'] ?? '').toString(),
          'phone': u['phone']?.toString(),
          'role': role,
          'status': (u['status'] ?? 'pending').toString(),
          'lastLogin': _formatDate((u['lastLogin'] ?? u['last_login'] ?? u['createdAt'] ?? u['created_at'])?.toString()),
          'expiredAt': (u['expiredAt'] ?? u['expired_at'])?.toString(),
          'expired_at': (u['expired_at'] ?? u['expiredAt'])?.toString(), // Ensure both are present
        };
      }).toList();
      _filteredUsers = List<Map<String, dynamic>>.from(_allUsers);
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String userId, String newStatus) async {
    try {
      await _repo.updateUserStatus(userId, newStatus);
      // Remove from current list and refresh
      await loadUsers(_currentStatus);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updateData) async {
    try {
      final updatedUser = await _repo.updateUser(userId, updateData);
      
      // Update local state immediately for better UX
      final allIndex = _allUsers.indexWhere((u) => u['id'] == userId);
      if (allIndex != -1 && updatedUser.isNotEmpty) {
        final Map<String, dynamic> mappedUser = {
          ..._allUsers[allIndex],
          ...updatedUser,
          'lastLogin': _formatDate((updatedUser['lastLogin'] ?? updatedUser['last_login'] ?? updatedUser['createdAt'] ?? updatedUser['created_at'])?.toString()),
          'expiredAt': (updatedUser['expiredAt'] ?? updatedUser['expired_at'])?.toString(),
          'expired_at': (updatedUser['expired_at'] ?? updatedUser['expiredAt'])?.toString(),
        };
        
        _allUsers[allIndex] = mappedUser;
        
        // Also update the filtered list if present
        final filterIndex = _filteredUsers.indexWhere((u) => u['id'] == userId);
        if (filterIndex != -1) {
          _filteredUsers[filterIndex] = mappedUser;
        }
        
        notifyListeners();
      }
      
      // Still refresh to be sure everything is in sync
      await loadUsers(_currentStatus); 
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> approveUser(String userId) => updateStatus(userId, 'approved');
  Future<void> rejectUser(String userId) => updateStatus(userId, 'rejected');
  Future<void> pendingUser(String userId) => updateStatus(userId, 'pending');

  Future<void> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      await loadUsers(_currentStatus);
    } catch (e) {
      debugPrint('Error deleting user: ');
      rethrow;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '기록 없음';
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(date);
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
      _filteredUsers = List<Map<String, dynamic>>.from(_allUsers);
    } else {
      final String lowerQuery = query.toLowerCase();
      _filteredUsers = _allUsers
          .where(
            (Map<String, dynamic> user) =>
                ((user['name'] as String?)?.toLowerCase().contains(lowerQuery) ?? false) ||
                ((user['email'] as String?)?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
    }
    notifyListeners();
  }
}
