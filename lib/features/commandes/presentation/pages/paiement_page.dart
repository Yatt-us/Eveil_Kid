
// lib/features/commandes/presentation/pages/paiement_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/commande_model.dart';
import '../../providers/commande_provider.dart';
import 'confirmation_page.dart';

class PaiementPage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;
  final String adresseLivraison;

  const PaiementPage({
    super.key,
    required this.brouillonCommande,
    required this.adresseLivraison,
  });

  @override
  ConsumerState<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends ConsumerState<PaiementPage> {
  String? _modePaiement;

  static const Color primaryColor = Color(0xFF7E3DBE);

  @override
  Widget build(BuildContext context) {
    final double montant = widget.brouillonCommande.montantTotal;
    final double fraisLivraison =
        widget.brouillonCommande.fraisLivraison;
    final double sousTotal = montant - fraisLivraison;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepItem(
                  icon: Icons.check,
                  label: 'Livraison',
                  isCompleted: true,
                  primaryColor: primaryColor,
                ),
                _buildStepDivider(),
                _buildStepItem(
                  textNumber: '2',
                  label: 'Paiement',
                  isActive: true,
                  primaryColor: primaryColor,
                ),
                _buildStepDivider(),
                _buildStepItem(
                  textNumber: '3',
                  label: 'Confirmation',
                  primaryColor: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Mode de paiement
            const Text(
              'Methode de paiement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),
            _buildCustomPaymentCard(
              value: 'Mobile Money',
              title: 'Mobile Money',
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/logo.MM.png',
                    height: 42,
                    width: 54,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/icons/logo.OM.jpg',
                    height: 42,
                    width: 54,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    },
                  ),
                ],
              ),
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 10),
            _buildCustomPaymentCard(
              value: 'Carte bancaire',
              title: 'Carte bancaire',
              iconData: Icons.credit_card,
              trailingWidget: Image.asset(
                'assets/icons/LOGO visa.jpg',
                height: 48,
                width: 86,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'VISA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 10),
            _buildCustomPaymentCard(
              value: 'Paiement à la livraison',
              title: 'Paiement a la livraison',
              iconData: Icons.mail_outline,
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 20),
            // Resume
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resume de la commande',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Sous-total',
                    '${sousTotal.toStringAsFixed(2)} XOF',
                  ),

                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Livraison',
                    fraisLivraison == 0
                        ? 'Gratuite'
                        : '${fraisLivraison.toStringAsFixed(2)} XOF',
                    valueColor:
                        fraisLivraison == 0 ? Colors.green : null,
                  ),

                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Total',
                    '${montant.toStringAsFixed(2)} XOF',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Confirmer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  // Vérification du paiement
                  if (_modePaiement == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez sélectionner un mode de paiement',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // On crée une NOUVELLE liste indépendante des articles.
                  // Cela évite qu'une modification du panier puisse
                  // modifier les articles d'une ancienne commande.
                  final articlesCommande =
                      widget.brouillonCommande.articles
                          .map(
                            (article) => ArticleCommandeModel(
                              produitId: article.produitId,
                              titre: article.titre,
                              quantite: article.quantite,
                              prix: article.prix,
                              urlImage: article.urlImage,
                            ),
                          )
                          .toList();
                  // Création de la commande définitive
                  final nouvelleCommande = CommandeModel(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    parentId: widget.brouillonCommande.parentId,

                    // On utilise la copie indépendante
                    articles: articlesCommande,
                    montantTotal: montant,
                    fraisLivraison: fraisLivraison,
                    adresseLivraison:
                        widget.adresseLivraison,
                    modePaiement: _modePaiement!,
                    dateCreation: DateTime.now(),
                    statut: 'En cours',
                  );

                  // Enregistrement dans firebase
                  final succes = await ref
                      .read(commandeProvider.notifier)
                      .passerCommande(nouvelleCommande);

                  if (!mounted) return;

                  if (!succes) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Impossible d\'enregistrer la commande.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Commande enregistrée avec succès
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmationPage(
                        commande: nouvelleCommande,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Payer ${montant.toStringAsFixed(2)} XOF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Etape du checkout

  Widget _buildStepItem({
    String? textNumber,
    IconData? icon,
    required String label,
    bool isActive = false,
    bool isCompleted = false,
    required Color primaryColor,
  }) {
    final Color circleColor =
        (isCompleted || isActive)
            ? primaryColor
            : Colors.grey.shade300;

    final Color textColor =
        (isCompleted || isActive)
            ? Colors.white
            : Colors.grey.shade700;

    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 14,
                    color: Colors.white,
                  )
                : Text(
                    textNumber ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive || isCompleted
                ? Colors.black
                : Colors.grey,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  Widget _buildStepDivider() {
    return Container(
      width: 35,
      height: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 12,
      ),
    );
  }
  // Carte paiement
  Widget _buildCustomPaymentCard({
    required String value,
    required String title,
    Widget? trailingWidget,
    IconData iconData =
        Icons.account_balance_wallet_outlined,
    required Color primaryColor,
  }) {
    final bool isSelected = _modePaiement == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _modePaiement = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              color: isSelected
                  ? primaryColor
                  : Colors.black54,
              size: 22,
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 10),
            ],

            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Ligne de resume

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color: isTotal
                ? Colors.black
                : Colors.grey.shade600,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.w600,
            color: valueColor ??
                (isTotal
                    ? Colors.black
                    : Colors.black87),
          ),
        ),
      ],
    );
  }
}
