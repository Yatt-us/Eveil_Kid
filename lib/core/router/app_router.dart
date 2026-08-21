import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_catalog_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_category_detail_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_category_list_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_form_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_list_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/dashboard_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_user_list_page.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/presentation/pages/login_page.dart';
import 'package:eveilkid/features/auth/presentation/pages/register_page.dart';
import 'package:eveilkid/features/auth/presentation/pages/splash_page.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/parent/presentation/pages/parent_main_scaffold.dart';
import 'package:eveilkid/features/tutoriels/presentations/pages/tutorielPage.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/activites/presentation/pages/client/activites_list_page.dart';
import 'package:eveilkid/features/activites/presentation/pages/client/activites_play_page.dart';
import 'package:eveilkid/features/activites/presentation/pages/client/activites_resultat_page.dart';
import 'package:eveilkid/features/activites/presentation/pages/client/activites_corrige_page.dart';

/// Notifier pour déclencher les rafraîchissements de GoRouter lors des changements d'état d'authentification Riverpod
class _RouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, next) => notifyListeners(),
    );
  }
}

/// Provider de configuration globale de GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);

      // 1. Initialisation Firebase en cours -> afficher l'écran splash
      if (!authState.isInitialized) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthenticated = authState.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // 2. Utilisateur non authentifié (mode visiteur)
      if (!isAuthenticated) {
        // Autoriser l'accès aux pages d'authentification, accueil public ou tutoriels
        if (isGoingToAuth || state.matchedLocation == AppRoutes.home || state.matchedLocation == AppRoutes.tutoriels) {
          return null;
        }
        // Rediriger vers la page de connexion pour toute autre page
        return AppRoutes.login;
      }

      final role = authState.utilisateur?.role;
      final isAdminOrManager = role == UserRole.admin || role == UserRole.manager;

      // 3. Utilisateur Administrateur / Manager -> strictement dirigé et confiné à l'espace Admin
      if (isAdminOrManager) {
        // Un Manager n'a absolument pas accès à la gestion des utilisateurs -> redirection vers /admin
        if (role == UserRole.manager && state.matchedLocation.startsWith(AppRoutes.adminUsers)) {
          return AppRoutes.admin;
        }

        // Si l'admin est sur splash ou auth
        if (isSplash || isGoingToAuth) {
          return AppRoutes.admin;
        }
        // Accès autorisé aux pages d'administration
        if (state.matchedLocation.startsWith('/admin') || state.matchedLocation == AppRoutes.tutoriels) {
          return null;
        }
        // Toute autre tentative d'accès -> rediriger vers /admin
        return AppRoutes.admin;
      }

      // 4. Utilisateur Parent -> confiné à l'espace Parent
      if (!isAdminOrManager) {
        // Redirection vers l'accueil parent depuis splash ou auth
        if (isSplash || isGoingToAuth) {
          return AppRoutes.home;
        }
        // Accès formellement interdit à l'espace administration
        if (state.matchedLocation.startsWith('/admin')) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      // ── Splash ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Authentification ──
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Accueil & Fonctionnalités Utilisateur ──
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ParentMainScaffold(),
      ),
      GoRoute(
        path: AppRoutes.tutoriels,
        builder: (context, state) => const TutorielPage(),
      ),
      GoRoute(
        path: AppRoutes.activites,
        builder: (context, state) => const ActivitesListPage(),
      ),
      GoRoute(
        path: AppRoutes.activitesPlay,
        builder: (context, state) => const ActivitesPlayPage(),
      ),
      GoRoute(
        path: AppRoutes.activitesResultat,
        builder: (context, state) => const ActivitesResultatPage(),
      ),
      GoRoute(
        path: AppRoutes.activitesCorrige,
        builder: (context, state) => const ActivitesCorrigePage(),
      ),

      // ── Espace Administration (StatefulShellRoute avec sidebar persistant) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 0. Tableau de bord
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.admin,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // 1. Produits
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminProducts,
                builder: (context, state) => const AdminProductListPage(),
              ),
            ],
          ),
          // 2. Catégories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminCategories,
                builder: (context, state) => const AdminCategoryListPage(),
              ),
            ],
          ),
          // 3. Utilisateurs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminUsers,
                builder: (context, state) => const AdminUserListPage(),
              ),
            ],
          ),
          // 4. Catalogue global
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminCatalog,
                builder: (context, state) => const AdminCatalogPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.adminProductForm,
        builder: (context, state) {
          final jouet = state.extra as Jouet?;
          return AdminProductFormPage(jouetToEdit: jouet);
        },
      ),
      GoRoute(
        path: AppRoutes.adminCategoryForm,
        builder: (context, state) {
          final cat = state.extra as Categorie?;
          return AdminCategoryDetailPage(categorieToEdit: cat);
        },
      ),
    ],

    // ── Gestion Erreur 404 ──
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page introuvable'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Page Introuvable (404)',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'L’adresse demandée n’existe pas ou a été déplacée.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
