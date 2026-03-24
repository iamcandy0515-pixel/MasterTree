import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/bulk_extraction_viewmodel.dart';
import '../utils/bulk_text_utils.dart'; // New Utility
import './widgets/bulk_extraction/bulk_extraction_filter_panel.dart';
import './widgets/bulk_extraction/bulk_extraction_header.dart';
import './widgets/bulk_extraction/bulk_extraction_progress_bar.dart';
import './widgets/bulk_extraction/bulk_extraction_status_overlay.dart';
import './widgets/bulk_extraction/bulk_extraction_empty_view.dart';
import './parts/bulk_extraction_result_dialog.dart';
import './parts/bulk_extraction_editor_section.dart';

/// Bulk Extraction Screen (Refactored Strategy: Processing Logic Split)
/// Manages PDF-to-Quiz batch extraction operations.
/// Adheres to DEVELOPMENT_RULES.md (<200 lines).
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
    for (var c in [
      _scrollController, _fileIdController, _startController, _endController,
      _questionController, _answerController, _hintController, _wrongAnswerController
    ]) { c.dispose(); }
    super.dispose();
  }

  void _scrollToSelectedTab(int qNum, int startNum) {
    if (!_scrollController.hasClients) return;
    final double targetOffset = (qNum - startNum) * 31.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    _scrollController.animateTo(
      (targetOffset - (screenWidth / 2) + 14.0).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateEditorFields(Map<String, dynamic>? data) {
    final fields = BulkTextUtils.mapToEditorFields(data);
    _questionController.text = fields['question']!;
    _answerController.text = fields['answer']!;
    _hintController.text = fields['hint']!;
    _wrongAnswerController.text = fields['wrong']!;
  }

  void _syncFilters(BulkExtractionViewModel vm) {
    if (_fileIdController.text != vm.fileId && vm.fileId != null) _fileIdController.text = vm.fileId!;
    if (_startController.text != vm.startNumber.toString() && vm.startNumber > 0) _startController.text = vm.startNumber.toString();
    if (_endController.text != vm.endNumber.toString() && vm.endNumber > 0) _endController.text = vm.endNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BulkExtractionViewModel(),
      child: Consumer<BulkExtractionViewModel>(
        builder: (context, vm, _) {
          _syncFilters(vm);
          return Scaffold(
            backgroundColor: backgroundDark,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: BulkExtractionHeader(vm: vm, onSaveResult: (stats) => _showResult(stats)),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    if (vm.isLoading && _totalToExtract > 0)
                      BulkExtractionProgressBar(
                        current: _currentExtracted, total: _totalToExtract, 
                        status: vm.statusMessage, onCancel: vm.cancelExtraction,
                      ),
                    _buildFilterPanel(vm),
                    Expanded(
                      child: vm.extractedQuizzes.isEmpty 
                          ? const BulkExtractionEmptyView() 
                          : _buildEditorSection(vm),
                    ),
                  ],
                ),
                if (_isSuccessShowing) _buildStatusOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel(BulkExtractionViewModel vm) {
    return BulkExtractionFilterPanel(
      fileIdController: _fileIdController, startController: _startController, endController: _endController,
      subject: vm.subject, year: vm.year, round: vm.round,
      isLoading: vm.isLoading, isFilterComplete: vm.isFilterComplete,
      onFileIdChanged: (v) => vm.updateFilters(fileId: v),
      onSubjectChanged: (v) => vm.updateFilters(subject: v),
      onYearChanged: (v) => vm.updateFilters(year: int.tryParse(v ?? '')),
      onRoundChanged: (v) => vm.updateFilters(round: int.tryParse(v ?? '')),
      onStartChanged: (v) => vm.updateFilters(start: int.tryParse(v)),
      onEndChanged: (v) => vm.updateFilters(end: int.tryParse(v)),
      onExtractPressed: () => _handleExtraction(vm),
    );
  }

  void _handleExtraction(BulkExtractionViewModel vm) {
    _currentExtracted = 0;
    _totalToExtract = (vm.endNumber - vm.startNumber + 1);
    vm.startBatchExtraction(
      onProgress: (cur, total) => setState(() => _currentExtracted = cur),
      onMessage: (msg) => _showFloatingMessage(context, msg),
    );
  }

  Widget _buildEditorSection(BulkExtractionViewModel vm) {
    return BulkExtractionEditorSection(
      vm: vm, selectedTabIndex: _selectedTabIndex,
      scrollController: _scrollController, questionController: _questionController,
      answerController: _answerController, hintController: _hintController,
      wrongAnswerController: _wrongAnswerController,
      onTabSelected: (q) {
        setState(() => _selectedTabIndex = q);
        _updateEditorFields(vm.extractedQuizzes[q]);
        _scrollToSelectedTab(q, vm.startNumber);
      },
    );
  }

  Widget _buildStatusOverlay() {
    return BulkExtractionStatusOverlay(
      message: _completionMessage ?? '', 
      onDismiss: () => setState(() => _isSuccessShowing = false),
    );
  }

  void _showResult(Map<String, int> stats) {
    showDialog(context: context, builder: (_) => BulkExtractionResultDialog(stats: stats, surfaceDark: surfaceDark));
  }

  void _showFloatingMessage(BuildContext context, String msg) {
    if (msg.contains('완료') || msg.contains('성공')) {
      setState(() { _completionMessage = msg; _isSuccessShowing = true; });
      Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _isSuccessShowing = false); });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: Colors.white)), 
        backgroundColor: surfaceDark, behavior: SnackBarBehavior.floating),
      );
    }
  }
}
