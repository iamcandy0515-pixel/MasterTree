import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeBasicInfoSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const AddTreeBasicInfoSection({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();
    final isEditMode = vm.originalTree != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '기본 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeoColors.acidLime,
                ),
              ),
              _SubmitButton(formKey: formKey, vm: vm, isEditMode: isEditMode),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: vm.nameKrController,
            decoration: const InputDecoration(
              labelText: '한글 이름 (필수)',
              border: InputBorder.none,
              labelStyle: TextStyle(color: Colors.white54),
            ),
            validator: (v) => v == null || v.isEmpty ? '이름을 입력해주세요' : null,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white10),
          TextFormField(
            controller: vm.scientificNameController,
            decoration: const InputDecoration(
              labelText: '학명',
              border: InputBorder.none,
              labelStyle: TextStyle(color: Colors.white54),
            ),
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Divider(color: Colors.white10),
          Row(
            children: [
              _DropdownCategory(vm: vm),
              const SizedBox(width: 16),
              _DropdownDifficulty(vm: vm),
            ],
          ),
          const Divider(color: Colors.white10),
          TextFormField(
            controller: vm.descriptionController,
            decoration: const InputDecoration(
              hintText: '수목에 대한 상세 설명을 입력하세요.',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
              border: InputBorder.none,
              labelText: '수목 설명',
              labelStyle: TextStyle(color: Colors.white54),
            ),
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddTreeViewModel vm;
  final bool isEditMode;

  const _SubmitButton({
    required this.formKey,
    required this.vm,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: vm.isSubmitting ? null : () => _submit(context),
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

  Future<void> _submit(BuildContext context) async {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _DropdownCategory extends StatelessWidget {
  final AddTreeViewModel vm;
  const _DropdownCategory({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DropdownButtonFormField<String>(
        value: vm.selectedCategory,
        decoration: const InputDecoration(
          labelText: '구분 (필수)',
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.white54),
        ),
        dropdownColor: const Color(0xFF333333),
        items: ['침엽수', '활엽수']
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: vm.setSelectedCategory,
        validator: (v) => v == null ? '선택 필수' : null,
      ),
    );
  }
}

class _DropdownDifficulty extends StatelessWidget {
  final AddTreeViewModel vm;
  const _DropdownDifficulty({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DropdownButtonFormField<int>(
        value: vm.difficulty,
        decoration: const InputDecoration(
          labelText: '난이도 (1-5)',
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.white54),
        ),
        dropdownColor: const Color(0xFF333333),
        items: List.generate(5, (i) => i + 1)
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toString(), style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (v) => vm.setDifficulty(v ?? 1),
      ),
    );
  }
}
