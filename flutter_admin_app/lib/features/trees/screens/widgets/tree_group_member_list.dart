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
              '鍮꾧탳 ?섎ぉ 由ъ뒪??(${vm.members.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (vm.members.length < 6)
              TextButton.icon(
                onPressed: () => _showSelectionModal(context, vm),
                icon: const Icon(
                  Icons.add_circle,
                  color: NeoColors.acidLime,
                  size: 16,
                ),
                label: const Text(
                  '鍮꾧탳?섎ぉ 異붽?',
                  style: TextStyle(
                    color: NeoColors.acidLime,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
              '?좑툘 理쒖냼 2媛??댁긽???섎ぉ??異붽??댁빞 ??ν븷 ???덉뒿?덈떎.',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.members.length,
          onReorder: vm.reorderMembers,
          proxyDecorator: (child, index, animation) =>
              Material(color: Colors.transparent, child: child),
          itemBuilder: (context, index) {
            final member = vm.members[index];
            return _buildTextMemberItem(context, member, index, vm);
          },
        ),
      ],
    );
  }

  Widget _buildTextMemberItem(
    BuildContext context,
    TreeGroupMember member,
    int index,
    TreeGroupEditViewModel vm,
  ) {
    return Container(
      key: ValueKey(member.treeId),
      margin: const EdgeInsets.only(bottom: 4), // 醫곸? 媛꾧꺽?쇰줈 ?뚮뜑留?
      decoration: const BoxDecoration(color: Colors.transparent),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        title: Row(
          children: [
            Text(
              member.treeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
                child: const Text(
                  '鍮꾧탳?꾩슜',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          member.treeId, // ID ?먮뒗 ?숇챸 ?몄텧
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => vm.removeMember(index),
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 20,
              ),
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

  Future<void> _showSelectionModal(
    BuildContext context,
    TreeGroupEditViewModel vm,
  ) async {
    // 1嫄??댁긽 議댁옱?섎뒗 寃쎌슦 泥?踰덉㎏ 硫ㅻ쾭 ?뺣낫瑜??쒖슜??移댄뀒怨좊━(移??쒖뿽?? ?뺣낫 ?꾨떖
    // ???묒뾽? ?섏쨷??異붽???紐⑤떖?먯꽌 泥섎━?섎룄濡??몄옄瑜?異뷀썑 ?섏젙?⑸땲??
    final selectedTrees = await showDialog<List<Tree>>(
      context: context,
      barrierDismissible: false, // ?リ린 踰꾪듉?쇰줈留??ロ엳寃???
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

