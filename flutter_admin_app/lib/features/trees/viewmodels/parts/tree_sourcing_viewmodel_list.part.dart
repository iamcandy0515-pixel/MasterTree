part of '../tree_sourcing_viewmodel.dart';

extension TreeSourcingListExtension on TreeSourcingViewModel {
  Future<void> loadTrees({int page = 1}) async {
    _isLoading = true;
    _currentPage = page;
    _hasChanges = false;
    _pendingImages.clear();
    _imageSources.clear();
    _fileMissing.clear();
    notify();

    try {
      debugPrint('Fetching trees with query: "$_searchQuery", page: $page');
      final result = await _repository.getTrees(
        page: page,
        limit: TreeSourcingViewModel._pageSize,
        search: _searchQuery.trim(),
      );

      _trees = result.trees;
      _totalCount = result.total;
      _hasMore = _trees.length >= TreeSourcingViewModel._pageSize;
      
      debugPrint('Loaded ${_trees.length} trees. Total: $_totalCount');

      if (_trees.isNotEmpty) {
        if (_selectedTree == null ||
            !_trees.any((t) => t.id == _selectedTree!.id)) {
          _selectedTree = _trees.first;
        }
      } else {
        _selectedTree = null;
      }
    } catch (e) {
      debugPrint('Error loading trees in TreeSourcingViewModel: $e');
      _selectedTree = null;
    } finally {
      _isLoading = false;
      notify();
    }
  }

  void nextPage() {
    if (_hasMore) {
      loadTrees(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadTrees(page: _currentPage - 1);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
  }
}
