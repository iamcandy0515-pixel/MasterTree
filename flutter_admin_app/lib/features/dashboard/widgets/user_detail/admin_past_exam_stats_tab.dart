import 'package:flutter/material.dart';
import 'stats_colors.dart';
import 'stat_summary_card.dart';

/// 기출문제 현황: 과목/연도/회차별 필터링 기능 포함
class AdminPastExamStatsTab extends StatefulWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> exams;

  const AdminPastExamStatsTab({
    super.key,
    required this.stats,
    required this.exams,
  });

  @override
  State<AdminPastExamStatsTab> createState() => _AdminPastExamStatsTabState();
}

class _AdminPastExamStatsTabState extends State<AdminPastExamStatsTab> {
  String selectedSubject = '산림기사';
  String selectedYear = '전체';
  String selectedRound = '전체';

  @override
  Widget build(BuildContext context) {
    final subjects = ['산림기사', '산림산업기사'];
    final years = {'전체', ...widget.exams.map((e) => _parseYear(e['subject_name']))}.toList();
    final rounds = {'전체', ...widget.exams.map((e) => _parseRound(e['subject_name']))}.toList();

    final filteredExams = widget.exams.where((e) {
      final name = e['subject_name']?.toString() ?? '';
      final subjectMatch = name.contains(selectedSubject);
      final yearMatch = selectedYear == '전체' || name.contains('$selectedYear년');
      final roundMatch = selectedRound == '전체' || name.contains('$selectedRound회');
      return subjectMatch && yearMatch && roundMatch;
    }).toList();

    filteredExams.sort((a, b) {
      final String nameA = a['subject_name']?.toString() ?? '';
      final String nameB = b['subject_name']?.toString() ?? '';
      return nameB.compareTo(nameA);
    });

    int totalCount = 0;
    int masteredCount = 0;
    for (var exam in filteredExams) {
      totalCount += (exam['total_count'] as num?)?.toInt() ?? 0;
      masteredCount += (exam['mastered_count'] as num?)?.toInt() ?? 0;
    }
    double accuracyRate = totalCount > 0 ? (masteredCount / totalCount) * 100 : 0.0;

    final filteredSummary = {
      'totalCount': totalCount,
      'masteredCount': masteredCount,
      'accuracyRate': accuracyRate,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatSummaryCard(
            title: '기출 문제 학습 성과 ($selectedSubject)',
            data: filteredSummary,
            accentColor: Colors.orangeAccent,
            icon: Icons.history_edu,
          ),
          const SizedBox(height: 30),
          _buildFilterSection(subjects, years, rounds),
          const SizedBox(height: 15),
          const Text(
            '회차별 학습 현황',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (filteredExams.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('해당 조건의 학습 데이터가 없습니다.', style: TextStyle(color: StatsColors.textMuted)),
              ),
            )
          else
            ...filteredExams.map((exam) => _buildExamCard(exam)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<String> subjects, List<String> years, List<String> rounds) {
    return Row(
      children: [
        const Text('필터', style: TextStyle(color: StatsColors.textMuted, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildDropdown(
            value: selectedSubject,
            items: subjects,
            onChanged: (v) => setState(() => selectedSubject = v!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            value: selectedYear,
            items: years,
            onChanged: (v) => setState(() => selectedYear = v!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            value: selectedRound,
            items: rounds,
            onChanged: (v) => setState(() => selectedRound = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: StatsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: StatsColors.surface,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          icon: const Icon(Icons.arrow_drop_down, color: StatsColors.primary),
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      ),
    );
  }

  String _parseYear(dynamic name) {
    final s = name?.toString() ?? '';
    final match = RegExp(r'(\d+)년').firstMatch(s);
    return match?.group(1) ?? '전체';
  }

  String _parseRound(dynamic name) {
    final s = name?.toString() ?? '';
    final match = RegExp(r'(\d+)회').firstMatch(s);
    return match?.group(1) ?? '전체';
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final double accuracy = (exam['accuracy_rate'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StatsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exam['subject_name']?.toString() ?? '기출문제',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${accuracy.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMini(exam['total_count']?.toString() ?? '0', '전체'),
              _buildMini(exam['mastered_count']?.toString() ?? '0', '습득완료', color: Colors.orangeAccent),
              _buildMini(exam['in_progress_count']?.toString() ?? '0', '도전중'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMini(String val, String label, {Color? color}) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: StatsColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
