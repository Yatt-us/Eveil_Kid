import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityDifficultySelector extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onChanged;

  const ActivityDifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final difficulties = [
      {'value': 'facile', 'label': 'Facile'},
      {'value': 'moyen', 'label': 'Moyen'},
      {'value': 'difficile', 'label': 'Difficile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: difficulties.map((diff) {
          final isSelected = selectedDifficulty == diff['value'];
          return Expanded(
            child: TextButton(
              onPressed: () => onChanged(diff['value'] as String),
              style: TextButton.styleFrom(
                backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(diff['label'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }
}