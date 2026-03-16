import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class UnifiedExtractionHeader extends StatefulWidget {
  const UnifiedExtractionHeader({super.key});

  @override
  State<UnifiedExtractionHeader> createState() =>
      _UnifiedExtractionHeaderState();
}

class _UnifiedExtractionHeaderState extends State<UnifiedExtractionHeader> {
  final TextEditingController _fileSearchController = TextEditingController();
  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);
  static const backgroundDark = Color(0xFF102219);

  // 硫붿떆吏 ?곹깭 愿由?
  String _floatingMessage = '';

  @override
  void dispose() {
    _fileSearchController.dispose();
    super.dispose();
  }

  void _showLocalMessage(String message) {
    if (!mounted) return;
    setState(() {
      _floatingMessage = message;
    });
    // 2珥???硫붿떆吏 ?쒓굅
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _floatingMessage = '';
        });
      }
    });
  }

  void _showFloatingMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: primaryColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1?? ?뚯씪紐?諛뺤뒪
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.description, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fileSearchController,
                    onChanged: (val) => vm.searchFiles(val),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '?뚯씪紐??먮뒗 ?쒕씪?대툕 ID ?낅젰',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 2?? [怨쇰ぉ | ?곕룄 | ?뚯감] 媛濡??듯빀 ?꾪꽣
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropDown(
                    hint: '怨쇰ぉ',
                    value: vm.selectedSubject,
                    items: const ['?곕┝湲곗궗', '?곕┝?곗뾽湲곗궗'],
                    onChanged: (val) => vm.updateFilters(subject: val),
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '?곕룄',
                    value: vm.selectedYear?.toString(),
                    items: List.generate(14, (i) => (2013 + i).toString()),
                    onChanged: (val) =>
                        vm.updateFilters(year: int.tryParse(val ?? '')),
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '?뚯감',
                    value: vm.selectedRound?.toString(),
                    items: const ['1', '2', '3', '4'],
                    onChanged: (val) =>
                        vm.updateFilters(round: int.tryParse(val ?? '')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 3?? 臾몄젣踰덊샇 諛?踰꾪듉 ?곸뿭
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '臾몄젣踰덊샇:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCompactNumberBox(
                    value: vm.selectedQuestionNumber.toString(),
                    items: List.generate(15, (i) => (i + 1).toString()),
                    onChanged: (val) {
                      final qNum = int.tryParse(val ?? '1');
                      if (qNum != null) {
                        vm.updateFilters(questionNumber: qNum);
                      }
                    },
                  ),
                  const Spacer(),
                  // PDF 異붿텧 踰꾪듉
                  TextButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final fileId = _fileSearchController.text.trim();
                            if (fileId.isEmpty) {
                              _showFloatingMessage(context, '?뚯씪 ?뺣낫瑜??낅젰?댁＜?몄슂.');
                              return;
                            }

                            // 異붿텧 ?쒖옉 硫붿떆吏
                            _showLocalMessage('異붿텧 ?쒖옉');

                            await vm.startBatchExtractionAction(
                              fileId: fileId,
                              singleQuestionNumber: vm.selectedQuestionNumber,
                              onProgress: (current, total) {},
                              onMessage: (msg) {},
                            );

                            if (mounted) {
                              _showLocalMessage('異붿텧 ?꾨즺');
                            }
                          },
                    icon: const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: primaryColor,
                    ),
                    label: const Text(
                      'PDF 異붿텧',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: backgroundDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white10),
                      ),
                    ),
                  ),
                ],
              ),
              // 臾몄젣踰덊샇 ?꾨옒 ?뚮줈??硫붿떆吏 ?곸뿭
              AnimatedOpacity(
                opacity: _floatingMessage.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, left: 0),
                  child: SizedBox(
                    height: 16,
                    child: Text(
                      _floatingMessage,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white10,
    );
  }

  Widget _buildDropDown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        dropdownColor: const Color(0xFF161B22),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      ),
    );
  }

  Widget _buildCompactNumberBox({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: 60,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: Alignment.center,
              child: Text(
                item,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF161B22),
          icon: const SizedBox.shrink(),
          isDense: true,
        ),
      ),
    );
  }
}

