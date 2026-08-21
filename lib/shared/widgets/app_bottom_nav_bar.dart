import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Élément de la barre de navigation personnalisée
class AppNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Barre de navigation inférieure réutilisable et harmonisée
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem>? customItems;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
  });

  /// Liste par défaut des 4 onglets : Accueil, Jouets, Tutoriels, Profil
  static const List<AppNavItem> defaultItems = [
    AppNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
    ),
    AppNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Jouets',
    ),
    AppNavItem(
      icon: Icons.lightbulb_outline,
      activeIcon: Icons.lightbulb_rounded,
      label: 'Tutoriels',
    ),
    AppNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, items.length - 1),
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 1.5),
          items: items.map((item) {
            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(item.icon, size: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(item.activeIcon ?? item.icon, size: 24),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
