import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/favoris/models/favoris.dart';
import 'package:eveilkid/features/favoris/providers/favoris_providers.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_app_bar_action.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/video_player_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/jouets_suggestion_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class TutorielDetailPage extends ConsumerStatefulWidget {
  const TutorielDetailPage({
    super.key,
    required this.tutorielId,
  });

  final String tutorielId;

  @override
  ConsumerState<TutorielDetailPage> createState() => _TutorielDetailPageState();
}

class _TutorielDetailPageState extends ConsumerState<TutorielDetailPage> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tutorielAsync = ref.watch(tutorielByIdProvider(widget.tutorielId));
    final progressionAsync = ref.watch(progressionProvider(widget.tutorielId));
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Détail du tutoriel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isFav = ref.watch(isElementFavoriProvider(widget.tutorielId));
              final authState = ref.watch(authProvider);
              final userId = authState.utilisateur?.utilisateurId ?? '';

              return tutorielAsync.maybeWhen(
                data: (tutoriel) {
                  if (tutoriel == null) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav
                          ? Colors.redAccent
                          : (theme.iconTheme.color ?? theme.colorScheme.onSurface),
                    ),
                    tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                    onPressed: () {
                      if (userId.isEmpty) return;
                      ref.read(favoriServiceProvider).toggleFavori(
                            utilisateurId: userId,
                            elementId: tutoriel.tutorielId!,
                            typeElement: TypeElement.tutoriel,
                            titre: tutoriel.titre,
                            miniatureUrl: tutoriel.miniatureUrl,
                            prix: 0.0,
                          );
                    },
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          const PanierAppBarAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: tutorielAsync.when(
        data: (tutoriel) {
          if (tutoriel == null) {
            return AppEmptyState(
              title: 'Tutoriel introuvable',
              description: 'Ce tutoriel n\'est plus disponible.',
              actionText: 'Retour aux tutoriels',
              onActionPressed: () => Navigator.of(context).maybePop(),
            );
          }

          final categoryName = categoriesAsync.maybeWhen(
            data: (categories) {
              for (final cat in categories) {
                if (cat.categorieId == tutoriel.categorieId) return cat.nom;
              }
              return null;
            },
            orElse: () => null,
          );

          final progression = progressionAsync.maybeWhen(
            data: (value) => value,
            orElse: () => null,
          );

          final relatedTutoriels = tutorielsAsync.maybeWhen(
            data: (list) {
              final sameCategory = list
                  .where((item) =>
                      item.tutorielId != tutoriel.tutorielId &&
                      item.categorieId == tutoriel.categorieId)
                  .take(4)
                  .toList();

              if (sameCategory.isNotEmpty) return sameCategory;

              return list
                  .where((item) => item.tutorielId != tutoriel.tutorielId)
                  .take(4)
                  .toList();
            },
            orElse: () => <Tutoriel>[],
          );

          final currentPosition = progression?.position.toInt() ?? 0;
          final totalDuration = (progression?.duree ?? tutoriel.duree).toInt();
          final hasProgress = currentPosition > 0 && !(progression?.termine == true);
          final progressRatio = totalDuration > 0
              ? (currentPosition / totalDuration).clamp(0.0, 1.0)
              : 0.0;

          // Jouets suggérés
          final toyIds = <String>{
            if (tutoriel.jouetLieId != null && tutoriel.jouetLieId!.isNotEmpty)
              tutoriel.jouetLieId!,
            ...tutoriel.jouetsSuggeres.where((id) => id.isNotEmpty),
          }.toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BANNIÈRE VIDÉO HERO ──
                    _buildVideoHero(context, tutoriel),
                    const SizedBox(height: 16),

                    // ── REPRENDRE LA LECTURE (SI EN COURS) ──
                    if (hasProgress) ...[
                      _buildResumeCard(
                        context,
                        tutoriel,
                        currentPosition,
                        totalDuration,
                        progressRatio,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── TITRE & INFORMATIONS ÉPURÉES ──
                    Text(
                      tutoriel.titre,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 15,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65) ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            [
                              if (categoryName != null && categoryName.isNotEmpty) categoryName,
                              tutoriel.ageRangeLabel,
                              tutoriel.dureeFormatee,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65) ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── DESCRIPTION ──
                    if (tutoriel.description.isNotEmpty) ...[
                      _buildDescriptionCard(context, tutoriel.description),
                      const SizedBox(height: 20),
                    ],

                    // ── JOUETS & MATÉRIEL ASSOCIÉS ──
                    if (toyIds.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Matériel & Jouets associés',
                        subtitle: 'Les objets utilisés dans cette vidéo',
                      ),
                      const SizedBox(height: 12),
                      ...toyIds.map(
                        (toyId) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: JouetSuggestionCard(jouetId: toyId),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── TUTORIELS RECOMMANDÉS ──
                    if (relatedTutoriels.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Regarde aussi',
                        subtitle: 'D\'autres vidéos qui pourraient vous plaire',
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: relatedTutoriels.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.76,
                        ),
                        itemBuilder: (context, index) {
                          final item = relatedTutoriels[index];
                          return TutorielCard(
                            tutoriel: item,
                            isHorizontal: false,
                            onTap: () => _openOtherDetail(context, item.tutorielId!),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // ── BOUTON CTA FLOTTANT EN BAS ──
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AppButton(
                  text: hasProgress ? 'Reprendre le tutoriel' : 'Regarder le tutoriel',
                  icon: Icons.play_arrow_rounded,
                  size: AppButtonSize.large,
                  onPressed: () => _openVideoPlayer(context, tutoriel),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(tutorielByIdProvider(widget.tutorielId)),
        ),
      ),
    );
  }

  Widget _buildVideoHero(BuildContext context, Tutoriel tutoriel) {
    final theme = Theme.of(context);
    final imageUrl = tutoriel.miniatureUrl.isNotEmpty
        ? tutoriel.miniatureUrl
        : 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80';

    return GestureDetector(
      onTap: () => _openVideoPlayer(context, tutoriel),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9.5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.video_library_rounded, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          tutoriel.dureeFormatee,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    Tutoriel tutoriel,
    int currentPosition,
    int totalDuration,
    double progressRatio,
  ) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () => _openVideoPlayer(context, tutoriel),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reprendre la lecture',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(progressRatio * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, String description) {
    final theme = Theme.of(context);
    final isLong = description.length > 200;

    return AppCard(
      title: 'À propos de ce tutoriel',
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: isLong && !_isDescriptionExpanded ? 4 : null,
            overflow: isLong && !_isDescriptionExpanded ? TextOverflow.ellipsis : null,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ??
                  theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Text(
                _isDescriptionExpanded ? 'Voir moins' : 'Lire la suite',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  void _openVideoPlayer(BuildContext context, Tutoriel tutoriel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(tutoriel: tutoriel),
      ),
    );
  }

  void _openOtherDetail(BuildContext context, String newTutorielId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TutorielDetailPage(tutorielId: newTutorielId),
      ),
    );
  }
}
