import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityResultModel {
  final String activityId;
  final String childId;
  final int score;
  final int totalQuestions;
  final int bonnesReponses;
  final Map<String, String> reponses; // Ex: {"q1": "opt1", "q2": "opt3"}
  final DateTime date;

  const ActivityResultModel({
    required this.activityId,
    required this.childId,
    required this.score,
    required this.totalQuestions,
    required this.bonnesReponses,
    required this.reponses,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'childId': childId,
      'score': score,
      'totalQuestions': totalQuestions,
      'bonnesReponses': bonnesReponses,
      'reponses': reponses,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ActivityResultModel.fromMap(Map<String, dynamic> map) {
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

    return ActivityResultModel(
      activityId: map['activityId'] ?? '',
      childId: map['childId'] ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
      bonnesReponses: (map['bonnesReponses'] as num?)?.toInt() ?? 0,
      reponses: parsedReponses,
      date: dateParsed,
    );
  }
}