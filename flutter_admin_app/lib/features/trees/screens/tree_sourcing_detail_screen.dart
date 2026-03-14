import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_sourcing_viewmodel.dart';
import 'widgets/sourcing_category_section.dart';

class TreeSourcingDetailScreen extends StatefulWidget {
  final Tree tree;

  const TreeSourcingDetailScreen({super.key, required this.tree});

  @override
  State<TreeSourcingDetailScreen> createState() => _TreeSourcingDetailScreenState();
}

class _TreeSourcingDetailScreenState extends State<TreeSourcingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TreeSourcingViewModel>().initDetail(widget.tree);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TreeSourcingViewModel>(context);

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('수목 이미지 추출 상세'),
        actions: _buildAppBarActions(context, vm),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildTreeHeader(vm),
              SourcingCategorySection(vm: vm, type: 'main', label: '대표 이미지'),
              SourcingCategorySection(vm: vm, type: 'bark', label: '수피 (Bark)'),
              SourcingCategorySection(vm: vm, type: 'leaf', label: '잎 (Leaf)'),
              SourcingCategorySection(vm: vm, type: 'flower', label: '꽃 (Flower)'),
              SourcingCategorySection(vm: vm, type: 'fruit', label: '열매 / 겨울눈'),
            ],
          ),
          if (vm.isLoading)
            const Center(child: CircularProgressIndicator(color: NeoColors.acidLime)),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, TreeSourcingViewModel vm) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: TextButton(
          onPressed: vm.isLoading || !vm.hasChanges
              ? null
              : () => _handleSave(context, vm),
          style: TextButton.styleFrom(
            foregroundColor: NeoColors.acidLime,
          ),
          child: vm.isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: NeoColors.acidLime))
              : const Text('전체 저장', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    ];
  }

  Widget _buildTreeHeader(TreeSourcingViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.tree.nameKr,
            style: const TextStyle(color: NeoColors.acidLime, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: vm.isLoading ? null : () => vm.fetchFromDrive(),
            icon: const Icon(Icons.cloud_download, size: 16, color: NeoColors.acidLime),
            label: const Text('드라이브 추출', style: TextStyle(color: NeoColors.acidLime, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, TreeSourcingViewModel vm) async {
    try {
      await vm.saveChanges(
        onMessage: (msg) {
          if (context.mounted) {
            final isWarning = msg.contains('확인하세요');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: isWarning ? Colors.orange : Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (!isWarning) Navigator.pop(context, true);
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
