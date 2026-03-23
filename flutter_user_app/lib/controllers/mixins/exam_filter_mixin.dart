mixin ExamFilterMixin {
  String? selectedSubject;
  String? selectedYear;
  String? selectedSession;

  final List<String> subjects = [
    '산림기사',
    '산림산업기사',
    '산업안전기사',
    '산업안전산업기사',
    '조경기사',
    '조경산업기사',
  ];

  final List<String> years = List.generate(
    14,
    (index) => (2013 + index).toString(),
  );

  final List<String> sessions = ['1', '2', '3'];

  bool get isFilterComplete =>
      selectedSubject != null &&
      selectedYear != null &&
      selectedSession != null;

  void clearFilters() {
    selectedSubject = null;
    selectedYear = null;
    selectedSession = null;
  }
}
