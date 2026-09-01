import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/presentation/page/jouet_detail_screen.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_chip.dart';

class JouetSuggestionCard extends ConsumerWidget {
  final String? jouetId;
  final Jouet? jouet;
  final bool isCompact;
  final VoidCallback? onClose;

  const JouetSuggestionCard({
    super.key,
    this.jouetId,
    this.jouet,
    this.isCompact = false,
    this.onClose,
  }) : assert(jouetId != null || jouet != null, 'Provide either jouetId or jouet');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jouet != null) {
      return _buildContent(context, ref, jouet!);
    }

    final jouetAsync = ref.watch(jouetByIdProvider(jouetId!));

    return jouetAsync.when(
      data: (loadedJouet) {
        if (loadedJouet == null) return const SizedBox.shrink();
        return _buildContent(context, ref, loadedJouet);
      },
      loading: () => _buildSkeleton(context),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Jouet item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: item.imagePrincipaleUrl.isNotEmpty
                    ? Image.network(
                        item.imagePrincipaleUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholderIcon(context),
                      )
                    : _buildPlaceholderIcon(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jouet recommandé',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (item.prix > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${item.prix.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Voir',
              isFullWidth: false,
              size: AppButtonSize.small,
              onPressed: () => _navigateToDetail(context, ref, item),
            ),
            if (onClose != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      );
    }

    return AppCard(
      onTap: () => _navigateToDetail(context, ref, item),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.imagePrincipaleUrl.isNotEmpty
                  ? Image.network(
                      item.imagePrincipaleUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholderIcon(context),
                    )
                  : _buildPlaceholderIcon(context),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppChip(
                  label: 'Matériel utilisé',
                  variant: AppChipVariant.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  item.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.prix.toStringAsFixed(0)} FCFA • ${item.ageMinimum}-${item.ageMaximum} ans',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.toys_rounded,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, WidgetRef ref, Jouet item) {
    final userId = ref.read(authProvider).utilisateur?.utilisateurId ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JouetDetailScreen(
          jouet: item,
          utilisateurId: userId,
        ),
      ),
    );
  }
}
