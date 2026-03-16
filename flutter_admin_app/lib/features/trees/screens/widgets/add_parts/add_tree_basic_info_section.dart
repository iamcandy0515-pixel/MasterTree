import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'add_tree_submit_button.dart';

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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
              AddTreeSubmitButton(formKey: formKey, isEditMode: isEditMode),
            ],
          ),
          const SizedBox(height: 16),
          _NameInput(vm: vm),
          const Divider(color: Colors.white10),
          _ScientificNameInput(vm: vm),
          const Divider(color: Colors.white10),
          Row(
            children: [
              _DropdownCategory(vm: vm),
              const SizedBox(width: 16),
              _DropdownDifficulty(vm: vm),
            ],
          ),
          const Divider(color: Colors.white10),
          _DescriptionInput(vm: vm),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  final AddTreeViewModel vm;
  const _NameInput({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: vm.nameKrController,
      decoration: const InputDecoration(
        labelText: '한글 이름 (필수)',
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.white54),
      ),
      validator: (v) => v == null || v.isEmpty ? '이름을 입력해주세요' : null,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _ScientificNameInput extends StatelessWidget {
  final AddTreeViewModel vm;
  const _ScientificNameInput({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: vm.scientificNameController,
      decoration: const InputDecoration(
        labelText: '학명',
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  final AddTreeViewModel vm;
  const _DescriptionInput({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: vm.descriptionController,
      decoration: const InputDecoration(
        hintText: '수목에 대한 상세 설명을 입력하세요...',
        hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
        border: InputBorder.none,
        labelText: '수목 설명',
        labelStyle: TextStyle(color: Colors.white54),
      ),
      maxLines: 4,
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
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

