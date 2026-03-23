import 'package:flutter/material.dart';

class BulkPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  static const primaryColor = Color(0xFF2BEE8C);

  const BulkPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageBtn('맨처음', 1),
          _buildPageBtn('이전', currentPage > 1 ? currentPage - 1 : 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$currentPage / $totalPages',
              style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          _buildPageBtn('다음', currentPage < totalPages ? currentPage + 1 : totalPages),
          _buildPageBtn('맨끝', totalPages),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String label, int page) {
    return TextButton(
      onPressed: currentPage == page ? null : () => onPageChanged(page),
      child: Text(
        label,
        style: TextStyle(
          color: currentPage == page ? Colors.white24 : primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
