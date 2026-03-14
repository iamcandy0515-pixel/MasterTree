import 'package:flutter/material.dart';

class BulkExtractionFilterPanel extends StatelessWidget {
  final TextEditingController fileIdController;
  final TextEditingController startController;
  final TextEditingController endController;
  final String? subject;
  final int? year;
  final int? round;
  final bool isLoading;
  final bool isFilterComplete;
  final Function(String) onFileIdChanged;
  final Function(String?) onSubjectChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onRoundChanged;
  final Function(String) onStartChanged;
  final Function(String) onEndChanged;
  final VoidCallback onExtractPressed;

  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);

  const BulkExtractionFilterPanel({
    super.key,
    required this.fileIdController,
    required this.startController,
    required this.endController,
    required this.subject,
    required this.year,
    required this.round,
    required this.isLoading,
    required this.isFilterComplete,
    required this.onFileIdChanged,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onRoundChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onExtractPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: surfaceDark.withOpacity(0.5),
      child: Column(
        children: [
          TextField(
            controller: fileIdController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: '드라이브 파일 ID 또는 파일명',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              prefixIcon: const Icon(
                Icons.description,
                color: primaryColor,
                size: 18,
              ),
              filled: true,
              fillColor: surfaceDark,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onFileIdChanged,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropDown(
                    hint: '과목',
                    value: subject,
                    items: const ['산림기사', '산림산업기사'],
                    onChanged: onSubjectChanged,
                  ),
                ),
                _buildBannerDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '년도',
                    value: year?.toString(),
                    items: List.generate(14, (i) => (2013 + i).toString()),
                    onChanged: onYearChanged,
                  ),
                ),
                _buildBannerDivider(),
                Expanded(
                  child: _buildDropDown(
                    hint: '회차',
                    value: round?.toString(),
                    items: const ['1', '2', '3', '4'],
                    onChanged: onRoundChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text(
                    '범위:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  _buildNumberInput('시작', startController, onStartChanged),
                  const Text(
                    '~',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  _buildNumberInput('종료', endController, onEndChanged),
                ],
              ),
              TextButton.icon(
                onPressed: isLoading || !isFilterComplete
                    ? null
                    : onExtractPressed,
                icon: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: isFilterComplete ? primaryColor : Colors.white24,
                ),
                label: Text(
                  'PDF 추출',
                  style: TextStyle(
                    color: isFilterComplete ? Colors.white : Colors.white24,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: surfaceDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isFilterComplete
                          ? Colors.white10
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 44,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: surfaceDark,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: primaryColor,
            size: 20,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      width: 48,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBannerDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white10,
    );
  }
}
