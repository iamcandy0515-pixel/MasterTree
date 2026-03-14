import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import '../viewmodels/add_tree_viewmodel.dart';

class AddTreeScreen extends StatelessWidget {
  final Tree? tree;
  const AddTreeScreen({super.key, this.tree});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTreeViewModel(tree),
      child: const _AddTreeContent(),
    );
  }
}

class _AddTreeContent extends StatefulWidget {
  const _AddTreeContent();

  @override
  State<_AddTreeContent> createState() => _AddTreeContentState();
}

class _AddTreeContentState extends State<_AddTreeContent> {
  AddTreeViewModel get _viewModel => context.watch<AddTreeViewModel>();
  AddTreeViewModel get _readViewModel => context.read<AddTreeViewModel>();

  final _formKey = GlobalKey<FormState>();

  // Image Type Selection (UI metadata)
  final Map<String, String> _imageTypeLabels = {
    'main': '대표 사진',
    'leaf': '잎',
    'bark': '나무껍질(수피)',
    'flower': '꽃',
    'fruit': '열매/겨울눈',
    'full': '전체 전경',
  };

  // Design Constants (Synced with TreeDetailScreen)
  static const primaryColor = Color(0xFF80F20D);
  static const backgroundDark = Color(0xFF0A0C08);
  static const surfaceDark = Color(0xFF161B12);
  static const textGrey = Color(0xFF94A3B8);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode _uploadBoxFocusNode = FocusNode();
  bool _isDragging = false;
  late String _dropZoneViewId;

