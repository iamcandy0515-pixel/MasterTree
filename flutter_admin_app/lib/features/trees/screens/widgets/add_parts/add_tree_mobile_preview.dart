import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeMobilePreview extends StatelessWidget {
  const AddTreeMobilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();
    
    return Container(
      width: 400,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      color: NeoTheme.darkTheme.scaffoldBackgroundColor,
      child: Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: NeoTheme.darkTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: const Color(0xFF1E293B), width: 8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            _buildContent(vm),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AddTreeViewModel vm) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              vm.nameKrController.text.isEmpty ? '나무 이름' : vm.nameKrController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (vm.uploadedImages.isNotEmpty)
            Image.network(
              vm.uploadedImages.first.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              vm.descriptionController.text.isEmpty 
                  ? '설명이 여기에 표시됩니다.' 
                  : vm.descriptionController.text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 40,
      child: Container(
        color: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '19:41',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Row(
              children: const [
                Icon(Icons.wifi, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Icon(Icons.battery_full, color: Colors.white, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
