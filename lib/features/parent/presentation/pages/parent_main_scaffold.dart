// lib/features/parent/presentation/pages/parent_main_scaffold.dart

import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../jouets/presentation/pages/jouets_catalog_page.dart';
import 'accueil_parent.dart';
import 'profil_parent.dart';

class ParentMainScaffold extends StatefulWidget {
  final int initialIndex;

  const ParentMainScaffold({super.key, this.initialIndex = 0});

  @override
  State<ParentMainScaffold> createState() => _ParentMainScaffoldState();
}

class _ParentMainScaffoldState extends State<ParentMainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AccueilParentPage(onNavigateTab: _navigateToTab),
      const JouetsCatalogPage(),
      const ProfilParentPage(),
    ];

    return PopScope(
      // Autorise la fermeture uniquement si l'utilisateur est déjà sur l'onglet Accueil (index 0)
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Si l'utilisateur est sur un autre onglet (Jouets, Tutoriels, Profil),
        // le bouton retour le ramène d'abord à l'Accueil (comme dans WhatsApp)
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
