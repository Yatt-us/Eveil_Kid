import 'package:eveilkid/features/activity/questions/models/Question.model.dart';
import 'package:eveilkid/features/activity/questions/repository/Question.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});


final questionsByActiviteProvider = FutureProvider.family<List<Question>, String>((ref, activiteId) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionsByActivite(activiteId);
});

final questionByIdProvider = FutureProvider.family<Question?, ({String activiteId, String questionId})>((ref, params) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionById(params.activiteId, params.questionId);
});

class QuestionNotifier extends StateNotifier<AsyncValue<List<Question>>> {
  final QuestionRepository _repository;
  final String activiteId;

  QuestionNotifier(this._repository, this.activiteId) 
      : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    state = const AsyncValue.loading();
    try {
      final questions = await _repository.getQuestionsByActivite(activiteId);
      state = AsyncValue.data(questions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addQuestion(Question question) async {
    try {
      final newQuestion = await _repository.createQuestion(activiteId, question);
      await loadQuestions();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> updateQuestion(Question question) async {
    try {
      await _repository.updateQuestion(activiteId, question);
      await loadQuestions(); 
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _repository.deleteQuestion(activiteId, questionId);
      await loadQuestions(); 
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> reorderQuestions(List<Question> questions) async {
    try {
      await _repository.updateQuestionsOrder(activiteId, questions);
      await loadQuestions(); 
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<bool> verifierReponse(String questionId, int indexSelectionne) async {
    try {
      return await _repository.verifierReponse(activiteId, questionId, indexSelectionne);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteAllQuestions() async {
    try {
      await _repository.deleteAllQuestions(activiteId);
      await loadQuestions(); 
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

final questionNotifierProvider = StateNotifierProvider.family<QuestionNotifier, AsyncValue<List<Question>>, String>((ref, activiteId) {
  final repository = ref.read(questionRepositoryProvider);
  return QuestionNotifier(repository, activiteId);
});