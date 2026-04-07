import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_lookalike_detail_screen.dart';

class TreeGroupPreviewAction extends StatelessWidget {
  final TreeGroup group;

  const TreeGroupPreviewAction({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => TreeLookalikeDetailScreen(group: group),
          ),
        );
      },
      icon: const Icon(Icons.visibility),
      tooltip: '미리보기',
      color: NeoColors.acidLime,
    );
  }
}
