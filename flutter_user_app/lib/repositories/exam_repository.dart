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
      PostgrestFilterBuilder<PostgrestList> baseQuery = _supabase.from('quiz_questions').select<PostgrestList>('''
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

      final List<dynamic> data = await baseQuery
          .order('question_number', ascending: true)
          .range(from, to);

      // Count Query 
      PostgrestFilterBuilder<PostgrestList> countQuery = _supabase.from('quiz_questions').select<PostgrestList>(
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

      final PostgrestList allIds = await countQuery;
      final int totalCount = allIds.length;

      return <String, dynamic>{
        'questions': data.map((dynamic e) => Map<String, dynamic>.from(e as Map)).toList(),
        'totalItems': totalCount,
      };
    } catch (e) {
      rethrow;
    }
  }
}
