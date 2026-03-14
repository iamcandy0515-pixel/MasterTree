import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/features/trees/screens/tree_group_edit_screen.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_group_management_viewmodel.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class TreeGroupManagementScreen extends StatelessWidget {
  const TreeGroupManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeGroupManagementViewModel(),
      child: const _TreeGroupListContent(),
    );
  }
}

class _TreeGroupListContent extends StatelessWidget {
  const _TreeGroupListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreeGroupManagementViewModel>();

    return Scaffold(
      backgroundColor: NeoTheme.darkTheme.scaffoldBackgroundColor,
      // No standard AppBar, custom header area
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '비교 수목 일람',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, // More menu placeholder
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2518),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '비교하고 싶은 수종 검색',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Label & Add Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                '추천 비교 가이드',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '총 ${viewModel.totalCount}개',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 12,
                                color: NeoColors.acidLime,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Page Navigation
                      if (viewModel.totalPages > 1)
                        Row(
                          children: [
                            IconButton(
                              onPressed: viewModel.currentPage > 1
                                  ? viewModel.prevPage
                                  : null,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.chevron_left,
                                color: viewModel.currentPage > 1
                                    ? NeoColors.acidLime
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.currentPage} / ${viewModel.totalPages}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed:
                                  viewModel.currentPage < viewModel.totalPages
                                  ? viewModel.nextPage
                                  : null,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.chevron_right,
                                color:
                                    viewModel.currentPage < viewModel.totalPages
                                    ? NeoColors.acidLime
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TreeGroupEditScreen(),
                            ),
                          );
                          if (context.mounted) {
                            context
                                .read<TreeGroupManagementViewModel>()
                                .loadGroups();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle,
                                color: NeoColors.acidLime,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '그룹 추가',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: NeoColors.acidLime,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child: viewModel.isLoading
                  ? _buildShimmerLoading()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      itemCount: viewModel.pagedGroups.length,
                      itemBuilder: (context, index) {
                        final group = viewModel.pagedGroups[index];
                        return _buildSimpleGroupItem(context, group);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleGroupItem(BuildContext context, TreeGroup group) {
    // Get first two members for title display
    final firstMember = group.members.isNotEmpty ? group.members[0] : null;
    final secondMember = group.members.length > 1 ? group.members[1] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TreeGroupEditScreen(group: group),
            ),
          );
          if (context.mounted) {
            context.read<TreeGroupManagementViewModel>().loadGroups();
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Thumbnails Group
              SizedBox(
                width: 72,
                height: 48,
                child: Stack(
                  children: [
                    if (firstMember?.imageUrl != null)
                      Positioned(
                        left: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: NetworkImage(firstMember!.imageUrl!),
                        ),
                      ),
                    if (secondMember?.imageUrl != null)
                      Positioned(
                        left: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoTheme.darkTheme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: NetworkImage(
                              secondMember!.imageUrl!,
                            ),
                          ),
                        ),
                      ),
                    if (group.members.length > 2)
                      Positioned(
                        left: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoTheme.darkTheme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: NeoColors.acidLime.withOpacity(
                              0.2,
                            ),
                            child: const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: NeoColors.acidLime,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: TreeA vs TreeB
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: firstMember?.treeName ?? 'A',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' vs ',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: secondMember?.treeName ?? 'B',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' (${group.members.length}건)',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: NeoColors.acidLime,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description Hint
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: NeoColors.acidLime,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            group.description,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              color: NeoColors.acidLime,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
