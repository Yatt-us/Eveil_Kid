import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/jouets/models/avis_model.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/avis_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class JouetAvisSection extends ConsumerStatefulWidget {
  final Jouet jouet;
  final String utilisateurId;

  const JouetAvisSection({
    super.key,
    required this.jouet,
    required this.utilisateurId,
  });

  @override
  ConsumerState<JouetAvisSection> createState() => _JouetAvisSectionState();
}

class _JouetAvisSectionState extends ConsumerState<JouetAvisSection> {
  int? _filterStar; // null = Tous, 5, 4, 3, 2, 1

  void _showAddEditAvisModal(
    BuildContext context, {
    AvisModel? avisExistant,
  }) {
    final theme = Theme.of(context);

    // 0.0 = aucune étoile sélectionnée (pour un nouvel avis)
    double noteSelectionnee = avisExistant?.note ?? 0.0;
    final commentaireController =
        TextEditingController(text: avisExistant?.commentaire ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final labels = {
              1.0: 'Décevant 😞',
              2.0: 'Moyen 😐',
              3.0: 'Bien 🙂',
              4.0: 'Très bien ! 😊',
              5.0: 'Excellent ! 🌟',
            };

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        avisExistant == null
                            ? 'Donnez votre avis'
                            : 'Modifier votre avis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.jouet.nom,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sélection des étoiles interactives
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starValue = index + 1.0;
                                final isFilled = noteSelectionnee >= starValue;

                                return IconButton(
                                  onPressed: () {
                                    setModalState(() {
                                      noteSelectionnee = starValue;
                                    });
                                  },
                                  icon: Icon(
                                    isFilled
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 38,
                                    color: noteSelectionnee == 0
                                        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                                        : const Color(0xFFF59E0B),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              noteSelectionnee == 0
                                  ? 'Appuyez sur une étoile pour noter'
                                  : (labels[noteSelectionnee] ?? ''),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: noteSelectionnee == 0
                                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Champ de commentaire
                      Text(
                        'Votre commentaire',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: commentaireController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Partagez votre expérience : qualité du produit, intérêt de l\'enfant, robustesse...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton de publication
                      AppButton(
                        text: avisExistant == null
                            ? 'Publier mon avis'
                            : 'Mettre à jour mon avis',
                        icon: Icons.send_rounded,
                        isLoading: isSubmitting,
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final comm = commentaireController.text.trim();
                                if (noteSelectionnee == 0) {
                                  AppDialogs.showSnackBar(
                                    context: modalContext,
                                    message:
                                        'Veuillez sélectionner une note avant de publier votre avis.',
                                    isWarning: true,
                                  );
                                  return;
                                }
                                if (comm.isEmpty) {
                                  AppDialogs.showSnackBar(
                                    context: modalContext,
                                    message:
                                        'Veuillez écrire un court commentaire pour accompagner votre note.',
                                    isWarning: true,
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                try {
                                  final authState = ref.read(authProvider);
                                  final nom = authState.utilisateur?.nom ?? 'Parent';
                                  final photo = authState.utilisateur?.photoUrl;

                                  final avis = AvisModel(
                                    avisId: avisExistant?.avisId ?? '',
                                    jouetId: widget.jouet.jouetId,
                                    utilisateurId: widget.utilisateurId,
                                    nomUtilisateur: nom.isNotEmpty ? nom : 'Parent',
                                    photoUrl: photo,
                                    note: noteSelectionnee,
                                    commentaire: comm,
                                    dateCreation: avisExistant?.dateCreation ?? DateTime.now(),
                                    dateModification: avisExistant != null ? DateTime.now() : null,
                                  );

                                  final repo = ref.read(avisRepositoryProvider);
                                  await repo.ajouterOuModifierAvis(avis);

                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    AppDialogs.showSnackBar(
                                      context: context,
                                      message: 'Votre avis a été publié avec succès !',
                                    );
                                  }
                                } catch (e) {
                                  if (modalContext.mounted) {
                                    setModalState(() => isSubmitting = false);
                                    AppDialogs.showSnackBar(
                                      context: modalContext,
                                      message: 'Erreur lors de la publication : $e',
                                      isError: true,
                                    );
                                  }
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _supprimerAvis(AvisModel avis) async {
    final confirme = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer votre avis ?',
      message: 'Voulez-vous vraiment supprimer cet avis ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirme == true && mounted) {
      try {
        final repo = ref.read(avisRepositoryProvider);
        await repo.supprimerAvis(widget.jouet.jouetId, avis.avisId);
        if (mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Votre avis a été supprimé.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Erreur lors de la suppression : $e',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final textPrimary =
        theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
            (isDark ? Colors.white70 : AppColors.textSecondary);

    final avisStream = ref.watch(avisJouetStreamProvider(widget.jouet.jouetId));

    return avisStream.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: dividerColor),
        ),
        child: Text(
          'Impossible de charger les avis : $err',
          style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        ),
      ),
      data: (listeAvis) {
        final totalCount = listeAvis.length;
        final noteMoyenne = totalCount > 0
            ? listeAvis.fold<double>(0.0, (sum, a) => sum + a.note) / totalCount
            : widget.jouet.noteMoyenneDenormalise;

        // Histogramme de répartition 1 à 5 étoiles (Façon Google Play)
        final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        for (final a in listeAvis) {
          final rounded = a.note.round().clamp(1, 5);
          counts[rounded] = (counts[rounded] ?? 0) + 1;
        }

        // Vérifier si l'utilisateur connecté a déjà publié un avis
        AvisModel? monAvis;
        if (widget.utilisateurId.isNotEmpty) {
          try {
            monAvis = listeAvis.firstWhere(
              (a) => a.utilisateurId == widget.utilisateurId,
            );
          } catch (_) {
            monAvis = null;
          }
        }

        // Filtrage des avis par étoile
        final avisFiltres = _filterStar == null
            ? listeAvis
            : listeAvis.where((a) => a.note.round() == _filterStar).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITRE DE LA SECTION
            Text(
              'NOTES ET AVIS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // 1. CARTE RÉCAPITULATIVE GOOGLE PLAY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Colonne de Gauche : Note Globale & Étoiles
                      SizedBox(
                        width: 110,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              noteMoyenne > 0 ? noteMoyenne.toStringAsFixed(1) : '—',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (idx) {
                                final starIdx = idx + 1;
                                return Icon(
                                  starIdx <= noteMoyenne.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 16,
                                  color: const Color(0xFFF59E0B),
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$totalCount note${totalCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Colonne de Droite : Barres de répartition 5★ à 1★ (Google Play)
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = counts[star] ?? 0;
                            final pct = totalCount > 0 ? count / totalCount : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Text(
                                    '$star',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 7,
                                        backgroundColor: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : const Color(0xFFE2E8F0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 22,
                                    child: Text(
                                      '$count',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: dividerColor),
                  const SizedBox(height: 12),

                  // Bouton d'action "Donner votre avis" ou "Modifier votre avis"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddEditAvisModal(
                        context,
                        avisExistant: monAvis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        monAvis != null
                            ? Icons.edit_note_rounded
                            : Icons.rate_review_outlined,
                        size: 18,
                      ),
                      label: Text(
                        monAvis != null
                            ? 'Modifier mon avis (${monAvis.note.toStringAsFixed(0)} ★)'
                            : 'Donner votre avis sur ce jouet',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. FILTRAGE PAR NOTE (CHIPS)
            if (totalCount > 0) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tous ($totalCount)', null, theme, isDark, dividerColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('5 ★ (${counts[5]})', 5, theme, isDark, dividerColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('4 ★ (${counts[4]})', 4, theme, isDark, dividerColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('3 ★ (${counts[3]})', 3, theme, isDark, dividerColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('2 ★ (${counts[2]})', 2, theme, isDark, dividerColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('1 ★ (${counts[1]})', 1, theme, isDark, dividerColor),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. LISTE DES COMMENTAIRES INDIVIDUELS
            if (avisFiltres.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 32,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filterStar == null
                          ? 'Aucun commentaire pour l\'instant'
                          : 'Aucun avis avec $_filterStar étoile(s)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Soyez le premier parent à partager votre retour sur ce jouet !',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: avisFiltres.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final avis = avisFiltres[idx];
                  final isMyReview = avis.utilisateurId == widget.utilisateurId;
                  final dateStr = DateFormat('dd/MM/yyyy').format(avis.dateCreation);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMyReview
                            ? theme.colorScheme.primary.withValues(alpha: 0.4)
                            : dividerColor,
                        width: isMyReview ? 1.4 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête de l'avis
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar utilisateur
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                              backgroundImage: avis.photoUrl != null && avis.photoUrl!.isNotEmpty
                                  ? NetworkImage(avis.photoUrl!)
                                  : null,
                              child: avis.photoUrl == null || avis.photoUrl!.isEmpty
                                  ? Text(
                                      avis.nomUtilisateur.isNotEmpty
                                          ? avis.nomUtilisateur[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          avis.nomUtilisateur,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isMyReview) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Vous',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(5, (sIdx) {
                                          return Icon(
                                            sIdx < avis.note.round()
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            size: 13,
                                            color: const Color(0xFFF59E0B),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        dateStr,
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isMyReview) ...[
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                tooltip: 'Modifier',
                                onPressed: () => _showAddEditAvisModal(
                                  context,
                                  avisExistant: avis,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                tooltip: 'Supprimer',
                                onPressed: () => _supprimerAvis(avis),
                              ),
                            ],
                          ],
                        ),
                        if (avis.commentaire.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            avis.commentaire,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    int? starValue,
    ThemeData theme,
    bool isDark,
    Color dividerColor,
  ) {
    final isSelected = _filterStar == starValue;
    final primaryColor = theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? primaryColor : dividerColor,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? primaryColor : theme.colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (sel) {
        setState(() {
          _filterStar = sel ? starValue : null;
        });
      },
    );
  }
}
