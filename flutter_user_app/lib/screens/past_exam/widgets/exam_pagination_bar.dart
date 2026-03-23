import 'package:flutter/material.dart';

class ExamPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onFirstPage;
  final VoidCallback onLastPage;
  final VoidCallback onNextPage;
  final VoidCallback onPrevPage;

  const ExamPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onFirstPage,
    required this.onLastPage,
    required this.onNextPage,
    required this.onPrevPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, color: Colors.white, size: 24),
            onPressed: currentPage > 1 ? onFirstPage : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
            onPressed: currentPage > 1 ? onPrevPage : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$currentPage / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            onPressed: currentPage < totalPages ? onNextPage : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: Colors.white, size: 24),
            onPressed: currentPage < totalPages ? onLastPage : null,
          ),
        ],
      ),
    );
  }
}
