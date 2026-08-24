import 'package:cloud_firestore/cloud_firestore.dart';

class Progression {
  final String tutorielId;
  final num position;
  final num duree;
  final bool termine;
  final DateTime dateDerniereLecture;

  Progression({
    required this.tutorielId,
    required this.position,
    required this.duree,
    required this.termine,
    required this.dateDerniereLecture,
  });

  factory Progression.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Progression(
      tutorielId: data['tutorielId'] as String,
      position: data['position'] as num,
      duree: data['duree'] as num,
      termine: data['termine'] as bool,
      dateDerniereLecture:
          (data['dateDerniereLecture'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tutorielId': tutorielId,
      'position': position,
      'duree': duree,
      'termine': termine,
      'dateDerniereLecture':
          Timestamp.fromDate(dateDerniereLecture),
    };
  }
}