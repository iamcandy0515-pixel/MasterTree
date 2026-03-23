import 'package:flutter/material.dart';
import '../../../models/tree_group.dart';
import '../../../viewmodels/tree_lookalike_viewmodel.dart';
import 'lookalike_tab_selector.dart';
import 'lookalike_nav_controls.dart';
import 'lookalike_tree_column.dart';

class LookalikeComparisonMatrix extends StatefulWidget {
  final TreeGroup group;
  final TreeLookalikeViewModel vm;

  const LookalikeComparisonMatrix({super.key, required this.group, required this.vm});

  @override
  State<LookalikeComparisonMatrix> createState() => _LookalikeComparisonMatrixState();
}

class _LookalikeComparisonMatrixState extends State<LookalikeComparisonMatrix> {
  final ScrollController _horizontalController = ScrollController();
  final double _columnWidth = 180.0;
  final double _labelColumnWidth = 100.0;

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    if (!_horizontalController.hasClients) return;
    final currentOffset = _horizontalController.offset;
    final targetOffset = (currentOffset - _columnWidth).clamp(0.0, _horizontalController.position.maxScrollExtent);
    _horizontalController.animateTo(targetOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _scrollRight() {
    if (!_horizontalController.hasClients) return;
    final currentOffset = _horizontalController.offset;
    final targetOffset = (currentOffset + _columnWidth).clamp(0.0, _horizontalController.position.maxScrollExtent);
    _horizontalController.animateTo(targetOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    const double imageRowHeight = 160;
    const double nameRowHeight = 50;
    const double characteristicRowHeight = 180;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),
          LookalikeTabSelector(vm: widget.vm),
          const SizedBox(height: 16),
          LookalikeNavControls(onScrollLeft: _scrollLeft, onScrollRight: _scrollRight),
          const SizedBox(height: 16),

          // Main Matrix Table
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Label Column
                _buildFixedLabelColumn(imageRowHeight, nameRowHeight, characteristicRowHeight),

                // Scrollable Data Columns (Lazy loaded via ListView.builder)
                Expanded(
                  child: SizedBox(
                    height: imageRowHeight + nameRowHeight + characteristicRowHeight + 3, // Includes 3 dividers
                    child: ListView.builder(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.group.members.length,
                      itemBuilder: (context, index) {
                        return LookalikeTreeColumn(
                          member: widget.group.members[index],
                          selectedTab: widget.vm.selectedTab,
                          columnWidth: _columnWidth,
                          imageRowHeight: imageRowHeight,
                          nameRowHeight: nameRowHeight,
                          characteristicRowHeight: characteristicRowHeight,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedLabelColumn(double imgH, double nameH, double charH) {
    return Container(
      width: _labelColumnWidth,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          _buildFixedLabelCell('이미지', height: imgH, isHeader: true),
          const Divider(height: 1, color: Colors.white10),
          _buildFixedLabelCell('수목명', height: nameH, isHeader: true),
          const Divider(height: 1, color: Colors.white10),
          _buildFixedLabelCell('주요 특징\n(Hint)', height: charH, isHeader: true),
        ],
      ),
    );
  }

  Widget _buildFixedLabelCell(String text, {double height = 60, bool isHeader = false}) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: isHeader ? Colors.white.withOpacity(0.02) : null,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}
