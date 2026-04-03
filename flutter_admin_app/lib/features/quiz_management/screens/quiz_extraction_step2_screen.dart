import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drive_file.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';
import 'widgets/quiz_extraction/google_drive_search_module.dart';
import 'widgets/quiz_extraction/pdf_extraction_module.dart';
import 'widgets/quiz_extraction/quiz_extraction_sticky_header.dart';
import 'widgets/quiz_extraction/quiz_extraction_filter_summary.dart';
import 'widgets/quiz_extraction/quiz_extraction_data_form.dart';

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
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _hintControllers =
      List.generate(5, (_) => TextEditingController());

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
    for (var c in _optionControllers) {
      c.dispose();
    }
    for (var c in _hintControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _validateFile() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final fallbackId =
        widget.selectedFiles.isNotEmpty ? widget.selectedFiles.first.id : null;

    try {
      await vm.validateFile(fallbackId);
      if (mounted) SnackBarUtil.showFloating(context, '파일 검증 성공! PDF 추출 시작 가능.');
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('검증 실패 / 불일치', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(error, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Future<void> _extractQuiz() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    _showLoading();

    try {
      await vm.extractQuiz();
      final block = vm.populateExtractedQuiz();
      _updateControllers(block, vm);
      if (mounted) {
        Navigator.pop(context); // loading
        SnackBarUtil.showFloating(context, '기출문제가 성공적으로 추출되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // loading
        SnackBarUtil.showFloating(context, e.toString(), isError: true);
      }
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: primaryColor)),
    );
  }

  void _updateControllers(Map<String, dynamic> block, QuizExtractionStep2ViewModel vm) {
    if (block['content_blocks']?.isNotEmpty ?? false) {
      _questionController.text = block['content_blocks'].first['content'] ?? '';
    }
    if (block['explanation_blocks']?.isNotEmpty ?? false) {
      _explanationController.text = block['explanation_blocks'].first['content'] ?? '';
    }
    if (block['options'] != null) {
      final options = block['options'] as List;
      final correctIdx = block['correct_option_index'] ?? 0;
      
      // 1. Correct Option (always first controller)
      if (options.length > correctIdx) {
        _optionControllers[0].text = options[correctIdx]['content'] ?? '';
      }

      // 2. Incorrect Options (rest of controllers)
      final incorrect = options.where((o) => options.indexOf(o) != correctIdx).toList();
      for (int i = 0; i < 3; i++) {
        _optionControllers[i + 1].text = i < incorrect.length ? (incorrect[i]['content'] ?? '') : '';
      }
    }

    final hintBlocks = block['hint_blocks'] as List? ?? [];
    for (int i = 0; i < vm.hintsCount; i++) {
      _hintControllers[i].text = i < hintBlocks.length ? (hintBlocks[i]['content'] ?? '') : '';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // 1. Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 72,
                bottom: 24,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    QuizExtractionFilterSummary(
                      subject: widget.initialSubject,
                      year: widget.initialYear,
                      round: widget.initialRound,
                    ),
                    const GoogleDriveSearchModule(),
                    const SizedBox(height: 16),
                    PdfExtractionModule(
                      onValidateFile: _validateFile,
                      onExtractQuiz: _extractQuiz,
                    ),
                    const SizedBox(height: 16),
                    QuizExtractionDataForm(
                      questionController: _questionController,
                      explanationController: _explanationController,
                      optionControllers: _optionControllers,
                      hintControllers: _hintControllers,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Header (Glassmorphism Sticky)
          Positioned(
            top: 0, left: 0, right: 0,
            child: QuizExtractionStickyHeader(
              onBack: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
