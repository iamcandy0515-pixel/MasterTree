import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimilarSpeciesController {
  int currentPage = 1;
  final int itemsPerPage = 5;
  List<Map<String, dynamic>> allComparisons = [];
  bool isLoading = true;
  String searchQuery = '';

  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    searchQuery = prefs.getString('user_similar_search') ?? '';
    currentPage = prefs.getInt('user_similar_page') ?? 1;
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_similar_search', searchQuery);
    await prefs.setInt('user_similar_page', currentPage);
  }

  Future<void> fetchGroups({required VoidCallback onUpdate}) async {
    isLoading = true;
    onUpdate();

    try {
      final List<Map<String, dynamic>> groups = await ApiService.getTreeGroups();
      allComparisons = groups.map((Map<String, dynamic> g) {
        final List<dynamic> members = g['tree_group_members'] as List<dynamic>? ?? <dynamic>[];
        final String tree1 = (members.isNotEmpty && (members[0] as Map<String, dynamic>)['trees'] != null)
            ? (members[0] as Map<String, dynamic>)['trees']['name_kr']?.toString() ?? '미지정'
            : '미지정';
        final String tree2 = (members.length > 1 && (members[1] as Map<String, dynamic>)['trees'] != null)
            ? (members[1] as Map<String, dynamic>)['trees']['name_kr']?.toString() ?? '미지정'
            : '미지정';

        String? img1;
        String? img2;

        if (members.isNotEmpty && (members[0] as Map<String, dynamic>)['trees'] != null) {
          final List<dynamic>? images = (members[0] as Map<String, dynamic>)['trees']['tree_images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            img1 = (images.firstWhere(
              (dynamic i) => (i as Map<String, dynamic>)['image_type'] == 'main',
              orElse: () => images[0],
            ) as Map<String, dynamic>)['image_url']?.toString();
          }
        }

        if (members.length > 1 && (members[1] as Map<String, dynamic>)['trees'] != null) {
          final List<dynamic>? images = (members[1] as Map<String, dynamic>)['trees']['tree_images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            img2 = (images.firstWhere(
              (dynamic i) => (i as Map<String, dynamic>)['image_type'] == 'main',
              orElse: () => images[0],
            ) as Map<String, dynamic>)['image_url']?.toString();
          }
        }

        return <String, dynamic>{
          'id': g['id'],
          'group_name': g['group_name'],
          'tree1': tree1,
          'tree2': tree2,
          'desc': g['description'] ?? '비교 설명이 없습니다.',
          'img1': ApiService.getProxyImageUrl(img1),
          'img2': ApiService.getProxyImageUrl(img2),
          'count': members.length,
        };
      }).toList();
      isLoading = false;
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      isLoading = false;
    } finally {
      onUpdate();
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    if (searchQuery.isEmpty) return allComparisons;
    return allComparisons.where((Map<String, dynamic> item) {
      final String groupName = (item['group_name'] ?? '').toString().toLowerCase();
      final String tree1 = (item['tree1'] ?? '').toString().toLowerCase();
      final String tree2 = (item['tree2'] ?? '').toString().toLowerCase();
      final String query = searchQuery.toLowerCase();
      return groupName.contains(query) ||
          tree1.contains(query) ||
          tree2.contains(query);
    }).toList();
  }

  int get totalFilteredResults => _filteredList.length;

  int get totalPages => (_filteredList.length / itemsPerPage).ceil();

  List<Map<String, dynamic>> get displayList {
    final list = _filteredList;
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];

    final endIndex = startIndex + itemsPerPage > list.length
        ? list.length
        : startIndex + itemsPerPage;
    return list.sublist(startIndex, endIndex);
  }

  void updateSearchQuery(String query, {required VoidCallback onUpdate}) {
    searchQuery = query;
    currentPage = 1; // Reset to first page on search
    _saveState();
    onUpdate();
  }

  void setPage(int page, {required VoidCallback onUpdate}) {
    currentPage = page;
    _saveState();
    onUpdate();
  }

  void nextPage({required VoidCallback onUpdate}) {
    if (currentPage < totalPages) {
      currentPage++;
      onUpdate();
    }
  }

  void prevPage({required VoidCallback onUpdate}) {
    if (currentPage > 1) {
      currentPage--;
      onUpdate();
    }
  }
}
