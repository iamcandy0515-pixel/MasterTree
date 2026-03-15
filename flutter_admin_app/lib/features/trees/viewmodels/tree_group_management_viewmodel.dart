import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_group_repository.dart';

class TreeGroupManagementViewModel extends ChangeNotifier {
  final _repository = TreeGroupRepository();
  List<TreeGroup> _groups = [];
  bool _isLoading = false;

  List<TreeGroup> get groups => _groups;
  bool get isLoading => _isLoading;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  static const int _pageSize = 5;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;

  // With server-side pagination, the pagedGroups are just the _groups list
  List<TreeGroup> get pagedGroups => _groups;

  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      loadGroups();
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadGroups();
    }
  }

  TreeGroupManagementViewModel() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
        '🔍 [TreeGroupVM] Calling API for groups (Page: $_currentPage)...',
      );

      final result = await _repository.getTreeGroups(
        page: _currentPage,
        limit: _pageSize,
      );

      _groups = result['groups'] as List<TreeGroup>;
      final meta = result['meta'] as Map<String, dynamic>;

      _totalCount = meta['total'] ?? 0;
      _totalPages = meta['totalPages'] ?? 1;

      debugPrint(
        '✅ [TreeGroupVM] Successfully loaded ${_groups.length} groups.',
      );
    } catch (e) {
      debugPrint('🔥 [TreeGroupVM] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      // Currently repository doesn't have deleteGroup,
      // but for refactoring purposes, we should stick to standardized calls.
      // If we need deletion, we should add it to repository first.
      debugPrint('Delete functionality should be moved to repository.');
    } catch (e) {
      debugPrint('Error deleting group: $e');
    }
  }
}
