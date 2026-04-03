import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';
import '../../../models/drive_file.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';

class GoogleDriveSearchModule extends StatefulWidget {
  const GoogleDriveSearchModule({super.key});

  @override
  State<GoogleDriveSearchModule> createState() =>
      _GoogleDriveSearchModuleState();
}

class _GoogleDriveSearchModuleState extends State<GoogleDriveSearchModule> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _searchFiles() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      SnackBarUtil.showFloating(context, '검색할 키워드를 입력해주세요.', isError: true);
      return;
    }
    
    final vm = context.read<QuizExtractionStep2ViewModel>();
    try {
      await vm.searchFiles(keyword);
      _keywordController.clear();
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '드라이브 검색 오류: $e', isError: true);
      }
    }
  }

  String _getSelectedFileName(List<DriveFile> files, String? selectedId) {
    if (files.isEmpty) return '선택된 파일이 없습니다.';
    
    try {
      final String targetId = selectedId ?? files.first.id;
      // Use where + firstOrElse for maximum release stability
      final matching = files.where((f) => f.id == targetId);
      return matching.isNotEmpty ? matching.first.name : files.first.name;
    } catch (e) {
      debugPrint('❌ [_getSelectedFileName] Fallback error: $e');
      return files.isNotEmpty ? files.first.name : '파일 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizExtractionStep2ViewModel>(
      builder: (context, vm, _) {
        // 🔥 [FTF] Safely extract list from ViewModel
        final List<DriveFile> files = vm.driveFiles.toList();
        final String? selectedId = vm.selectedFileId;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Icon(Icons.cloud, color: Colors.blueAccent, size: 20),
                  const Text(
                    '구글 드라이브 연동',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: vm.isSearching ? null : _searchFiles,
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: vm.isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                          )
                        : Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: const [
                              Icon(Icons.search, size: 16),
                              SizedBox(width: 4),
                              Text('드라이브 검색', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        onSubmitted: (_) => _searchFiles(),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '파일명 키워드 검색 (예: 산림기사_2013)',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: backgroundDark,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Use if check + list directly to avoid redundant builds
              if (files.isNotEmpty) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSelectedFileName(files, selectedId),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
