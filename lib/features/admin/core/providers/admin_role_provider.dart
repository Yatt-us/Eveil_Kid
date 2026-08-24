import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import '../models/admin_role.dart';

/// Provider dérivé directement et strictement de l'utilisateur connecté dans Firebase / Firestore.
/// Ne permet aucune manipulation artificielle de rôle côté client.
final adminRoleProvider = Provider<AdminRole>((ref) {
  final authState = ref.watch(authProvider);
  final userRole = authState.utilisateur?.role;

  if (userRole == UserRole.admin) {
    return AdminRole.admin;
  }
  return AdminRole.manager;
});
