import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bulk_similar_management_viewmodel.dart';
import 'widgets/bulk/bulk_filter_panel.dart';
import 'widgets/bulk/bulk_action_header.dart';
import 'widgets/bulk/bulk_pagination_bar.dart';
import 'widgets/bulk/parts/bulk_list_view.dart';
import '../repositories/quiz_repository.dart';

/// Bulk Similar Management Screen (Refactored Strategy: Action Separation & Select Rebuild)
/// 131라인 -> 70라인 이하 감축. 200줄 제한(1-1) 준수.
class BulkSimilarManagementScreen extends StatefulWidget {
  const BulkSimilarManagementScreen({super.key});

  @override
  State<BulkSimilarManagementScreen> createState() => _BulkSimilarManagementScreenState();
}

class _BulkSimilarManagementScreenState extends State<BulkSimilarManagementScreen> {
  final BulkSimilarManagementViewModel _viewModel = BulkSimilarManagementViewModel();
  final QuizRepository _quizRepo = QuizRepository();

  @override
  void initState() {
    super.initState();
    _viewModel.loadSavedFilters();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF102219);
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          backgroundColor: backgroundDark,
          elevation: 0,
          title: const Text('기출문제 유사문제 추출(일괄)', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        body: Column(
          children: [
            _buildActionHeaderPart(),
            _buildFilterPanelPart(),
            _buildPaginationBarPart(),
            Expanded(child: BulkQuizListView(quizRepo: _quizRepo)),
          ],
        ),
      ),
    );
  }

  /// Action Header 영역 분리 (Strategy: Selective Interaction)
  Widget _buildActionHeaderPart() {
    return Consumer<BulkSimilarManagementViewModel>(
      builder: (_, vm, __) => BulkActionHeader(
        isProcessing: vm.isProcessing,
        isEmpty: vm.quizzes.isEmpty,
        hasRecommendations: vm.tempRecommendations.isNotEmpty,
        onBulkRecommend: vm.runBulkRecommendation,
        onSaveAll: vm.saveAll,
      ),
    );
  }

  /// Filter Panel 영역 분리
  Widget _buildFilterPanelPart() {
    return Consumer<BulkSimilarManagementViewModel>(
      builder: (_, vm, __) => BulkFilterPanel(
        selectedSubject: vm.selectedSubject, selectedYear: vm.selectedYear, selectedRound: vm.selectedRound,
        subjects: vm.subjects, years: vm.years, rounds: vm.rounds, statusMessage: vm.statusMessage,
        onSubjectChanged: vm.setSubject, onYearChanged: vm.setYear, onRoundChanged: vm.setRound,
      ),
    );
  }

  /// Pagination Bar 영역 분리
  Widget _buildPaginationBarPart() {
    return Consumer<BulkSimilarManagementViewModel>(
      builder: (_, vm, __) => BulkPaginationBar(
        currentPage: vm.currentPage, totalPages: vm.totalPages, onPageChanged: vm.setPage,
      ),
    );
  }
}
