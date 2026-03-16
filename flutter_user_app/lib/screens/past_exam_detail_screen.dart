import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/past_exam_detail_controller.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';

// Modular Widgets
import 'past_exam/widgets/exam_info_banner.dart';
import 'past_exam/widgets/quiz_content_card.dart';
import 'past_exam/widgets/option_selector_list.dart';
import 'past_exam/widgets/explanation_panel.dart';
import 'past_exam/widgets/related_quiz_section.dart';

class PastExamDetailScreen extends StatefulWidget {
  final int quizId;

  const PastExamDetailScreen({super.key, required this.quizId});

  @override
  State<PastExamDetailScreen> createState() => _PastExamDetailScreenState();
}

class _PastExamDetailScreenState extends State<PastExamDetailScreen> {
  final PastExamDetailController _controller = PastExamDetailController();

  // 이미지 영역 확장 상태
  bool _isQuestionExpanded = false;
  bool _isExplanationExpanded = false;

  @override
  void dispose() {
    ApiService.syncPendingAttempts();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.fetchQuizData(
      quizId: widget.quizId,
      onUpdate: () => setState(() {}),
      onError: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터 로딩 실패: $message')),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await ApiService.syncPendingAttempts();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: _buildAppBar(),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('기출 / 학습 상세'),
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () async {
          await ApiService.syncPendingAttempts();
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ApiService.syncPendingAttempts();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const UserStatsScreen(initialIndex: 2)),
            );
          },
          child: const Text(
            '학습통계',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 정보 배너
          ExamInfoBanner(
            subject: _controller.subject,
            year: _controller.year,
            round: _controller.round,
            questionNo: _controller.questionNo,
          ),
          const SizedBox(height: 20),

          // 2. 문제 영역
          QuizContentCard(
            contentBlocks: _controller.contentBlocks,
            isExpanded: _isQuestionExpanded,
            onToggleExpand: () => setState(() => _isQuestionExpanded = !_isQuestionExpanded),
          ),
          const SizedBox(height: 20),

          // 3. 보기 영역
          OptionSelectorList(
            options: _controller.options,
            selectedIndex: _controller.selectedOptionIndex,
            correctIndex: _controller.correctOptionIndex,
            isAnswered: _controller.isAnswered,
            onSelect: (index) => _controller.selectOption(index, onUpdate: () => setState(() {})),
          ),
          const SizedBox(height: 20),

          // 4. 해설 및 힌트 영역
          if (_controller.isAnswered)
            ExplanationPanel(
              explanationBlocks: _controller.explanationBlocks,
              hintText: _controller.hintText,
              isExpanded: _isExplanationExpanded,
              onToggleExpand: () =>
                  setState(() => _isExplanationExpanded = !_isExplanationExpanded),
            ),

          // 5. 유사문제 섹션
          RelatedQuizSection(similarQuizzes: _controller.similarQuizzes),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
