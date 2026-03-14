import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_admin_app/features/dashboard/viewmodels/dashboard_viewmodel.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<DashboardViewModel, Map<String, dynamic>>(
      selector: (_, vm) => vm.stats,
      builder: (context, stats, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildTextStatItem('수목', stats['totalTrees'] ?? 0, '종'),
                ),
                _buildStatDivider(),
                Expanded(
                  child:
                      _buildTextStatItem('기출', stats['totalQuizzes'] ?? 0, '문'),
                ),
                _buildStatDivider(),
                Expanded(
                  child: _buildTextStatItem(
                    '유사',
                    stats['totalSimilarGroups'] ?? 0,
                    '조합',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextStatItem(String label, int count, String unit) {
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            unit,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 12,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
