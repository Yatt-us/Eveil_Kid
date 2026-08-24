import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends ConsumerWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerIndex = ref.watch(bottomIndexProvider);
    final activeIndex = currentIndex ?? providerIndex;

    return BottomNavigationBar(
      currentIndex: activeIndex,

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
        if (onTap != null) {
          onTap!(index);
        } else {
          ref.read(bottomIndexProvider.notifier).setIndex(index);

          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.jouetscreen);
              break;
            case 2:
              context.go(AppRoutes.tutoriels);
              break;
            case 3:
              context.go(AppRoutes.profile);
              break;
          }
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
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
