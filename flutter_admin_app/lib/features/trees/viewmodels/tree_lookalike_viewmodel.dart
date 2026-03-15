import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/repositories/tree_group_repository.dart';

class TreeLookalikeViewModel extends ChangeNotifier {
  final _repository = TreeGroupRepository();
  TreeGroup? _group;
  bool _isLoading = false;

  TreeGroup? get group => _group;
  bool get isLoading => _isLoading;

  TreeLookalikeViewModel({TreeGroup? initialGroup}) {
    if (initialGroup != null) {
      _group = initialGroup;
    }
  }

  Future<void> loadGroupDetail(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getTreeGroupById(groupId);
      _group = response;
    } catch (e) {
      debugPrint('Error loading group detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // UI Logic: Tab Selection
  String _selectedTab = 'leaf'; // 'leaf' or 'bark'
  String get selectedTab => _selectedTab;

  void setSelectedTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  // Dynamic getters for current content based on tab
  String? getLeftImageUrl() {
    if (_group == null || _group!.members.isEmpty) return null;
    return _selectedTab == 'leaf'
        ? _group!.members[0].leafImageUrl
        : _group!.members[0].barkImageUrl;
  }

  String? getRightImageUrl() {
    if (_group == null || _group!.members.length < 2) return null;
    return _selectedTab == 'leaf'
        ? _group!.members[1].leafImageUrl
        : _group!.members[1].barkImageUrl;
  }

  String getHint() {
    if (_group == null) return '';
    return _group!.description;
  }

  String getLeftHint() {
    if (_group == null || _group!.members.isEmpty) return '데이터 없음';
    final member = _group!.members[0];

    if (_selectedTab == 'leaf') {
      return member.imageHints['leaf'] ??
          member.imageHints['leaves'] ??
          '등록된 잎 특징이 없습니다.';
    }
    return member.imageHints['bark'] ?? '등록된 수피 특징이 없습니다.';
  }

  String getRightHint() {
    if (_group == null || _group!.members.length < 2) return '데이터 없음';
    final member = _group!.members[1];

    if (_selectedTab == 'leaf') {
      return member.imageHints['leaf'] ??
          member.imageHints['leaves'] ??
          '등록된 잎 특징이 없습니다.';
    }
    return member.imageHints['bark'] ?? '등록된 수피 특징이 없습니다.';
  }
}
