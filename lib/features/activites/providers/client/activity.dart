import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity.dart';

// 1. Stream Provider pour récupérer les activités en temps réel depuis Firebase
final activitesStreamProvider = StreamProvider<List<Activite>>((ref) {
  return FirebaseFirestore.instance
      .collection('activites')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Activite.fromFirestore(doc)).toList();
  });
});

// 2. State Notifier moderne pour mémoriser l'onglet actif (0: Toutes, 1: En cours, 2: Terminées)
final activiteFilterProvider = NotifierProvider<ActiviteFilterNotifier, int>(() {
  return ActiviteFilterNotifier();
});

class ActiviteFilterNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Valeur initiale : 0
  }

  void setFilter(int newFilter) {
    state = newFilter;
  }
}