import 'package:cloud_firestore/cloud_firestore.dart';

class AvisModel {
  final String avisId;
  final String jouetId;
  final String utilisateurId;
  final String nomUtilisateur;
  final String? photoUrl;
  final double note; // Note de 1.0 à 5.0
  final String commentaire;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final String? reponseAdmin;
  final DateTime? dateReponseAdmin;

  AvisModel({
    required this.avisId,
    required this.jouetId,
    required this.utilisateurId,
    required this.nomUtilisateur,
    this.photoUrl,
    required this.note,
    required this.commentaire,
    required this.dateCreation,
    this.dateModification,
    this.reponseAdmin,
    this.dateReponseAdmin,
  });

  AvisModel copyWith({
    String? avisId,
    String? jouetId,
    String? utilisateurId,
    String? nomUtilisateur,
    String? photoUrl,
    double? note,
    String? commentaire,
    DateTime? dateCreation,
    DateTime? dateModification,
    String? reponseAdmin,
    DateTime? dateReponseAdmin,
  }) {
    return AvisModel(
      avisId: avisId ?? this.avisId,
      jouetId: jouetId ?? this.jouetId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      nomUtilisateur: nomUtilisateur ?? this.nomUtilisateur,
      photoUrl: photoUrl ?? this.photoUrl,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      reponseAdmin: reponseAdmin ?? this.reponseAdmin,
      dateReponseAdmin: dateReponseAdmin ?? this.dateReponseAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avisId': avisId,
      'jouetId': jouetId,
      'utilisateurId': utilisateurId,
      'nomUtilisateur': nomUtilisateur,
      'photoUrl': photoUrl,
      'note': note,
      'commentaire': commentaire,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': dateModification != null
          ? Timestamp.fromDate(dateModification!)
          : null,
      'reponseAdmin': reponseAdmin,
      'dateReponseAdmin': dateReponseAdmin != null
          ? Timestamp.fromDate(dateReponseAdmin!)
          : null,
    };
  }

  factory AvisModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AvisModel(
      avisId: docId.isNotEmpty ? docId : (map['avisId'] ?? ''),
      jouetId: map['jouetId'] ?? '',
      utilisateurId: map['utilisateurId'] ?? '',
      nomUtilisateur: map['nomUtilisateur'] ?? 'Utilisateur',
      photoUrl: map['photoUrl'],
      note: (map['note'] is num) ? (map['note'] as num).toDouble() : 5.0,
      commentaire: map['commentaire'] ?? '',
      dateCreation: parseDate(map['dateCreation']),
      dateModification: map['dateModification'] != null
          ? parseDate(map['dateModification'])
          : null,
      reponseAdmin: map['reponseAdmin'],
      dateReponseAdmin: map['dateReponseAdmin'] != null
          ? parseDate(map['dateReponseAdmin'])
          : null,
    );
  }

  factory AvisModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AvisModel.fromMap(data, doc.id);
  }
}
