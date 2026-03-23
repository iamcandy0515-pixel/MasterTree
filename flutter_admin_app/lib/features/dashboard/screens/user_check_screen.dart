import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_check_viewmodel.dart';
import '../../../core/theme/neo_theme.dart';
import 'widgets/user_check_parts/user_search_header.dart';
import 'widgets/user_check_parts/user_card_item.dart';
import 'widgets/user_check_parts/user_delete_dialog.dart';

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
    final viewModel = context.read<UserCheckViewModel>();
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
        ),
        body: Column(
          children: [
            UserSearchHeader(
              onTabTap: (index) {
                final status = ['pending', 'approved', 'rejected'][index];
                viewModel.loadUsers(status);
              },
              onSearchChanged: viewModel.searchUsers,
              primaryColor: primaryColor,
              surfaceColor: surfaceDark,
            ),
            const Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _UserListBuilder(primaryColor: primaryColor),
                  _UserListBuilder(primaryColor: primaryColor),
                  _UserListBuilder(primaryColor: primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListBuilder extends StatelessWidget {
  final Color primaryColor;

  const _UserListBuilder({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserCheckViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator(color: NeoColors.acidLime));
        }
        
        final users = vm.users;
        if (users.isEmpty) {
          return Center(
            child: Text('사용자가 없습니다.', style: TextStyle(color: Colors.grey[500])),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return UserCardItem(
              user: users[index],
              currentStatus: vm.currentStatus,
              primaryColor: primaryColor,
              onApprove: (id) => vm.approveUser(id),
              onReject: (id) => vm.rejectUser(id),
              onDelete: (id, name) => _handleDelete(context, vm, id, name),
            );
          },
        );
      },
    );
  }

  void _handleDelete(
    BuildContext context,
    UserCheckViewModel viewModel,
    String userId,
    String userName,
  ) {
    UserDeleteDialog.show(context, userName, () async {
      try {
        await viewModel.deleteUser(userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자가 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
        }
      }
    });
  }
}