  @override
  void initState() {
    super.initState();
    // Register Drop Zone View Factory (Unique per instance)
    _dropZoneViewId =
        'upload-drop-zone-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      WebUtils.registerViewFactory(_dropZoneViewId, (int viewId) {
        return WebUtils.createDropZoneElement(
          onDragOver: () {
            if (!_isDragging) {
              setState(() => _isDragging = true);
            }
          },
          onDragLeave: () {
            if (_isDragging) {
              setState(() => _isDragging = false);
            }
          },
          onDrop: (files) async {
            setState(() => _isDragging = false);
            if (files != null && files.isNotEmpty) {
              final file = files[0];
              // On web, file.type is available
              if ((file as dynamic).type.startsWith('image/')) {
                try {
                  await _readViewModel.handleDroppedFiles(file);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('이미지가 성공적으로 업로드되었습니다!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('업로드 실패: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            }
          },
          onClick: () {
            _uploadBoxFocusNode.requestFocus();
            if (!_readViewModel.isUploading) {
              _pickAndUploadImage();
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _uploadBoxFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      await _readViewModel.pickAndUploadImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지가 성공적으로 업로드되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pasteImageFromClipboard() async {
    try {
      await _readViewModel.pasteImageFromClipboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('클립보드 이미지가 성공적으로 업로드되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('붙여넣기 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('나무 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '정말로 이 나무 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTree();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTree() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await _readViewModel.submitTree();
      if (success && mounted) {
        final isEditMode = _readViewModel.originalTree != null;
        if (isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('나무 정보가 성공적으로 수정되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          final shouldClear = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text('등록 완료', style: TextStyle(color: Colors.white)),
              content: const Text(
                '나무가 성공적으로 등록되었습니다.\n입력한 내용을 지우시겠습니까?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('유지'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('지우기'),
                ),
              ],
            ),
          );

          if (shouldClear == true) {
            _readViewModel.clearForm();
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('나무가 성공적으로 등록되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteTree() async {
    if (_readViewModel.originalTree == null) return;
    try {
      await _readViewModel.deleteTree();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('나무가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _viewModel.originalTree != null;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundDark,
      endDrawer: Drawer(
        width: 450,
        backgroundColor: backgroundDark,
        child: _buildMobilePreview(),
      ),
      appBar: AppBar(
        title: Text(isEditMode ? '나무 정보 수정' : '새 나무 등록'),
        backgroundColor: backgroundDark,
        actions: [
          TextButton.icon(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.smartphone, size: 14, color: primaryColor),
            label: const Text(
              '미리보기',
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          if (isEditMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _confirmDelete,
              tooltip: '이나무 삭제',
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          children: [
            // 1. Basic Info Section
            _buildSection(
              context,
              title: '기본 정보',
              action: TextButton(
                onPressed: _viewModel.isSubmitting ? null : _submitTree,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: const Color(0xFF020402),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _viewModel.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF020402),
                        ),
                      )
                    : Text(
                        isEditMode ? '수정' : '등록',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _viewModel.nameKrController,
                    decoration: const InputDecoration(
                      labelText: '한글 이름 (필수)',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? '이름을 입력해주세요' : null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  TextFormField(
                    controller: _viewModel.scientificNameController,
                    decoration: const InputDecoration(
                      labelText: '학명',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<String>(
                          initialValue: _viewModel.selectedCategory,
                          decoration: const InputDecoration(
                            labelText: '구분 (필수)',
                            border: InputBorder.none,
                          ),
                          dropdownColor: const Color(0xFF333333),
                          items: ['침엽수', '활엽수']
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _viewModel.setSelectedCategory,
                          validator: (v) => v == null ? '선택 필수' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          initialValue: _viewModel.difficulty,
                          decoration: const InputDecoration(
                            labelText: '난이도 (1-5)',
                            border: InputBorder.none,
                          ),
                          dropdownColor: const Color(0xFF333333),
                          items: List.generate(5, (i) => i + 1)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => _viewModel.setDifficulty(v ?? 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Tree Description Section
            _buildSection(
              context,
              title: '수목 설명',
              child: TextFormField(
                controller: _viewModel.descriptionController,
                decoration: const InputDecoration(
                  hintText: '수목에 대한 상세 설명을 입력하세요.',
                  border: InputBorder.none,
                  filled: false,
                ),
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Image Section
            _buildSection(
              context,
              title: '수목 이미지',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _viewModel.selectedImageType,
                    decoration: const InputDecoration(
                      labelText: '이미지 구분',
                      border: InputBorder.none,
                    ),
                    dropdownColor: const Color(0xFF333333),
                    items: _imageTypeLabels.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        _viewModel.setSelectedImageType(v ?? 'main'),
                  ),
                  const SizedBox(height: 12),
                  Focus(
                    focusNode: _uploadBoxFocusNode,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent) {
                          final isCtrlPressed =
                              HardwareKeyboard.instance.isControlPressed;
                          final isCmdPressed =
                              HardwareKeyboard.instance.isMetaPressed;
                          final isVPressed =
                              event.logicalKey == LogicalKeyboardKey.keyV;
                          if ((isCtrlPressed || isCmdPressed) && isVPressed) {
                            _pasteImageFromClipboard();
                          }
                        }
                      },
                      child: Builder(
                        builder: (context) {
                          return Stack(
                            children: [
                              if (kIsWeb)
                                SizedBox(
                                  height: 100,
                                  child: HtmlElementView(
                                    viewType: _dropZoneViewId,
                                  ),
                                ),
                              IgnorePointer(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          _isDragging ||
                                              _uploadBoxFocusNode.hasFocus
                                          ? const Color(0xFFCCFF00)
                                          : Colors.white10,
                                      width:
                                          _isDragging ||
                                              _uploadBoxFocusNode.hasFocus
                                          ? 2
                                          : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        _isDragging ||
                                            _uploadBoxFocusNode.hasFocus
                                        ? const Color(
                                            0xFFCCFF00,
                                          ).withOpacity(0.05)
                                        : Colors.white.withOpacity(0.02),
                                  ),
                                  child: _viewModel.isUploading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFCCFF00),
                                          ),
                                        )
                                      : Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                color: _isDragging
                                                    ? const Color(0xFFCCFF00)
                                                    : Colors.white38,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _isDragging
                                                    ? '여기에 놓으세요'
                                                    : '클릭/드래그/붙여넣기 업로드',
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (_viewModel.uploadedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: _viewModel.uploadedImages.length,
                      itemBuilder: (context, index) {
                        final img = _viewModel.uploadedImages[index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(img.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _viewModel.removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                ),
                                child: Text(
                                  _imageTypeLabels[img.imageType] ??
                                      img.imageType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Quiz Distractors Section
            _buildSection(
              context,
              title: '퀴즈 오답 설정',
              action: GestureDetector(
                onTap: () => _viewModel.setAutoQuizEnabled(
                  !_viewModel.isAutoQuizEnabled,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _viewModel.isAutoQuizEnabled
                        ? const Color(0xFFCCFF00)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _viewModel.isAutoQuizEnabled
                            ? Icons.auto_awesome
                            : Icons.edit_note,
                        size: 12,
                        color: _viewModel.isAutoQuizEnabled
                            ? Colors.black
                            : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _viewModel.isAutoQuizEnabled ? 'AI 자동' : '수동',
                        style: TextStyle(
                          color: _viewModel.isAutoQuizEnabled
                              ? Colors.black
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: Column(
                children: [
                  ..._viewModel.distractorControllers.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Container(
                      key: ValueKey(
                        'distractor_${index}_${controller.hashCode}',
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: '오답 입력...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_viewModel.distractorControllers.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 18,
                              ),
                              onPressed: () =>
                                  _viewModel.removeDistractor(index),
                              color: Colors.redAccent.withOpacity(0.6),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _viewModel.addDistractor,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('오답 추가'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCCFF00),
                        side: const BorderSide(color: Color(0xFFCCFF00)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePreview() {
    return Container(
      width: 400,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: backgroundDark,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: const Color(0xFF1E293B), width: 8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.bottomCenter,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                      Icon(Icons.share_outlined, color: Colors.white, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Added: Progress Bar
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(
                                value: 0.25, // Mock value
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _viewModel.uploadedImages.isNotEmpty
                                ? Image.network(
                                    _viewModel.uploadedImages.first.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: textGrey,
                                              ),
                                            ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: textGrey,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _viewModel.descriptionController.text,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 13,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daily Quiz',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  [
                                    {'label': '대표', 'icon': Icons.stars},
                                    {
                                      'label': '잎',
                                      'icon': Icons.energy_savings_leaf,
                                    },
                                    {'label': '수피', 'icon': Icons.texture},
                                    {'label': '꽃', 'icon': Icons.local_florist},
                                    {'label': '열매/겨울눈', 'icon': Icons.eco},
                                  ].map((item) {
                                    final label = item['label'] as String;
                                    final icon = item['icon'] as IconData;
                                    final isMain = label == '대표';
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: isMain
                                            ? primaryColor.withOpacity(0.15)
                                            : surfaceDark,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isMain
                                              ? primaryColor.withOpacity(0.5)
                                              : Colors.white10,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Tooltip(
                                        message: label,
                                        preferBelow: false,
                                        child: Icon(
                                          icon,
                                          size: 18,
                                          color: isMain
                                              ? primaryColor
                                              : Colors.white60,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPreviewOption(
                            1,
                            _viewModel.nameKrController.text.isEmpty
                                ? '정답'
                                : _viewModel.nameKrController.text,
                            true,
                          ),
                          const SizedBox(height: 6),
                          ...List.generate(
                            _viewModel.distractorControllers.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _buildPreviewOption(
                                i + 2,
                                _viewModel.distractorControllers[i].text.isEmpty
                                    ? '오답 ${i + 1}'
                                    : _viewModel.distractorControllers[i].text,
                                false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 120,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOption(int index, String text, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? primaryColor.withOpacity(0.12)
            : surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect ? primaryColor : surfaceDark,
              shape: BoxShape.circle,
              border: isCorrect ? null : Border.all(color: Colors.white24),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: isCorrect ? Colors.black : textGrey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(
              Icons.check_circle_outline,
              color: primaryColor,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFCCFF00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
