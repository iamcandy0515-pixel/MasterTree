import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class TreeBasicInfoSection extends StatelessWidget {
  const TreeBasicInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeDetailViewModel>();
    final tree = vm.tree;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NeoColors.acidLime,
              ),
            ),
            const SizedBox(width: 12),
            if (tree.category != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: NeoColors.acidLime),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tree.category!,
                  style: const TextStyle(
                    color: NeoColors.acidLime,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: vm.descController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.6,
          ),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '나무에 대한 기본 설명을 입력하세요..',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF1E2518),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: NeoColors.acidLime,
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

