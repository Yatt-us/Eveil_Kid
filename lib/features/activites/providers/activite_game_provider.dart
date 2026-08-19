import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/activite_enums.dart';
import '../models/activite.dart';
import '../models/activite_resultat.dart';
import '../models/question.dart';
import 'activites_provider.dart';

/// État d'une partie de jeu / quiz en cours.
class ActiviteGameState {
  final Activite? activiteEnCours;
  final int indexQuestionActuelle;
  final String? optionSelectionneeId;
  final Map<String, String> reponsesJoueur; // {questionId: optionId}
  final bool estQuizTermine;
  final String childIdActif;
  final bool estEnregistre;

  const ActiviteGameState({
    this.activiteEnCours,
    this.indexQuestionActuelle = 0,
    this.optionSelectionneeId,
    this.reponsesJoueur = const {},
    this.estQuizTermine = false,
    this.childIdActif = 'enfant_default',
    this.estEnregistre = false,
  });

  /// Question actuellement présentée à l'enfant
  Question? get questionActuelle {
    if (activiteEnCours == null ||
        activiteEnCours!.questions.isEmpty ||
        indexQuestionActuelle >= activiteEnCours!.questions.length) {
      return null;
    }
    return activiteEnCours!.questions[indexQuestionActuelle];
  }

  /// Total de questions de l'activité
  int get totalQuestions => activiteEnCours?.questions.length ?? activiteEnCours?.totalQuestions ?? 0;

  /// Ratio de progression actuel dans la session (ex: 0.25, 0.50, 1.0)
  double get progressionRatio {
    if (totalQuestions == 0) return 0.0;
    final currentNumber = indexQuestionActuelle + 1;
    return (currentNumber / totalQuestions).clamp(0.0, 1.0);
  }

  /// Nombre de réponses correctes fournies
  int get nombreBonnesReponses {
    if (activiteEnCours == null) return 0;
    int count = 0;
    for (final q in activiteEnCours!.questions) {
      if (reponsesJoueur[q.id] == q.idReponseCorrecte) {
        count++;
      }
    }
    return count;
  }

  /// Nombre d'erreurs
  int get nombreMauvaisesReponses {
    if (activiteEnCours == null) return 0;
    return activiteEnCours!.questions.length - nombreBonnesReponses;
  }

  /// Points cumulés pour cette session
  int get pointsGagnes => nombreBonnesReponses * 10;

  /// Ratio de réussite (entre 0.0 et 1.0)
  double get scoreRatio {
    if (totalQuestions == 0) return 0.0;
    return (nombreBonnesReponses / totalQuestions).clamp(0.0, 1.0);
  }

  /// Vérifie si l'enfant a correctement répondu à une question
  bool estReponseCorrecte(Question question) {
    return reponsesJoueur[question.id] == question.idReponseCorrecte;
  }

  ActiviteGameState copyWith({
    Activite? activiteEnCours,
    bool clearActivite = false,
    int? indexQuestionActuelle,
    String? optionSelectionneeId,
    bool clearOptionSelectionnee = false,
    Map<String, String>? reponsesJoueur,
    bool? estQuizTermine,
    String? childIdActif,
    bool? estEnregistre,
  }) {
    return ActiviteGameState(
      activiteEnCours: clearActivite ? null : activiteEnCours ?? this.activiteEnCours,
      indexQuestionActuelle: indexQuestionActuelle ?? this.indexQuestionActuelle,
      optionSelectionneeId: clearOptionSelectionnee ? null : optionSelectionneeId ?? this.optionSelectionneeId,
      reponsesJoueur: reponsesJoueur ?? this.reponsesJoueur,
      estQuizTermine: estQuizTermine ?? this.estQuizTermine,
      childIdActif: childIdActif ?? this.childIdActif,
      estEnregistre: estEnregistre ?? this.estEnregistre,
    );
  }
}

