import 'package:eveilkid/features/activity/questions/models/Question.model.dart';
import 'package:eveilkid/features/activity/questions/repository/Question.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


// 1. PROVIDER DU REPOSITORY
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

// 2. PROVIDER POUR RÉCUPÉRER TOUTES LES QUESTIONS D'UNE ACTIVITÉ
final questionsByActiviteProvider = FutureProvider.family<List<Question>, String>((ref, activiteId) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionsByActivite(activiteId);
});

// 3. PROVIDER POUR RÉCUPÉRER UNE QUESTION PAR SON ID
final questionByIdProvider = FutureProvider.family<Question?, ({String activiteId, String questionId})>((ref, params) async {
  final repository = ref.read(questionRepositoryProvider);
  return repository.getQuestionById(params.activiteId, params.questionId);
});

// 4. NOTIFIER POUR GÉRER LES QUESTIONS
class QuestionNotifier extends StateNotifier<AsyncValue<List<Question>>> {
  final QuestionRepository _repository;
  final String activiteId;

  QuestionNotifier(this._repository, this.activiteId) 
      : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  // Charger les questions
  Future<void> loadQuestions() async {
    state = const AsyncValue.loading();
    try {
      final questions = await _repository.getQuestionsByActivite(activiteId);
      state = AsyncValue.data(questions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Ajouter une question
  Future<void> addQuestion(Question question) async {
    try {
      final newQuestion = await _repository.createQuestion(activiteId, question);
      await loadQuestions(); // Recharger la liste
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Modifier une question
  Future<void> updateQuestion(Question question) async {
    try {
      await _repository.updateQuestion(activiteId, question);
      await loadQuestions(); // Recharger la liste
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer une question
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _repository.deleteQuestion(activiteId, questionId);
      await loadQuestions(); // Recharger la liste
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Réordonner les questions
  Future<void> reorderQuestions(List<Question> questions) async {
    try {
      await _repository.updateQuestionsOrder(activiteId, questions);
      await loadQuestions(); // Recharger la liste
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Vérifier une réponse
  Future<bool> verifierReponse(String questionId, int indexSelectionne) async {
    try {
      return await _repository.verifierReponse(activiteId, questionId, indexSelectionne);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer toutes les questions
  Future<void> deleteAllQuestions() async {
    try {
      await _repository.deleteAllQuestions(activiteId);
      await loadQuestions(); // Recharger la liste
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

// 5. PROVIDER DU NOTIFIER POUR LES QUESTIONS
final questionNotifierProvider = StateNotifierProvider.family<QuestionNotifier, AsyncValue<List<Question>>, String>((ref, activiteId) {
  final repository = ref.read(questionRepositoryProvider);
  return QuestionNotifier(repository, activiteId);
});