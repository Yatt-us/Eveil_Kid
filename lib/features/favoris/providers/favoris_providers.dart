import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';
import 'package:eveilkid/features/favoris/repository/favoris_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
