// lib/features/parent/presentation/pages/parent_main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jouets/presentation/pages/jouets_catalog_page.dart';
import '../../../tutoriels/presentations/pages/tutorielPage.dart';
import 'accueil_parent.dart';
import 'profil_parent.dart';

class ParentMainScaffold extends ConsumerStatefulWidget {
  final int initialIndex;

  const ParentMainScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ParentMainScaffold> createState() => _ParentMainScaffoldState();
}

class _ParentMainScaffoldState extends ConsumerState<ParentMainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToTab(int index) {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;

    // Si le visiteur clique sur l'onglet Profil (index 3), redirection vers la page de connexion
    if (!isAuthenticated && index == 3) {
      context.push(AppRoutes.login);
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écoute de l'état d'authentification :
    // Dès que le parent se déconnecte, on le ramène instantanément sur l'onglet Accueil (index 0 - visiteur)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated && _currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });

    final authState = ref.watch(authProvider);
    // Sécurité : si un visiteur est sur l'index 3 (Profil), forcer le retour à l'Accueil
    if (!authState.isAuthenticated && _currentIndex == 3) {
      _currentIndex = 0;
    }

    final List<Widget> pages = [
      AccueilParentPage(onNavigateTab: _navigateToTab),
      const JouetsCatalogPage(),
      const TutorielPage(),
      const ProfilParentPage(),
    ];

    return PopScope(
      // Autorise la fermeture uniquement si l'utilisateur est déjà sur l'onglet Accueil (index 0)
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Si l'utilisateur est sur un autre onglet, le bouton retour le ramène d'abord à l'Accueil
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _navigateToTab,
        ),
      ),
    );
  }
}
