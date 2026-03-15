import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeQuizConfig extends StatelessWidget {
  const AddTreeQuizConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();

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
                '퀴즈 오답 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeoColors.acidLime,
                ),
              ),
              _AutoQuizToggle(vm: vm),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.distractorControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return _DistractorField(index: index, controller: controller, vm: vm);
          }),
          const SizedBox(height: 8),
          _AddDistractorButton(vm: vm),
        ],
      ),
    );
  }
}

class _AutoQuizToggle extends StatelessWidget {
  final AddTreeViewModel vm;
  const _AutoQuizToggle({required this.vm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.setAutoQuizEnabled(!vm.isAutoQuizEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: vm.isAutoQuizEnabled ? NeoColors.acidLime : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              vm.isAutoQuizEnabled ? Icons.auto_awesome : Icons.edit_note,
              size: 12,
              color: vm.isAutoQuizEnabled ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              vm.isAutoQuizEnabled ? 'AI 자동' : '수동',
              style: TextStyle(
                color: vm.isAutoQuizEnabled ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistractorField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final AddTreeViewModel vm;

  const _DistractorField({
    required this.index,
    required this.controller,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('distractor_${index}_${controller.hashCode}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '오답 입력...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (vm.distractorControllers.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              onPressed: () => vm.removeDistractor(index),
              color: Colors.redAccent.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}

class _AddDistractorButton extends StatelessWidget {
  final AddTreeViewModel vm;
  const _AddDistractorButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: vm.addDistractor,
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('오답 추가'),
        style: OutlinedButton.styleFrom(
          foregroundColor: NeoColors.acidLime,
          side: const BorderSide(color: NeoColors.acidLime),
        ),
      ),
    );
  }
}
