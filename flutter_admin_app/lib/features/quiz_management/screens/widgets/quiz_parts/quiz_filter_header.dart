import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/quiz_management_viewmodel.dart';
import '../../quiz_extraction_step2_screen.dart';

class QuizFilterHeader extends StatelessWidget {
  const QuizFilterHeader({super.key});

  static const surfaceDark = Color(0xFF1A2E24);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QuizManagementViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<QuizManagementViewModel>(
            builder: (context, vm, _) {
              final selectedSubject = vm.selectedSubject;
              final selectedYear = vm.selectedYear;
              final selectedSession = vm.selectedSession;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    '조회 필터',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  _buildDropdown(
                    hint: '과목',
                    value: selectedSubject,
                    items: viewModel.subjects,
                    onChanged: viewModel.setSubject,
                  ),
                  _buildDropdown(
                    hint: '연도',
                    value: selectedYear,
                    items: viewModel.years,
                    onChanged: viewModel.setYear,
                  ),
                  _buildDropdown(
                    hint: '회차',
                    value: selectedSession,
                    items: viewModel.sessions,
                    onChanged: viewModel.setSession,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
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
                  ).then((_) => viewModel.fetchQuizzes());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoColors.acidLime,
                  foregroundColor: NeoColors.voidGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('신규 기출등록', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: surfaceDark,
          hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: NeoColors.acidLime, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      ),
    );
  }
}

