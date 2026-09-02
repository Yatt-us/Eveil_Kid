import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../categories/providers/categorie_provider.dart';
import '../../../panier/models/panier.dart';
import '../../../panier/presentation/widgets/panier_app_bar_action.dart';
import '../../../panier/providers/panier_provider.dart';
import '../../../favoris/models/favoris.dart';
import '../../../favoris/providers/favoris_providers.dart';
import '../../../../core/utils/video_route_helper.dart';
import '../../../tutoriels/enums/tutoriel_status.enum.dart';
import '../../../tutoriels/models/tutoriel.dart';
import '../../../tutoriels/presentation/pages/tutoriel_detail_page.dart';
import '../../../tutoriels/providers/tutoriel_provider.dart';
import '../../models/jouet.dart';
import '../../providers/jouet_provider.dart';
import '../widgets/jouet_avis_section.dart';

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
  int _selectedImageIndex = 0;
  final PageController _imagePageController = PageController();

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _incrementerQuantite(int maxStock) {
    final effectiveMax = maxStock > 0 ? maxStock : 1;
    if (_quantite < effectiveMax) {
      setState(() {
        _quantite++;
      });
    } else {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Stock maximum disponible atteint ($effectiveMax)',
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

  Future<void> _ajouterAuPanier(Jouet currentJouet) async {
    if (widget.utilisateurId.isEmpty) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Veuillez vous connecter pour ajouter au panier',
        isWarning: true,
      );
      return;
    }

    if (currentJouet.stockDisponible <= 0) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Ce produit est actuellement en rupture de stock.',
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
        jouetId: currentJouet.jouetId,
        nomJouet: currentJouet.nom,
        prixUnitaire: currentJouet.prix,
        miniatureUrl: currentJouet.imagePrincipaleUrl,
        stockDispo: currentJouet.stockDisponible,
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

  String _formatPrice(double price, String devise) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted ${devise.isNotEmpty ? devise : "FCFA"}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final textPrimary =
        theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
            (isDark ? Colors.white70 : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    // 1. ÉCOUTE RÉACTIVE DU JOUET DEPUIS LA BASE DE DONNÉES FIRESTORE
    final liveJouetAsync = ref.watch(jouetStreamProvider(widget.jouet.jouetId));
    final currentJouet = liveJouetAsync.value ?? widget.jouet;

    // 2. RÉCUPÉRATION DU NOM DE LA CATÉGORIE EN BASE DE DONNÉES
    final categoriesAsync = ref.watch(categoriesProvider);
    String nomCategorie = currentJouet.nomCategorieDenormalise;
    categoriesAsync.whenData((cats) {
      final found = cats.where((c) => c.categorieId == currentJouet.categorieId);
      if (found.isNotEmpty) {
        nomCategorie = found.first.nom;
      }
    });

    // 3. RÉCUPÉRATION DYNAMIQUE DES TUTORIELS ASSOCIÉS AU JOUET
    final tutorielsAsync = ref.watch(tutorielsProvider);
    final tutorielsDuJouet = tutorielsAsync.maybeWhen(
      data: (tuts) => tuts.where((t) {
        final isLie = t.jouetLieId == currentJouet.jouetId;
        final isSuggere = t.jouetsSuggeres.contains(currentJouet.jouetId);
        final isPublie = t.statut == TutorielStatus.publie;
        return (isLie || isSuggere) && isPublie;
      }).toList(),
      orElse: () => <Tutoriel>[],
    );

    // Liste des images
    final allImages = currentJouet.images.isNotEmpty
        ? currentJouet.images
        : (currentJouet.imagePrincipaleUrl.isNotEmpty
            ? [currentJouet.imagePrincipaleUrl]
            : <String>[]);

    final isEnRupture = currentJouet.stockDisponible <= 0;
    final isStockFaible = currentJouet.stockDisponible > 0 && currentJouet.stockDisponible <= 3;

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
          'Détails du produit',
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
              final isFav = ref.watch(isElementFavoriProvider(currentJouet.jouetId));
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : (theme.iconTheme.color ?? textPrimary),
                ),
                tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                onPressed: () {
                  ref.read(favoriServiceProvider).toggleFavori(
                        utilisateurId: widget.utilisateurId,
                        elementId: currentJouet.jouetId,
                        typeElement: TypeElement.jouet,
                        titre: currentJouet.nom,
                        miniatureUrl: currentJouet.imagePrincipaleUrl,
                        prix: currentJouet.prix,
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
                    // 1. CARROUSEL D'IMAGES DU PRODUIT
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.card,
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                            : theme.colorScheme.surface,
                        border: Border.all(color: dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (allImages.isNotEmpty)
                            PageView.builder(
                              controller: _imagePageController,
                              itemCount: allImages.length,
                              onPageChanged: (index) {
                                setState(() => _selectedImageIndex = index);
                              },
                              itemBuilder: (ctx, idx) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.network(
                                    allImages[idx],
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, error, stackTrace) => Icon(
                                      Icons.toys_outlined,
                                      size: 80,
                                      color: primaryColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Center(
                              child: Icon(
                                Icons.toys_outlined,
                                size: 80,
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),

                          // Indicateurs de pagination du carrousel
                          if (allImages.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(allImages.length, (idx) {
                                  final isCurrent = idx == _selectedImageIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: isCurrent ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? primaryColor
                                          : primaryColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),

                          // Badges d'état (Populaire / Âge)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Row(
                              children: [
                                if (currentJouet.estPopulaire) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, size: 13, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Populaire',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                if (currentJouet.ageMinimum > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : Colors.black.withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currentJouet.ageMaximum > currentJouet.ageMinimum
                                          ? '${currentJouet.ageMinimum}-${currentJouet.ageMaximum} ans'
                                          : 'Dès ${currentJouet.ageMinimum} ans',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. NOM DU PRODUIT & CATÉGORIE
                    if (nomCategorie.isNotEmpty) ...[
                      Text(
                        nomCategorie.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      currentJouet.nom,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. PRIX DU PRODUIT
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatPrice(currentJouet.prix, currentJouet.devise),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. DESCRIPTION
                    Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentJouet.description.isNotEmpty
                          ? currentJouet.description
                          : 'Aucune description détaillée disponible pour ce produit.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 5. SECTION TUTORIELS VIDÉO INCLUS DYNAMIQUES
                    if (tutorielsDuJouet.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TUTORIELS VIDÉO INCLUS',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${tutorielsDuJouet.length} vidéo${tutorielsDuJouet.length > 1 ? "s" : ""}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...tutorielsDuJouet.map(
                        (tut) => _buildTutorielTile(
                          context,
                          tut,
                          theme,
                          isDark,
                          primaryColor,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // 6. SECTION NOTES ET AVIS GOOGLE PLAY
                    JouetAvisSection(
                      jouet: currentJouet,
                      utilisateurId: widget.utilisateurId,
                    ),
                  ],
                ),
              ),
            ),

            // 7. BARRE D'ACTION INFÉRIEURE (SÉLECTEUR DE QUANTITÉ & BOUTON D'AJOUT)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: dividerColor),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sélecteur de quantité
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
                          onTap: isEnRupture ? null : _decrementerQuantite,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Icon(
                              Icons.remove_rounded,
                              size: 18,
                              color: isEnRupture
                                  ? textSecondary.withValues(alpha: 0.3)
                                  : textPrimary,
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
                              color: isEnRupture
                                  ? textSecondary.withValues(alpha: 0.3)
                                  : textPrimary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isEnRupture
                              ? null
                              : () => _incrementerQuantite(currentJouet.stockDisponible),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: isEnRupture
                                  ? textSecondary.withValues(alpha: 0.3)
                                  : textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bouton Ajouter au panier
                  Expanded(
                    child: AppButton(
                      text: isEnRupture ? 'Rupture de stock' : 'Ajouter au panier',
                      icon: isEnRupture ? Icons.block_rounded : Icons.shopping_bag_outlined,
                      isLoading: _isLoading,
                      onPressed: isEnRupture || _isLoading
                          ? null
                          : () => _ajouterAuPanier(currentJouet),
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

  Widget _buildTutorielTile(
    BuildContext context,
    Tutoriel tut,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        elevation: isDark ? 0 : 1,
        child: InkWell(
          onTap: () {
            if (tut.tutorielId != null && tut.tutorielId!.isNotEmpty) {
              openYouTubeStyleVideo(
                context,
                TutorielDetailPage(tutorielId: tut.tutorielId!),
              );
            }
          },
          borderRadius: AppRadius.card,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(
                color:
                    theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.12),
              ),
            ),
            child: Row(
              children: [
                // Miniature avec bouton play
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 72,
                        height: 52,
                        color: primaryColor.withValues(alpha: 0.1),
                        child: tut.miniatureUrl.isNotEmpty
                            ? Image.network(
                                tut.miniatureUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: primaryColor,
                                  size: 32,
                                ),
                              )
                            : Icon(
                                Icons.play_circle_fill_rounded,
                                color: primaryColor,
                                size: 32,
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Titre & Âge / Durée
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tut.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (tut.ageRangeLabel.isNotEmpty) ...[
                            Text(
                              tut.ageRangeLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textSecondary,
                              ),
                            ),
                            if (tut.duree > 0)
                              Text(
                                ' • ${tut.dureeFormatted}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
