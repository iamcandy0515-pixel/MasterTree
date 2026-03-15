import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_management_viewmodel.dart';
import '../../quiz_extraction_step2_screen.dart';

class QuizFilterHeader extends StatelessWidget {
  const QuizFilterHeader({super.key});

  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QuizManagementViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Selector<QuizManagementViewModel, (String?, String?, String?)>(
            selector: (_, vm) => (vm.selectedSubject, vm.selectedYear, vm.selectedSession),
            builder: (context, data, _) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    '조회 조건',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  _buildDropdown(
                    hint: '과목',
                    value: data.$1,
                    items: viewModel.subjects,
                    onChanged: viewModel.setSubject,
                  ),
                  _buildDropdown(
                    hint: '년도',
                    value: data.$2,
                    items: viewModel.years,
                    onChanged: viewModel.setYear,
                  ),
                  _buildDropdown(
                    hint: '회차',
                    value: data.$3,
                    items: viewModel.sessions,
                    onChanged: viewModel.setSession,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizExtractionStep2Screen(
                        selectedFiles: const [],
                        initialSubject: viewModel.selectedSubject,
                        initialYear: viewModel.selectedYear != null ? int.tryParse(viewModel.selectedYear!) : null,
                        initialRound: viewModel.selectedSession != null ? int.tryParse(viewModel.selectedSession!) : null,
                      ),
                    ),
                  );
                },
                child: const Text('신규등록', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: surfaceDark,
        hint: Text(hint, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        value: value,
        icon: const Icon(Icons.expand_more, color: primaryColor, size: 16),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: onChanged,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      ),
    );
  }
}
