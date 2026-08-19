import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

class JouetBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const JouetBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Accueil',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          _BottomItem(
            icon: Icons.extension_outlined,
            activeIcon: Icons.extension,
            label: 'Jouets',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          _BottomItem(
            icon: Icons.construction_outlined,
            activeIcon: Icons.construction,
            label: 'Activités',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),

          _BottomItem(
            icon: Icons.lightbulb_outline,
            activeIcon: Icons.lightbulb,
            label: 'Tutoriels',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),

          _BottomItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            selected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.primary
        : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 20,
                color: color,
              ),

              const SizedBox(height: 3),

              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: color,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}