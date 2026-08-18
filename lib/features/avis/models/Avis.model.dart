import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/auth/models/enums/StatutAvis.enum.dart';



class Avis {
  final String? id;
  final String cibleId;    // ID de l'activité, tutoriel ou jouet
  final String typeCible;  // 'activite', 'tutoriel', 'jouet'
  final String utilisateurId;
  final String nomUtilisateur;
  final double note;       // Note sur 5
  final String commentaire;
  final StatutAvis statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  Avis({
    this.id,
    required this.cibleId,
    required this.typeCible,
    required this.utilisateurId,
    required this.nomUtilisateur,
    required this.note,
    required this.commentaire,
    this.statut = StatutAvis.visible,
    required this.dateCreation,
    required this.dateModification,
  });

  // Créer un avis depuis Firestore
  factory Avis.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Avis(
      id: doc.id,
      cibleId: data['cibleId'] ?? '',
      typeCible: data['typeCible'] ?? '',
      utilisateurId: data['utilisateurId'] ?? '',
      nomUtilisateur: data['nomUtilisateur'] ?? 'Utilisateur',
      note: (data['note'] ?? 0.0).toDouble(),
      commentaire: data['commentaire'] ?? '',
      statut: _getStatutFromString(data['statut']),
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'cibleId': cibleId,
      'typeCible': typeCible,
      'utilisateurId': utilisateurId,
      'nomUtilisateur': nomUtilisateur,
      'note': note,
      'commentaire': commentaire,
      'statut': statut.toString().split('.').last,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  static StatutAvis _getStatutFromString(String value) {
    switch (value) {
      case 'visible': return StatutAvis.visible;
      case 'masque': return StatutAvis.masque;
      default: return StatutAvis.signale;
    }
  }

  Avis copyWith({
    String? id,
    String? cibleId,
    String? typeCible,
    String? utilisateurId,
    String? nomUtilisateur,
    double? note,
    String? commentaire,
    StatutAvis? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Avis(
      id: id ?? this.id,
      cibleId: cibleId ?? this.cibleId,
      typeCible: typeCible ?? this.typeCible,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      nomUtilisateur: nomUtilisateur ?? this.nomUtilisateur,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}