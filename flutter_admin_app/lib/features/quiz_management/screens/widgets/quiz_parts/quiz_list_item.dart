import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/quiz_management_viewmodel.dart';
import '../../quiz_review_detail_screen.dart';

class QuizListItem extends StatelessWidget {
  final Map<String, dynamic> quiz;
  const QuizListItem({super.key, required this.quiz});

  static const surfaceDark = Color(0xFF1A2E24);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QuizManagementViewModel>();
    final qText = _extractQuestionText(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceDark,
            surfaceDark.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizReviewDetailScreen(quizId: quiz['id'])),
              ).then((_) => viewModel.fetchQuizzes());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: NeoColors.error, size: 22),
                    onPressed: () => _handleDelete(context, viewModel, quiz['id']),
                    style: IconButton.styleFrom(
                      backgroundColor: NeoColors.error.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('삭제 확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('정말 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await viewModel.deleteQuiz(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기출문제가 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: NeoColors.error, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
