import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../core/design_system.dart';

class QuizContentRenderer extends StatelessWidget {
  final String content;

  const QuizContentRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.contains('\$\$') || content.contains('\$')) {
      List<Widget> spans = [];
      final parts = content.split('\$\$');
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1) {
          spans.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Math.tex(
                  parts[i],
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.yellowAccent,
                  ),
                ),
              ),
            ),
          );
        } else {
          final inlineParts = parts[i].split('\$');
          List<InlineSpan> inlineSpans = [];
          for (int j = 0; j < inlineParts.length; j++) {
            if (j % 2 == 1) {
              inlineSpans.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Math.tex(
                    inlineParts[j],
                    textStyle: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            } else {
              inlineSpans.add(TextSpan(text: inlineParts[j]));
            }
          }
          spans.add(
            Text.rich(
              TextSpan(
                children: inlineSpans,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spans,
      );
    } else {
      return Text(
        content,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          height: 1.6,
        ),
      );
    }
  }
}
