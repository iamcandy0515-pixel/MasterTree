import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'tree_selection_modal.dart';

class TreeGroupMemberList extends StatelessWidget {
  const TreeGroupMemberList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeGroupEditViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '비교 수목 리스트 (${vm.members.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (vm.members.length < 6)
              TextButton.icon(
                onPressed: () => _showSelectionModal(context, vm),
                icon: const Icon(Icons.add_circle, color: NeoColors.acidLime, size: 16),
                label: const Text(
                  '비교수목 추가',
                  style: TextStyle(color: NeoColors.acidLime, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.members.length < 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '⚠️ 최소 2개 이상의 수목을 추가해야 저장할 수 있습니다.',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.members.length,
          onReorder: vm.reorderMembers,
          proxyDecorator: (child, index, animation) => Material(color: Colors.transparent, child: child),
          itemBuilder: (context, index) {
            final member = vm.members[index];
            return _buildTextMemberItem(context, member, index, vm);
          },
        ),
      ],
    );
  }

  Widget _buildTextMemberItem(BuildContext context, TreeGroupMember member, int index, TreeGroupEditViewModel vm) {
    return Container(
      key: ValueKey(member.treeId),
      margin: const EdgeInsets.only(bottom: 4), // 좁은 간격으로 렌더링
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        title: Row(
          children: [
            Text(
              member.treeName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (!member.isAutoQuizEnabled) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Text('비교전용', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(
          member.treeId, // ID 또는 학명 노출
          style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => vm.removeMember(index),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSelectionModal(BuildContext context, TreeGroupEditViewModel vm) async {
    // 1건 이상 존재하는 경우 첫 번째 멤버 정보를 활용해 카테고리(침/활엽수) 정보 전달
    // 이 작업은 나중에 추가될 모달에서 처리하도록 인자를 추후 수정합니다.
    final selectedTrees = await showDialog<List<Tree>>(
      context: context,
      barrierDismissible: false, // 닫기 버튼으로만 닫히게 함
      builder: (ctx) => TreeSelectionModal(parentVm: vm),
    );

    if (selectedTrees != null && selectedTrees.isNotEmpty) {
      for (final tree in selectedTrees) {
        vm.addMember(
          TreeGroupMember(
            treeId: tree.id.toString(),
            treeName: tree.nameKr,
            keyCharacteristics: '',
            isAutoQuizEnabled: tree.isAutoQuizEnabled,
          ),
        );
      }
    }
  }
}
