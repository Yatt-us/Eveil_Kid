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

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory ArticlePanier.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ArticlePanier(
      articlePanierId: doc.id,
      utilisateurId: data['utilisateurId'] as String? ?? '',
      jouetId: data['jouetId'] as String? ?? '',
      nomJouet: data['nomJouet'] as String? ?? '',
      prixUnitaire: (data['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      miniatureUrl: data['miniatureUrl'] as String? ?? '',
      stockDispo: (data['stockDispo'] as num?)?.toInt() ?? 0,
      quantite: (data['quantite'] as num?)?.toInt() ?? 1,
      dateCreation: _parseDate(data['dateCreation']),
      dateModification: _parseDate(data['dateModification']),
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
