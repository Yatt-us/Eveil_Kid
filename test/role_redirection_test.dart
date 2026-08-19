import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Role-based Auth Redirection Tests', () {
    test('Utilisateur avec rôle ADMIN est identifié comme administrateur', () {
      final adminUser = Utilisateur(
        utilisateurId: 'admin_1',
        role: UserRole.admin,
        email: 'admin@eveilkid.com',
        nom: 'Admin Principal',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: adminUser,
        isInitialized: true,
      );

      final isAdminOrManager = state.utilisateur?.role == UserRole.admin ||
          state.utilisateur?.role == UserRole.manager;

      expect(isAdminOrManager, isTrue);
      expect(state.utilisateur?.role, equals(UserRole.admin));
    });

    test('Utilisateur avec rôle MANAGER est identifié comme gestionnaire', () {
      final managerUser = Utilisateur(
        utilisateurId: 'manager_1',
        role: UserRole.manager,
        email: 'manager@eveilkid.com',
        nom: 'Manager Catalogue',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: managerUser,
        isInitialized: true,
      );

      final isAdminOrManager = state.utilisateur?.role == UserRole.admin ||
          state.utilisateur?.role == UserRole.manager;

      expect(isAdminOrManager, isTrue);
      expect(state.utilisateur?.role, equals(UserRole.manager));
    });

    test('Utilisateur avec rôle PARENT est identifié comme parent', () {
      final parentUser = Utilisateur(
        utilisateurId: 'parent_1',
        role: UserRole.parent,
        email: 'parent@example.com',
        nom: 'Parent Test',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: parentUser,
        isInitialized: true,
      );

      final isAdminOrManager = state.utilisateur?.role == UserRole.admin ||
          state.utilisateur?.role == UserRole.manager;

      expect(isAdminOrManager, isFalse);
      expect(state.utilisateur?.role, equals(UserRole.parent));
    });

    test('Admin tentant d’accéder à l’accueil parent (/) est redirigé vers /admin', () {
      final adminUser = Utilisateur(
        utilisateurId: 'admin_1',
        role: UserRole.admin,
        email: 'admin@eveilkid.com',
        nom: 'Admin Principal',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: adminUser,
        isInitialized: true,
      );

      final role = state.utilisateur?.role;
      final isAdminOrManager = role == UserRole.admin || role == UserRole.manager;

      // Simulation de la logique de redirection de app_router.dart pour l'admin
      const matchedLocation = '/';
      final isSplash = matchedLocation == '/splash';
      final isGoingToAuth = matchedLocation == '/login' || matchedLocation == '/register';

      String? targetRoute;
      if (isAdminOrManager) {
        if (isSplash || isGoingToAuth || matchedLocation == '/') {
          targetRoute = '/admin';
        }
      }

      expect(targetRoute, equals('/admin'));
    });

    test('Parent tentant d’accéder à l’espace administration (/admin) est redirigé vers /', () {
      final parentUser = Utilisateur(
        utilisateurId: 'parent_1',
        role: UserRole.parent,
        email: 'parent@example.com',
        nom: 'Parent Test',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: parentUser,
        isInitialized: true,
      );

      final role = state.utilisateur?.role;
      final isAdminOrManager = role == UserRole.admin || role == UserRole.manager;

      // Simulation de la logique de redirection de app_router.dart pour le parent
      const matchedLocation = '/admin/products';
      String? targetRoute;
      if (!isAdminOrManager) {
        if (matchedLocation.startsWith('/admin')) {
          targetRoute = '/';
        }
      }

      expect(targetRoute, equals('/'));
    });
  });
}
