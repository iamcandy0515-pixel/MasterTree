import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';
import '../screens/widgets/quiz_extraction/google_drive_search_module.dart';
import '../screens/widgets/quiz_extraction/pdf_extraction_module.dart';
import '../screens/widgets/quiz_extraction/quiz_extraction_data_form.dart';
import '../screens/widgets/quiz_extraction/quiz_extraction_sticky_header.dart';
import '../screens/widgets/quiz_extraction/quiz_extraction_filter_summary.dart';

class QuizExtractionStep2Screen extends StatelessWidget {
  final String? initialSubject;
  final int? initialYear;
  final int? initialRound;

  const QuizExtractionStep2Screen({
    super.key,
    this.initialSubject,
    this.initialYear,
    this.initialRound,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizExtractionStep2ViewModel()..init(
        subject: initialSubject,
        year: initialYear,
        round: initialRound,
      ),
      child: _QuizExtractionStep2ScreenContent(
        initialSubject: initialSubject,
        initialYear: initialYear,
        initialRound: initialRound,
      ),
    );
  }
}

class _QuizExtractionStep2ScreenContent extends StatefulWidget {
  final String? initialSubject;
  final int? initialYear;
  final int? initialRound;

  const _QuizExtractionStep2ScreenContent({
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
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _hintControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var c in _optionControllers) c.dispose();
    for (var c in _hintControllers) c.dispose();
    super.dispose();
  }

  void _validateFile() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    await vm.validateFile();
  }

  void _extractQuiz() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    await vm.extractQuiz();
    if (vm.extractedBlock != null) {
      _updateControllers(vm.extractedBlock!, vm);
    }
  }

  void _updateControllers(Map<String, dynamic> block, QuizExtractionStep2ViewModel vm) {
    try {
      _questionController.text = block['content_blocks']?.first['content'] ?? '';
      _explanationController.text = block['explanation'] ?? '';
      
      final options = block['options'] as List?;
      if (options != null) {
        for (int i = 0; i < options.length && i < _optionControllers.length; i++) {
          _optionControllers[i].text = options[i]['content'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error updating controllers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();
    const backgroundDark = Color(0xFF102219);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // 1. Content Area
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 72,
                left: 20, right: 20, bottom: 40,
              ),
              child: Column(
                children: [
                  // 🔥 [Bulletproof] Wrap Summary in safe wrapper
                  QuizExtractionFilterSummary(
                    subject: widget.initialSubject,
                    year: widget.initialYear,
                    round: widget.initialRound,
                  ),
                  const GoogleDriveSearchModule(),
                  const SizedBox(height: 16),
                  
                  // 🔥 [Bulletproof] PdfExtractionModule with hardened inputs
                  PdfExtractionModule(
                    onValidateFile: _validateFile,
                    onExtractQuiz: _extractQuiz,
                  ),
                  const SizedBox(height: 16),
                  
                  // 🔥 [Bulletproof] DataForm built only on clean data
                  if (vm.extractedBlock != null) ...[
                    QuizExtractionDataForm(
                      questionController: _questionController,
                      explanationController: _explanationController,
                      optionControllers: _optionControllers,
                      hintControllers: _hintControllers,
                    ),
                  ],
                ],
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
