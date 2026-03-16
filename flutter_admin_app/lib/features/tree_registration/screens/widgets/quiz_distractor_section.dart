import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/tree_registration/viewmodels/tree_registration_viewmodel.dart';

class QuizDistractorSection extends StatelessWidget {
  const QuizDistractorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeRegistrationViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. 퀴즈 오답 설정 (오답 2개)',
          style: TextStyle(
            color: Color(0xFF80F20D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...vm.distractorControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF80F20D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '오답 보기를 입력하세요.',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

