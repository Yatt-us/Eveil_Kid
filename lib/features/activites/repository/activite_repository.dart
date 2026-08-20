import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/activite_enums.dart';
import '../models/activite.dart';
import '../models/activite_resultat.dart';
import '../models/question.dart';

/// Repository Firestore pour les activités et leurs résultats.
class ActiviteRepository {
  final FirebaseFirestore? _customFirestore;

  ActiviteRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _activitesRef =>
      _firestore.collection('activites');

  CollectionReference<Map<String, dynamic>> get _resultatsRef =>
      _firestore.collection('resultats');

  /// 1. Récupérer toutes les activités
  Future<List<Activite>> getAllActivites({StatutPublication? statut}) async {
    try {
      Query<Map<String, dynamic>> query = _activitesRef;
      if (statut != null) {
        query = query.where('statutPublication', isEqualTo: statut.name);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        // Fournir les activités de démonstration si Firestore est vide
        return getFallbackActivities();
      }

      return snapshot.docs.map((doc) => Activite.fromFirestore(doc)).toList();
    } catch (e) {
      // En cas d'erreur de connexion à Firestore, retourner le fallback pour que l'app reste fonctionnelle
      return getFallbackActivities();
    }
  }

  /// 2. Récupérer une activité par ID
  Future<Activite?> getActiviteById(String id) async {
    try {
      final doc = await _activitesRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Activite.fromFirestore(doc);
      }
      return getFallbackActivities().cast<Activite?>().firstWhere(
            (a) => a?.id == id,
            orElse: () => null,
          );
    } catch (e) {
      return getFallbackActivities().cast<Activite?>().firstWhere(
            (a) => a?.id == id,
            orElse: () => null,
          );
    }
  }

  /// 3. Enregistrer ou mettre à jour une activité
  Future<void> saveActivite(Activite activite) async {
    try {
      final docId = activite.id.isEmpty ? _activitesRef.doc().id : activite.id;
      final activiteToSave = activite.copyWith(
        id: docId,
        dateModification: DateTime.now(),
      );
      await _activitesRef.doc(docId).set(activiteToSave.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'activité : $e');
    }
  }

  /// 4. Mettre à jour la progression d'une activité
  Future<void> updateProgression(String activityId, double progression, StatutActivite statut) async {
    try {
      await _activitesRef.doc(activityId).update({
        'progression': progression,
        'statut': statut.name,
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      // Ignore si le document n'existe pas en local fallback
    }
  }

  /// 5. Supprimer une activité
  Future<void> deleteActivite(String id) async {
    try {
      await _activitesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'activité : $e');
    }
  }

  /// 6. Enregistrer le résultat d'un enfant
  Future<void> saveResult(ActivityResult result) async {
    try {
      final docKey = '${result.activityId}_${result.childId}';
      await _resultatsRef.doc(docKey).set(result.toMap());
    } catch (e) {
      // Ignorer l'erreur réseau si hors ligne
    }
  }

  /// 7. Récupérer le résultat d'un enfant pour une activité
  Future<ActivityResult?> fetchResultForChild(String activityId, String childId) async {
    try {
      final doc = await _resultatsRef.doc('${activityId}_$childId').get();
      if (doc.exists && doc.data() != null) {
        return ActivityResult.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 8. Activités de démonstration enrichies (Fallback immédiat et sans latence)
  List<Activite> getFallbackActivities() {
    final now = DateTime.now();

    return [
      Activite(
        id: 'act_animaux',
        titre: 'Les Animaux',
        description: 'Découvre et reconnais les animaux de la forêt, de la savane et de la ferme !',
        cheminImage: 'assets/images/animaux.png',
        categorie: CategorieActivite.sciences,
        difficulte: DifficulteActivite.facile,
        statut: StatutActivite.enCours,
        progression: 0.6,
        totalQuestions: 5,
        points: 50,
        dateCreation: now,
        dateModification: now,
        questions: const [
          Question(
            id: 'q1',
            enonce: 'Quel est cet animal qui rugit dans la savane ?',
            idReponseCorrecte: 'opt_lion',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_lion', texte: 'Le Lion 🦁', imagePath: 'assets/images/lion.png'),
              OptionQuestion(id: 'opt_chat', texte: 'Le Chat 🐱', imagePath: 'assets/images/chat.png'),
              OptionQuestion(id: 'opt_lapin', texte: 'Le Lapin 🐰', imagePath: 'assets/images/lapin.png'),
              OptionQuestion(id: 'opt_ours', texte: 'L\'Ours 🐻', imagePath: 'assets/images/ours.png'),
            ],
          ),
          Question(
            id: 'q2',
            enonce: 'Où vit le poisson ?',
            idReponseCorrecte: 'opt_eau',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_eau', texte: 'Dans l\'eau 🌊'),
              OptionQuestion(id: 'opt_arbre', texte: 'Dans un arbre 🌳'),
              OptionQuestion(id: 'opt_ciel', texte: 'Dans le ciel ☁️'),
              OptionQuestion(id: 'opt_terre', texte: 'Sous terre 🕳️'),
            ],
          ),
          Question(
            id: 'q3',
            enonce: 'Quel oiseau ne sait pas voler mais nage très bien ?',
            idReponseCorrecte: 'opt_manchot',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_aigle', texte: 'L\'Aigle 🦅'),
              OptionQuestion(id: 'opt_manchot', texte: 'Le Manchot 🐧'),
              OptionQuestion(id: 'opt_perroquet', texte: 'Le Perroquet 🦜'),
            ],
          ),
          Question(
            id: 'q4',
            enonce: 'Combien de pattes a une araignée ?',
            idReponseCorrecte: 'opt_8',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_4', texte: '4 pattes'),
              OptionQuestion(id: 'opt_6', texte: '6 pattes'),
              OptionQuestion(id: 'opt_8', texte: '8 pattes 🕷️'),
              OptionQuestion(id: 'opt_10', texte: '10 pattes'),
            ],
          ),
          Question(
            id: 'q5',
            enonce: 'Que mange le panda géant ?',
            idReponseCorrecte: 'opt_bambou',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_bambou', texte: 'Du bambou 🎋'),
              OptionQuestion(id: 'opt_viande', texte: 'De la viande 🥩'),
              OptionQuestion(id: 'opt_pomme', texte: 'Des pommes 🍎'),
            ],
          ),
        ],
      ),
      Activite(
        id: 'act_formes',
        titre: 'Les Formes & Couleurs',
        description: 'Apprends à identifier les formes géométriques et les couleurs primaires.',
        cheminImage: 'assets/images/formes.png',
        categorie: CategorieActivite.math,
        difficulte: DifficulteActivite.facile,
        statut: StatutActivite.terminees,
        progression: 1.0,
        totalQuestions: 4,
        points: 40,
        dateCreation: now,
        dateModification: now,
        questions: const [
          Question(
            id: 'qf1',
            enonce: 'Quelle forme a 3 côtés ?',
            idReponseCorrecte: 'opt_triangle',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_carre', texte: 'Le Carré ⬛'),
              OptionQuestion(id: 'opt_triangle', texte: 'Le Triangle 🔺'),
              OptionQuestion(id: 'opt_rond', texte: 'Le Rond 🔴'),
              OptionQuestion(id: 'opt_rectangle', texte: 'Le Rectangle ▭'),
            ],
          ),
          Question(
            id: 'qf2',
            enonce: 'Quelle couleur obtient-on en mélangeant du bleu et du jaune ?',
            idReponseCorrecte: 'opt_vert',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_orange', texte: 'Orange 🟧'),
              OptionQuestion(id: 'opt_vert', texte: 'Vert 🟩'),
              OptionQuestion(id: 'opt_violet', texte: 'Violet 🟪'),
            ],
          ),
          Question(
            id: 'qf3',
            enonce: 'De quelle couleur est le soleil ?',
            idReponseCorrecte: 'opt_jaune',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_jaune', texte: 'Jaune ☀️'),
              OptionQuestion(id: 'opt_bleu', texte: 'Bleu 🔵'),
              OptionQuestion(id: 'opt_vert', texte: 'Vert 🟢'),
              OptionQuestion(id: 'opt_rouge', texte: 'Rouge 🔴'),
            ],
          ),
          Question(
            id: 'qf4',
            enonce: 'Quelle forme ressemble à un ballon de foot ?',
            idReponseCorrecte: 'opt_cercle',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_cercle', texte: 'Un cercle / Sphère ⚽'),
              OptionQuestion(id: 'opt_cube', texte: 'Un cube 🎲'),
              OptionQuestion(id: 'opt_pyramide', texte: 'Une pyramide 📐'),
            ],
          ),
        ],
      ),
      Activite(
        id: 'act_fruits',
        titre: 'Les Fruits et Légumes',
        description: 'Distingue les délicieux fruits et légumes vitaminés !',
        cheminImage: 'assets/images/fruits.png',
        categorie: CategorieActivite.sciences,
        difficulte: DifficulteActivite.facile,
        statut: StatutActivite.enCours,
        progression: 0.25,
        totalQuestions: 4,
        points: 40,
        dateCreation: now,
        dateModification: now,
        questions: const [
          Question(
            id: 'qfr1',
            enonce: 'Quel fruit est jaune et allongé ?',
            idReponseCorrecte: 'opt_banane',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_pomme', texte: 'La Pomme 🍎'),
              OptionQuestion(id: 'opt_banane', texte: 'La Banane 🍌'),
              OptionQuestion(id: 'opt_fraise', texte: 'La Fraise 🍓'),
              OptionQuestion(id: 'opt_orange', texte: 'L\'Orange 🍊'),
            ],
          ),
          Question(
            id: 'qfr2',
            enonce: 'Lequel est un légume qui pousse sous terre ?',
            idReponseCorrecte: 'opt_carotte',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_carotte', texte: 'La Carotte 🥕'),
              OptionQuestion(id: 'opt_peche', texte: 'La Pêche 🍑'),
              OptionQuestion(id: 'opt_raisin', texte: 'Le Raisin 🍇'),
            ],
          ),
          Question(
            id: 'qfr3',
            enonce: 'Quel fruit rouge a de petites graines à l\'extérieur ?',
            idReponseCorrecte: 'opt_fraise',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_fraise', texte: 'La Fraise 🍓'),
              OptionQuestion(id: 'opt_citron', texte: 'Le Citron 🍋'),
              OptionQuestion(id: 'opt_ananas', texte: 'L\'Ananas 🍍'),
              OptionQuestion(id: 'opt_pasteque', texte: 'La Pastèque 🍉'),
            ],
          ),
          Question(
            id: 'qfr4',
            enonce: 'Quel agrume est réputé pour son goût très acide ?',
            idReponseCorrecte: 'opt_citron',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_citron', texte: 'Le Citron 🍋'),
              OptionQuestion(id: 'opt_poire', texte: 'La Poire 🍐'),
              OptionQuestion(id: 'opt_cerise', texte: 'La Cerise 🍒'),
            ],
          ),
        ],
      ),
      Activite(
        id: 'act_transports',
        titre: 'Les Transports',
        description: 'Vroum vroum ! Découvre les véhicules sur terre, mer et dans les airs.',
        cheminImage: 'assets/images/transports.png',
        categorie: CategorieActivite.logique,
        difficulte: DifficulteActivite.moyen,
        statut: StatutActivite.enCours,
        progression: 0.0,
        totalQuestions: 3,
        points: 30,
        dateCreation: now,
        dateModification: now,
        questions: const [
          Question(
            id: 'qt1',
            enonce: 'Quel véhicule vole dans le ciel avec des ailes ?',
            idReponseCorrecte: 'opt_avion',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_avion', texte: 'L\'Avion ✈️'),
              OptionQuestion(id: 'opt_bateau', texte: 'Le Bateau 🚢'),
              OptionQuestion(id: 'opt_voiture', texte: 'La Voiture 🚗'),
              OptionQuestion(id: 'opt_train', texte: 'Le Train 🚆'),
            ],
          ),
          Question(
            id: 'qt2',
            enonce: 'Sur quoi roule un train ?',
            idReponseCorrecte: 'opt_rails',
            typeAffichage: TypeAffichageQuestion.liste,
            options: [
              OptionQuestion(id: 'opt_rails', texte: 'Sur des rails 🛤️'),
              OptionQuestion(id: 'opt_route', texte: 'Sur une route goudronnée 🛣️'),
              OptionQuestion(id: 'opt_eau', texte: 'Sur l\'eau 🌊'),
            ],
          ),
          Question(
            id: 'qt3',
            enonce: 'Combien de roues possède un vélo standard ?',
            idReponseCorrecte: 'opt_2',
            typeAffichage: TypeAffichageQuestion.grille,
            options: [
              OptionQuestion(id: 'opt_1', texte: '1 roue'),
              OptionQuestion(id: 'opt_2', texte: '2 roues 🚲'),
              OptionQuestion(id: 'opt_3', texte: '3 roues'),
              OptionQuestion(id: 'opt_4', texte: '4 roues'),
            ],
          ),
        ],
      ),
    ];
  }
}
