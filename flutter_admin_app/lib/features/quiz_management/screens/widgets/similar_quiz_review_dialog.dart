import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/quiz_repository.dart';

class SimilarQuizReviewDialog extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final String? selectedYear;
  final String? selectedRound;
  final List<Map<String, dynamic>> initialRecommendations;
  final QuizRepository quizRepo;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const SimilarQuizReviewDialog({
    super.key,
    required this.quiz,
    this.selectedYear,
    this.selectedRound,
    required this.initialRecommendations,
    required this.quizRepo,
    required this.onUpdate,
  });

  @override
  State<SimilarQuizReviewDialog> createState() => _SimilarQuizReviewDialogState();
}

class _SimilarQuizReviewDialogState extends State<SimilarQuizReviewDialog> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);
  
  late List<Map<String, dynamic>> _recommendations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recommendations = List<Map<String, dynamic>>.from(widget.initialRecommendations);
    
    // If no session recommendations but has stored IDs, fetch them
    if (_recommendations.isEmpty) {
      final relatedIds = widget.quiz['related_quiz_ids'] as List?;
      if (relatedIds != null && relatedIds.isNotEmpty) {
        _fetchStoredRecommendations(relatedIds.cast<int>());
      }
    }
  }

  Future<void> _fetchStoredRecommendations(List<int> ids) async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('quiz_questions')
          .select('id, question_number, quiz_exams(year, round, title), quiz_categories(name), content_blocks')
          .filter('id', 'in', ids);

      if (mounted) {
        final List<Map<String, dynamic>> fetched = (response as List).map((item) {
          final exam = item['quiz_exams'] as Map<String, dynamic>?;
          final category = item['quiz_categories'] as Map<String, dynamic>?;
          
          return {
            'id': item['id'],
            'year': exam?['year'],
            'round': exam?['round'],
            'subject': category?['name'],
            'question_number': item['question_number'],
            'question': _getFullQuizText(item),
          };
        }).toList();

        // Sort by year/round desc
        fetched.sort((a, b) {
          final yearA = a['year'] ?? 0;
          final yearB = b['year'] ?? 0;
          if (yearA != yearB) return yearB.compareTo(yearA);
          final roundA = a['round'] ?? 0;
          final roundB = b['round'] ?? 0;
          return roundB.compareTo(roundA);
        });

        setState(() {
          _recommendations = fetched;
        });
        widget.onUpdate(_recommendations);
      }
    } catch (e) {
      debugPrint('Error fetching stored recommendations: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFullQuizText(Map<String, dynamic> quiz) {
    final blocks = quiz['content_blocks'] as List?;
    if (blocks == null || blocks.isEmpty) return '';

    return blocks
        .map((block) {
          if (block is Map<String, dynamic> && block['type'] == 'text') {
            return block['content']?.toString() ?? '';
          } else if (block is String) {
            return block.toString();
          }
          return '';
        })
        .where((text) => text.isNotEmpty)
        .join('\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceDark,
      title: Text(
        '${widget.selectedYear ?? ''}년 ${widget.selectedRound ?? ''}회 - Q${widget.quiz['question_number']}',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지문 요약',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _getFullQuizText(widget.quiz).replaceAll(RegExp(r'^\d+[\.\)]?\s*'), ''),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 3,
            ),
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '유사 문제 리스트',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_isLoading && _recommendations.isEmpty)
              const Text(
                '유사 문제가 없습니다.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _recommendations.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                  itemBuilder: (context, idx) {
                    final rec = _recommendations[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${rec['year'] ?? ''}년 ${rec['round'] ?? ''}회 ${rec['question_number'] ?? ''}번(${rec['subject'] ?? ''})',
                        style: const TextStyle(color: primaryColor, fontSize: 11),
                      ),
                      subtitle: Text(
                        (rec['question'] ?? '-').toString().replaceAll(RegExp(r'^\d+[\.\)]?\s*'), ''),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            _recommendations.removeAt(idx);
                          });
                          widget.onUpdate(_recommendations);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
