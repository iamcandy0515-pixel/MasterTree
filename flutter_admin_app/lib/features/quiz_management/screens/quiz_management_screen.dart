import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_management_viewmodel.dart';
import 'widgets/quiz_parts/quiz_filter_header.dart';
import 'widgets/quiz_parts/quiz_list_item.dart';
import 'widgets/quiz_parts/quiz_pagination_bar.dart';
import 'widgets/quiz_parts/quiz_empty_state.dart';
import 'widgets/quiz_parts/quiz_error_state.dart';

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
  const _QuizManagementContent();

  static const backgroundDark = Color(0xFF102219);
  static const primaryColor = Color(0xFF2BEE8C);

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
          child: Container(color: Colors.white.withOpacity(0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          const QuizFilterHeader(),
          Expanded(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Consumer<QuizManagementViewModel>(
      builder: (context, vm, _) {
        final isLoading = vm.isLoading;
        final hasSearched = vm.hasSearched;
        final error = vm.error;

        if (error != null) {
          return QuizErrorState(error: error);
        }

        if (!hasSearched) {
          return const QuizEmptyState(message: '조회 조건을 선택해 주세요');
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        return Column(
          children: [
            const QuizPaginationBar(),
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
          return const QuizEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) => QuizListItem(quiz: quizzes[index]),
        );
      },
    );
  }
}

