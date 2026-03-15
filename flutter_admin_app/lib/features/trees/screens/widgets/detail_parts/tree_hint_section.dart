import 'package:flutter/material.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class TreeHintSection extends StatelessWidget {
  const TreeHintSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeDetailViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '부위별 힌트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NeoColors.acidLime,
              ),
            ),
            TextButton(
              onPressed: vm.isSaving ? null : () => vm.saveHints(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: vm.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: NeoColors.acidLime,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      '저장',
                      style: TextStyle(
                        color: NeoColors.acidLime,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildHintInput('대표 (main)', 'main', vm),
        _buildHintInput('수피와 가지 (bark)', 'bark', vm),
        _buildHintInput('잎 (leaf)', 'leaf', vm),
        _buildHintInput('꽃 (flower)', 'flower', vm),
        _buildHintInput('열매/겨울눈 (fruit/bud)', 'fruit', vm),
      ],
    );
  }

  Widget _buildHintInput(String label, String key, TreeDetailViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: vm.hintControllers[key],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '$label 힌트 입력...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
