import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/features/panier/models/panier.dart';
import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/panier/providers/panier_provider.dart';
import 'package:eveilkid/features/panier/presentation/widgets/panier_app_bar_action.dart';

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
  bool _isFavorite = false;
  bool _isLoading = false;

  int _quantite = 1;

  void _incrementerQuantite() {
    // Si la limite du stock est atteinte ou vaut <= 1, on autorise au moins le test d'incrémentation
    // sinon la valeur est plafonnée au stock réel disponible.
    final maxStock = widget.jouet.stockDisponible > 0
        ? widget.jouet.stockDisponible
        : 99;

    if (_quantite < maxStock) {
      setState(() {
        _quantite++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock maximum atteint ($maxStock disponible(s))'),
          duration: const Duration(seconds: 1),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour ajouter au panier'),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit ajouté au panier avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Détails jouet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppColors.textPrimary,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          const PanierAppBarAction(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE PRINCIPALE
                    Center(
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.card,
                          color: AppColors.surfaceVariant,
                        ),
                        child: widget.jouet.imagePrincipaleUrl.isNotEmpty
                            ? Image.network(
                                widget.jouet.imagePrincipaleUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.toys_outlined,
                                  size: 80,
                                  color: AppColors.disabled,
                                ),
                              )
                            : const Icon(
                                Icons.toys_outlined,
                                size: 80,
                                color: AppColors.disabled,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // NOM DU JOUET
                    Text(
                      widget.jouet.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // NOTE + PRIX
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.jouet.noteMoyenneDenormalise.toStringAsFixed(1)} avis (${widget.jouet.nombreAvisDenormalise})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.jouet.prix.toStringAsFixed(0)} ${widget.jouet.devise}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DESCRIPTION
                    Text(
                      widget.jouet.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SKILLS / COMPETENCES
                    // SKILLS / COMPETENCES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSkillBadge(
                          icon: Icons.edit_outlined,
                          label: 'Créativité',
                          backgroundColor: const Color.fromARGB(
                            255,
                            234,
                            224,
                            255,
                          ), // Violet / Mauve léger
                          iconColor: const Color.fromARGB(
                            255,
                            13,
                            50,
                            232,
                          ), // Violet
                        ),
                        _buildSkillBadge(
                          icon: Icons.crop_free_outlined,
                          label: 'Logique',
                          backgroundColor: const Color(
                            0xFFE8F5E9,
                          ), // Vert léger
                          iconColor: const Color(0xFF2E7D32), // Vert
                        ),
                        _buildSkillBadge(
                          icon: Icons.gesture_outlined,
                          label: 'Motricité',
                          backgroundColor: const Color(
                            0xFFFFF3E0,
                          ), // Orange léger
                          iconColor: const Color(0xFFE65100), // Orange
                        ),
                        _buildSkillBadge(
                          icon: Icons.psychology_outlined,
                          label: 'Concentration',
                          backgroundColor: const Color(
                            0xFFE3F2FD,
                          ), // Bleu léger
                          iconColor: const Color(0xFF1565C0), // Bleu
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // BANNIERE TUTORIELS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 216, 255),
                        borderRadius: AppRadius.card,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vidéos tutoriels incluses',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Apprenez à votre enfant à construire et à explorer de nouvelles idées',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.circularRadius,
                                      ),
                                    ),
                                    child: Text(
                                      'Voir les vidéos (${widget.jouet.nbTutorielsAssocies})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: AppRadius.card,
                            child: Image.network(
                              widget.jouet.imagePrincipaleUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.play_circle_outline,
                                size: 40,
                                color: AppColors.primary,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // SELECTEUR DE QUANTITE
                  // SELECTEUR DE QUANTITE
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_quantite',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _incrementerQuantite,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(24),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // BOUTON AJOUTER AU PANIER
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _ajouterAuPanier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.circularRadius,
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Ajouter au panier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
