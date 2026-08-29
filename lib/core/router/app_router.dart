import 'package:eveilkid/features/activites/presentation/pages/admin/activites_liste.dart';
import 'package:eveilkid/features/activites/presentation/pages/admin/add_activity_screen.dart';
import 'package:eveilkid/features/activites/presentation/pages/admin/edit_activity_screen.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/options_questions/choose_question_type_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/add_question_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/edit_question_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/question_detail_screen.dart';
import 'package:eveilkid/features/questions/presentation/pages/questions_list_screen.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/features/enfant/presentation/pages/acceuil_enfant_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/tutoriel_page.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/parents/presentation/pages/accueil_parent.dart';
import 'package:eveilkid/features/parents/presentation/pages/aide_support_page.dart';
import 'package:eveilkid/features/parents/presentation/pages/detail_enfant.dart';
import 'package:eveilkid/features/parents/presentation/pages/profil_parent.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/admin/presentation/pages/admin/admin_tutoriel_detail_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/admin/admin_tutoriel_form_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/admin/tutoriels_list_screen.dart';
import 'package:eveilkid/features/favoris/presentation/pages/favoris_page.dart';
import 'package:eveilkid/features/panier/presentation/pages/panier_page.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:eveilkid/features/admin/presentation/pages/commandes/admin_commandes_screen.dart';
import 'package:eveilkid/features/admin/presentation/pages/commandes/admin_detail_commande_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_catalog_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_category_detail_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_category_list_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_form_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/catalog/admin_product_list_page.dart';
import 'package:eveilkid/features/admin/presentation/pages/dashboard_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_manager_form_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_staff_list_page.dart';
import 'package:eveilkid/features/admin/users/presentation/pages/admin_user_list_page.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/presentation/pages/auth_action_page.dart';
import 'package:eveilkid/features/auth/presentation/pages/login_page.dart';
import 'package:eveilkid/features/auth/presentation/pages/register_page.dart';
import 'package:eveilkid/features/auth/presentation/pages/splash_page.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
//import 'package:eveilkid/features/activites/presentation/pages/client/activites_list_page.dart';
//import 'package:eveilkid/features/activites/presentation/pages/client/activites_play_page.dart';
//import 'package:eveilkid/features/activites/presentation/pages/client/activites_resultat_page.dart';
//import 'package:eveilkid/features/activites/presentation/pages/client/activites_corrige_page.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_detail_screen.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouets_screen.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
//import 'package:eveilkid/features/tutoriels/presentations/pages/tutorielPage.dart';

