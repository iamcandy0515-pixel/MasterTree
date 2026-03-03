import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drive_file.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';
import 'widgets/quiz_extraction/1_google_drive_search_module.dart';
import 'widgets/quiz_extraction/2_pdf_extraction_module.dart';
import 'widgets/quiz_extraction/3_question_explanation_module.dart';
import 'widgets/quiz_extraction/4_distractor_module.dart';
import 'widgets/quiz_extraction/5_hint_module.dart';
import 'widgets/quiz_extraction/6_related_question_module.dart';
import 'widgets/quiz_extraction/7_db_registration_module.dart';

class QuizExtractionStep2Screen extends StatelessWidget {
  final List<DriveFile> selectedFiles;
  final String? initialSubject;
  final int? initialYear;
  final int? initialRound;

  const QuizExtractionStep2Screen({
    super.key,
    required this.selectedFiles,
    this.initialSubject,
    this.initialYear,
    this.initialRound,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizExtractionStep2ViewModel(),
      child: _QuizExtractionStep2ScreenContent(
        selectedFiles: selectedFiles,
        initialSubject: initialSubject,
        initialYear: initialYear,
        initialRound: initialRound,
      ),
    );
  }
}

class _QuizExtractionStep2ScreenContent extends StatefulWidget {
  final List<DriveFile> selectedFiles;
  final String? initialSubject;
  final int? initialYear;
  final int? initialRound;

  const _QuizExtractionStep2ScreenContent({
    super.key,
    required this.selectedFiles,
    this.initialSubject,
    this.initialYear,
    this.initialRound,
  });

  @override
  State<_QuizExtractionStep2ScreenContent> createState() =>
      _QuizExtractionStep2ScreenContentState();
}

class _QuizExtractionStep2ScreenContentState
    extends State<_QuizExtractionStep2ScreenContent> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _hintControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<QuizExtractionStep2ViewModel>();
      vm.setInitialFilter(
        widget.initialSubject,
        widget.initialYear,
        widget.initialRound,
      );
      if (widget.selectedFiles.isNotEmpty) {
        vm.setInitialFiles(widget.selectedFiles);
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _hintControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _validateFile() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    String? fallbackFileId;
    if (widget.selectedFiles.isNotEmpty) {
      fallbackFileId = widget.selectedFiles.first.id;
    }

    try {
      await vm.validateFile(fallbackFileId);
      if (mounted) {
        SnackBarUtil.showFloating(context, '파일 검증 성공! PDF 추출을 진행해주세요.');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.orangeAccent),
                SizedBox(width: 8),
                Text(
                  '검증 실패 / 불일치',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _extractQuiz() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      },
    );

    try {
      await vm.extractQuiz();
      final block = vm.populateExtractedQuiz();
      if (block['content_blocks'] != null &&
          block['content_blocks'].isNotEmpty) {
        _questionController.text =
            block['content_blocks'].first['content'] ?? '';
      }
      if (block['explanation_blocks'] != null &&
          block['explanation_blocks'].isNotEmpty) {
        _explanationController.text =
            block['explanation_blocks'].first['content'] ?? '';
      }
      if (block['options'] != null) {
        final options = block['options'] as List;
        if (options.isNotEmpty) {
          final correctIdx = block['correct_option_index'] ?? 0;
          final correctText = options.length > correctIdx
              ? options[correctIdx]['content'] ?? ''
              : '';
          final incorrectText =
              options
                  .where((o) => options.indexOf(o) != correctIdx)
                  .firstOrNull?['content'] ??
              '';

          _optionControllers[0].text = correctText;
          _optionControllers[1].text = incorrectText;
        }
      }
      if (block['hint_blocks'] != null) {
        final hints = block['hint_blocks'] as List;
        for (int i = 0; i < vm.hintsCount; i++) {
          if (i < hints.length) {
            _hintControllers[i].text = hints[i]['content'] ?? '';
          } else {
            _hintControllers[i].text = '';
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        SnackBarUtil.showFloating(context, '기출문제가 성공적으로 추출되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        SnackBarUtil.showFloating(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    56 +
                    12, // header + spacing
                bottom: 20, // removed footer padding
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.initialSubject != null ||
                        widget.initialYear != null ||
                        widget.initialRound != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          border: Border.all(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_list,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '검색필터:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (widget.initialSubject != null) ...[
                              Text(
                                widget.initialSubject!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.initialYear != null) ...[
                              Text(
                                '${widget.initialYear}년',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.initialRound != null)
                              Text(
                                '${widget.initialRound}회',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const GoogleDriveSearchModule(),
                    const SizedBox(height: 16),
                    PdfExtractionModule(
                      onValidateFile: _validateFile,
                      onExtractQuiz: _extractQuiz,
                    ),
                    const SizedBox(height: 16),
                    // UI of Extraction Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_note,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '추출 데이터 상세',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            DbRegistrationModule(
                              questionController: _questionController,
                              explanationController: _explanationController,
                              optionControllers: _optionControllers,
                              hintControllers: _hintControllers,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        QuestionAndExplanationModule(
                          questionController: _questionController,
                          explanationController: _explanationController,
                        ),
                        const SizedBox(height: 12),
                        DistractorModule(
                          questionController: _questionController,
                          optionControllers: _optionControllers,
                        ),
                        const SizedBox(height: 8),
                        HintModule(
                          questionController: _questionController,
                          explanationController: _explanationController,
                          hintControllers: _hintControllers,
                        ),
                        const SizedBox(height: 12),
                        RelatedQuestionModule(
                          questionController: _questionController,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 16,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: backgroundDark.withValues(alpha: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '기출문제 연동',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 36), // Balance the back button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
