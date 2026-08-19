import 'package:flutter/material.dart';

import '../models/activitees_enums.dart';
import '../models/activitees_model.dart';
import '../models/activitees_resultat_model.dart';
import '../models/question_model.dart';
import '../repositories/activitees_repository.dart';

class ActiviteesProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  // --- ÉTATS DU CHARGEMENT DES DONNÉES ---
  List<ActiviteesModel> _listeActivitees = [];
  bool _estEnChargement = false;
  String? _erreur;

  // --- ÉTATS DU JEU ET DES FILTRES ---
  StatutActivitee _filtreActif = StatutActivitee.toutes;
  ActiviteesModel? _activiteeEnCours;
  int _indexQuestionActuelle = 0;
  String? _optionSelectionneeId;
  bool _estQuizTermine = false;
  final Map<String, String> _reponsesJoueur = {}; // {questionId: optionId}

  // Identifiant de l'enfant (à remplacer dynamiquement si tu as un système de profil)
  String _childIdActif = 'enfant_default';

  // --- GETTERS POUR L'INTERFACE USER ---
  List<ActiviteesModel> get listeActivitees => _listeActivitees;
  bool get estEnChargement => _estEnChargement;
  String? get erreur => _erreur;

  StatutActivitee get filtreActif => _filtreActif;
  ActiviteesModel? get activiteeEnCours => _activiteeEnCours;
  int get indexQuestionActuelle => _indexQuestionActuelle;
  String? get optionSelectionneeId => _optionSelectionneeId;
  bool get estQuizTermine => _estQuizTermine;
  Map<String, String> get reponsesJoueur => _reponsesJoueur;

  // Question actuellement affichée dans ActiviteesPlayPage
  QuestionModel? get questionActuelle {
    if (_activiteeEnCours == null ||
        _activiteeEnCours!.questions.isEmpty ||
        _indexQuestionActuelle >= _activiteeEnCours!.questions.length) {
      return null;
    }
    return _activiteeEnCours!.questions[_indexQuestionActuelle];
  }

  // Filtrage de la liste d'activités sur l'accueil
  List<ActiviteesModel> get activiteesFiltrees {
    if (_filtreActif == StatutActivitee.toutes) {
      return _listeActivitees;
    }
    return _listeActivitees
        .where((activite) => activite.statut == _filtreActif)
        .toList();
  }

  // --- CONSTRUCTEUR ---
  ActiviteesProvider() {
    chargerActivitees();
  }

  // --- CHARGEMENT FIRESTORE VIA LE REPOSITORY ---
  Future<void> chargerActivitees() async {
    _estEnChargement = true;
    _erreur = null;
    notifyListeners();

    try {
      _listeActivitees = await _repository.fetchActivities();
    } catch (e) {
      _erreur = 'Erreur lors du chargement des données : $e';
    } finally {
      _estEnChargement = false;
      notifyListeners();
    }
  }

  // --- GESTION DES FILTRES ---
  void changerFiltre(StatutActivitee nouveauFiltre) {
    _filtreActif = nouveauFiltre;
    notifyListeners();
  }

  // --- LOGIQUE DU DEROULEMENT DU QUIZ ---

  /// Initialise une nouvelle partie
  void demarrerActivite(ActiviteesModel activite) {
    _activiteeEnCours = activite;
    _indexQuestionActuelle = 0;
    _optionSelectionneeId = null;
    _estQuizTermine = false;
    _reponsesJoueur.clear();
    notifyListeners();
  }

  /// Sélection d'une option sur la question en cours
  void selectionnerOption(String optionId) {
    _optionSelectionneeId = optionId;
    notifyListeners();
  }

  /// Valide la réponse sélectionnée et passe à la question suivante
  void validerReponse() {
    if (_activiteeEnCours != null && _optionSelectionneeId != null) {
      final q = questionActuelle;
      if (q != null) {
        _reponsesJoueur[q.id] = _optionSelectionneeId!;
      }
      _optionSelectionneeId = null;

      if (_indexQuestionActuelle < _activiteeEnCours!.questions.length - 1) {
        _indexQuestionActuelle++;
      } else {
        _estQuizTermine = true;
        _enregistrerResultatFinal(); // Sauvegarde automatique dans Firestore
      }
      notifyListeners();
    }
  }

  /// Relance l'activité en cours
  void recommencerActivite() {
    if (_activiteeEnCours != null) {
      demarrerActivite(_activiteeEnCours!);
    }
  }

  // --- SAUVEGARDE DU RESULTAT DANS FIRESTORE ---
  Future<void> _enregistrerResultatFinal() async {
    if (_activiteeEnCours == null) return;

    final resultat = ActivityResultModel(
      activityId: _activiteeEnCours!.id,
      childId: _childIdActif,
      score: pointsGagnes,
      totalQuestions: _activiteeEnCours!.questions.length,
      bonnesReponses: nombreBonnesReponses,
      reponses: _reponsesJoueur,
      date: DateTime.now(),
    );

    try {
      await _repository.saveResult(resultat);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du résultat: $e');
    }
  }

  // --- CALCULS DES SCORES (Pour ActiviteesResultatPage et CorrigePage) ---

  int get nombreBonnesReponses {
    if (_activiteeEnCours == null) return 0;
    int count = 0;
    for (var q in _activiteeEnCours!.questions) {
      if (_reponsesJoueur[q.id] == q.idReponseCorrecte) {
        count++;
      }
    }
    return count;
  }

  int get nombreMauvaisesReponses {
    if (_activiteeEnCours == null) return 0;
    return _activiteeEnCours!.questions.length - nombreBonnesReponses;
  }

  int get pointsGagnes => nombreBonnesReponses * 10;

  /// Vérifie si l'enfant a bien répondu à une question spécifique (pour l'écran corrigé)
  bool estReponseCorrecte(QuestionModel question) {
    return _reponsesJoueur[question.id] == question.idReponseCorrecte;
  }

  /// Permet de définir l'enfant connecté
  void setChildId(String childId) {
    _childIdActif = childId;
    notifyListeners();
  }
}