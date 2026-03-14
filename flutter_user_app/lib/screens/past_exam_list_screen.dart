import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/past_exam_list_controller.dart';
import 'past_exam_detail_screen.dart';

class PastExamListScreen extends StatefulWidget {
  const PastExamListScreen({super.key});

  @override
  State<PastExamListScreen> createState() => _PastExamListScreenState();
}

class _PastExamListScreenState extends State<PastExamListScreen> {
  final PastExamListController _controller = PastExamListController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadSavedFilters(
        onUpdate: () => setState(() {}),
        onError: _onFetchError,
      );
    });
  }

  void _onFetchError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          '기출문제 일람',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '조건',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildDropdown(
                    hint: '과목',
                    value: _controller.selectedSubject,
                    items: _controller.subjects,
                    onChanged: (val) {
                      _controller.setSubject(
                        val,
                        onUpdate: () => setState(() {}),
                        onError: _onFetchError,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    hint: '년도',
                    value: _controller.selectedYear,
                    items: _controller.years,
                    onChanged: (val) {
                      _controller.setYear(
                        val,
                        onUpdate: () => setState(() {}),
                        onError: _onFetchError,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    hint: '회차',
                    value: _controller.selectedSession,
                    items: _controller.sessions,
                    onChanged: (val) {
                      _controller.setSession(
                        val,
                        onUpdate: () => setState(() {}),
                        onError: _onFetchError,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          if (!_controller.isLoading &&
              _controller.hasSearched &&
              _controller.quizzes.isNotEmpty)
            _buildPagination(),
          Expanded(
            child: !_controller.hasSearched
                ? Center(
                    child: Text(
                      '조회 조건을 모두 선택하면 자동으로 목록이 표시됩니다.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _controller.quizzes.isEmpty
                ? Center(
                    child: Text(
                      '조건에 맞는 기출문제가 없습니다.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _controller.quizzes.length,
                    itemBuilder: (context, index) {
                      return _buildQuizCard(_controller.quizzes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: false,
          dropdownColor: AppColors.surfaceDark,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          value: value,
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.primary,
            size: 16,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final qText = _controller.extractQuestionText(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PastExamDetailScreen(quizId: quiz['id']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    qText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white24,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, color: Colors.white, size: 24),
            onPressed: _controller.currentPage > 1
                ? () => _controller.firstPage(
                    onUpdate: () => setState(() {}),
                    onError: _onFetchError,
                  )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
            onPressed: _controller.currentPage > 1
                ? () => _controller.prevPage(
                    onUpdate: () => setState(() {}),
                    onError: _onFetchError,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            '${_controller.currentPage} / ${_controller.totalPages}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _controller.currentPage < _controller.totalPages
                ? () => _controller.nextPage(
                    onUpdate: () => setState(() {}),
                    onError: _onFetchError,
                  )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: Colors.white, size: 24),
            onPressed: _controller.currentPage < _controller.totalPages
                ? () => _controller.lastPage(
                    onUpdate: () => setState(() {}),
                    onError: _onFetchError,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
