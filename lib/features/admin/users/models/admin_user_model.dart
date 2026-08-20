import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  final String utilisateurId;
  final String email;
  final String nom;
  final String? photoUrl;
  final String? telephone;
  final String role; // 'PARENT' | 'MANAGER' | 'ADMIN'
  final bool estActif;
  final int nombreEnfants;
  final int nombreFavoris;
  final Timestamp dateCreation;
  final Timestamp dateModification;

  const AdminUserModel({
    required this.utilisateurId,
    required this.email,
    required this.nom,
    this.photoUrl,
    this.telephone,
    this.role = 'PARENT',
    this.estActif = true,
    this.nombreEnfants = 0,
    this.nombreFavoris = 0,
    required this.dateCreation,
    required this.dateModification,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isManager => role.toUpperCase() == 'MANAGER';
  bool get isParent => role.toUpperCase() == 'PARENT';

  AdminUserModel copyWith({
    String? utilisateurId,
    String? email,
    String? nom,
    String? photoUrl,
    String? telephone,
    String? role,
    bool? estActif,
    int? nombreEnfants,
    int? nombreFavoris,
    Timestamp? dateCreation,
    Timestamp? dateModification,
  }) {
    return AdminUserModel(
      utilisateurId: utilisateurId ?? this.utilisateurId,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      photoUrl: photoUrl ?? this.photoUrl,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      estActif: estActif ?? this.estActif,
      nombreEnfants: nombreEnfants ?? this.nombreEnfants,
      nombreFavoris: nombreFavoris ?? this.nombreFavoris,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  factory AdminUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return AdminUserModel(
      utilisateurId: data['utilisateurId'] ?? snapshot.id,
      email: data['email'] ?? '',
      nom: data['nom'] ?? 'Utilisateur',
      photoUrl: data['photoUrl'],
      telephone: data['telephone'],
      role: data['role'] ?? 'PARENT',
      estActif: data['estActif'] ?? true,
      nombreEnfants: (data['nombreEnfants'] as num?)?.toInt() ?? 0,
      nombreFavoris: (data['nombreFavoris'] as num?)?.toInt() ?? 0,
      dateCreation: data['dateCreation'] ?? Timestamp.now(),
      dateModification: data['dateModification'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'utilisateurId': utilisateurId,
      'email': email,
      'nom': nom,
      'photoUrl': photoUrl,
      'telephone': telephone,
      'role': role,
      'estActif': estActif,
      'nombreEnfants': nombreEnfants,
      'nombreFavoris': nombreFavoris,
      'dateCreation': dateCreation,
      'dateModification': dateModification,
    };
  }
}