/// Notifier pour déclencher les rafraîchissements de GoRouter lors des changements d'état d'authentification Riverpod
class _RouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, next) => notifyListeners());
    _ref.listen<ChildModeState>(childModeProvider, (_, next) => notifyListeners());
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
      final childMode = ref.read(childModeProvider);

      // 1. Initialisation Firebase ou ChildMode en cours -> afficher l'écran splash
      if (!authState.isInitialized || !childMode.isInitialized) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final isAuthenticated = authState.isAuthenticated;
      final uri = state.uri;
      final host = uri.host;
      final path = uri.path;

      // Normalisation des Custom URL Schemes (eveilkid://...)
      if (host == 'reset-password') {
        final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
        if (state.matchedLocation != AppRoutes.resetPassword) {
          return '${AppRoutes.resetPassword}$query';
        }
      }

      if (host == 'auth' &&
          (path == '/action' || path == 'action' || path.isEmpty)) {
        final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
        if (state.matchedLocation != AppRoutes.authAction) {
          return '${AppRoutes.authAction}$query';
        }
      }

      if (host == 'verify-email') {
        final query = uri.query.isNotEmpty ? '&${uri.query}' : '';
        return '${AppRoutes.authAction}?mode=verifyEmail$query';
      }

      if (host == 'login' && state.matchedLocation != AppRoutes.login) {
        return AppRoutes.login;
      }

      if (host == 'home' && state.matchedLocation != AppRoutes.home) {
        return AppRoutes.home;
      }

      final isGoingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isAuthAction =
          state.matchedLocation.startsWith(AppRoutes.authAction) ||
          state.matchedLocation.startsWith(AppRoutes.resetPassword) ||
          state.matchedLocation == '/action';
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // 2. Actions d'authentification directes (Deep Links Firebase : resetPassword, verifyEmail)
      if (isAuthAction) {
        return null;
      }

      // 3. Mode Enfant Actif & Persistant -> Redirection directe & confinement prioritaire
      if (childMode.isChildModeActive && isAuthenticated) {
        final activeChildId = childMode.activeChildId ?? '';
        final childDestination = activeChildId.isNotEmpty
            ? AppRoutes.espaceEnfantFor(activeChildId)
            : AppRoutes.espaceEnfant;

        // Si l'utilisateur arrive du splash, de l'auth ou d'une route parent -> envoi direct
        if (!state.matchedLocation.startsWith(AppRoutes.espaceEnfant) || isSplash || isGoingToAuth) {
          return childDestination;
        }

        // Autoriser la navigation dans l'espace enfant
        return null;
      }

      // 4. Utilisateur non authentifié (mode visiteur)
      if (!isAuthenticated) {
        // Rediriger le splash vers la page d'accueil par défaut (mode visiteur)
        if (isSplash) {
          return AppRoutes.home;
        }

        // Autoriser l'accès aux pages d'authentification, accueil public, boutique et tutoriels
        if (isGoingToAuth ||
            state.matchedLocation == AppRoutes.home ||
            state.matchedLocation == AppRoutes.jouetscreen ||
            state.matchedLocation == AppRoutes.jouetdetail ||
            state.matchedLocation == AppRoutes.tutoriels) {
          return null;
        }
        // Rediriger vers la page de connexion pour toute page protégée (admin, profil...)
        return AppRoutes.login;
      }

      final role = authState.utilisateur?.role;
      final isAdminOrManager =
          role == UserRole.admin || role == UserRole.manager;

      // 5. Utilisateur Administrateur / Manager -> dirigé par défaut vers l'espace Admin
      if (isAdminOrManager) {
        // Un Manager n'a pas accès à la gestion des utilisateurs / staff -> redirection vers /admin
        if (role == UserRole.manager &&
            (state.matchedLocation.startsWith(AppRoutes.adminUsers) ||
                state.matchedLocation.startsWith(AppRoutes.adminStaff))) {
          return AppRoutes.admin;
        }

        // Si l'admin/manager vient de splash ou login/register -> rediriger vers /admin
        if (isSplash || isGoingToAuth) {
          return AppRoutes.admin;
        }

        // Accès autorisé à toutes les autres pages (admin, profil, boutique, etc.)
        return null;
      }

      // 6. Utilisateur Parent / Client -> confiné à l'espace Parent
      // Redirection vers la racine / accueil depuis splash ou auth
      if (isSplash || isGoingToAuth) {
        return AppRoutes.home;
      }

      // Accès formellement interdit à l'espace administration pour un Parent
      if (state.matchedLocation.startsWith('/admin')) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Splash ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Authentification & Deep Links ──
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.authAction,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final oobCode = state.uri.queryParameters['oobCode'];
          final apiKey = state.uri.queryParameters['apiKey'];
          final continueUrl = state.uri.queryParameters['continueUrl'];
          return AuthActionPage(
            mode: mode,
            oobCode: oobCode,
            apiKey: apiKey,
            continueUrl: continueUrl,
          );
        },
      ),
      GoRoute(
        path: '/action',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final oobCode = state.uri.queryParameters['oobCode'];
          final apiKey = state.uri.queryParameters['apiKey'];
          final continueUrl = state.uri.queryParameters['continueUrl'];
          return AuthActionPage(
            mode: mode,
            oobCode: oobCode,
            apiKey: apiKey,
            continueUrl: continueUrl,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final oobCode = state.uri.queryParameters['oobCode'];
          final apiKey = state.uri.queryParameters['apiKey'];
          final continueUrl = state.uri.queryParameters['continueUrl'];
          return AuthActionPage(
            mode: 'resetPassword',
            oobCode: oobCode,
            apiKey: apiKey,
            continueUrl: continueUrl,
          );
        },
      ),

      // ── Accueil & Fonctionnalités Utilisateur ──
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: AccueilParentPage());
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: ProfilParentPage());
        },
        routes: [
          GoRoute(
            path: 'favoris',
            builder: (context, state) => const FavorisPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/favoris',
        redirect: (context, state) => AppRoutes.favoris,
      ),
      GoRoute(
        path: AppRoutes.tutoriels,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: TutorielPage());
        },
      ),
      GoRoute(
        path: AppRoutes.panier,
        builder: (context, state) => const PanierPage(),
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
          // 3. Parents (Clients)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminUsers,
                builder: (context, state) => const AdminUserListPage(),
              ),
            ],
          ),
          // 4. Équipe & Staff
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminStaff,
                builder: (context, state) => const AdminStaffListPage(),
              ),
            ],
          ),
          // 5. Catalogue global
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminCatalog,
                builder: (context, state) => const AdminCatalogPage(),
              ),
            ],
          ),
          // 5. Profil Administrateur
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminProfile,
                builder: (context, state) => const AdminProfilePage(),
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
        path: AppRoutes.adminActivites,
        builder: (context, state) => const ActivitiesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAddActivity,
        builder: (context, state) => const AddActivityScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEditActivity,

        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;

          return EditActivityLoader(activityId: activityId);
        },
      ),

      GoRoute(
        path: AppRoutes.adminActivityQuestions,
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return QuestionsListScreen(activityId: activityId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminActivityTypeQuestions,
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          return ChooseQuestionTypeScreen(activityId: activityId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminActivityAddQuestions,
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          final type = state.uri.queryParameters['type'] ?? 'choixMultiple';
          final questionType = QuestionTypeExtension.fromString(type);
          return AddQuestionScreen(activityId: activityId, type: questionType);
        },
      ),

      GoRoute(
        path: AppRoutes.adminActivityEditQuestions,
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          final questionId = state.pathParameters['questionId']!;
          return EditQuestionScreen(
            activityId: activityId,
            questionId: questionId,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.adminActivityDetailQuestions,
        builder: (context, state) {
          final activityId = state.pathParameters['activityId']!;
          final questionId = state.pathParameters['questionId']!;
          return QuestionDetailScreen(
            activityId: activityId,
            questionId: questionId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminTutoriels,
        builder: (context, state) => const TutorielsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAddTutoriel,
        builder: (context, state) => const AdminTutorielFormPage(),
      ),
      GoRoute(
        path: AppRoutes.adminEditTutoriel,
        builder: (context, state) {
          final tutorielId = state.pathParameters['tutorielId'];
          final tutoriel = state.extra as Tutoriel?;
          return AdminTutorielFormPage(
            tutorielId: tutorielId,
            tutorielToEdit: tutoriel,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminDetailTutoriel,
        builder: (context, state) {
          final tutorielId = state.pathParameters['tutorielId']!;
          final tutoriel = state.extra as Tutoriel?;
          return AdminTutorielDetailPage(
            tutorielId: tutorielId,
            initialTutoriel: tutoriel,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminTutorielForm,
        redirect: (context, state) => AppRoutes.adminAddTutoriel,
      ),
      GoRoute(
        path: AppRoutes.adminCategoryForm,
        builder: (context, state) {
          final cat = state.extra as Categorie?;
          return AdminCategoryDetailPage(categorieToEdit: cat);
        },
      ),
      GoRoute(
        path: AppRoutes.adminManagerForm,
        builder: (context, state) => const AdminManagerFormPage(),
      ),
      GoRoute(
        path: AppRoutes.adminCommandes,
        builder: (context, state) => const AdminCommandesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDetailCommande,
        builder: (context, state) {
          final commandeId = state.pathParameters['commandeId']!;
          final commande = state.extra as CommandeModel?;
          return AdminDetailCommandePage(
            commandeId: commandeId,
            initialCommande: commande,
          );
        },
      ),

      // ── Espace Jouets ──
      GoRoute(
        path: AppRoutes.jouets,
        redirect: (context, state) => AppRoutes.jouetscreen,
      ),
      GoRoute(
        path: AppRoutes.jouetscreen,
        pageBuilder: (context, state) {
          final authState = ref.watch(authProvider);

          final utilisateurId = authState.utilisateur?.utilisateurId ?? '';

          return NoTransitionPage(
            child: JouetsScreen(utilisateurId: utilisateurId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.jouetdetail,
        builder: (context, state) {
          final jouet = state.extra as Jouet;
          final authState = ref.watch(authProvider);
          final utilisateurId = authState.utilisateur?.utilisateurId ?? '';

          return JouetDetailScreen(jouet: jouet, utilisateurId: utilisateurId);
        },
      ),
      GoRoute(
        path: AppRoutes.enfantDetail,
        builder: (context, state) {
          final enfant = state.extra as EnfantModel;
          return DetailEnfantPage(enfant: enfant);
        },
      ),

      // ── Espace Enfant ──
      GoRoute(
        path: AppRoutes.espaceEnfant,
        builder: (context, state) {
          final activeChildId = ref.read(childModeProvider).activeChildId;
          return KidThemeScope(
            child: AccueilEnfantPage(initialEnfantId: activeChildId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.espaceEnfant}/:enfantId',
        builder: (context, state) {
          final enfantId = state.pathParameters['enfantId'];
          return KidThemeScope(
            child: AccueilEnfantPage(initialEnfantId: enfantId),
          );
        },
      ),

      // ── Aide & Support ──
      GoRoute(
        path: AppRoutes.aideSupport,
        builder: (context, state) => const AideSupportPage(),
      ),
    ],

    // ── Gestion Erreur 404 ──
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
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
                onPressed: () => context.go(AppRoutes.jouetscreen),
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
