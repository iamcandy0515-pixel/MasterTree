import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_check_viewmodel.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../core/utils/format_utils.dart';

class UserCheckScreen extends StatelessWidget {
  const UserCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserCheckViewModel(),
      child: const _UserCheckContent(),
    );
  }
}

class _UserCheckContent extends StatelessWidget {
  const _UserCheckContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserCheckViewModel>();
    const primaryColor = NeoColors.acidLime;
    const backgroundDark = NeoColors.voidGreen;
    const surfaceDark = NeoColors.darkGray;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          backgroundColor: backgroundDark,
          elevation: 0,
          title: const Text(
            '사용자 관리',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            onTap: (index) {
              final status = ['pending', 'approved', 'rejected'][index];
              viewModel.loadUsers(status);
            },
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: '대기 중'),
              Tab(text: '승인됨'),
              Tab(text: '거절됨'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: viewModel.searchUsers,
                decoration: InputDecoration(
                  hintText: '사용자 이름 또는 이메일 검색',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(), // Handle via onTap load
                children: [
                  _buildUserList(viewModel, primaryColor),
                  _buildUserList(viewModel, primaryColor),
                  _buildUserList(viewModel, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(UserCheckViewModel viewModel, Color primaryColor) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NeoColors.acidLime),
      );
    }

    if (viewModel.users.isEmpty) {
      return Center(
        child: Text(
          '사용자가 없습니다.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = viewModel.users[index];
        final name = user['name'] ?? '사용자';
        final initial = name.replaceAll(RegExp(r'\[.*?\]\s*'), '').isNotEmpty 
            ? name.replaceAll(RegExp(r'\[.*?\]\s*'), '')[0] 
            : '?';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NeoColors.darkGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user['email'] ?? ''}${user['phone'] != null ? ' | ${FormatUtils.formatPhone(user['phone'])}' : ''}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(user['role'] ?? 'User', primaryColor),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                    onPressed: () => _showDeleteConfirm(context, viewModel, user['id']!, user['name']!),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근 활동: ${user['lastLogin']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  if (viewModel.currentStatus == 'pending')
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => viewModel.rejectUser(user['id']!),
                          child: const Text('거절', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => viewModel.approveUser(user['id']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('승인', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  else if (viewModel.currentStatus == 'rejected')
                    TextButton(
                      onPressed: () => viewModel.approveUser(user['id']!),
                      child: Text('재승인', style: TextStyle(color: primaryColor)),
                    )
                  else
                    TextButton(
                      onPressed: () => viewModel.rejectUser(user['id']!),
                      child: const Text('활동 정지', style: TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, UserCheckViewModel viewModel, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeoColors.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '사용자 삭제',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '삭제시 사용자의 정보가 사라집니다, 그래도 삭제하시겠습니까',
          style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await viewModel.deleteUser(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사용자가 삭제되었습니다.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            child: const Text('확인', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
