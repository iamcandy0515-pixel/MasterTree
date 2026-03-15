import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';

class TreeListSearchBar extends StatelessWidget {
  const TreeListSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TreeListViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: vm.search,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '수목명 또는 학명 검색...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3)),
          filled: true,
          fillColor: const Color(0xFF1A2E24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
