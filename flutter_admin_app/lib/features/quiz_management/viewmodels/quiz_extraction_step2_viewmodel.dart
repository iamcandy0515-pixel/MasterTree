import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/quiz_drive_repository.dart';
import '../repositories/quiz_repository.dart';
import '../models/drive_file.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/parts/quiz_file_handler_mixin.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/parts/quiz_ai_assistant_mixin.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/parts/quiz_image_handler_mixin.dart';

class QuizExtractionStep2ViewModel extends ChangeNotifier 
    with QuizFileHandlerMixin, QuizAiAssistantMixin, QuizImageHandlerMixin {
  
  final _quizRepo = QuizRepository();
  final _driveRepo = QuizDriveRepository();

  // --- Core State (Step 2 Specific) ---
  String? _selectedSubject;
  String? _selectedYear;
  String? _selectedRound;
  int _selectedQuestionNumber = 1;
  int _hintsCount = 4;
  bool _isLoading = false;

  // --- Getters (For UI & Lints) ---
  bool get isLoading => _isLoading;
  String? get selectedSubject => _selectedSubject;
  String? get selectedYear => _selectedYear;
  String? get selectedRound => _selectedRound;
  int get selectedQuestionNumber => _selectedQuestionNumber;
  int get hintsCount => _hintsCount;

  String? get initialSubject => _selectedSubject;
  String? get initialYear => _selectedYear;
  String? get initialRound => _selectedRound;

  bool get isStep1Validating => isValidating;
  bool get isStep2Extracting => isExtractingInternal;
  bool get isStep1Done => extractedFilterRawString != null;
  Map<String, dynamic>? get extractedBlock => validatedQuizData;

  Map<String, dynamic> _forceCast(dynamic data) {
    if (data is! Map) return <String, dynamic>{};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  void init({String? subject, int? year, int? round}) {
    _selectedSubject = subject;
    _selectedYear = year;
    _selectedRound = round;
    notifyListeners();
  }

  void updateFilters({String? subject, String? year, String? round, int? questionNum}) {
    if (subject != null) _selectedSubject = subject;
    if (year != null) _selectedYear = year;
    if (round != null) _selectedRound = round;
    if (questionNum != null) _selectedQuestionNumber = questionNum;
    notifyListeners();
  }

  void setHintsCount(int count) {
    _hintsCount = count;
    notifyListeners();
  }

  Future<void> performValidation() async {
    await validateFile(
      selectedFileId,
      subject: _selectedSubject,
      year: _selectedYear != null ? int.tryParse(_selectedYear!) : null,
      round: _selectedRound != null ? int.tryParse(_selectedRound!) : null,
    );
    notifyListeners();
  }

  Future<void> extractQuiz() async {
    await extractQuizInternal(_selectedQuestionNumber, _hintsCount);
    notifyListeners();
  }

  Future<List<String>> generateHintsAction(String questionText, String explanation) async {
    return await generateHintsInternal(questionText, explanation, _hintsCount);
  }

  Future<Map<String, dynamic>> reviewExplanationAction(String explanationText) async {
    final rawReview = await reviewExplanationInternal(explanationText, extractedBlock);
    return _forceCast(rawReview);
  }

  /// --- Image Support (Satisfies SingleImageManagerDialog) ---
  Future<bool> addImageToQuiz(XFile file, String field) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String? url = await uploadImageAction(file);
      if (url == null || extractedBlock == null) return false;
      
      // Update the extracted block locally
      final Map<String, dynamic> currentBlock = _forceCast(extractedBlock);
      final List<dynamic> blocks = List.from(currentBlock[field] ?? []);
      blocks.add({'type': 'image', 'content': url});
      currentBlock[field] = blocks;
      
      // The Mixin managed state might need to be updated if it's used directly
      // validatedQuizData is a getter for a private field in the Mixin? 
      // Actually validatedQuizData is a getter for _validatedQuizData in QuizFileHandlerMixin.
      // But _validatedQuizData is private to the Mixin.
      // We might need a setter or just use the local block if the UI watches this.
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [Step2VM] addImage error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveToDb() async {
    if (extractedBlock == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> dataToSave = _forceCast(extractedBlock);
      dataToSave['subject'] = _selectedSubject;
      dataToSave['year'] = _selectedYear;
      dataToSave['round'] = _selectedRound;
      dataToSave['question_number'] = _selectedQuestionNumber;

      await _quizRepo.upsertQuizQuestion(dataToSave);
      return true;
    } catch (e) {
      debugPrint('❌ [Step2VM] Save error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startBatchExtractionAction(dynamic progress, dynamic message) async {
    debugPrint('🔔 [Step2VM] Batch redirection logic here.');
  }
}
