import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/tree_sourcing_viewmodel.dart';
import '../../../core/theme/neo_theme.dart';
import 'widgets/tree_sourcing/species_selection_section.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TreeSourcingViewModel>();
      if (vm.searchQuery.isNotEmpty) {
        _searchController.text = vm.searchQuery;
      }
    });
  }

  @override
  void dispose() {
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
            _buildHeader(context, primaryColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context, primaryColor),
                    const SizedBox(height: 24),
                    SpeciesSelectionSection(
                      primaryColor: primaryColor,
                      backgroundDark: backgroundDark,
                    ),
                    const SizedBox(height: 100), // Footer spacer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              ),
              const SizedBox(width: 8),
              Text(
                '수목 이미지 추출(수목별)',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildExternalLinkButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildExternalLinkButton(Color primaryColor) {
    return TextButton.icon(
      onPressed: () async {
        final url = Uri.parse('https://www.nature.go.kr/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      icon: Icon(Icons.open_in_new, size: 14, color: primaryColor),
      label: Text(
        '국가생물정보',
        style: TextStyle(color: primaryColor, fontSize: 11),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color primaryColor) {
    final vm = context.watch<TreeSourcingViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (val) => vm.setSearchQuery(val),
        onSubmitted: (val) => vm.loadTrees(page: 1),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: '수목명으로 검색..',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: primaryColor, size: 20),
            onPressed: () => vm.loadTrees(page: 1),
          ),
        ),
      ),
    );
  }
}
