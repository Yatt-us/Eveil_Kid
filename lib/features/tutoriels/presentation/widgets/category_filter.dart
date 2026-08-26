import 'package:flutter/material.dart';

class CategoryFilterChip extends StatelessWidget {
  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF763CD1).withValues(alpha: 0.12),
      checkmarkColor: const Color(0xFF763CD1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF763CD1) : const Color(0xFF6C687D),
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF763CD1) : const Color(0xFFE6E2F2),
      ),
    );
  }
}