import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class TreeListStatsBar extends StatelessWidget {
  const TreeListStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeListViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF15281E),
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatInfo(count: vm.filteredTotalCount),
          _PaginationControls(vm: vm),
        ],
      ),
    );
  }
}

class _StatInfo extends StatelessWidget {
  final int count;
  const _StatInfo({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수목 현황',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '총 $count건',
          style: const TextStyle(
            color: NeoColors.acidLime,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final TreeListViewModel vm;
  const _PaginationControls({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PageIconButton(
            icon: Icons.first_page,
            onTap: vm.currentPage > 1 ? () => vm.setPage(1) : null,
          ),
          _PageIconButton(
            icon: Icons.chevron_left,
            onTap: vm.currentPage > 1 ? vm.previousPage : null,
          ),
          const SizedBox(width: 8),
          _PageNumberDisplay(current: vm.currentPage, total: vm.totalPages),
          const SizedBox(width: 8),
          _PageIconButton(
            icon: Icons.chevron_right,
            onTap: vm.currentPage < vm.totalPages ? vm.nextPage : null,
          ),
          _PageIconButton(
            icon: Icons.last_page,
            onTap: vm.currentPage < vm.totalPages ? () => vm.setPage(vm.totalPages) : null,
          ),
        ],
      ),
    );
  }
}

class _PageIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: onTap != null ? Colors.white : Colors.white12, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
    );
  }
}

class _PageNumberDisplay extends StatelessWidget {
  final int current;
  final int total;
  const _PageNumberDisplay({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    const primary = NeoColors.acidLime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

