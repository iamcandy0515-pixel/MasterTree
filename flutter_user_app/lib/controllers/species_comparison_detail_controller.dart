import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/tree_comparison_data.dart';
import '../controllers/tree_comparison_controller.dart';

class SpeciesComparisonDetailController {
  String selectedTag = '잎'; // '잎' or '수피'
  Map<String, dynamic>? groupData;
  bool isDataLoading = true;

  TreeComparisonData tree1Data = TreeComparisonData.empty();
  TreeComparisonData tree2Data = TreeComparisonData.empty();

  Future<void> fetchDetailData({
    required String tree1,
    required String tree2,
    required String? groupId,
    required VoidCallback onUpdate,
  }) async {
    debugPrint(
      '[DEBUG] Starting fetchDetailData for groupId: $groupId, names: $tree1 vs $tree2',
    );
    isDataLoading = true;
    onUpdate();

    try {
      if (groupId != null) {
        final group = await ApiService.getTreeGroup(groupId);

        if (group.isEmpty) {
          debugPrint('[DEBUG] No matching group found for id: $groupId');
          groupData = null;
        } else {
          debugPrint('[DEBUG] Match found: ${group['group_name']}');
          groupData = group;
          final members = group['tree_group_members'] as List;

          // 이름으로 수목 매칭 (비교 방향 보장)
          dynamic t1;
          dynamic t2;

          for (var member in members) {
            final tree = member['trees'];
            if (tree != null) {
              final name = tree['name_kr']?.toString().trim();
              debugPrint(
                '[DEBUG] Checking member: $name (Target1: ${tree1.trim()}, Target2: ${tree2.trim()})',
              );
              if (name == tree1.trim()) {
                t1 = tree;
                debugPrint('[DEBUG] Match found for Tree1: $name');
              } else if (name == tree2.trim()) {
                t2 = tree;
                debugPrint('[DEBUG] Match found for Tree2: $name');
              }
            }
          }

          if (t1 == null)
            debugPrint('[DEBUG] Tree1 data is NULL after matching');
          if (t2 == null)
            debugPrint('[DEBUG] Tree2 data is NULL after matching');

          // 비즈니스 로직 프로세서를 통한 데이터 가공
          tree1Data = TreeComparisonProcessor.processTreeData(t1);
          tree2Data = TreeComparisonProcessor.processTreeData(t2);

          debugPrint(
            '[DEBUG] Processed results: T1 Bark: ${tree1Data.barkHint}, T2 Bark: ${tree2Data.barkHint}',
          );
        }
      } else {
        debugPrint('[DEBUG] groupId is null');
      }
    } catch (e) {
      debugPrint('[DEBUG] Error fetching detail data: $e');
    } finally {
      isDataLoading = false;
      onUpdate();
    }
  }

  void setSelectedTag(String label, {required VoidCallback onUpdate}) {
    selectedTag = label;
    onUpdate();
  }
}
