import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

class ResumeCommandeWidget extends StatelessWidget {
  final double sousTotal;
  final double fraisLivraison;
  final double total;

  const ResumeCommandeWidget({
    super.key,
    required this.sousTotal,
    required this.fraisLivraison,
    required this.total,
  });

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sous-total', style: TextStyle(fontSize: 13, color: textSecondary)),
            Text(
              _formatPrice(sousTotal),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Livraison', style: TextStyle(fontSize: 13, color: textSecondary)),
            Text(
              fraisLivraison > 0 ? _formatPrice(fraisLivraison) : 'Gratuite',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fraisLivraison > 0
                    ? theme.colorScheme.onSurface
                    : AppColors.success,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: dividerColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              _formatPrice(total),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}