import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String? message;

  const ErrorMessageWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}