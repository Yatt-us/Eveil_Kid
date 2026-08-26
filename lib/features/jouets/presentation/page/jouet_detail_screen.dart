import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../panier/models/panier.dart';
import '../../../panier/presentation/widgets/panier_app_bar_action.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../../favoris/models/favoris.dart';
import '../../../favoris/providers/favoris_providers.dart';
import '../../models/jouet.dart';

class JouetDetailScreen extends ConsumerStatefulWidget {
  final Jouet jouet;
  final String utilisateurId;

  const JouetDetailScreen({
    super.key,
    required this.jouet,
    required this.utilisateurId,
    Jouet? jouetToDisplay,
    Jouet? jouetToEdit,
  });

  @override
  ConsumerState<JouetDetailScreen> createState() => _JouetDetailScreenState();
}

class _JouetDetailScreenState extends ConsumerState<JouetDetailScreen> {
  bool _isLoading = false;

  int _quantite = 1;

  void _incrementerQuantite() {
    final maxStock = widget.jouet.stockDisponible > 0
        ? widget.jouet.stockDisponible
        : 99;

    if (_quantite < maxStock) {
      setState(() {
        _quantite++;
      });
    } else {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Stock maximum atteint ($maxStock disponible(s))',
        isWarning: true,
      );
    }
  }

  void _decrementerQuantite() {
    if (_quantite > 1) {
      setState(() {
        _quantite--;
      });
    }
  }

  Future<void> _ajouterAuPanier() async {
    if (widget.utilisateurId.isEmpty) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Veuillez vous connecter pour ajouter au panier',
        isWarning: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final panierService = ref.read(panierServiceProvider);
      final now = DateTime.now();

      final article = ArticlePanier(
        articlePanierId: '',
        utilisateurId: widget.utilisateurId,
        jouetId: widget.jouet.jouetId,
        nomJouet: widget.jouet.nom,
        prixUnitaire: widget.jouet.prix,
        miniatureUrl: widget.jouet.imagePrincipaleUrl,
        stockDispo: widget.jouet.stockDisponible,
        quantite: _quantite,
        dateCreation: now,
        dateModification: now,
      );

      await panierService.ajouterProduit(article);

      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Produit ajouté au panier avec succès !',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur : $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted ${widget.jouet.devise.isNotEmpty ? widget.jouet.devise : "FCFA"}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final textPrimary = theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détails jouet',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isFav = ref.watch(isElementFavoriProvider(widget.jouet.jouetId));
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : (theme.iconTheme.color ?? textPrimary),
                ),
                tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: () {
                  ref.read(favoriServiceProvider).toggleFavori(
                        utilisateurId: widget.utilisateurId,
                        elementId: widget.jouet.jouetId,
                        typeElement: TypeElement.jouet,
                        titre: widget.jouet.nom,
                        miniatureUrl: widget.jouet.imagePrincipaleUrl,
                        prix: widget.jouet.prix,
                      );
                },
              );
            },
          ),
          const PanierAppBarAction(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE PRINCIPALE
                    Center(
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.card,
                          color: isDark
                              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                              : theme.colorScheme.surface,
                          border: Border.all(color: dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.25 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: widget.jouet.imagePrincipaleUrl.isNotEmpty
                            ? Image.network(
                                widget.jouet.imagePrincipaleUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, error, stackTrace) => Icon(
                                  Icons.toys_outlined,
                                  size: 80,
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              )
                            : Icon(
                                Icons.toys_outlined,
                                size: 80,
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // NOM DU JOUET
                    Text(
                      widget.jouet.nom,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // NOTE + PRIX
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.jouet.noteMoyenneDenormalise.toStringAsFixed(1)} (${widget.jouet.nombreAvisDenormalise} avis)',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatPrice(widget.jouet.prix),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // DESCRIPTION
                    Text(
                      widget.jouet.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // SKILLS / COMPETENCES
                    Text(
                      'COMPÉTENCES DÉVELOPPÉES',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSkillBadge(
                          icon: Icons.edit_outlined,
                          label: 'Créativité',
                          theme: theme,
                          isDark: isDark,
                          badgeColor: primaryColor,
                        ),
                        _buildSkillBadge(
                          icon: Icons.crop_free_outlined,
                          label: 'Logique',
                          theme: theme,
                          isDark: isDark,
                          badgeColor: const Color(0xFF10B981),
                        ),
                        _buildSkillBadge(
                          icon: Icons.gesture_outlined,
                          label: 'Motricité',
                          theme: theme,
                          isDark: isDark,
                          badgeColor: const Color(0xFFF59E0B),
                        ),
                        _buildSkillBadge(
                          icon: Icons.psychology_outlined,
                          label: 'Concentration',
                          theme: theme,
                          isDark: isDark,
                          badgeColor: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // BANNIERE TUTORIELS
                    if (widget.jouet.nbTutorielsAssocies > 0)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: AppRadius.card,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vidéos tutoriels incluses',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Apprenez à votre enfant à construire et à explorer de nouvelles idées.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.circularRadius,
                                        ),
                                      ),
                                      child: Text(
                                        'Voir les vidéos (${widget.jouet.nbTutorielsAssocies})',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: AppRadius.card,
                              child: widget.jouet.imagePrincipaleUrl.isNotEmpty
                                  ? Image.network(
                                      widget.jouet.imagePrincipaleUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, error, stackTrace) => Container(
                                        width: 80,
                                        height: 80,
                                        color: primaryColor.withValues(alpha: 0.1),
                                        child: Icon(
                                          Icons.play_circle_outline_rounded,
                                          size: 40,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: primaryColor.withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.play_circle_outline_rounded,
                                        size: 40,
                                        color: primaryColor,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // BARRE D'ACTION (COMPTEUR ET BOUTON D'AJOUT AU PANIER)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: dividerColor),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // SELECTEUR DE QUANTITE
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                          : theme.scaffoldBackgroundColor,
                      border: Border.all(color: dividerColor),
                      borderRadius: AppRadius.circularRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _decrementerQuantite,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 18,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_quantite',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _incrementerQuantite,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // BOUTON AJOUTER AU PANIER
                  Expanded(
                    child: AppButton(
                      text: 'Ajouter au panier',
                      icon: Icons.shopping_bag_outlined,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _ajouterAuPanier,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBadge({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required bool isDark,
    required Color badgeColor,
  }) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: badgeColor, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodySmall?.color ??
                (isDark ? Colors.white70 : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
