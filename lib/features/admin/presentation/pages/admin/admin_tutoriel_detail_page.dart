import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/video_player_widget.dart';
import 'package:eveilkid/features/tutoriels/providers/cloudinary_duration_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/features/tutoriels/utils/duration_utils.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class AdminTutorielDetailPage extends ConsumerStatefulWidget {
  final String tutorielId;
  final Tutoriel? initialTutoriel;

  const AdminTutorielDetailPage({
    super.key,
    required this.tutorielId,
    this.initialTutoriel,
  });

  @override
  ConsumerState<AdminTutorielDetailPage> createState() => _AdminTutorielDetailPageState();
}

class _AdminTutorielDetailPageState extends ConsumerState<AdminTutorielDetailPage> {
  bool _isActionLoading = false;

  @override
  Widget build(BuildContext context) {
    final tutorielStreamAsync = ref.watch(tutorielStreamByIdProvider(widget.tutorielId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mapping ID Catégorie -> Nom
    final categoriesMap = <String, String>{};
    categoriesAsync.whenData((cats) {
      for (final c in cats) {
        categoriesMap[c.categorieId] = c.nom;
      }
    });

    return tutorielStreamAsync.when(
      data: (tutoriel) {
        // Si le tutoriel est introuvable après suppression ou ID erroné
        if (tutoriel == null) {
          if (widget.initialTutoriel != null) {
            return _buildContent(context, widget.initialTutoriel!, categoriesMap, isDark);
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tutoriel introuvable'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _handleBack(context),
              ),
            ),
            body: AppEmptyState(
              title: 'Tutoriel introuvable',
              description: 'Ce tutoriel a peut-être été supprimé.',
              actionText: 'Retour à la liste',
              onActionPressed: () => _handleBack(context),
            ),
          );
        }

        return _buildContent(context, tutoriel, categoriesMap, isDark);
      },
      loading: () {
        if (widget.initialTutoriel != null) {
          return _buildContent(context, widget.initialTutoriel!, categoriesMap, isDark);
        }
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Détails du tutoriel'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
      error: (err, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: const Text('Erreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _handleBack(context),
          ),
        ),
        body: AppErrorState(
          message: 'Erreur lors du chargement : $err',
          onRetry: () => ref.invalidate(tutorielStreamByIdProvider(widget.tutorielId)),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.adminTutoriels);
    }
  }

  Widget _buildContent(
    BuildContext context,
    Tutoriel tutoriel,
    Map<String, String> categoriesMap,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isPublie = tutoriel.statut == TutorielStatus.publie;
    final categoryName = categoriesMap[tutoriel.categorieId] ?? 'Catégorie inconnue';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          tooltip: 'Retour',
          onPressed: () => _handleBack(context),
        ),
        title: Text(
          'Détails du tutoriel',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          // 1. Bouton Bascule Statut (Publié / Brouillon)
          if (_isActionLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                isPublie ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: isPublie ? AppColors.success : AppColors.warning,
              ),
              tooltip: isPublie ? 'Passer en brouillon' : 'Publier le tutoriel',
              onPressed: () => _toggleStatut(tutoriel),
            ),

          // 2. Bouton Édition
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            tooltip: 'Modifier ce tutoriel',
            onPressed: () => _navigateToEdit(context, tutoriel),
          ),

          // 3. Bouton Suppression
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            tooltip: 'Supprimer ce tutoriel',
            onPressed: () => _confirmDelete(tutoriel),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. LECTEUR VIDÉO INLINE SANS DISTRACTION ──
            if (tutoriel.videoUrl.isNotEmpty) ...[
              TutorielInlineVideoPlayer(
                key: ValueKey('admin_video_${tutoriel.videoUrl}'),
                tutoriel: tutoriel,
                autoPlay: false,
              ),
              const SizedBox(height: 22),
            ],

