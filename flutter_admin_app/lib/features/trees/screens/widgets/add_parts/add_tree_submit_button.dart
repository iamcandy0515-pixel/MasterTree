import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isEditMode;

  const AddTreeSubmitButton({
    super.key,
    required this.formKey,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();
    return TextButton(
      onPressed: vm.isSubmitting ? null : () => _submit(context, vm),
      style: TextButton.styleFrom(
        backgroundColor: NeoColors.acidLime,
        foregroundColor: const Color(0xFF020402),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: vm.isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF020402),
              ),
            )
          : Text(
              isEditMode ? '수정' : '등록',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _submit(BuildContext context, AddTreeViewModel vm) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final success = await vm.submitTree();
      if (success && context.mounted) {
        if (isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('정보가 수정되었습니다.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          _showClearFormDialog(context, vm);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showClearFormDialog(BuildContext context, AddTreeViewModel vm) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('등록 완료', style: TextStyle(color: Colors.white)),
        content: const Text(
          '나무가 성공적으로 등록되었습니다.\n입력한 내용을 지우시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('유지'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('지우기'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      vm.clearForm();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성공적으로 등록되었습니다.'), backgroundColor: Colors.green),
      );
    }
  }
}
