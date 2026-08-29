import 'package:cloud_firestore/cloud_firestore.dart';

class ResultatsActivite {
  final String? id;
  final String activiteId;
  final int score;
  final int nombreQuestions;
  final int bonnesReponses;
  final int mauvaisesReponses;
  final int pointsGagnes;
  final bool estTerminee;
  final int numeroTentative;
  final DateTime dateDebut;
  final DateTime? dateFin;

  const ResultatsActivite({
    this.id,
    required this.activiteId,
    required this.score,
    required this.nombreQuestions,
    required this.bonnesReponses,
    required this.mauvaisesReponses,
    required this.pointsGagnes,
    required this.estTerminee,
    required this.numeroTentative,
    required this.dateDebut,
    this.dateFin,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ResultatsActivite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final activite = data['activiteId'];

    return ResultatsActivite(
      id: snapshot.id,
      activiteId: activite is DocumentReference
          ? activite.id
          : activite as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      nombreQuestions: (data['nombreQuestions'] as num?)?.toInt() ?? 0,
      bonnesReponses: (data['bonnesReponses'] as num?)?.toInt() ?? 0,
      mauvaisesReponses: (data['mauvaisesReponses'] as num?)?.toInt() ?? 0,
      pointsGagnes: (data['pointsGagnes'] as num?)?.toInt() ?? 0,
      estTerminee: data['estTerminee'] as bool? ?? false,
      numeroTentative: (data['numeroTentative'] as num?)?.toInt() ?? 1,
      dateDebut: _parseDate(data['dateDebut']),
      dateFin: data['dateFin'] == null ? null : _parseDate(data['dateFin']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'activiteId': activiteId,
      'score': score,
      'nombreQuestions': nombreQuestions,
      'bonnesReponses': bonnesReponses,
      'mauvaisesReponses': mauvaisesReponses,
      'pointsGagnes': pointsGagnes,
      'estTerminee': estTerminee,
      'numeroTentative': numeroTentative,
      'dateDebut': Timestamp.fromDate(dateDebut),
      if (dateFin != null) 'dateFin': Timestamp.fromDate(dateFin!),
    };
  }
}
