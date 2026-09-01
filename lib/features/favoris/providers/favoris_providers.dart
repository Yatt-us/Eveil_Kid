import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';
import 'package:eveilkid/features/favoris/repository/favoris_repository.dart';

final favoriServiceProvider = Provider<FavoriService>((ref) {
  return FavoriService(FirebaseFirestore.instance);
});

final favorisProvider = StreamProvider.family<List<Favori>, String>((
  ref,
  utilisateurId,
) {
  final service = ref.watch(favoriServiceProvider);
  return service.getFavoris(utilisateurId);
});

/// Stream des favoris de l'utilisateur actuellement connecté
final currentUserFavorisProvider = StreamProvider<List<Favori>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.utilisateur?.utilisateurId ?? '';
  if (userId.isEmpty) {
    return Stream.value([]);
  }
  final service = ref.watch(favoriServiceProvider);
  return service.getFavoris(userId);
});

/// Vérifie si un élément précis (jouet / tutoriel) est en favori
final isElementFavoriProvider = Provider.family<bool, String>((ref, elementId) {
  final favorisAsync = ref.watch(currentUserFavorisProvider);
  final favoris = favorisAsync.value ?? [];
  return favoris.any((f) => f.elementId == elementId);
});
