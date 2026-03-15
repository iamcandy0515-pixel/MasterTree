import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/tree_list_viewmodel.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class TreeListHeader extends StatelessWidget {
  const TreeListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TreeListViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _BackButton(),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '수목도감 일람',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _MoreMenu(vm: vm),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final TreeListViewModel vm;
  const _MoreMenu({required this.vm});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'export') {
          _handleExport(context);
        } else if (value == 'import') {
          _handleImport(context);
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.white),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: const Color(0xFF15281E),
      itemBuilder: (context) => [
        _buildMenuItem('export', Icons.download, '데이터 내보내기 (CSV)'),
        _buildMenuItem('import', Icons.upload, '데이터 가져오기 (CSV)'),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: NeoColors.acidLime),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final csvData = await vm.exportData();
    if (csvData != null) {
      if (kIsWeb) {
        WebUtils.downloadFile(csvData, "trees_export_${DateTime.now().millisecondsSinceEpoch}.csv");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수목 데이터가 다운로드되었습니다.'))
        );
      }
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final results = await vm.importData(file.bytes!, file.name);

      if (context.mounted && results != null) {
        final success = results['success'] ?? 0;
        final failed = results['failed'] ?? 0;
        _showImportResult(context, success, failed);
      }
    }
  }

  void _showImportResult(BuildContext context, int success, int failed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가져오기 완료'),
        content: Text('성공: $success건\n실패: $failed건'),
        backgroundColor: const Color(0xFF15281E),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인', style: TextStyle(color: NeoColors.acidLime)),
          ),
        ],
      ),
    );
  }
}