/// Notifier pour orchestrer le gameplay des activités
class ActiviteGameNotifier extends Notifier<ActiviteGameState> {
  @override
  ActiviteGameState build() {
    return const ActiviteGameState();
  }

  /// Initialise et démarre une session de jeu pour une activité
  void demarrerActivite(Activite activite, {String? childId}) {
    state = ActiviteGameState(
      activiteEnCours: activite,
      indexQuestionActuelle: 0,
      optionSelectionneeId: null,
      reponsesJoueur: {},
      estQuizTermine: false,
      childIdActif: childId ?? state.childIdActif,
      estEnregistre: false,
    );
  }

  /// Sélection d'une réponse par l'enfant
  void selectionnerOption(String optionId) {
    state = state.copyWith(optionSelectionneeId: optionId);
  }

  /// Valide la réponse sélectionnée et avance d'une question.
  /// Renvoie true si c'était la dernière question et que le quiz est terminé.
  bool validerReponse() {
    if (state.activiteEnCours == null || state.optionSelectionneeId == null) {
      return false;
    }

    final question = state.questionActuelle;
    if (question == null) return false;

    final updatedReponses = Map<String, String>.from(state.reponsesJoueur);
    updatedReponses[question.id] = state.optionSelectionneeId!;

    final total = state.activiteEnCours!.questions.length;
    final isLastQuestion = state.indexQuestionActuelle >= total - 1;

    if (!isLastQuestion) {
      state = state.copyWith(
        reponsesJoueur: updatedReponses,
        indexQuestionActuelle: state.indexQuestionActuelle + 1,
        clearOptionSelectionnee: true,
      );
      return false;
    } else {
      state = state.copyWith(
        reponsesJoueur: updatedReponses,
        estQuizTermine: true,
        clearOptionSelectionnee: true,
      );
      _sauvegarderResultatFinal();
      return true;
    }
  }

  /// Recommence l'activité en cours
  void recommencerActivite() {
    if (state.activiteEnCours != null) {
      demarrerActivite(state.activiteEnCours!, childId: state.childIdActif);
    }
  }

  /// Réinitialise l'état du jeu lors de la fermeture
  void reinitialiserSession() {
    state = const ActiviteGameState();
  }

  /// Définit l'identifiant de l'enfant
  void setChildId(String childId) {
    state = state.copyWith(childIdActif: childId);
  }

  /// Enregistre les résultats dans Firestore et met à jour la progression globale
  Future<void> _sauvegarderResultatFinal() async {
    if (state.activiteEnCours == null || state.estEnregistre) return;

    final activite = state.activiteEnCours!;
    final repository = ref.read(activiteRepositoryProvider);

    final resultat = ActivityResult(
      activityId: activite.id,
      childId: state.childIdActif,
      score: state.pointsGagnes,
      totalQuestions: activite.questions.length,
      bonnesReponses: state.nombreBonnesReponses,
      mauvaisesReponses: state.nombreMauvaisesReponses,
      reponses: state.reponsesJoueur,
      date: DateTime.now(),
    );

    try {
      await repository.saveResult(resultat);
      if (!ref.mounted) return;

      // Mettre à jour la progression dans la liste
      final nouveauStatut = state.scoreRatio >= 0.5 
          ? StatutActivite.terminees 
          : StatutActivite.enCours;
      final nouvelleProgression = state.scoreRatio >= 0.5 ? 1.0 : state.scoreRatio;

      ref.read(activitesProvider.notifier).actualiserProgressionActivite(
        activite.id,
        nouvelleProgression,
        nouveauStatut,
      );

      if (!ref.mounted) return;
      state = state.copyWith(estEnregistre: true);
    } catch (_) {
      // Échec silencieux si pas de connexion
    }
  }
}

/// Provider pour la session de jeu active
final activiteGameProvider = NotifierProvider<ActiviteGameNotifier, ActiviteGameState>(
  ActiviteGameNotifier.new,
);
