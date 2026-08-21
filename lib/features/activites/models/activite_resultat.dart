import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle stockant le résultat obtenu par un enfant à la fin d'une activité.
class ActivityResult {
  final String activityId;
  final String childId;
  final int score;
  final int totalQuestions;
  final int bonnesReponses;
  final int mauvaisesReponses;
  final Map<String, String> reponses; // Ex: {"q_0": "opt_1", "q_1": "opt_3"}
  final DateTime date;

  const ActivityResult({
    required this.activityId,
    required this.childId,
    required this.score,
    required this.totalQuestions,
    required this.bonnesReponses,
    int? mauvaisesReponses,
    required this.reponses,
    required this.date,
  }) : mauvaisesReponses = mauvaisesReponses ?? (totalQuestions - bonnesReponses);

  double get ratio => totalQuestions > 0 ? (bonnesReponses / totalQuestions).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'childId': childId,
      'score': score,
      'totalQuestions': totalQuestions,
      'bonnesReponses': bonnesReponses,
      'mauvaisesReponses': mauvaisesReponses,
      'reponses': reponses,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ActivityResult.fromMap(Map<String, dynamic> map) {
    final rawReponses = map['reponses'] as Map<String, dynamic>? ?? {};
    final parsedReponses = rawReponses.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    DateTime dateParsed;
    if (map['date'] is Timestamp) {
      dateParsed = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      dateParsed = DateTime.tryParse(map['date']) ?? DateTime.now();
    } else {
      dateParsed = DateTime.now();
    }

    final total = (map['totalQuestions'] as num?)?.toInt() ?? 0;
    final bonnes = (map['bonnesReponses'] as num?)?.toInt() ?? 0;
    final mauvaises = (map['mauvaisesReponses'] as num?)?.toInt() ?? (total - bonnes);

    return ActivityResult(
      activityId: map['activityId']?.toString() ?? '',
      childId: map['childId']?.toString() ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalQuestions: total,
      bonnesReponses: bonnes,
      mauvaisesReponses: mauvaises,
      reponses: parsedReponses,
      date: dateParsed,
    );
  }
}
