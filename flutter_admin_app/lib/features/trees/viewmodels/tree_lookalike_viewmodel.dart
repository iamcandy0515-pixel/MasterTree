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
    final member = _group!.members[0];
    if (_selectedTab == 'leaf') return member.leafImageUrl;
    if (_selectedTab == 'bark') return member.barkImageUrl;
    if (_selectedTab == 'flower') return member.flowerImageUrl;
    if (_selectedTab == 'fruit') return member.fruitImageUrl;
    return member.imageUrl;
  }

  String? getRightImageUrl() {
    if (_group == null || _group!.members.length < 2) return null;
    final member = _group!.members[1];
    if (_selectedTab == 'leaf') return member.leafImageUrl;
    if (_selectedTab == 'bark') return member.barkImageUrl;
    if (_selectedTab == 'flower') return member.flowerImageUrl;
    if (_selectedTab == 'fruit') return member.fruitImageUrl;
    return member.imageUrl;
  }

  String getHint() {
    if (_group == null) return '';
    return _group!.description;
  }

  String getLeftHint() {
    if (_group == null || _group!.members.isEmpty) return '데이터 없음';
    final member = _group!.members[0];
    return _getHintForMember(member);
  }

  String getRightHint() {
    if (_group == null || _group!.members.length < 2) return '데이터 없음';
    final member = _group!.members[1];
    return _getHintForMember(member);
  }

  String _getHintForMember(TreeGroupMember member) {
    if (_selectedTab == 'leaf') {
      return member.imageHints['leaf'] ??
          member.imageHints['leaves'] ??
          member.imageHints['잎'] ??
          '등록된 잎 특징이 없습니다.';
    } else if (_selectedTab == 'bark') {
      return member.imageHints['bark'] ?? member.imageHints['수피'] ?? '등록된 수피 특징이 없습니다.';
    } else if (_selectedTab == 'flower') {
      return member.imageHints['flower'] ?? member.imageHints['꽃'] ?? '등록된 꽃 특징이 없습니다.';
    } else if (_selectedTab == 'fruit') {
      return member.imageHints['fruit'] ?? member.imageHints['열매'] ?? '등록된 열매 특징이 없습니다.';
    }
    return '-';
  }
}
