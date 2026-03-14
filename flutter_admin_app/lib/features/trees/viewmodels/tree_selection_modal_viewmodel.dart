import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_repository.dart';

class TreeSelectionModalViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();

  List<Tree> _trees = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;
  
  int _currentPage = 1;
  final int _limit = 20;
  int _totalCount = 0;
  int _totalPages = 1;

  final List<Tree> _selectedTrees = [];
  final Set<String> _existingTreeIds;

  // Getters
  List<Tree> get trees => _trees;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<Tree> get selectedTrees => _selectedTrees;

  TreeSelectionModalViewModel({
    required List<TreeGroupMember> existingMembers,
    String? initialCategory,
  }) : _existingTreeIds = existingMembers.map((e) => e.treeId).toSet() {
    _selectedCategory = initialCategory;
    _fetchTrees();
  }

  Future<void> _fetchTrees() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getTrees(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
      );
      _trees = response.trees;
      _totalCount = response.total;
      _totalPages = response.totalPages;
    } catch (e) {
      debugPrint('Error fetching trees in modal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    _fetchTrees();
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _currentPage = 1;
    _fetchTrees();
  }

  // Pagination navigation
  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _fetchTrees();
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _fetchTrees();
    }
  }

  void firstPage() {
    if (_currentPage > 1) {
      _currentPage = 1;
      _fetchTrees();
    }
  }

  void lastPage() {
    if (_currentPage < _totalPages) {
      _currentPage = _totalPages;
      _fetchTrees();
    }
  }

  bool isSelected(Tree tree) {
    return _selectedTrees.any((t) => t.id == tree.id);
  }

  bool isAlreadyMember(Tree tree) {
    return _existingTreeIds.contains(tree.id.toString());
  }

  void toggleSelection(Tree tree) {
    if (isAlreadyMember(tree)) return;

    if (isSelected(tree)) {
      _selectedTrees.removeWhere((t) => t.id == tree.id);
    } else {
      _selectedTrees.add(tree);
    }
    notifyListeners();
  }

  void removeSelection(Tree tree) {
    _selectedTrees.removeWhere((t) => t.id == tree.id);
    notifyListeners();
  }
}
