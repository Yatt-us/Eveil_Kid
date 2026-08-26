import 'package:eveilkid/features/questions/repository/question_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

final questionByIdProvider = FutureProvider.family<Question?, ({String activiteId, String questionId})>((ref, params) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionById(params.activiteId, params.questionId);
});

final questionsByActiviteProvider = FutureProvider.family<List<Question>, String>((ref, activiteId) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionsByActivite(activiteId);
});

class QuestionNotifier extends AsyncNotifier<List<Question>> {
  late final QuestionRepository _repository;
  String? _activiteId;

  @override
  Future<List<Question>> build() async {
    _repository = ref.read(questionRepositoryProvider);
    return [];
  }

  void setActiviteId(String activiteId) {
    _activiteId = activiteId;
  }

  Future<void> loadQuestions(String activiteId) async {
    state = const AsyncValue.loading();
    try {
      final questions = await _repository.getQuestionsByActivite(activiteId);
      state = AsyncValue.data(questions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createQuestion(Question question) async {
    if (_activiteId == null) throw Exception('ActiviteId manquant');
    try {
      await _repository.createQuestion(_activiteId!, question);
      await loadQuestions(_activiteId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuestion(Question question) async {
    if (_activiteId == null) throw Exception('ActiviteId manquant');
    try {
      await _repository.updateQuestion(_activiteId!, question);
      await loadQuestions(_activiteId!);
    } catch (e) {
      rethrow;
    }
  }

  
  Future<void> archiveQuestion(String questionId) async {
    if (_activiteId == null) throw Exception('ActiviteId manquant');
    try {
      await _repository.archiveQuestion(_activiteId!, questionId);
      await loadQuestions(_activiteId!);
    } catch (e) {
      rethrow;
    }
  }

 
  Future<void> restoreQuestion(String questionId) async {
    if (_activiteId == null) throw Exception('ActiviteId manquant');
    try {
      await _repository.restoreQuestion(_activiteId!, questionId);
      await loadQuestions(_activiteId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderQuestions(List<Question> questions) async {
    if (_activiteId == null) throw Exception('ActiviteId manquant');
    try {
      await _repository.updateQuestionsOrder(_activiteId!, questions);
      await loadQuestions(_activiteId!);
    } catch (e) {
      rethrow;
    }
  }
}

final questionNotifierProvider = AsyncNotifierProvider<QuestionNotifier, List<Question>>(() {
  return QuestionNotifier();
});