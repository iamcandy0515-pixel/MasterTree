import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

class OptionSelectorList extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final int correctIndex;
  final bool isAnswered;
  final Function(int) onSelect;

  const OptionSelectorList({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              '보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '반드시 보기를 선택 해야만 해설을 볼수 있습니다',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(options.length, (index) {
          final isCorrect = index == correctIndex;
          final isSelected = index == selectedIndex;

          Color bgColor = Colors.white.withOpacity(0.03);
          Color textColor = Colors.white70;
          Color borderColor = Colors.white10;
          FontWeight fontWeight = FontWeight.normal;

          if (isAnswered) {
            if (isCorrect) {
              bgColor = AppColors.primary.withOpacity(0.12);
              textColor = AppColors.primary;
              borderColor = AppColors.primary.withOpacity(0.3);
              fontWeight = FontWeight.bold;
            } else if (isSelected) {
              bgColor = Colors.red.withOpacity(0.12);
              textColor = Colors.redAccent;
              borderColor = Colors.redAccent.withOpacity(0.3);
              fontWeight = FontWeight.bold;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isAnswered && isCorrect
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: fontWeight,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: textColor,
                          fontWeight: fontWeight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isAnswered && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                    if (isAnswered && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: Colors.redAccent, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
