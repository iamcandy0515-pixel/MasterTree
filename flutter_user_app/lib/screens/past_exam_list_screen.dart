import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/past_exam_list_controller.dart';
import 'past_exam/widgets/exam_filter_header.dart';
import 'past_exam/widgets/exam_quiz_card.dart';
import 'past_exam/widgets/exam_pagination_bar.dart';

class PastExamListScreen extends StatefulWidget {
  const PastExamListScreen({super.key});

  @override
  State<PastExamListScreen> createState() => _PastExamListScreenState();
}

class _PastExamListScreenState extends State<PastExamListScreen> {
  final PastExamListController _controller = PastExamListController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadSavedFilters(
        onUpdate: () => setState(() {}),
        onError: _onFetchError,
      );
    });
  }

  void _onFetchError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          '기출 / 학습',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ExamFilterHeader(
            selectedSubject: _controller.selectedSubject,
            selectedYear: _controller.selectedYear,
            selectedSession: _controller.selectedSession,
            subjects: _controller.subjects,
            years: _controller.years,
            sessions: _controller.sessions,
            onSubjectChanged: (val) => _controller.setSubject(
              val,
              onUpdate: () => setState(() {}),
              onError: _onFetchError,
            ),
            onYearChanged: (val) => _controller.setYear(
              val,
              onUpdate: () => setState(() {}),
              onError: _onFetchError,
            ),
            onSessionChanged: (val) => _controller.setSession(
              val,
              onUpdate: () => setState(() {}),
              onError: _onFetchError,
            ),
          ),
          if (_controller.hasSearched && !_controller.isLoading) _buildResultCount(),
          const Divider(color: Colors.white10, height: 1),
          if (!_controller.isLoading && _controller.hasSearched && _controller.quizzes.isNotEmpty)
            ExamPaginationBar(
              currentPage: _controller.currentPage,
              totalPages: _controller.totalPages,
              onFirstPage: () => _controller.firstPage(onUpdate: () => setState(() {}), onError: _onFetchError),
              onLastPage: () => _controller.lastPage(onUpdate: () => setState(() {}), onError: _onFetchError),
              onNextPage: () => _controller.nextPage(onUpdate: () => setState(() {}), onError: _onFetchError),
              onPrevPage: () => _controller.prevPage(onUpdate: () => setState(() {}), onError: _onFetchError),
            ),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            '검색 결과: 총 ${_controller.totalResults}건',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (!_controller.hasSearched) {
      return Center(
        child: Text(
          '조회 조건을 모두 선택하면 자동으로 목록이 표시됩니다.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_controller.quizzes.isEmpty) {
      return Center(
        child: Text(
          '조건에 맞는 기출문제가 없습니다.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = _controller.quizzes[index];
        return ExamQuizCard(
          quiz: quiz,
          questionText: _controller.extractQuestionText(quiz),
        );
      },
    );
  }
}
