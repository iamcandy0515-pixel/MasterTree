import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_management_viewmodel.dart';
import '../../quiz_review_detail_screen.dart';

class QuizListItem extends StatelessWidget {
  final Map<String, dynamic> quiz;
  const QuizListItem({super.key, required this.quiz});

  static const surfaceDark = Color(0xFF1A2E24);
  static const primaryColor = Color(0xFF2BEE8C);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QuizManagementViewModel>();
    final qText = _extractQuestionText(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizReviewDetailScreen(quizId: quiz['id'])),
          ).then((_) => viewModel.fetchQuizzes());
        },
        title: Text(
          qText,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
          onPressed: () => _handleDelete(context, viewModel, quiz['id']),
        ),
      ),
    );
  }

  String _extractQuestionText(Map<String, dynamic> quiz) {
    String qText = '문제 내용 없음';
    try {
      final blocks = quiz['content_blocks'];
      if (blocks != null && blocks is List && blocks.isNotEmpty) {
        final firstBlock = blocks[0];
        if (firstBlock is String) {
          qText = firstBlock;
        } else if (firstBlock is Map && firstBlock.containsKey('content')) {
          qText = firstBlock['content'] as String;
        }
        qText = qText.replaceFirst(RegExp(r'^\s*\d+[\.\s]+'), '').trim();
      }
    } catch (_) {}
    final qNum = quiz['question_number'];
    return qNum != null ? '$qNum번. $qText' : qText;
  }

  void _handleDelete(BuildContext context, QuizManagementViewModel viewModel, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text('삭제 확인', style: TextStyle(color: Colors.white)),
        content: const Text('정말 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await viewModel.deleteQuiz(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                }
              }
            },
            child: const Text('확인', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
