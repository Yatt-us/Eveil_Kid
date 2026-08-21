import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,

      // Apparence
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,

      selectedFontSize: 12,
      unselectedFontSize: 12,

      elevation: 8,

      // Navigation
      onTap: (index) {
        ref.read(bottomIndexProvider.notifier).setIndex(index);

        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;

          case 1:
            context.go(AppRoutes.jouets);
            break;

          case 2:
            context.go(AppRoutes.tutoriels);
            break;

          case 3:
            context.go(AppRoutes.profile);
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.toys_outlined),
          activeIcon: Icon(Icons.toys),
          label: 'Boutique',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          activeIcon: Icon(Icons.play_circle),
          label: 'Tutoriels',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
