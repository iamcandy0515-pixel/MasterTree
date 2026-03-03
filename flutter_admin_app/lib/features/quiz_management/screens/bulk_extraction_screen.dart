import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/bulk_extraction_viewmodel.dart';
import '../widgets/image_manager_dialog.dart';

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

  int _selectedTabIndex = 1; // Default question number 1
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _fileIdController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _wrongAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab(int qNum, int startNum) {
    if (!_scrollController.hasClients) return;

    // 탭 너비(28) + 간격(3) = 31px
    final double targetOffset = (qNum - startNum) * 31.0;
    final double screenWidth = MediaQuery.of(context).size.width;

    // 중앙 배치 계산
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
          // 필터 대시보드에서 로드된 값이 있는 경우 컨트롤러 업데이트 (초기 1회)
          if (_fileIdController.text.isEmpty && vm.fileId != null) {
            _fileIdController.text = vm.fileId!;
          }
          if (_startController.text.isEmpty && vm.startNumber > 0) {
            _startController.text = vm.startNumber.toString();
          }
          if (_endController.text.isEmpty && vm.endNumber > 0) {
            _endController.text = vm.endNumber.toString();
          }
          return Scaffold(
            backgroundColor: backgroundDark,
            appBar: AppBar(
              backgroundColor: backgroundDark,
              elevation: 0,
              title: LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    constraints.maxWidth < 360 ? '일괄추출' : 'PDF 일괄 추출',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              actions: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact =
                        MediaQuery.of(context).size.width < 400;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: vm.isLoading || vm.extractedQuizzes.isEmpty
                              ? null
                              : () => _showSaveConfirmDialog(context, vm),
                          icon: const Icon(
                            Icons.cloud_upload,
                            size: 18,
                            color: Colors.white70,
                          ),
                          label: isCompact
                              ? const SizedBox.shrink()
                              : const Text(
                                  'DB등록',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 4),
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
                    _buildFilterArea(vm),
                    const Divider(height: 1, color: Colors.white10),
                    Expanded(
                      child: vm.extractedQuizzes.isEmpty
                          ? _buildEmptyState()
                          : _buildQuizList(vm),
                    ),
                  ],
                ),
                // 화면 중앙 플로팅 메시지 (로딩/진행 중일 때)
                if (vm.isLoading)
                  _buildCenterOverlay(vm.statusMessage, isProgress: true),
                // 완료 시 중앙 플로팅 메시지
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
                  ? primaryColor.withOpacity(0.5)
                  : Colors.white24,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
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
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildQuizList(BulkExtractionViewModel vm) {
    final currentData = vm.extractedQuizzes[_selectedTabIndex];
    return Column(
      children: [
        _buildQuestionTabs(vm),
        const Divider(height: 1, color: Colors.white10),
        Expanded(child: _buildEditingArea(vm, currentData)),
      ],
    );
  }

  Widget _buildFilterArea(BulkExtractionViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: surfaceDark.withOpacity(0.5),
      child: Column(
        children: [
          TextField(
            controller: _fileIdController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: '드라이브 파일 ID 또는 파일명',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              prefixIcon: const Icon(
                Icons.description,
                color: primaryColor,
                size: 18,
              ),
              filled: true,
              fillColor: surfaceDark,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => vm.updateFilters(fileId: val),
          ),
          const SizedBox(height: 8),
          // 필터 대시보드 - 정보 배너 스타일 적용
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropDown(
                    hint: '과목',
                    value: vm.subject,
                    items: const ['산림기사', '산림산업기사'],
                    onChanged: (val) => vm.updateFilters(subject: val),
                  ),
                ),
                _buildBannerDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '년도',
                    value: vm.year?.toString(),
                    items: List.generate(14, (i) => (2013 + i).toString()),
                    onChanged: (val) =>
                        vm.updateFilters(year: int.tryParse(val ?? '')),
                  ),
                ),
                _buildBannerDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '회차',
                    value: vm.round?.toString(),
                    items: const ['1', '2', '3', '4'],
                    onChanged: (val) =>
                        vm.updateFilters(round: int.tryParse(val ?? '')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 범위 및 추출 버튼 영역
          // 범위 및 추출 버튼 영역 (Wrap으로 변경하여 오버플로우 대응)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              // 범위 입력부 (Wrap으로 변경하여 오버플로우 대응)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text(
                    '범위:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  _buildNumberInput(
                    '시작',
                    _startController,
                    (val) => vm.updateFilters(start: int.tryParse(val)),
                  ),
                  const Text(
                    '~',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  _buildNumberInput(
                    '종료',
                    _endController,
                    (val) => vm.updateFilters(end: int.tryParse(val)),
                  ),
                ],
              ),
              // 추출 버튼
              TextButton.icon(
                onPressed: vm.isLoading || !vm.isFilterComplete
                    ? null
                    : () => vm.startBatchExtraction(
                        onProgress: (current, total) {
                          if (current % 5 == 0 || current == total) {
                            _showFloatingMessage(
                              context,
                              '✅ $current / $total 문항 추출 완료',
                            );
                            // 현재 선택된 탭의 데이터가 비어있었는데 추출된 경우 UI 업데이트
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
                icon: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: vm.isFilterComplete ? primaryColor : Colors.white24,
                ),
                label: Text(
                  'PDF 추출',
                  style: TextStyle(
                    color: vm.isFilterComplete ? Colors.white : Colors.white24,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: surfaceDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: vm.isFilterComplete
                          ? Colors.white10
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTabs(BulkExtractionViewModel vm) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: (vm.endNumber >= vm.startNumber && vm.startNumber > 0)
            ? (vm.endNumber - vm.startNumber + 1)
            : 0,
        itemBuilder: (context, index) {
          final qNum = vm.startNumber + index;
          final isSelected = _selectedTabIndex == qNum;
          final isExtracted = vm.extractedQuizzes.containsKey(qNum);
          final hasImage = vm.hasImage(qNum);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedTabIndex = qNum);
              _updateEditorFields(vm.extractedQuizzes[qNum]);
              _scrollToSelectedTab(qNum, vm.startNumber);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 3),
              width: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isExtracted ? surfaceDark : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.white10,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$qNum',
                    style: TextStyle(
                      color: isSelected
                          ? backgroundDark
                          : (isExtracted ? Colors.white : Colors.white24),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  if (hasImage)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Icon(
                        Icons.image,
                        size: 8,
                        color: isSelected
                            ? backgroundDark
                            : primaryColor.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditingArea(
    BulkExtractionViewModel vm,
    Map<String, dynamic>? data,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEditFieldWithImages(
            '문제',
            _questionController,
            (v) => vm.updateQuizContent(_selectedTabIndex, 'question', v),
            5,
            vm,
            'question',
          ),
          _buildEditFieldWithImages(
            '정답 및 해설',
            _answerController,
            (v) => vm.updateQuizContent(_selectedTabIndex, 'explanation', v),
            5,
            vm,
            'explanation',
          ),
          _buildEditField(
            '힌트',
            _hintController,
            (v) => vm.updateQuizContent(_selectedTabIndex, 'hint', v),
            3,
          ),
          _buildEditField(
            '오답 (대표)',
            _wrongAnswerController,
            (v) => vm.updateQuizContent(_selectedTabIndex, 'wrong_answer', v),
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildEditFieldWithImages(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    int lines,
    BulkExtractionViewModel vm,
    String field,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ImageManagerDialog(
                  viewModel: vm,
                  qNum: _selectedTabIndex,
                  field: field,
                ),
              ),
              icon: Icon(
                vm.hasImage(_selectedTabIndex, field)
                    ? Icons.image
                    : Icons.image_outlined,
                color: primaryColor,
                size: 18,
              ),
              label: Text(
                '이미지 관리${vm.hasImage(_selectedTabIndex, field) ? ' (첨부됨)' : ''}',
                style: const TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: lines,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    int lines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: lines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceDark,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
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
                onProgress: (current, total) {
                  // 진행바는 UI 상단에서 자동 갱신됨 (vm.isLoading 활용)
                },
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
        if (mounted) {
          setState(() => _isSuccessShowing = false);
        }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDropDown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4), // 패딩 축소 (8 -> 4)
      height: 44,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: surfaceDark,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: primaryColor,
            size: 20,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      width: 48,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBannerDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white10,
    );
  }
}
