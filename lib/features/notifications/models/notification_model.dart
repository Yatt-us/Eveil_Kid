import 'package:cloud_firestore/cloud_firestore.dart';

enum NotifType {
  commande,
  livraison,
  nouveauJouet,
  promo,
  activite,
  tutoriel,
  enfant,
  systeme,
}

extension NotifTypeExt on NotifType {
  String get label {
    switch (this) {
      case NotifType.commande:
        return 'Commande';
      case NotifType.livraison:
        return 'Livraison';
      case NotifType.nouveauJouet:
        return 'Nouveau jouet';
      case NotifType.promo:
        return 'Promotion';
      case NotifType.activite:
        return 'Activité';
      case NotifType.tutoriel:
        return 'Tutoriel';
      case NotifType.enfant:
        return 'Enfant';
      case NotifType.systeme:
        return 'Système';
    }
  }

  static NotifType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'commande':
        return NotifType.commande;
      case 'livraison':
        return NotifType.livraison;
      case 'nouveau_jouet':
      case 'nouveaujouet':
        return NotifType.nouveauJouet;
      case 'promo':
      case 'promotion':
        return NotifType.promo;
      case 'activite':
      case 'activité':
        return NotifType.activite;
      case 'tutoriel':
        return NotifType.tutoriel;
      case 'enfant':
        return NotifType.enfant;
      default:
        return NotifType.systeme;
    }
  }
}

class NotificationModel {
  final String notificationId;
  final String utilisateurId;
  final String titre;
  final String corps;
  final NotifType type;
  final bool estLue;
  final String? imageUrl;
  final String? routeDestination; // route vers laquelle naviguer au clic
  final Map<String, dynamic>? payload;
  final DateTime dateCreation;
  final DateTime? dateLecture;

  NotificationModel({
    required this.notificationId,
    required this.utilisateurId,
    required this.titre,
    required this.corps,
    required this.type,
    this.estLue = false,
    this.imageUrl,
    this.routeDestination,
    this.payload,
    required this.dateCreation,
    this.dateLecture,
  });

  NotificationModel copyWith({
    String? notificationId,
    String? utilisateurId,
    String? titre,
    String? corps,
    NotifType? type,
    bool? estLue,
    String? imageUrl,
    String? routeDestination,
    Map<String, dynamic>? payload,
    DateTime? dateCreation,
    DateTime? dateLecture,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      titre: titre ?? this.titre,
      corps: corps ?? this.corps,
      type: type ?? this.type,
      estLue: estLue ?? this.estLue,
      imageUrl: imageUrl ?? this.imageUrl,
      routeDestination: routeDestination ?? this.routeDestination,
      payload: payload ?? this.payload,
      dateCreation: dateCreation ?? this.dateCreation,
      dateLecture: dateLecture ?? this.dateLecture,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'utilisateurId': utilisateurId,
      'titre': titre,
      'corps': corps,
      'type': type.name,
      'estLue': estLue,
      'imageUrl': imageUrl,
      'routeDestination': routeDestination,
      'payload': payload,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateLecture': dateLecture != null ? Timestamp.fromDate(dateLecture!) : null,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return NotificationModel(
      notificationId: docId.isNotEmpty ? docId : (map['notificationId'] ?? ''),
      utilisateurId: map['utilisateurId'] ?? '',
      titre: map['titre'] ?? '',
      corps: map['corps'] ?? '',
      type: NotifTypeExt.fromString(map['type']),
      estLue: map['estLue'] ?? false,
      imageUrl: map['imageUrl'],
      routeDestination: map['routeDestination'],
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
      dateCreation: parseDate(map['dateCreation']),
      dateLecture: map['dateLecture'] != null ? parseDate(map['dateLecture']) : null,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return NotificationModel.fromMap(data, doc.id);
  }
}
