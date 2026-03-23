import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_group_repository.dart';

class TreeGroupManagementViewModel extends ChangeNotifier {
  final _repository = TreeGroupRepository();
  List<TreeGroup> _groups = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounce;

  List<TreeGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

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

  TreeGroupManagementViewModel() {
    loadGroups();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _currentPage = 1; // Reset to page 1 on search
      loadGroups();
    });
  }

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

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
        '🔍 [TreeGroupVM] Searching for: $_searchQuery (Page: $_currentPage)',
      );

      // Note: Passing query to repository. Repository should handle adding 'query' param to URL.
      // Based on our analysis, we assume the backend supports filtering by query.
      final result = await _repository.getTreeGroups(
        page: _currentPage,
        limit: _pageSize,
        query: _searchQuery,
      );

      _groups = result['groups'] as List<TreeGroup>;
      final meta = result['meta'] as Map<String, dynamic>;

      _totalCount = meta['total'] ?? 0;
      _totalPages = meta['totalPages'] ?? 1;

      // Local filtering fallback if server-side search is not fully implemented in DB
      /*
      if (_searchQuery.isNotEmpty) {
        _groups = _groups.where((g) => g.name.contains(_searchQuery) || g.description.contains(_searchQuery)).toList();
      }
      */

      debugPrint(
        '✅ [TreeGroupVM] Successfully loaded ${_groups.length} groups.',
      );
    } catch (e) {
      debugPrint('🔥 [TreeGroupVM] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      await _repository.deleteTreeGroup(groupId);
      await loadGroups();
      return true;
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
