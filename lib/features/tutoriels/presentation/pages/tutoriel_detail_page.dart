import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/pages/video_player_page.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/jouets_suggestion_card.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card.dart';
import 'package:eveilkid/features/tutoriels/providers/progression_provider.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';

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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: theme.colorScheme.onSurface,
          tooltip: 'Retour',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Détail du tutoriel',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: theme.colorScheme.onSurface,
            tooltip: 'Partager',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lien du tutoriel copié')),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: tutorielAsync.when(
        data: (tutoriel) {
          if (tutoriel == null) {
            return _buildNotFound(context);
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
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BANNIÈRE VIDÉO HERO ──
                    _buildVideoHero(context, tutoriel),
                    const SizedBox(height: 18),

                    // ── REPRENDRE LA LECTURE (SI EN COURS) ──
                    if (hasProgress) ...[
                      _buildResumeCard(
                        context,
                        tutoriel,
                        currentPosition,
                        totalDuration,
                        progressRatio,
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ── TITRE & BADGES ──
                    Text(
                      tutoriel.titre,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.4,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (categoryName != null)
                          _buildBadge(
                            context,
                            icon: Icons.category_outlined,
                            label: categoryName,
                            color: theme.colorScheme.primary,
                          ),
                        _buildBadge(
                          context,
                          icon: Icons.child_care_rounded,
                          label: tutoriel.ageRangeLabel,
                          color: theme.colorScheme.secondary,
                        ),
                        _buildBadge(
                          context,
                          icon: Icons.timer_outlined,
                          label: tutoriel.dureeFormatee,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── DESCRIPTION ──
                    _buildDescriptionSection(context, tutoriel.description),
                    const SizedBox(height: 24),

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
                      const SizedBox(height: 18),
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

              // ── BOUTON CTA FLOTTANT / FIXE EN BAS ──
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _openVideoPlayer(context, tutoriel),
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: Text(
                      hasProgress ? 'Reprendre le tutoriel' : 'Regarder le tutoriel',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text('Erreur de chargement: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(tutorielByIdProvider(widget.tutorielId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
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
                    width: 68,
                    height: 68,
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
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          tutoriel.dureeFormatee,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
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

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, String description) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (description.isEmpty) return const SizedBox.shrink();

    final isLong = description.length > 200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de ce tutoriel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: isLong && !_isDescriptionExpanded ? 4 : null,
            overflow: isLong && !_isDescriptionExpanded ? TextOverflow.ellipsis : null,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
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
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Tutoriel introuvable',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Retour à la liste'),
          ),
        ],
      ),
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
