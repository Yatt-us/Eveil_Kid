import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/panier/models/panier.dart';
import 'package:eveilkid/features/panier/repository/panier_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final panierServiceProvider = Provider<PanierService>((ref) {
  return PanierService(
    FirebaseFirestore.instance,
  );
});

final panierProvider =
    StreamProvider.family<List<ArticlePanier>, String>(
  (ref, utilisateurId) {
    final service = ref.watch(
      panierServiceProvider,
    );

    return service.getPanier(utilisateurId);
  },
);