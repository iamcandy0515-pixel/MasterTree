import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class GoogleDriveSearchModule extends StatefulWidget {
  final Function(dynamic file) onFileSelected;

  const GoogleDriveSearchModule({super.key, required this.onFileSelected});

  @override
  State<GoogleDriveSearchModule> createState() =>
      _GoogleDriveSearchModuleState();
}

class _GoogleDriveSearchModuleState extends State<GoogleDriveSearchModule> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    final vm = context.read<QuizExtractionStep2ViewModel>();
    setState(() => _isSearching = true);

    try {
      await vm.searchFiles(keyword);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);
    const primaryColor = Color(0xFF2BEE8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '구글 드라이브 파일 검색',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '검색어 입력 (예: 2024 나무의사)',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSearching ? null : _performSearch,
              icon: _isSearching
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : const Icon(Icons.search, color: primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vm.driveFiles.isNotEmpty)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: ListView.builder(
              itemCount: vm.driveFiles.length,
              itemBuilder: (context, index) {
                final file = vm.driveFiles[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  title: Text(
                    file.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => widget.onFileSelected(file),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                    size: 16,
                  ),
                );
              },
            ),
          )
        else if (!_isSearching && _searchController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                '검색 결과가 없습니다.',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
