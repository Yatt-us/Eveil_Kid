import 'package:cloud_firestore/cloud_firestore.dart';

enum TypeElement { jouet, tutoriel }

class Favori {
  final String favoriId;
  final String utilisateurId;
  final String elementId;

  final TypeElement typeElement;

  final String titre;
  final String miniatureUrl;
  final double prix;

  final DateTime dateCreation;

  const Favori({
    required this.favoriId,
    required this.utilisateurId,
    required this.elementId,
    required this.typeElement,
    required this.titre,
    required this.miniatureUrl,
    required this.prix,
    required this.dateCreation,
  });

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory Favori.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Favori(
      favoriId: doc.id,
      utilisateurId: data['utilisateurId'] as String? ?? '',
      elementId: data['elementId'] as String? ?? '',

      typeElement: data['typeElement'] == 'JOUET'
          ? TypeElement.jouet
          : TypeElement.tutoriel,

      titre: data['titre'] as String? ?? '',
      miniatureUrl: data['miniatureUrl'] as String? ?? '',
      prix: (data['prix'] as num?)?.toDouble() ?? 0.0,

      dateCreation: _parseDate(data['dateCreation']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'utilisateurId': utilisateurId,
      'elementId': elementId,
      'typeElement': typeElement == TypeElement.jouet ? 'JOUET' : 'TUTORIEL',
      'titre': titre,
      'miniatureUrl': miniatureUrl,
      'prix': prix,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }
}
