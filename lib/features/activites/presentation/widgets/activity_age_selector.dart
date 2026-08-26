import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityAgeSelector extends StatelessWidget {
  final int minAge;
  final int maxAge;
  final Function(int) onMinAgeChanged;
  final Function(int) onMaxAgeChanged;

  const ActivityAgeSelector({
    super.key,
    required this.minAge,
    required this.maxAge,
    required this.onMinAgeChanged,
    required this.onMaxAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'De',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: minAge,
                    isExpanded: true,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(
                              value: age,
                              child: Text('$age ans'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                       
                        if (value <= maxAge) {
                          onMinAgeChanged(value);
                        } else {
                          // Afficher un message si l'utilisateur essaie de dépasser
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('L\'âge minimum ne peut pas dépasser l\'âge maximum ($maxAge ans)'),
                              backgroundColor: AppColors.danger,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'À',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: maxAge,
                    isExpanded: true,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(
                              value: age,
                              child: Text('$age ans'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
               
                        if (value >= minAge) {
                          onMaxAgeChanged(value);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('L\'âge maximum ne peut pas être inférieur à l\'âge minimum ($minAge ans)'),
                              backgroundColor: AppColors.danger,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}