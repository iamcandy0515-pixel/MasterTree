import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_edit_viewmodel.dart';
import 'widgets/tree_group_info_section.dart';
import 'widgets/tree_group_member_list.dart';
import 'widgets/tree_group_preview_action.dart';

class TreeGroupEditScreen extends StatelessWidget {
  final TreeGroup? group;

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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<TreeGroupEditViewModel>();
    _titleController.text = vm.title;
    _descController.text = vm.description;

    if (vm.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchDetails(vm);
      });
    }
  }

  Future<void> _fetchDetails(TreeGroupEditViewModel vm) async {
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
      if (mounted) {
        scaffold.showSnackBar(const SnackBar(content: Text('그룹이 저장되었습니다.')));
        navigator.pop(true);
      }
    } else {
      if (mounted) {
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
        title: Text(vm.isEditing ? '비교 수목 상세' : '유사수목 그룹 등록'),
        actions: [
          TreeGroupPreviewAction(group: vm.toGroup()),
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
                  TreeGroupInfoSection(
                    titleController: _titleController,
                    descController: _descController,
                  ),
                  const SizedBox(height: 32),
                  const TreeGroupMemberList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
