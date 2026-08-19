import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  parent,
  manager,
  admin;

  String get value {
    switch (this) {
      case UserRole.parent:
        return 'PARENT';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'PARENT':
        return UserRole.parent;

      case 'MANAGER':
        return UserRole.manager;

      case 'ADMIN':
        return UserRole.admin;

      default:
        throw ArgumentError(
          'Rôle utilisateur inconnu : $value',
        );
    }
  }
}

class Utilisateur {
  final String utilisateurId;
  final UserRole role;
  final int? nombreFavoris;
  final int? nombreEnfants;
  final String email;
  final String nom;
  final String? photoUrl;
  final String? telephone;
  final bool estActif;
  final DateTime? dateCreation;
  final DateTime? dateModification;

  const Utilisateur({
    required this.utilisateurId,
    required this.role,
    this.nombreFavoris,
    this.nombreEnfants,
    required this.email,
    required this.nom,
    this.photoUrl,
    this.telephone,
    required this.estActif,
    this.dateCreation,
    this.dateModification,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      utilisateurId: map['utilisateurId'] as String,
      role: UserRole.fromValue(map['role'] as String),
      nombreFavoris: map['nombreFavoris'] as int?,
      nombreEnfants: map['nombreEnfants'] as int?,
      email: map['email'] as String,
      nom: map['nom'] as String,
      photoUrl: map['photoUrl'] as String?,
      telephone: map['telephone'] as String?,
      estActif: map['estActif'] as bool? ?? true,
      dateCreation: _timestampToDateTime(
        map['dateCreation'],
      ),
      dateModification: _timestampToDateTime(
        map['dateModification'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'utilisateurId': utilisateurId,
      'role': role.value,
      'nombreFavoris': nombreFavoris,
      'nombreEnfants': nombreEnfants,
      'email': email,
      'nom': nom,
      'photoUrl': photoUrl,
      'telephone': telephone,
      'estActif': estActif,
      'dateCreation': dateCreation,
      'dateModification': dateModification,
    };
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}