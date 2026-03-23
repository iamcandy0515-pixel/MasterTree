import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/bulk_extraction_viewmodel.dart';
import './widgets/bulk_extraction/bulk_extraction_filter_panel.dart';
import './widgets/bulk_extraction/bulk_extraction_question_tabs.dart';
import './widgets/bulk_extraction/bulk_extraction_editor_form.dart';
import './widgets/bulk_extraction/bulk_extraction_header.dart';
import './widgets/bulk_extraction/bulk_extraction_progress_bar.dart';
import './widgets/bulk_extraction/bulk_extraction_status_overlay.dart';
import './widgets/bulk_extraction/bulk_extraction_empty_view.dart';

class BulkExtractionScreen extends StatefulWidget {
  const BulkExtractionScreen({super.key});

  @override
  State<BulkExtractionScreen> createState() => _BulkExtractionScreenState();
}

class _BulkExtractionScreenState extends State<BulkExtractionScreen> {
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  String? _completionMessage;
  bool _isSuccessShowing = false;
  int _selectedTabIndex = 1;
  int _currentExtracted = 0;
  int _totalToExtract = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _fileIdController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _wrongAnswerController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _fileIdController.dispose();
    _startController.dispose();
    _endController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    _wrongAnswerController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab(int qNum, int startNum) {
    if (!_scrollController.hasClients) return;
    final double targetOffset = (qNum - startNum) * 31.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double finalOffset = targetOffset - (screenWidth / 2) + 14.0;
    _scrollController.animateTo(
      finalOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateEditorFields(Map<String, dynamic>? data) {
    if (data == null) {
      _questionController.clear();
      _answerController.clear();
      _hintController.clear();
      _wrongAnswerController.clear();
    } else {
      _questionController.text = _getTextFromBlocks(data['question']);
      _answerController.text = _getTextFromBlocks(data['explanation']);
      _hintController.text = data['hint'] ?? '';
      _wrongAnswerController.text = data['wrong_answer'] ?? '';
    }
  }

  String _getTextFromBlocks(dynamic blocks) {
    if (blocks is! List) return blocks?.toString() ?? '';
    return blocks.where((b) => b['type'] == 'text').map((b) => b['content']?.toString() ?? '').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BulkExtractionViewModel(),
      child: Consumer<BulkExtractionViewModel>(
        builder: (context, vm, child) {
          _syncFilters(vm);
          return Scaffold(
            backgroundColor: backgroundDark,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: BulkExtractionHeader(
                vm: vm,
                onSaveResult: (stats) => _showResultDialog(context, stats),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    if (vm.isLoading && _totalToExtract > 0)
                      BulkExtractionProgressBar(
                        current: _currentExtracted,
                        total: _totalToExtract,
                        status: vm.statusMessage,
                        onCancel: vm.cancelExtraction,
                      ),
                    _buildFilterPanel(vm),
                    Expanded(
                      child: vm.extractedQuizzes.isEmpty ? const BulkExtractionEmptyView() : _buildEditor(vm),
                    ),
                  ],
                ),
                if (_isSuccessShowing)
                  BulkExtractionStatusOverlay(
                    message: _completionMessage ?? '',
                    onDismiss: () => setState(() => _isSuccessShowing = false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _syncFilters(BulkExtractionViewModel vm) {
    if (_fileIdController.text != vm.fileId && vm.fileId != null) _fileIdController.text = vm.fileId!;
    if (_startController.text != vm.startNumber.toString() && vm.startNumber > 0) _startController.text = vm.startNumber.toString();
    if (_endController.text != vm.endNumber.toString() && vm.endNumber > 0) _endController.text = vm.endNumber.toString();
  }

  Widget _buildFilterPanel(BulkExtractionViewModel vm) {
    return BulkExtractionFilterPanel(
      fileIdController: _fileIdController,
      startController: _startController,
      endController: _endController,
      subject: vm.subject,
      year: vm.year,
      round: vm.round,
      isLoading: vm.isLoading,
      isFilterComplete: vm.isFilterComplete,
      onFileIdChanged: (val) => vm.updateFilters(fileId: val),
      onSubjectChanged: (val) => vm.updateFilters(subject: val),
      onYearChanged: (val) => vm.updateFilters(year: int.tryParse(val ?? '')),
      onRoundChanged: (val) => vm.updateFilters(round: int.tryParse(val ?? '')),
      onStartChanged: (val) => vm.updateFilters(start: int.tryParse(val)),
      onEndChanged: (val) => vm.updateFilters(end: int.tryParse(val)),
      onExtractPressed: () {
        _currentExtracted = 0;
        _totalToExtract = (vm.endNumber - vm.startNumber + 1);
        vm.startBatchExtraction(
          onProgress: (cur, total) => setState(() => _currentExtracted = cur),
          onMessage: (msg) => _showFloatingMessage(context, msg),
        );
      },
    );
  }

  Widget _buildEditor(BulkExtractionViewModel vm) {
    return Column(
      children: [
        BulkExtractionQuestionTabs(
          startNumber: vm.startNumber,
          endNumber: vm.endNumber,
          selectedTabIndex: _selectedTabIndex,
          scrollController: _scrollController,
          extractedQuizzes: vm.extractedQuizzes,
          hasImage: vm.hasImage,
          onTabSelected: (qNum) {
            setState(() => _selectedTabIndex = qNum);
            _updateEditorFields(vm.extractedQuizzes[qNum]);
            _scrollToSelectedTab(qNum, vm.startNumber);
          },
        ),
        const Divider(height: 1, color: Colors.white10),
        Expanded(
          child: BulkExtractionEditorForm(
            selectedTabIndex: _selectedTabIndex,
            questionController: _questionController,
            answerController: _answerController,
            hintController: _hintController,
            wrongAnswerController: _wrongAnswerController,
            vm: vm,
          ),
        ),
      ],
    );
  }

  void _showResultDialog(BuildContext context, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text('DB 등록 결과', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('■ 총 문항: ${stats['total']}건', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('■ 성공: ${stats['success']}건', style: const TextStyle(color: Color(0xFF2BEE8C))),
            const SizedBox(height: 4),
            Text('■ 실패: ${stats['failed']}건', style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인', style: TextStyle(color: Color(0xFF2BEE8C)))),
        ],
      ),
    );
  }

  void _showFloatingMessage(BuildContext context, String message) {
    if (message.contains('완료') || message.contains('성공')) {
      setState(() {
        _completionMessage = message;
        _isSuccessShowing = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isSuccessShowing = false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          backgroundColor: surfaceDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
