import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'widgets/list_parts/tree_list_header.dart';
import 'widgets/list_parts/tree_list_search_bar.dart';
import 'widgets/list_parts/tree_list_category_filters.dart';
import 'widgets/list_parts/tree_list_stats_bar.dart';
import 'widgets/list_parts/tree_list_item.dart';

import 'package:flutter_admin_app/core/widgets/neo_error_state.dart';

class TreeListScreen extends StatelessWidget {
  const TreeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeListViewModel()..fetchTrees(),
      child: const _TreeListContent(),
    );
  }
}

class _TreeListContent extends StatelessWidget {
  const _TreeListContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeListViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF102219),
      body: SafeArea(
        child: Column(
          children: [
            const TreeListHeader(),
            const TreeListSearchBar(),
            const TreeListCategoryFilters(),
            const SizedBox(height: 8),
            const TreeListStatsBar(),
            Expanded(
              child: _buildBody(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TreeListViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: NeoColors.acidLime));
    }

    if (vm.errorMessage != null) {
      return NeoErrorState(
        message: vm.errorMessage!,
        onRetry: () => vm.fetchTrees(),
      );
    }

    return ListView.separated(
      itemCount: vm.trees.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) => TreeListItem(tree: vm.trees[index]),
    );
  }
}
