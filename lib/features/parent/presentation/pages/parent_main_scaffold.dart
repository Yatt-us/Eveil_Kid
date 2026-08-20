// lib/features/parent/presentation/pages/parent_main_scaffold.dart

import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../jouets/presentation/pages/jouets_catalog_page.dart';
import '../../../tutoriels/presentations/pages/tutorielPage.dart';
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
      const TutorielPage(),
      const ProfilParentPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _navigateToTab,
      ),
    );
  }
}
