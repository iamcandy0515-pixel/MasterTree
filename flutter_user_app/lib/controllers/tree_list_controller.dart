import 'package:flutter/foundation.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreeListController {
  List<Map<String, dynamic>> allTrees = [];
  List<Map<String, dynamic>> filteredTrees = [];
  bool isLoading = true;
  String selectedType = '전체';
  String selectedHabit = '전체';
  String searchQuery = '';
  int currentPage = 0;
  static const int itemsPerPage = 5;

  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    selectedType = prefs.getString('user_tree_type') ?? '전체';
    selectedHabit = prefs.getString('user_tree_habit') ?? '전체';
    searchQuery = prefs.getString('user_tree_search') ?? '';
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_tree_type', selectedType);
    await prefs.setString('user_tree_habit', selectedHabit);
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
      final category = (tree['category'] ?? '').toString();
      final lowerQuery = query.toLowerCase();

      final matchesSearch =
          name.contains(lowerQuery) || scientificName.contains(lowerQuery);
      
      final matchesType = selectedType == '전체' || category.contains(selectedType);
      final matchesHabit = selectedHabit == '전체' || category.contains(selectedHabit);

      return matchesSearch && matchesType && matchesHabit;
    }).toList();
    onUpdate();
  }

  void changeType(String type, String query, VoidCallback onUpdate) {
    selectedType = type;
    filterTrees(query, onUpdate);
  }

  void changeHabit(String habit, String query, VoidCallback onUpdate) {
    selectedHabit = habit;
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
    final List<dynamic> data = (tree['tree_images'] as List<dynamic>?) ?? <dynamic>[];

    // UI 태그 명칭과 서버 image_type 간의 매핑 정의
    final Map<String, List<String>> tagMapping = {
      '대표': ['main', 'representative'],
      '잎': ['leaf'],
      '수피': ['bark', 'branch', 'twig', 'stem'], // 수피 및 가지 정보 포함
      '꽃': ['flower'],
      '열매/겨울눈': ['fruit', 'fruit_bud', 'winter_bud', 'bud'],
    };

    Map<String, Map<String, String?>> imageData = {};

    for (final MapEntry<String, List<String>> entry in tagMapping.entries) {
      final String koreanTag = entry.key;
      final List<String> targetTypes = entry.value;

      // 해당 태그에 해당하는 모든 이미지 필터링
      final List<dynamic> images = data
          .where((dynamic img) => targetTypes.contains((img as Map<String, dynamic>)['image_type']))
          .toList();

      String? imageUrl;
      String? thumbnailUrl;
      final List<String> hints = <String>[];

      for (final dynamic imgRaw in images) {
        final Map<String, dynamic> img = Map<String, dynamic>.from(imgRaw as Map);
        // 첫 번째 이미지 URL 및 썸네일을 대표로 선택
        imageUrl ??= (img['quizz_source_image_url'] ?? img['image_url'])?.toString();
        thumbnailUrl ??= img['thumbnail_url']?.toString();

        final String? hint = img['hint']?.toString();
        if (hint != null && hint.isNotEmpty && hint != '자료없음') {
          if (!hints.contains(hint)) {
            hints.add(hint);
          }
        }
      }

      imageData[koreanTag] = {
        'image_url': imageUrl,
        'thumbnail_url': thumbnailUrl,
        'hint': hints.isEmpty ? null : hints.join('\n\n'),
      };
    }

    return imageData;
  }
}
