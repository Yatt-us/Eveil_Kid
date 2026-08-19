import 'package:cloud_firestore/cloud_firestore.dart';

class ArticlePanier {
  final String articlePanierId;
  final String utilisateurId;
  final String jouetId;

  final String nomJouet;
  final double prixUnitaire;
  final String miniatureUrl;
  final int stockDispo;

  final int quantite;

  final DateTime dateCreation;
  final DateTime dateModification;

  const ArticlePanier({
    required this.articlePanierId,
    required this.utilisateurId,
    required this.jouetId,
    required this.nomJouet,
    required this.prixUnitaire,
    required this.miniatureUrl,
    required this.stockDispo,
    required this.quantite,
    required this.dateCreation,
    required this.dateModification,
  });

  factory ArticlePanier.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ArticlePanier(
      articlePanierId: doc.id,
      utilisateurId: data['utilisateurId'] as String,
      jouetId: data['jouetId'] as String,
      nomJouet: data['nomJouet'] as String,
      prixUnitaire: (data['prixUnitaire'] as num).toDouble(),
      miniatureUrl: data['miniatureUrl'] as String,
      stockDispo: (data['stockDispo'] as num).toInt(),
      quantite: (data['quantite'] as num).toInt(),
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'utilisateurId': utilisateurId,
      'jouetId': jouetId,
      'nomJouet': nomJouet,
      'prixUnitaire': prixUnitaire,
      'miniatureUrl': miniatureUrl,
      'stockDispo': stockDispo,
      'quantite': quantite,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  double get sousTotal => prixUnitaire * quantite;
}
