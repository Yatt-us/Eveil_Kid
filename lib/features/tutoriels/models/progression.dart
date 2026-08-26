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

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory Progression.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Progression(
      tutorielId: data['tutorielId'] as String? ?? '',
      position: (data['position'] as num?) ?? 0,
      duree: (data['duree'] as num?) ?? 0,
      termine: (data['termine'] as bool?) ?? false,
      dateDerniereLecture: _parseDate(data['dateDerniereLecture']),
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