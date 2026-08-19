import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activitees_model.dart';
import '../models/activitees_resultat_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Récupérer toutes les activités depuis la collection 'activites' de Firestore
  Future<List<ActiviteesModel>> fetchActivities() async {
    try {
      final snapshot = await _firestore.collection('activites').get();
      return snapshot.docs
          .map((doc) => ActiviteesModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des activités : $e');
    }
  }

  // 2. Enregistrer ou mettre à jour une activité dans Firestore
  Future<void> saveActivity(ActiviteesModel activity) async {
    try {
      await _firestore
          .collection('activites')
          .doc(activity.id)
          .set({
            'titre': activity.titre,
            'description': activity.description,
            'cheminImage': activity.cheminImage,
            'categorie': activity.categorie.name,
            'difficulte': activity.difficulte.name,
            'statut': activity.statut.name,
            'progression': activity.progression,
            'totalQuestions': activity.totalQuestions,
            'questions': activity.questions.map((q) => {
              'id': q.id,
              'enonce': q.enonce,
              'idReponseCorrecte': q.idReponseCorrecte,
              'options': q.options.map((opt) => {
                'id': opt.id,
                'texte': opt.texte,
                'imagePath': opt.imagePath,
              }).toList(),
            }).toList(),
          });
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'activité : $e');
    }
  }

  // 3. Supprimer une activité
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activites').doc(activityId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'activité : $e');
    }
  }

  // 4. Enregistrer le résultat d'un enfant
  Future<void> saveResult(ActivityResultModel result) async {
    try {
      await _firestore
          .collection('resultats')
          .doc('${result.activityId}_${result.childId}')
          .set(result.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du résultat : $e');
    }
  }

  // 5. Récupérer le résultat d'un enfant pour une activité donnée
  Future<ActivityResultModel?> fetchResultForChild(
    String activityId,
    String childId,
  ) async {
    try {
      final doc = await _firestore
          .collection('resultats')
          .doc('${activityId}_$childId')
          .get();

      if (doc.exists && doc.data() != null) {
        return ActivityResultModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du résultat : $e');
    }
  }
}