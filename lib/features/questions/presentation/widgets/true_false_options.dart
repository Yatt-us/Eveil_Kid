import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TrueFalseOptions extends StatelessWidget {
  final String? selectedTrueFalse;
  final Function(String) onChanged;

  const TrueFalseOptions({
    super.key,
    required this.selectedTrueFalse,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bonne réponse',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('vrai'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedTrueFalse == 'vrai'
                        ? AppColors.primary
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedTrueFalse == 'vrai'
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: selectedTrueFalse == 'vrai' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedTrueFalse == 'vrai'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedTrueFalse == 'vrai'
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Vrai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged('faux'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedTrueFalse == 'faux'
                        ? AppColors.primary
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedTrueFalse == 'faux'
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: selectedTrueFalse == 'faux' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedTrueFalse == 'faux'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedTrueFalse == 'faux'
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Faux',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (selectedTrueFalse != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Bonne réponse sélectionnée',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}