            // ── 2. CARTE RÉCAPITULATIVE PRINCIPALE ──
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne Statut + Catégorie
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(isPublie),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    tutoriel.titre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Grille des métadonnées
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          icon: Icons.child_care_rounded,
                          title: 'Tranche d\'âge',
                          value: tutoriel.ageRangeLabel,
                          color: AppColors.childSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetaItem(
                          icon: Icons.timer_outlined,
                          title: 'Durée réelle',
                          value: tutoriel.duree > 0
                              ? tutoriel.dureeFormatted
                              : ref.watch(cloudinaryVideoDurationProvider(tutoriel.videoUrl)).when(
                                  data: (secs) => secs > 0 ? formatDurationSeconds(secs) : 'Non déterminée',
                                  loading: () => 'Calcul en cours...',
                                  error: (_, _) => 'Non déterminée',
                                ),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          icon: Icons.calendar_today_rounded,
                          title: 'Créé le',
                          value: DateFormat('dd/MM/yyyy à HH:mm').format(tutoriel.dateCreation),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetaItem(
                          icon: Icons.update_rounded,
                          title: 'Mis à jour le',
                          value: DateFormat('dd/MM/yyyy à HH:mm').format(tutoriel.dateModification),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. DESCRIPTION PÉDAGOGIQUE ──
            AppCard(
              title: 'Description du tutoriel',
              padding: const EdgeInsets.all(18),
              child: Text(
                tutoriel.description.isNotEmpty
                    ? tutoriel.description
                    : 'Aucune description renseignée.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 4. MINIATURE DE COUVERTURE ──
            if (tutoriel.miniatureUrl.isNotEmpty) ...[
              AppCard(
                title: 'Miniature de couverture',
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          tutoriel.miniatureUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMediaUrlRow('URL Miniature', tutoriel.miniatureUrl),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 5. INFORMATIONS TECHNIQUES MÉDIAS & CLOUDINARY ──
            AppCard(
              title: 'Fichiers & Hébergement Cloudinary',
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaUrlRow('Fichier Vidéo', tutoriel.videoUrl),
                  if (tutoriel.miniatureUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildMediaUrlRow('Fichier Image', tutoriel.miniatureUrl),
                  ],
                  if (tutoriel.tutorielId != null) ...[
                    const SizedBox(height: 12),
                    _buildMediaUrlRow('Identifiant Unique', tutoriel.tutorielId!),
                  ],
                ],
              ),
            ),

            // ── 6. JOUETS ASSOCIÉS (SI PRÉSENTS) ──
            if (tutoriel.jouetsSuggeres.isNotEmpty || (tutoriel.jouetLieId != null && tutoriel.jouetLieId!.isNotEmpty)) ...[
              const SizedBox(height: 16),
              _buildAssociatedToysCard(context, tutoriel, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isPublie ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isPublie ? AppColors.success : AppColors.warning).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublie ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 14,
            color: isPublie ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            isPublie ? 'Publié' : 'Brouillon',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPublie ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaUrlRow(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  url,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                tooltip: 'Copier',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien copié dans le presse-papiers'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssociatedToysCard(BuildContext context, Tutoriel tutoriel, bool isDark) {
    final toyIds = <String>{
      if (tutoriel.jouetLieId != null && tutoriel.jouetLieId!.isNotEmpty)
        tutoriel.jouetLieId!,
      ...tutoriel.jouetsSuggeres.where((id) => id.isNotEmpty),
    }.toList();

    return AppCard(
      title: 'Jouets associés (${toyIds.length})',
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...toyIds.map((toyId) => Consumer(
            builder: (context, ref, _) {
              final jouetAsync = ref.watch(jouetByIdProvider(toyId));
              return jouetAsync.maybeWhen(
                data: (jouet) {
                  if (jouet == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (jouet.images.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              jouet.images.first,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(Icons.toys_outlined, size: 24),
                            ),
                          )
                        else
                          const Icon(Icons.toys_outlined, size: 24, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jouet.nom,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              if (jouet.prix > 0)
                                Text(
                                  '${jouet.prix.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          )),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context, Tutoriel tutoriel) async {
    final result = await context.push(
      AppRoutes.adminEditTutorielPath(tutoriel.tutorielId ?? ''),
      extra: tutoriel,
    );

    if (result == true && mounted) {
      ref.invalidate(tutorielStreamByIdProvider(widget.tutorielId));
      ref.invalidate(tutorielByIdProvider(widget.tutorielId));
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);
    }
  }

  Future<void> _toggleStatut(Tutoriel tutoriel) async {
    if (tutoriel.tutorielId == null) return;
    setState(() => _isActionLoading = true);

    try {
      final repository = ref.read(tutorielRepositoryProvider);
      final isCurrentlyPublie = tutoriel.statut == TutorielStatus.publie;

      if (isCurrentlyPublie) {
        await repository.depublierTutoriel(tutoriel.tutorielId!);
      } else {
        await repository.publierTutoriel(tutoriel.tutorielId!);
      }

      ref.invalidate(tutorielStreamByIdProvider(widget.tutorielId));
      ref.invalidate(tutorielByIdProvider(widget.tutorielId));
      ref.invalidate(adminTutorielsProvider);
      ref.invalidate(tutorielsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyPublie
                  ? 'Tutoriel passé en brouillon'
                  : 'Tutoriel publié avec succès !',
            ),
            backgroundColor: isCurrentlyPublie ? AppColors.warning : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmDelete(Tutoriel tutoriel) async {
    if (tutoriel.tutorielId == null) return;

    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer le tutoriel',
      message: 'Voulez-vous vraiment supprimer "${tutoriel.titre}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      setState(() => _isActionLoading = true);
      try {
        final repository = ref.read(tutorielRepositoryProvider);
        await repository.deleteTutoriel(tutoriel.tutorielId!);

        ref.invalidate(adminTutorielsProvider);
        ref.invalidate(tutorielsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutoriel supprimé avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          _handleBack(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
          );
        }
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }
}
