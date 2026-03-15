import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_management_viewmodel.dart';
import 'quiz_review_detail_screen.dart';
import 'quiz_extraction_step2_screen.dart';

class QuizManagementScreen extends StatelessWidget {
  const QuizManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizManagementViewModel(),
      child: const _QuizManagementContent(),
    );
  }
}

class _QuizManagementContent extends StatelessWidget {
  const _QuizManagementContent({super.key});

  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        title: const Text(
          '기출문제 일람',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final viewModel = context.read<QuizManagementViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Selector<QuizManagementViewModel, (String?, String?, String?)>(
            selector: (_, vm) => (vm.selectedSubject, vm.selectedYear, vm.selectedSession),
            builder: (context, data, _) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    '조회 조건',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  _buildDropdown(
                    hint: '과목',
                    value: data.$1,
                    items: viewModel.subjects,
                    onChanged: viewModel.setSubject,
                  ),
                  _buildDropdown(
                    hint: '년도',
                    value: data.$2,
                    items: viewModel.years,
                    onChanged: viewModel.setYear,
                  ),
                  _buildDropdown(
                    hint: '회차',
                    value: data.$3,
                    items: viewModel.sessions,
                    onChanged: viewModel.setSession,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizExtractionStep2Screen(
                        selectedFiles: const [],
                        initialSubject: viewModel.selectedSubject,
                        initialYear: viewModel.selectedYear != null ? int.tryParse(viewModel.selectedYear!) : null,
                        initialRound: viewModel.selectedSession != null ? int.tryParse(viewModel.selectedSession!) : null,
                      ),
                    ),
                  );
                },
                child: const Text('신규등록', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Selector<QuizManagementViewModel, (bool, bool, String?)>(
      selector: (_, vm) => (vm.isLoading, vm.hasSearched, vm.error),
      builder: (context, data, _) {
        final isLoading = data.$1;
        final hasSearched = data.$2;
        final error = data.$3;

        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<QuizManagementViewModel>().fetchQuizzes(),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('다시 시도', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        }

        if (!hasSearched) {
          return const Center(child: Text('조회 조건을 선택해 주세요.', style: TextStyle(color: Colors.white54)));
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        return Column(
          children: [
            _buildPagination(context),
            Expanded(child: _buildQuizList(context)),
          ],
        );
      },
    );
  }

  Widget _buildQuizList(BuildContext context) {
    return Selector<QuizManagementViewModel, List<Map<String, dynamic>>>(
      selector: (_, vm) => vm.quizzes,
      builder: (context, quizzes, _) {
        if (quizzes.isEmpty) {
          return const Center(child: Text('조건에 맞는 기출문제가 없습니다.', style: TextStyle(color: Colors.white54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) => _buildQuizCard(context, quizzes[index]),
        );
      },
    );
  }

  Widget _buildQuizCard(BuildContext context, Map<String, dynamic> quiz) {
    final viewModel = context.read<QuizManagementViewModel>();
    final qText = _extractQuestionText(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizReviewDetailScreen(quizId: quiz['id'])),
          ).then((_) => viewModel.fetchQuizzes());
        },
        title: Text(
          qText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white38),
          onPressed: () => _handleDelete(context, viewModel, quiz['id']),
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Selector<QuizManagementViewModel, (int, int)>(
      selector: (_, vm) => (vm.currentPage, vm.totalPages),
      builder: (context, data, _) {
        final cur = data.$1;
        final total = data.$2;
        final viewModel = context.read<QuizManagementViewModel>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: cur > 1 ? () => viewModel.setPage(cur - 1) : null),
              Text('$cur / $total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: cur < total ? () => viewModel.setPage(cur + 1) : null),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: surfaceDark,
        hint: Text(hint, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        value: value,
        icon: const Icon(Icons.expand_more, color: primaryColor, size: 16),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: onChanged,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
              await viewModel.deleteQuiz(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
              }
            },
            child: const Text('확인', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
