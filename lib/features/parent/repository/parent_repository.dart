// lib/features/parent/repositories/parent_repository.dart

import '../models/parent_model.dart';

abstract class ParentRepository {
  Future<ParentModel> fetchParentProfile(String parentId);
  Future<void> ajouterEnfant(String parentId, EnfantModel enfant);
}

class ParentRepositoryImpl implements ParentRepository {
  // Données factices pour tester en local avant de brancher Firestore
  @override
  Future<ParentModel> fetchParentProfile(String parentId) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulation réseau

    return ParentModel(
      id: parentId,
      name: 'Aissata',
      email: 'aissata@example.com',
      enfants: [
        EnfantModel(id: '1', name: 'Nour', age: 5, level: 'Niveau 3'),
        EnfantModel(id: '2', name: 'Ilyas', age: 7, level: 'Niveau 4'),
        EnfantModel(id: '3', name: 'Mariam', age: 4, level: 'Niveau 2'),
      ],
    );
  }

  @override
  Future<void> ajouterEnfant(String parentId, EnfantModel enfant) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Tu ajouteras la requête Firebase Firestore ici plus tard
  }
}