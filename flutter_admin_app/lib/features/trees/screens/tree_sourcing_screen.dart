import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:file_picker/file_picker.dart';
import '../viewmodels/tree_sourcing_viewmodel.dart';
import '../repositories/tree_repository.dart';
import '../models/tree.dart';
import '../../../core/theme/neo_theme.dart';

class TreeSourcingScreen extends StatelessWidget {
  const TreeSourcingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeSourcingViewModel(),
      child: const _TreeSourcingContent(),
    );
  }
}

class _TreeSourcingContent extends StatefulWidget {
  const _TreeSourcingContent();

  @override
  State<_TreeSourcingContent> createState() => _TreeSourcingContentState();
}

class _TreeSourcingContentState extends State<_TreeSourcingContent> {
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync controller with VM query if needed (e.g. initial load)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TreeSourcingViewModel>();
      if (vm.searchQuery.isNotEmpty) {
        _searchController.text = vm.searchQuery;
      }
    });

    // Listen to VM changes to clear controller when AI search runs
    final vm = context.read<TreeSourcingViewModel>();
    vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (!mounted) return;
    final vm = context.read<TreeSourcingViewModel>();
    // If VM query is empty but controller text is not, update controller
    if (vm.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }
    // If VM query is different from controller (e.g. set programmatically), update controller
    else if (vm.searchQuery.isNotEmpty &&
        vm.searchQuery != _searchController.text) {
      _searchController.text = vm.searchQuery;
    }
  }

  @override
  void dispose() {
    final vm = context.read<TreeSourcingViewModel>();
    vm.removeListener(_onVmChanged);
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = NeoColors.acidLime;
    const backgroundDark = NeoColors.voidGreen;

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, primaryColor),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Species Selection Section
                    _buildSpeciesSelectionSection(context, primaryColor),
                    const SizedBox(height: 24),

                    // Image Management Section
                    _buildImageManagementSection(context, primaryColor),
                    const SizedBox(height: 100), // Footer spacer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar removed
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '수목 이미지 수집',
                      style: TextStyle(color: primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildExternalLinkButton(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildExternalLinkButton(BuildContext context, Color primaryColor) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse('https://www.nature.go.kr/main/Main.do');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_new, size: 14, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              '국가생물종지식시스템',
              style: TextStyle(color: primaryColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesSelectionSection(
    BuildContext context,
    Color primaryColor,
  ) {
    final vm = context.watch<TreeSourcingViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '수목 조회 및 선택',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Show button only when tree is selected
                if (vm.selectedTree != null)
                  InkWell(
                    onTap: () async {
                      final count = await vm.fetchGoogleImagesAll();
                      if (context.mounted && count == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              '구글드라이브에 해당 이미지가 없습니다.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(24),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_download_outlined,
                            size: 14,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '구글이미지 추가',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                try {
                  await vm.aiSearch();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(24),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // Basic styling for AI search
                child: Text(
                  'AI 검색',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (val) {
              vm.setSearchQuery(val);
              setState(() {}); // Rebuild for suffix icon
            },
            onSubmitted: (val) {
              vm.setSearchQuery(val);
              vm.loadTrees();
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '수목명으로 검색...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        vm.setSearchQuery('');
                        vm.loadTrees(); // Optional: reload all trees on clear
                        setState(() {});
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.search, color: primaryColor, size: 20),
                      onPressed: () => vm.loadTrees(),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (vm.selectedTree != null)
          _buildSingleTreeCard(context, vm.selectedTree!, primaryColor)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, color: Colors.grey[700], size: 48),
                const SizedBox(height: 12),
                Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSingleTreeCard(
    BuildContext context,
    Tree tree,
    Color primaryColor,
  ) {
    // Parse category for tags
    // Parse category for tags
    final category = tree.category ?? '';
    final List<String> tags = [];

    // 1. Retention Type (Evergreen vs Deciduous) - Default to Deciduous if ambiguous?
    // User request: "반드시 ... 하나를 표시"
    if (category.contains('상록')) {
      tags.add('상록수');
    } else {
      tags.add('낙엽수'); // Default/Fallback
    }

    // 2. Leaf Type (Conifer vs Broadleaf)
    if (category.contains('침엽')) {
      tags.add('침엽수');
    } else {
      tags.add('활엽수'); // Default/Fallback
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumb/Info
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tree.nameKr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      ...tags.map(
                        (tag) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  tree.scientificName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                // Removed old category container
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status Icons
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '부위별 데이터',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildDetailedStatusIcon(
                        Icons.eco,
                        '잎',
                        _hasImageType(context, tree, 'leaf'),
                        primaryColor,
                      ),
                      _buildDetailedStatusIcon(
                        Icons.texture,
                        '수피',
                        _hasImageType(context, tree, 'bark'),
                        primaryColor,
                      ),
                      _buildDetailedStatusIcon(
                        Icons.grain,
                        '열매/겨울눈',
                        _hasImageType(context, tree, 'fruit'),
                        primaryColor,
                      ),
                      _buildDetailedStatusIcon(
                        Icons.filter_vintage,
                        '꽃',
                        _hasImageType(context, tree, 'flower'),
                        primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatusIcon(
    IconData icon,
    String label,
    bool active,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: active ? primaryColor : Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? primaryColor.withOpacity(0.8) : Colors.grey[800],
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageManagementSection(
    BuildContext context,
    Color primaryColor,
  ) {
    // Header Row with Buttons
    final headerRow = Row(
      children: [
        const Text(
          '이미지 데이터 관리',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        // Save Button
        Consumer<TreeSourcingViewModel>(
          builder: (context, vm, _) {
            final isEnabled =
                vm.hasChanges && !vm.isLoading && vm.selectedTree != null;
            return TextButton(
              onPressed: isEnabled
                  ? () async {
                      try {
                        await vm.saveChanges();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: NeoColors.acidLime,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    '변경사항이 저장되었습니다.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: NeoColors.acidLime.withOpacity(0.5),
                                ),
                              ),
                              margin: const EdgeInsets.all(24),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('저장 실패: $e'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red[900],
                              margin: const EdgeInsets.all(24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              child: vm.isLoading
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: NeoColors.acidLime,
                      ),
                    )
                  : Text(
                      '저장 및 등록',
                      style: TextStyle(
                        color: isEnabled
                            ? NeoColors.acidLime
                            : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
      ],
    );

    return Column(
      children: [
        headerRow,
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            final types = ['main', 'leaf', 'bark', 'fruit', 'flower'];
            final labels = ['대표 이미지', '잎', '수피', '열매/겨울눈', '꽃'];
            return _buildImageCard(
              context,
              types[index],
              labels[index],
              primaryColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    String type,
    String label,
    Color primaryColor,
  ) {
    return _SourcingImageCard(
      type: type,
      label: label,
      primaryColor: primaryColor,
    );
  }

  bool _hasImageType(BuildContext context, Tree tree, String type) {
    // 1. Check if it explicitly exists in the current pending additions
    final vm = context.read<TreeSourcingViewModel>();
    if (vm.pendingImages.containsKey(type)) {
      return true;
    }

    // 2. Fallback to check DB tree data
    return tree.images.any((img) {
      final isMatchingType = img.imageType == type;

      // Exclude placeholder images from activating the icon
      final hasRealImage =
          img.imageUrl.isNotEmpty && !img.imageUrl.contains('placehold.co');

      return isMatchingType && hasRealImage;
    });
  }
}

class _SourcingImageCard extends StatefulWidget {
  final String type;
  final String label;
  final Color primaryColor;

  const _SourcingImageCard({
    required this.type,
    required this.label,
    required this.primaryColor,
  });

  @override
  State<_SourcingImageCard> createState() => _SourcingImageCardState();
}

class _SourcingImageCardState extends State<_SourcingImageCard> {
  bool _isHovered = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController =
      TextEditingController(); // Added _searchController

  @override
  void initState() {
    super.initState();
    // Sync controller with VM query if needed (e.g. initial load)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TreeSourcingViewModel>();
      if (vm.searchQuery.isNotEmpty) {
        _searchController.text = vm.searchQuery;
      }
    });

    // Listen to VM changes to clear controller when AI search runs
    final vm = context.read<TreeSourcingViewModel>();
    vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (!mounted) return;
    final vm = context.read<TreeSourcingViewModel>();
    if (vm.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    final vm = context.read<TreeSourcingViewModel>();
    vm.removeListener(_onVmChanged);
    _focusNode.dispose();
    _searchController.dispose(); // Disposed _searchController
    super.dispose();
  }

  Future<void> _handlePaste() async {
    final vm = context.read<TreeSourcingViewModel>();
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final reader = await clipboard.read();

    // Check for images
    if (reader.canProvide(Formats.png)) {
      reader.getFile(Formats.png, (file) async {
        final bytes = await file.readAll();
        vm.stageImage(widget.type, bytes);
      });
    } else if (reader.canProvide(Formats.jpeg)) {
      reader.getFile(Formats.jpeg, (file) async {
        final bytes = await file.readAll();
        vm.stageImage(widget.type, bytes);
      });
    }
  }

  Future<void> _handleFilePick() async {
    final vm = context.read<TreeSourcingViewModel>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes != null) {
        vm.stageImage(widget.type, bytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TreeSourcingViewModel>();
    final treeImage = vm.getImageForType(widget.type);
    final pendingBytes = vm.pendingImages[widget.type];
    final hasImage = treeImage != null || pendingBytes != null;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _focusNode.requestFocus();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _focusNode.unfocus();
      },
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyV &&
              HardwareKeyboard.instance.isControlPressed) {
            _handlePaste();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isHovered ? 0.08 : 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage
                  ? widget.primaryColor.withOpacity(0.3)
                  : (_isHovered
                        ? widget.primaryColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05)),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (pendingBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    pendingBytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.red.withOpacity(0.1),
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                )
              else if (treeImage != null)
                Opacity(
                  opacity: 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      TreeRepository.getProxyUrl(treeImage.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white.withOpacity(0.02),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Overlay for hover state to indicate paste ready
              if (_isHovered)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Ctrl+V 붙여넣기',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: hasImage ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: hasImage
                          ? [const Shadow(blurRadius: 4, color: Colors.black)]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasImage)
                    Icon(
                      Icons.check_circle,
                      color: widget.primaryColor,
                      size: 24,
                    )
                  else
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.grey[800],
                      size: 24,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconButton(
                        Icons.content_paste,
                        _handlePaste,
                        widget.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        Icons.upload_file,
                        _handleFilePick,
                        widget.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
    Color primaryColor,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: primaryColor),
      ),
    );
  }
}
