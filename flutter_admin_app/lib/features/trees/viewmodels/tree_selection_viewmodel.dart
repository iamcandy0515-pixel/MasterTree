import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_repository.dart';

class TreeSelectionViewModel extends ChangeNotifier {
  final TreeRepository _repo = TreeRepository();

  List<Tree> _allTrees = [];
  List<Tree> _filteredTrees = [];
  final List<Tree> _selectedTrees = [];

  String _searchQuery = '';
  String? _selectedCategory; // '침엽수', '활엽수' or null
  bool _isLoading = false;

  List<Tree> get filteredTrees => _filteredTrees;
  List<Tree> get selectedTrees => _selectedTrees;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  TreeSelectionViewModel() {
    _loadTrees();
  }

  Future<void> _loadTrees() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch a larger set for selection, or implement search-on-server
      // For now, let's fetch 100 trees to provide a good selection list
      final result = await _repo.getTrees(page: 1, limit: 100);
      _allTrees = result.trees;
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading trees for selection: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage; // Expose for UI if needed

  List<Tree> get paginatedTrees {
    if (_filteredTrees.isEmpty) return [];
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= _filteredTrees.length) return [];
    return _filteredTrees.sublist(
      startIndex,
      endIndex > _filteredTrees.length ? _filteredTrees.length : endIndex,
    );
  }

  int get totalPages => (_filteredTrees.length / _itemsPerPage).ceil();

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredTrees = _allTrees.where((tree) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          tree.nameKr.contains(_searchQuery) ||
          (tree.scientificName?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      bool matchesCategory = true;
      if (_selectedCategory != null) {
        matchesCategory = tree.category?.contains(_selectedCategory!) ?? false;
      }

      return matchesQuery && matchesCategory;
    }).toList();
    _currentPage = 1; // Reset to first page
    notifyListeners();
  }

  void toggleSelection(Tree tree) {
    bool found = false;
    for (int i = 0; i < _selectedTrees.length; i++) {
      if (_selectedTrees[i].id == tree.id) {
        _selectedTrees.removeAt(i);
        found = true;
        break;
      }
    }
    if (!found) {
      _selectedTrees.add(tree);
    }
    notifyListeners();
  }

  bool isSelected(Tree tree) {
    return _selectedTrees.any((t) => t.id == tree.id);
  }

  void clearSelection(Tree tree) {
    _selectedTrees.removeWhere((t) => t.id == tree.id);
    notifyListeners();
  }
}
