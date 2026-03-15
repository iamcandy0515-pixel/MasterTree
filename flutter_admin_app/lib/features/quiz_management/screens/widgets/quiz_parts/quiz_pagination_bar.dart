import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_management_viewmodel.dart';

class QuizPaginationBar extends StatelessWidget {
  const QuizPaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<QuizManagementViewModel, (int, int)>(
      selector: (_, vm) => (vm.currentPage, vm.totalPages),
      builder: (context, data, _) {
        final cur = data.$1;
        final total = data.$2;
        final viewModel = context.read<QuizManagementViewModel>();

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
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cur / $total',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
