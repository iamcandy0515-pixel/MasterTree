import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import '../../../viewmodels/tree_group_management_viewmodel.dart';
import '../../tree_group_edit_screen.dart';

class ManagementControlBar extends StatelessWidget {
  final TreeGroupManagementViewModel vm;
  const ManagementControlBar({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfo(vm),
          if (vm.totalPages > 1) _buildPagination(vm),
          const Spacer(),
          _buildAddButton(context, vm),
        ],
      ),
    );
  }

  Widget _buildInfo(TreeGroupManagementViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '전체 (${vm.totalCount})',
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: NeoColors.acidLime,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(TreeGroupManagementViewModel vm) {
    return Row(
      children: [
        IconButton(
          onPressed: vm.currentPage > 1 ? vm.prevPage : null,
          iconSize: 18,
          icon: Icon(
            Icons.chevron_left,
            color: vm.currentPage > 1 ? NeoColors.acidLime : Colors.grey[700],
          ),
        ),
        Text(
          '${vm.currentPage} / ${vm.totalPages}',
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: vm.currentPage < vm.totalPages ? vm.nextPage : null,
          iconSize: 18,
          icon: Icon(
            Icons.chevron_right,
            color: vm.currentPage < vm.totalPages ? NeoColors.acidLime : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, TreeGroupManagementViewModel vm) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TreeGroupEditScreen()),
        );
        vm.loadGroups();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.add_circle, color: NeoColors.acidLime, size: 20),
            const SizedBox(width: 4),
            Text(
              '그룹 추가',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: NeoColors.acidLime,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
