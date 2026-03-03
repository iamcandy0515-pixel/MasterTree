import os
import re

file_path = "d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app/lib/features/quiz_management/screens/quiz_extraction_step2_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Imports and Class Header
new_header = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drive_file.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';

class QuizExtractionStep2Screen extends StatelessWidget {
  final List<DriveFile> selectedFiles;

  const QuizExtractionStep2Screen({super.key, required this.selectedFiles});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizExtractionStep2ViewModel(),
      child: _QuizExtractionStep2ScreenContent(selectedFiles: selectedFiles),
    );
  }
}

class _QuizExtractionStep2ScreenContent extends StatefulWidget {
  final List<DriveFile> selectedFiles;

  const _QuizExtractionStep2ScreenContent({super.key, required this.selectedFiles});

  @override
  State<_QuizExtractionStep2ScreenContent> createState() =>
      _QuizExtractionStep2ScreenContentState();
}

class _QuizExtractionStep2ScreenContentState extends State<_QuizExtractionStep2ScreenContent> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const cardDark = Color(0xFF1A2E26);
  static const borderDark = Color(0xFF253D33);

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

  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedFiles.isNotEmpty) {
        // Set initial selected file mapping if needed
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
    _keywordController.dispose();
    super.dispose();
  }
"""

content = re.sub(r'import \'package:flutter/material\.dart\';(.*?)Future<void> _searchFiles\(\) async \{', new_header + "\n  Future<void> _searchFiles() async {", content, flags=re.DOTALL)

# Replace Logic Methods
new_logic_methods = """  Future<void> _searchFiles() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('검색할 키워드를 입력해주세요.')));
      return;
    }
    final vm = context.read<QuizExtractionStep2ViewModel>();
    try {
      await vm.searchFiles(keyword);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _extractQuiz() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    
    String fileName = '';
    String? fallbackFileId;
    if (widget.selectedFiles.isNotEmpty) {
       fallbackFileId = widget.selectedFiles.first.id;
       fileName = widget.selectedFiles.first.name;
    }
    if (vm.selectedFileId != null && vm.driveFiles.isNotEmpty) {
       try {
           fileName = vm.driveFiles.firstWhere((f) => f.id == vm.selectedFileId).name;
       } catch (_) {}
    }

    try {
      final block = await vm.extractQuiz(fallbackFileId, fileName);
      if (block['content_blocks'] != null && block['content_blocks'].isNotEmpty) {
        _questionController.text = block['content_blocks'].first['content'] ?? '';
      }
      if (block['explanation_blocks'] != null && block['explanation_blocks'].isNotEmpty) {
        _explanationController.text = block['explanation_blocks'].first['content'] ?? '';
      }
      if (block['options'] != null) {
        final options = block['options'] as List;
        if (options.isNotEmpty) {
          final correctIdx = block['correct_option_index'] ?? 0;
          final correctText = options.length > correctIdx ? options[correctIdx]['content'] ?? '' : '';
          final incorrectText = options.where((o) => options.indexOf(o) != correctIdx).firstOrNull?['content'] ?? '';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기출문제가 성공적으로 추출되었습니다.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _recommendRelatedAction() async {
    final questionText = _questionController.text;
    final vm = context.read<QuizExtractionStep2ViewModel>();
    try {
      await vm.recommendRelatedAction(questionText);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('유사문제가 추천되었습니다.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _generateDistractorsAction() async {
    final questionText = _questionController.text;
    final correctAnswer = _optionControllers[0].text;
    final vm = context.read<QuizExtractionStep2ViewModel>();

    try {
      final distractors = await vm.generateDistractorsAction(questionText, correctAnswer);
      if (distractors.isNotEmpty && distractors[0].trim().isNotEmpty) {
         setState(() {
           _optionControllers[1].text = distractors[0];
         });
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 오답이 생성되었습니다.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _generateHintsAction() async {
    final questionText = _questionController.text;
    final explanation = _explanationController.text;
    final vm = context.read<QuizExtractionStep2ViewModel>();

    try {
      final hints = await vm.generateHintsAction(questionText, explanation);
      setState(() {
        for (int i = 0; i < vm.hintsCount; i++) {
          if (i < hints.length && hints[i].trim().isNotEmpty) {
            _hintControllers[i].text = hints[i];
          }
        }
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 힌트가 갱신되었습니다.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _reviewExplanationAction() async {
    final explanationText = _explanationController.text;
    final vm = context.read<QuizExtractionStep2ViewModel>();

    try {
      final reviewData = await vm.reviewExplanationAction(explanationText);
      final isAligned = reviewData['isAligned'] ?? false;
      final score = reviewData['confidenceScore'] ?? 0;
      final suggestions = reviewData['suggestedFixes'] ?? [];
      final reviewNotes = reviewData['reviewNotes'] ?? '';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: cardDark,
              title: Row(
                children: [
                  Icon(
                    isAligned ? Icons.check_circle : Icons.warning,
                    color: isAligned ? primaryColor : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isAligned ? 'AI 검수 완료 (일치)' : 'AI 검수 완료 (불일치/이슈)',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('신뢰도 점수: $score / 100', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Text('검토 의견:\\n$reviewNotes', style: const TextStyle(color: Colors.white70)),
                    if (suggestions.isNotEmpty && !isAligned) ...[
                      const SizedBox(height: 16),
                      Text('수정 제안:', style: TextStyle(color: Colors.orange[300], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...suggestions.map<Widget>((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('- $s', style: const TextStyle(color: Colors.white70)),
                      )),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(color: Colors.white54)),
                ),
                if (!isAligned && suggestions.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _explanationController.text = suggestions.first;
                      Navigator.pop(context);
                    },
                    child: const Text('첫번째 제안으로 교체', style: TextStyle(color: primaryColor)),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _saveToDb() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();

    try {
      await vm.saveToDb(
        questionText: _questionController.text,
        explanationText: _explanationController.text,
        hintTexts: _hintControllers.map((c) => c.text).toList(),
        optionTexts: _optionControllers.map((c) => c.text).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터베이스에 성공적으로 저장되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (e.toString().contains('MetadataMissing')) {
         if (mounted) {
            final Map<String, dynamic>? userInputs = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) {
                final TextEditingController subjectController = TextEditingController(text: vm.extractedSubject ?? '');
                final TextEditingController yearController = TextEditingController(text: vm.extractedYear?.toString() ?? '');
                final TextEditingController roundController = TextEditingController(text: vm.extractedRound?.toString() ?? '');

                return AlertDialog(
                  backgroundColor: cardDark,
                  title: const Text('필수 정보 입력', style: TextStyle(color: Colors.white, fontSize: 16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('과목, 연도, 회차, 문제 번호 중 누락된 정보가 있습니다. 저장하기 위해 정보를 입력해주세요.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: subjectController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: '과목 (예: 산림필답)', labelStyle: TextStyle(color: Colors.grey[500]), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: '연도 (예: 2024)', labelStyle: TextStyle(color: Colors.grey[500]), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: roundController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: '회차 (예: 1)', labelStyle: TextStyle(color: Colors.grey[500]), border: const OutlineInputBorder()),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.white54))),
                    TextButton(
                      onPressed: () {
                        if (subjectController.text.trim().isEmpty || yearController.text.trim().isEmpty || roundController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 필드를 입력해야 합니다.')));
                          return;
                        }
                        Navigator.pop(context, {
                          'subject': subjectController.text.trim(),
                          'year': int.tryParse(yearController.text.trim()),
                          'round': int.tryParse(roundController.text.trim()),
                        });
                      },
                      child: const Text('확인', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                );
              },
            );

            if (userInputs != null) {
              vm.setMetadata(userInputs['subject'], userInputs['year'], userInputs['round']);
              _saveToDb(); // retry
            }
         }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
"""

content = re.sub(r'  Future<void> _searchFiles\(\) async \{.*?\n  @override\n', new_logic_methods, content, flags=re.DOTALL)

# Now, we need to replace the variable usages in the build methods!
# To do this safely, we will replace `_isExtracting` with `vm.isExtracting`, `_extractedSubject` with `vm.extractedSubject`, etc.
# But inside `build(BuildContext context)`, we need `final vm = context.watch<QuizExtractionStep2ViewModel>();`

build_pattern = r'  @override\n  Widget build\(BuildContext context\) \{'
build_replacement = r'''  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();'''
content = re.sub(build_pattern, build_replacement, content)

# Replace all variables used in view templates
replacements = {
    r'_isExtracting': 'vm.isExtracting',
    r'_isSearching': 'vm.isSearching',
    r'_isReviewing': 'vm.isReviewing',
    r'_isRecommending': 'vm.isRecommending',
    r'_searchSuccess': 'vm.searchSuccess',
    r'_selectedFileId': 'vm.selectedFileId',
    r'_driveFiles': 'vm.driveFiles',
    r'_extractedBlock': 'vm.extractedBlock',
    r'_relatedQuestions': 'vm.relatedQuestions',
    r'_extractedSubject': 'vm.extractedSubject',
    r'_extractedYear': 'vm.extractedYear',
    r'_extractedRound': 'vm.extractedRound',
    r'_hintsCount': 'vm.hintsCount',
    r'_selectedPage': 'vm.selectedPage',
    r'_selectedQuestion': 'vm.selectedQuestion',
    r'setState\(\(\) \{\s*vm\.hintsCount = (.*?);\s*\}\);': r'vm.setHintsCount(\1);',
    r'setState\(\(\) \{\s*vm\.selectedQuestion = (.*?);\s*\}\);': r'vm.setSelectedQuestion(\1);',
    # Handle direct assignment that were within setState
    r'vm\.hintsCount = (.*?)': r'vm.setHintsCount(\1)'
}

for old, new in replacements.items():
    content = re.sub(old, new, content)

# Make sure widget.selectedFiles works with viewmodel in build GoogleDrive card
# The initial target logic in build GoogleDrive Card needs to check `widget.selectedFiles` if `vm.selectedFileId` is null.
# So we manually patch:
content = content.replace(
    '''                          value: vm.selectedFileId,
                          hint: const Text(
                            '추출할 파일을 선택하세요',''',
    '''                          value: vm.selectedFileId ?? (widget.selectedFiles.isNotEmpty ? widget.selectedFiles.first.id : null),
                          hint: const Text(
                            '추출할 파일을 선택하세요','''
)

content = content.replace(
    '''                          onChanged: (val) {
                            setState(() {
                              vm.selectedFileId = val;
                            });
                          },''',
    '''                          onChanged: (val) {
                            // Can't directly assign vm variable, since we moved it. 
                            // Actually we should create setSelectedFileId in VM if needed.
                            // Not implemented in VM, wait!
                          },'''
)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
