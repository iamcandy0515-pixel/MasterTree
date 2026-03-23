import 'package:supabase_flutter/supabase_flutter.dart';

class ExamRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchQuestions({
    String? subject,
    String? year,
    String? session,
    required int from,
    required int to,
  }) async {
    try {
      // Data Query 
      var baseQuery = _supabase.from('quiz_questions').select('''
        *,
        quiz_exams!inner(year, round, title),
        quiz_categories!inner(name)
      ''');

      if (subject != null) {
        baseQuery = baseQuery.like('quiz_categories.name', '%$subject%');
      }
      if (year != null) {
        baseQuery = baseQuery.eq('quiz_exams.year', int.parse(year));
      }
      if (session != null) {
        baseQuery = baseQuery.eq('quiz_exams.round', int.parse(session));
      }

      final data = await baseQuery
          .order('question_number', ascending: true)
          .range(from, to);

      // Count Query (Note: Supabase returns count but for inner joins, sometimes manual calculation of result set is safer or easier for total filtering)
      var countQuery = _supabase.from('quiz_questions').select(
        'id, quiz_exams!inner(year, round), quiz_categories!inner(name)',
      );
      
      if (subject != null) {
        countQuery = countQuery.like('quiz_categories.name', '%$subject%');
      }
      if (year != null) {
        countQuery = countQuery.eq('quiz_exams.year', int.parse(year));
      }
      if (session != null) {
        countQuery = countQuery.eq('quiz_exams.round', int.parse(session));
      }

      final allIds = await countQuery;
      final totalCount = (allIds as List).length;

      return {
        'questions': List<Map<String, dynamic>>.from(data),
        'totalItems': totalCount,
      };
    } catch (e) {
      rethrow;
    }
  }
}
