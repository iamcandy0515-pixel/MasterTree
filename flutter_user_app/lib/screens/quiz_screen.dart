import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/viewmodels/quiz_viewmodel.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'widgets/quiz_parts/quiz_header.dart';
import 'widgets/quiz_parts/quiz_image_display.dart';
import 'widgets/quiz_parts/quiz_hint_toolbar.dart';
import 'widgets/quiz_parts/quiz_options_list.dart';
import 'widgets/quiz_parts/quiz_action_footer.dart';
import 'widgets/quiz_parts/quiz_feedback_overlays.dart';

/// Main Quiz Screen (Refactored Strategy: Load Balancing & Partial Rebuilds)
/// Optimized to minimize total-screen rebuilds via Selectors.
/// Adheres to DEVELOPMENT_RULES.md (<200 lines).
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizViewModel()..initialize(),
      child: const _QuizScreenContent(),
    );
  }
}

class _QuizScreenContent extends StatefulWidget {
  const _QuizScreenContent();

  @override
  State<_QuizScreenContent> createState() => _QuizScreenContentState();
}

class _QuizScreenContentState extends State<_QuizScreenContent> {
  @override
  void dispose() {
    ApiService.syncPendingAttempts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strategy: Partial Content Selection
    return WillPopScope(
      onWillPop: () async {
        await ApiService.syncPendingAttempts();
        return true;
      },
      child: Selector<QuizViewModel, bool>(
        selector: (_, vm) => vm.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.backgroundDark,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return child!;
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            children: [
              Column(
                children: [
                  const QuizHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          
                          // Question-Specific Rebuilds
                          Selector<QuizViewModel, String>(
                            selector: (_, vm) => vm.currentQuestion.imageUrl,
                            builder: (context, imageUrl, _) {
                              return QuizImageDisplay(imageUrl: imageUrl);
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          const QuizHintToolbar(),
                          const SizedBox(height: 12),
                          const QuizActionFooter(),
                          const SizedBox(height: 16),
                          const QuizOptionsList(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const QuizFeedbackOverlays(),
            ],
          ),
        ),
      ),
    );
  }
}
