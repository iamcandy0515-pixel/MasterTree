import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeRegistrationViewModel>();
    const labelStyle = TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. 기본 정보',
          style: TextStyle(
            color: Color(0xFF80F20D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 수목명
        TextFormField(
          controller: vm.nameKrController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: _inputDecoration('수목명 (필수)', '예) 소나무'),
        ),
        const SizedBox(height: 16),

        // 학명
        TextFormField(
          controller: vm.scientificNameController,
          style: const TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
          decoration: _inputDecoration('학명', '예) Pinus densiflora'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // 구분
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('구분', style: labelStyle),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: vm.selectedCategory,
                    hint: const Text(
                      '선택 (필수)',
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                    dropdownColor: const Color(0xFF161B12),
                    style: const TextStyle(color: Colors.white),
                    decoration: _dropdownDecoration(),
                    items: ['침엽수', '활엽수']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: vm.setSelectedCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 성상
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('성상', style: labelStyle),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: vm.selectedHabit,
                    hint: const Text(
                      '선택 (필수)',
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                    dropdownColor: const Color(0xFF161B12),
                    style: const TextStyle(color: Colors.white),
                    decoration: _dropdownDecoration(),
                    items: ['상록수', '낙엽수']
                        .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                        .toList(),
                    onChanged: vm.setSelectedHabit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Colors.white10),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white10),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF80F20D)),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF161B12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
