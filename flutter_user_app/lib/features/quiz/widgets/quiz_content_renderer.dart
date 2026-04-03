import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/design_system.dart';

class QuizContentRenderer extends StatelessWidget {
  final dynamic content;

  const QuizContentRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: (content as List).map((block) => _buildBlock(block)).toList(),
      );
    }
    
    // Fallback for plain string content
    return _buildTextWithMath(content.toString());
  }

  Widget _buildBlock(dynamic block) {
    if (block is! Map) return const SizedBox.shrink();
    
    final type = block['type'] ?? 'text';
    final data = block['content'] ?? '';

    if (type == 'image') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: data,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.white10,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return _buildTextWithMath(data.toString());
  }

  Widget _buildTextWithMath(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    
    if (text.contains('\$\$') || text.contains('\$')) {
      List<Widget> widgets = [];
      final parts = text.split('\$\$');
      
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1) {
          widgets.add(_buildMathBlock(parts[i]));
        } else {
          widgets.add(_buildInlineText(parts[i]));
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      );
    }

    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 18,
        height: 1.6,
      ),
    );
  }

  Widget _buildMathBlock(String tex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Math.tex(
          tex,
          textStyle: const TextStyle(fontSize: 18, color: Colors.yellowAccent),
        ),
      ),
    );
  }

  Widget _buildInlineText(String text) {
    final inlineParts = text.split('\$');
    List<InlineSpan> spans = [];
    
    for (int j = 0; j < inlineParts.length; j++) {
      if (j % 2 == 1) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            inlineParts[j],
            textStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 16),
          ),
        ));
      } else {
        spans.add(TextSpan(text: inlineParts[j]));
      }
    }
    
    return Text.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          height: 1.6,
        ),
      ),
    );
  }
}
