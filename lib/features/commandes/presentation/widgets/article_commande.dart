import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import '../../models/commande_model.dart';

class ArticleCommandeWidget extends StatelessWidget {
  final ArticleCommandeModel article;

  const ArticleCommandeWidget({super.key, required this.article});

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: article.urlImage != null && article.urlImage!.isNotEmpty
                  ? Image.network(
                      article.urlImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.toys_rounded,
                        color: textSecondary,
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.toys_rounded,
                      color: textSecondary,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.titre,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantité : ${article.quantite}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatPrice(article.prix * article.quantite),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}