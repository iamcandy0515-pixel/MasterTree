import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import '../../../models/tree_group.dart';
import '../../../viewmodels/tree_group_management_viewmodel.dart';
import '../../tree_group_edit_screen.dart';

class TreeGroupListItem extends StatelessWidget {
  final TreeGroup group;
  final TreeGroupManagementViewModel vm;

  const TreeGroupListItem({super.key, required this.group, required this.vm});

  @override
  Widget build(BuildContext context) {
    final firstMember = group.members.isNotEmpty ? group.members[0] : null;
    final secondMember = group.members.length > 1 ? group.members[1] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TreeGroupEditScreen(group: group)),
          );
          vm.loadGroups();
        },
        onLongPress: () => _confirmDeletion(context), // Added Long Press delete as requested
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildThumbnails(firstMember, secondMember, group.members.length),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(firstMember, secondMember)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails(TreeGroupMember? m1, TreeGroupMember? m2, int count) {
    return SizedBox(
      width: 72,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildIconAvatar(Icons.park_rounded),
          ),
          if (count > 1)
            Positioned(
              left: 24,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: NeoTheme.darkTheme.scaffoldBackgroundColor,
                      width: 2),
                ),
                child: _buildIconAvatar(Icons.nature_rounded),
              ),
            ),
          if (count > 2)
            Positioned(
              left: 48,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: NeoTheme.darkTheme.scaffoldBackgroundColor,
                      width: 2),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: NeoColors.acidLime.withOpacity(0.2),
                  child: const Icon(Icons.more_horiz,
                      size: 16, color: NeoColors.acidLime),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconAvatar(IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: NeoColors.acidLime.withOpacity(0.1),
      child: Icon(icon, color: NeoColors.acidLime, size: 20),
    );
  }

  Widget _buildInfo(TreeGroupMember? m1, TreeGroupMember? m2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: m1?.treeName ?? 'A',
                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextSpan(
                text: ' vs ',
                style: GoogleFonts.notoSans(
                    fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
              TextSpan(
                text: m2?.treeName ?? 'B',
                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextSpan(
                text: ' (${group.members.length}건)',
                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: NeoColors.acidLime),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.info, color: NeoColors.acidLime, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                group.description,
                style: GoogleFonts.notoSans(fontSize: 12, color: NeoColors.acidLime, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2518),
        title: const Text('그룹 삭제', style: TextStyle(color: Colors.white)),
        content: Text(
          '\'${group.name}\' 그룹을 삭제하시겠습니까?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteGroup(group.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제되었습니다.')),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
