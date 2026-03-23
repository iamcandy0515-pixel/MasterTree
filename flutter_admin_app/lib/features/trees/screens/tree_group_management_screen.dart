import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import '../viewmodels/tree_group_management_viewmodel.dart';
import 'widgets/management/management_header_section.dart';
import 'widgets/management/management_control_bar.dart';
import 'widgets/management/tree_group_list_item.dart';
import 'widgets/management/management_shimmer_loader.dart';

class TreeGroupManagementScreen extends StatelessWidget {
  const TreeGroupManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeGroupManagementViewModel(),
      child: const _TreeGroupListContent(),
    );
  }
}

class _TreeGroupListContent extends StatelessWidget {
  const _TreeGroupListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreeGroupManagementViewModel>();

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header & Search
            ManagementHeaderSection(vm: viewModel),

            // 2. Control Bar (Pagination, Add)
            ManagementControlBar(vm: viewModel),

            const SizedBox(height: 4),

            // 3. Main List
            Expanded(
              child: viewModel.isLoading
                  ? const ManagementShimmerLoader()
                  : _buildList(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(TreeGroupManagementViewModel vm) {
    if (vm.pagedGroups.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: vm.pagedGroups.length,
      itemBuilder: (context, index) {
        return TreeGroupListItem(group: vm.pagedGroups[index], vm: vm);
      },
    );
  }
}
