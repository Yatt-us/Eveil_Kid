import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

class AdresseLivraisonWidget extends StatelessWidget {
  final String adresse;
  final String telephone;
  final VoidCallback? surModification;

  const AdresseLivraisonWidget({
    super.key,
    required this.adresse,
    required this.telephone,
    this.surModification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: dividerColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Adresse de livraison',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (surModification != null)
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: surModification,
                  tooltip: 'Modifier l\'adresse',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            adresse.isNotEmpty ? adresse : 'Aucune adresse spécifiée',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (telephone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 13,
                  color: textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  telephone,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}