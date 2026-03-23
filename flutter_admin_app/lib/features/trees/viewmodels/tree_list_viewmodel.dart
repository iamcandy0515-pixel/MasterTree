import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_data_repository.dart';

class TreeListViewModel extends ChangeNotifier {
  final MasterTreeRepository _repo = MasterTreeRepository();
  final MasterTreeDataRepository _dataRepo = MasterTreeDataRepository();

  List<Tree> _paginatedTrees = [];
  bool _isLoading = false;

  // Stats
  int _totalTrees = 0;
  int _completedTrees = 0;
  int _incompleteTrees = 0;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = '전체'; // 전체, 침엽수, 활엽수

  // Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 5; // Show 5 items per page as requested
  int _totalPages = 1;

  // Getters
  List<Tree> get trees => _paginatedTrees;
  bool get isLoading => _isLoading;
  int get totalTrees => _totalTrees;
  int get completedTrees => _completedTrees;
  int get incompleteTrees => _incompleteTrees;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  // Pagination Getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get filteredTotalCount => _totalTrees; // Total matching filter

  static const List<String> categories = ['전체', '침엽수', '활엽수'];

  Future<void> fetchTrees({int? page}) async {
    if (page != null) _currentPage = page;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getTrees(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery,
        category: _selectedCategory,
      );

      _paginatedTrees = result.trees;
      _totalTrees = result.total;
      _totalPages = result.totalPages;

      // Note: completed/incomplete stats cannot be accurately calculated
      // from a partial page without fetching all data.
      _completedTrees = 0;
      _incompleteTrees = 0;
    } catch (e) {
      _errorMessage = '데이터 로드 실패: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    fetchTrees();
  }

  void filterByCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _currentPage = 1;
    fetchTrees();
  }

  void setPage(int page) {
    if (page < 1 || page > _totalPages) return;
    fetchTrees(page: page);
  }

  void nextPage() => setPage(_currentPage + 1);
  void previousPage() => setPage(_currentPage - 1);

  Future<void> deleteTree(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.deleteTree(id);
      // Refresh current page
      await fetchTrees();
    } catch (e) {
      _errorMessage = '삭제 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> exportData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final csvData = await _dataRepo.exportTrees();
      return csvData;
    } catch (e) {
      _errorMessage = '내보내기 실패: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> importData(
    List<int> bytes,
    String fileName,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await _dataRepo.importTrees(bytes, fileName);
      // Refresh list
      _currentPage = 1;
      await fetchTrees();
      return results;
    } catch (e) {
      _errorMessage = '가져오기 실패: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
