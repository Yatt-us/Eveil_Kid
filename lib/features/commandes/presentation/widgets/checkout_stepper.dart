import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CheckoutStepper extends StatelessWidget {
  final int stepActuel; // 1: Adresse, 2: Paiement, 3: Confirmation

  const CheckoutStepper({super.key, required this.stepActuel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    const successColor = Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Adresse', stepActuel, primaryColor, successColor, theme, isDark),
          _buildLine(1, stepActuel, successColor, theme, isDark),
          _buildStep(2, 'Paiement', stepActuel, primaryColor, successColor, theme, isDark),
          _buildLine(2, stepActuel, successColor, theme, isDark),
          _buildStep(3, 'Confirmation', stepActuel, primaryColor, successColor, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildStep(
    int step,
    String title,
    int current,
    Color primary,
    Color success,
    ThemeData theme,
    bool isDark,
  ) {
    final bool isDone = step < current;
    final bool isCurrent = step == current;

    final Color circleColor = isDone
        ? success
        : (isCurrent
            ? primary
            : (isDark
                ? theme.colorScheme.surfaceContainerHighest
                : AppColors.surfaceVariant));
    final Color textColor = isCurrent || isDone
        ? (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface)
        : (isDark ? Colors.white38 : AppColors.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: circleColor,
          child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$step',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(
    int step,
    int current,
    Color success,
    ThemeData theme,
    bool isDark,
  ) {
    final bool isDone = step < current;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          color: isDone
              ? success
              : (isDark ? theme.dividerColor.withValues(alpha: 0.3) : AppColors.border),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}