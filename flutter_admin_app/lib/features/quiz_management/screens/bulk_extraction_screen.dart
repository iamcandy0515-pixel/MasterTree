import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/bulk_extraction_viewmodel.dart';
import './widgets/bulk_extraction/bulk_extraction_filter_panel.dart';
import './widgets/bulk_extraction/bulk_extraction_question_tabs.dart';
import './widgets/bulk_extraction/bulk_extraction_editor_form.dart';

class BulkExtractionScreen extends StatefulWidget {
  const BulkExtractionScreen({super.key});

  @override
  State<BulkExtractionScreen> createState() => _BulkExtractionScreenState();
}

class _BulkExtractionScreenState extends State<BulkExtractionScreen> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  String? _completionMessage;
  bool _isSuccessShowing = false;

  int _selectedTabIndex = 1;
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

  String _getTextFromBlocks(dynamic blocks) {
    if (blocks is! List) return blocks?.toString() ?? '';
    return blocks
        .where((b) => b['type'] == 'text')
        .map((b) => b['content']?.toString() ?? '')
        .join('\n');
  }

  void _updateEditorFields(Map<String, dynamic>? data) {
    if (data == null) {
      _questionController.text = '';
      _answerController.text = '';
      _hintController.text = '';
      _wrongAnswerController.text = '';
    } else {
      _questionController.text = _getTextFromBlocks(data['question']);
      _answerController.text = _getTextFromBlocks(data['explanation']);
      _hintController.text = data['hint'] ?? '';
      _wrongAnswerController.text = data['wrong_answer'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BulkExtractionViewModel(),
      child: Consumer<BulkExtractionViewModel>(
        builder: (context, vm, child) {
          // Sync controllers with ViewModel state
          if (_fileIdController.text != vm.fileId && vm.fileId != null) {
            _fileIdController.text = vm.fileId!;
          }
          if (_startController.text != vm.startNumber.toString() &&
              vm.startNumber > 0) {
            _startController.text = vm.startNumber.toString();
          }
          if (_endController.text != vm.endNumber.toString() &&
              vm.endNumber > 0) {
            _endController.text = vm.endNumber.toString();
          }

          return Scaffold(
            backgroundColor: backgroundDark,
            appBar: AppBar(
              backgroundColor: backgroundDark,
              elevation: 0,
              title: Text(
                '기출문제 추출(일괄)',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: vm.isLoading || vm.extractedQuizzes.isEmpty
                      ? null
                      : () => _showSaveConfirmDialog(context, vm),
                  icon: const Icon(
                    Icons.cloud_upload,
                    size: 18,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'DB등록',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.white10, height: 1),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    BulkExtractionFilterPanel(
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
                      onYearChanged: (val) =>
                          vm.updateFilters(year: int.tryParse(val ?? '')),
                      onRoundChanged: (val) =>
                          vm.updateFilters(round: int.tryParse(val ?? '')),
                      onStartChanged: (val) =>
                          vm.updateFilters(start: int.tryParse(val)),
                      onEndChanged: (val) =>
                          vm.updateFilters(end: int.tryParse(val)),
                      onExtractPressed: () => vm.startBatchExtraction(
                        onProgress: (current, total) {
                          if (current % 5 == 0 || current == total) {
                            _showFloatingMessage(
                              context,
                              '✅ $current / $total 문항 추출 완료',
                            );
                            if (vm.extractedQuizzes.containsKey(
                                  _selectedTabIndex,
                                ) &&
                                _questionController.text.isEmpty) {
                              _updateEditorFields(
                                vm.extractedQuizzes[_selectedTabIndex],
                              );
                            }
                          }
                        },
                        onMessage: (msg) => _showFloatingMessage(context, msg),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    Expanded(
                      child: vm.extractedQuizzes.isEmpty
                          ? _buildEmptyState()
                          : Column(
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
                                    _updateEditorFields(
                                      vm.extractedQuizzes[qNum],
                                    );
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
                                    wrongAnswerController:
                                        _wrongAnswerController,
                                    vm: vm,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
                if (vm.isLoading)
                  _buildCenterOverlay(vm.statusMessage, isProgress: true),
                if (_isSuccessShowing)
                  _buildCenterOverlay(
                    _completionMessage ?? '',
                    isProgress: false,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            '추출된 퀴즈가 없습니다.\nPDF를 추출해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterOverlay(String message, {required bool isProgress}) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isProgress
                  ? primaryColor.withValues(alpha: 0.5)
                  : Colors.white24,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProgress)
                const CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                )
              else
                const Icon(
                  Icons.check_circle_outline,
                  color: primaryColor,
                  size: 48,
                ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveConfirmDialog(
    BuildContext context,
    BulkExtractionViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text(
          '일괄 DB 등록',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          '편집한 모든 문항을 데이터베이스에 등록하시겠습니까?\n이미 등록된 문항은 업데이트됩니다.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('취소', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dctx);
              final stats = await vm.saveAllToDatabase(
                onProgress: (current, total) {},
                onMessage: (msg) => _showFloatingMessage(context, msg),
              );
              if (mounted) {
                _showResultDialog(context, 'DB 등록 결과', stats);
              }
            },
            child: const Text(
              '등록하기',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(
    BuildContext context,
    String title,
    Map<String, int> stats,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 총 문항: ${stats['total']}건',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              '• 성공: ${stats['success']}건',
              style: const TextStyle(color: primaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              '• 실패: ${stats['failed']}건',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: primaryColor)),
          ),
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
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: surfaceDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
