import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/avis/enums/StatutAvis.enum.dart';



class Avis {
  final String? id;
  final String cibleId;    
  final String typeCible;  
  final String utilisateurId;
  final String nomUtilisateur;
  final double note;       
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

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory Avis.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    
    return Avis(
      id: doc.id,
      cibleId: data['cibleId'] ?? '',
      typeCible: data['typeCible'] ?? '',
      utilisateurId: data['utilisateurId'] ?? '',
      nomUtilisateur: data['nomUtilisateur'] ?? 'Utilisateur',
      note: (data['note'] ?? 0.0).toDouble(),
      commentaire: data['commentaire'] ?? '',
      statut: _getStatutFromString(data['statut'] ?? ''),
      dateCreation: _parseDate(data['dateCreation']),
      dateModification: _parseDate(data['dateModification']),
    );
  }

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