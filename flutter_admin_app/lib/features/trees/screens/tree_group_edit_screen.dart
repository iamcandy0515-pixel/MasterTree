import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_selection_screen.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_lookalike_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TreeGroupEditScreen extends StatelessWidget {
  final TreeGroup? group; // If null, creates new group

  const TreeGroupEditScreen({super.key, this.group});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeGroupEditViewModel(initialGroup: group),
      child: const _TreeGroupEditContent(),
    );
  }
}

class _TreeGroupEditContent extends StatefulWidget {
  const _TreeGroupEditContent();

  @override
  State<_TreeGroupEditContent> createState() => _TreeGroupEditContentState();
}

class _TreeGroupEditContentState extends State<_TreeGroupEditContent> {
  // Controllers to keep input concise
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<TreeGroupEditViewModel>();
    _titleController.text = vm.title;
    _descController.text = vm.description;

    if (vm.isEditing) {
      // Use addPostFrameCallback to avoid 'setState() or markNeedsBuild() called during build' errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchDetails(vm);
      });
    }
  }

  Future<void> _fetchDetails(TreeGroupEditViewModel vm) async {
    // We use toGroup().id because _id is private in VM but set in constructor
    await vm.loadGroupDetail(vm.toGroup().id);
    if (mounted) {
      _titleController.text = vm.title;
      _descController.text = vm.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    final vm = context.read<TreeGroupEditViewModel>();

    final success = await vm.saveGroup();
    if (success) {
      if (context.mounted) {
        scaffold.showSnackBar(const SnackBar(content: Text('그룹이 저장되었습니다.')));
        navigator.pop(true); // Return true to refresh list
      }
    } else {
      if (context.mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했습니다. 데이터 권한이나 형식을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeGroupEditViewModel>();

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('유사 수목 그룹 편집'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TreeLookalikeDetailScreen(group: vm.toGroup()),
                ),
              );
            },
            icon: const Icon(Icons.visibility),
            tooltip: '미리보기',
            color: NeoColors.acidLime,
          ),
          TextButton(
            onPressed: vm.isValid && !vm.isLoading ? _onSave : null,
            child: Text(
              '저장',
              style: TextStyle(
                color: vm.isValid ? NeoColors.acidLime : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Info (with Delete Button if editing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('그룹 정보'),
                      const Spacer(),
                      if (vm.isEditing)
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('그룹 삭제'),
                                content: const Text('이 유사 수목 그룹을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success = await vm.deleteGroup();
                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('그룹이 삭제되었습니다.'),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              }
                            }
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red[400],
                          ),
                          label: Text(
                            '그룹 삭제',
                            style: TextStyle(
                              color: Colors.red[400],
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
                  TextField(
                    controller: _titleController,
                    onChanged: vm.setTitle,
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: '그룹 제목',
                      hintText: '예: 봄꽃이 비슷한 나무',
                      filled: true,
                      fillColor: const Color(0xFF1E2518),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    onChanged: vm.setDescription,
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: '비교 포인트 (팁)',
                      hintText: '비슷한 수목들을 구분하는 핵심 팁을 입력하세요...',
                      filled: true,
                      fillColor: const Color(0xFF1E2518),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section 2: Members
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('비교 수목 리스트 (${vm.members.length})'),

                      // Add Button (Moved here)
                      if (vm.members.length < 6)
                        TextButton.icon(
                          onPressed: () async {
                            final selectedTrees =
                                await Navigator.push<List<Tree>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TreeSelectionScreen(),
                                  ),
                                );

                            if (selectedTrees != null &&
                                selectedTrees.isNotEmpty) {
                              for (var tree in selectedTrees) {
                                vm.addMember(
                                  TreeGroupMember(
                                    treeId: tree.id.toString(),
                                    treeName: tree.nameKr,
                                    keyCharacteristics:
                                        '', // Default empty, user edits later?
                                    imageUrl: tree.imageUrl,
                                    isAutoQuizEnabled: tree.isAutoQuizEnabled,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: NeoColors.acidLime,
                            size: 16,
                          ),
                          label: const Text(
                            '비교수목 추가',
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
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        child: child, // Preserve look during drag
                      );
                    },
                    itemBuilder: (context, index) {
                      final member = vm.members[index];
                      // Key is crucial for ReorderableListView
                      return _buildMemberItem(context, member, index, vm);
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    TreeGroupMember member,
    int index,
    TreeGroupEditViewModel vm,
  ) {
    return Container(
      key: ValueKey(member.treeId),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2518),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Drag handle removed as requested
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[800],
              image: member.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(member.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.treeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!member.isAutoQuizEnabled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          '비교전용',
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
                Text(
                  member.treeId, // Show ID or scientific name
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),
          IconButton(
            onPressed: () => vm.removeMember(index),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            tooltip: '제거',
          ),
        ],
      ),
    );
  }
}
