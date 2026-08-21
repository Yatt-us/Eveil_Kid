import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../enums/activite_enums.dart';

/// Barre de filtres par statut (Toutes, En cours, Terminées).
class ActiviteFilterBar extends StatelessWidget {
  final StatutActivite selectedFilter;
  final ValueChanged<StatutActivite> onFilterSelected;

  const ActiviteFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: StatutActivite.values.map((statut) {
          final isSelected = selectedFilter == statut;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(statut, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(StatutActivite statut, bool isSelected) {
    return InkWell(
      onTap: () => onFilterSelected(statut),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3F3F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        child: Text(
          statut.label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
