import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/quiz_management_viewmodel.dart';

class QuizPaginationBar extends StatelessWidget {
  const QuizPaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizManagementViewModel>(
      builder: (context, vm, _) {
        final cur = vm.currentPage;
        final total = vm.totalPages;
        final viewModel = vm;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                onPressed: cur > 1 ? () => viewModel.setPage(cur - 1) : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cur / $total',
                  style: const TextStyle(color: NeoColors.acidLime, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                onPressed: cur < total ? () => viewModel.setPage(cur + 1) : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

