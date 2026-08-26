import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        theme.colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sous-total', style: TextStyle(color: textSecondary)),
            Text('${sousTotal.toStringAsFixed(0)} FCFA'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Livraison', style: TextStyle(color: textSecondary)),
            Text(
              fraisLivraison == 0 ? 'Gratuite' : '${fraisLivraison.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${total.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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