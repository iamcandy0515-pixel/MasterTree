import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_lookalike_viewmodel.dart';
import 'widgets/lookalike/lookalike_comparison_matrix.dart';

class TreeLookalikeDetailScreen extends StatelessWidget {
  final TreeGroup group;
  const TreeLookalikeDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeLookalikeViewModel(initialGroup: group),
      child: const _TreeLookalikeDetailContent(),
    );
  }
}

class _TreeLookalikeDetailContent extends StatefulWidget {
  const _TreeLookalikeDetailContent();

  @override
  State<_TreeLookalikeDetailContent> createState() => _TreeLookalikeDetailContentState();
}

class _TreeLookalikeDetailContentState extends State<_TreeLookalikeDetailContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<TreeLookalikeViewModel>();
        if (vm.group != null) {
          vm.loadGroupDetail(vm.group!.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeLookalikeViewModel>();
    final group = vm.group;

    if (group == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF141811),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF80F20D))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141811),
      appBar: _buildAppBar(context, group.name),
      body: LookalikeComparisonMatrix(group: group, vm: vm),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
