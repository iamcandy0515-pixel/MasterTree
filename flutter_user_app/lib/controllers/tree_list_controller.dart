import 'package:flutter/foundation.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreeListController {
  List<Map<String, dynamic>> allTrees = [];
  List<Map<String, dynamic>> filteredTrees = [];
  bool isLoading = true;
  String selectedCategory = '전체';
  String searchQuery = '';
  int currentPage = 0;
  static const int itemsPerPage = 5;

  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCategory = prefs.getString('user_tree_category') ?? '전체';
    searchQuery = prefs.getString('user_tree_search') ?? '';
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_tree_category', selectedCategory);
    await prefs.setString('user_tree_search', searchQuery);
  }

  Future<void> fetchTrees(VoidCallback onUpdate) async {
    try {
      final trees = await ApiService.getTrees();
      allTrees = trees;
      filterTrees(searchQuery, () {}); // Use saved search query
      isLoading = false;
    } catch (e) {
      debugPrint('Error fetching trees: $e');
      isLoading = false;
    }
    onUpdate();
  }

  void filterTrees(String query, VoidCallback onUpdate) {
    searchQuery = query;
    _saveFilters();
    currentPage = 0;
    filteredTrees = allTrees.where((tree) {
      final name = (tree['name_kr'] ?? '').toString().toLowerCase();
      final scientificName = (tree['scientific_name'] ?? '')
          .toString()
          .toLowerCase();
      final category = tree['category'] ?? '';
      final shape = tree['shape'] ?? '';
      final lowerQuery = query.toLowerCase();

      final matchesSearch =
          name.contains(lowerQuery) || scientificName.contains(lowerQuery);
      final matchesCategory =
          selectedCategory == '전체' ||
          category == selectedCategory ||
          shape == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
    onUpdate();
  }

  void changeCategory(String category, String query, VoidCallback onUpdate) {
    selectedCategory = category;
    filterTrees(query, onUpdate);
  }

  void nextPage(VoidCallback onUpdate) {
    final totalPages = (filteredTrees.length / itemsPerPage).ceil();
    if (currentPage < totalPages - 1) {
      currentPage++;
      onUpdate();
    }
  }

  void prevPage(VoidCallback onUpdate) {
    if (currentPage > 0) {
      currentPage--;
      onUpdate();
    }
  }

  void setPage(int page, VoidCallback onUpdate) {
    currentPage = page;
    onUpdate();
  }

  // Logic for TreeDetailSheet
  static Map<String, Map<String, String?>> processImageData(
    Map<String, dynamic> tree,
  ) {
    final List<dynamic> data = tree['tree_images'] ?? [];

    // UI 태그 명칭과 서버 image_type 간의 매핑 정의
    final tagMapping = {
      '대표': ['main', 'representative'],
      '잎': ['leaf'],
      '수피': ['bark', 'branch', 'twig', 'stem'], // 수피 및 가지 정보 포함
      '꽃': ['flower'],
      '열매/겨울눈': ['fruit', 'fruit_bud', 'winter_bud', 'bud'],
    };

    Map<String, Map<String, String?>> imageData = {};

    for (var entry in tagMapping.entries) {
      final koreanTag = entry.key;
      final targetTypes = entry.value;

      // 해당 태그에 해당하는 모든 이미지 필터링
      final images = data
          .where((img) => targetTypes.contains(img['image_type']))
          .toList();

      String? imageUrl;
      List<String> hints = [];

      for (var img in images) {
        // 첫 번째 이미지 URL을 대표로 선택
        imageUrl ??= img['image_url']?.toString();

        final hint = img['hint']?.toString();
        if (hint != null && hint.isNotEmpty && hint != '자료없음') {
          if (!hints.contains(hint)) {
            hints.add(hint);
          }
        }
      }

      imageData[koreanTag] = {
        'image_url': imageUrl,
        'hint': hints.isEmpty ? null : hints.join('\n\n'),
      };
    }

    return imageData;
  }
}
