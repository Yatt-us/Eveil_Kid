import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande_model.dart';
import '../../providers/commande_provider.dart';
import '../widgets/checkout_stepper.dart';
import 'confirmation_page.dart';

class PaiementPage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;

  const PaiementPage({super.key, required this.brouillonCommande});

  @override
  ConsumerState<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends ConsumerState<PaiementPage> {
  static const Color primaryColor = Color(0xFF7E3DBE);
  
  // Aucun mode de paiement sélectionné par défaut (null au démarrage)
  String? modePaiementSelectionne;

  @override
  Widget build(BuildContext context) {
    final commandeState = ref.watch(commandeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const CheckoutStepper(stepActuel: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Méthode de paiement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Options de paiement (Carte bancaire positionnée en dessous de Mobile Money)
                  _buildPaymentOption('Mobile Money'),
                  _buildPaymentOption('Carte bancaire'),
                  _buildPaymentOption('Paiement à la livraison'),

                  const SizedBox(height: 24),
                  const Text(
                    'Résumé de la commande',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sous-total', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${(widget.brouillonCommande.montantTotal - widget.brouillonCommande.fraisLivraison).toStringAsFixed(2)} XOF',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Livraison', style: TextStyle(color: Colors.grey)),
                      Text(
                        widget.brouillonCommande.fraisLivraison == 0
                            ? 'Gratuite'
                            : '${widget.brouillonCommande.fraisLivraison} XOF',
                        style: const TextStyle(color: Color(0xFF289F51)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${widget.brouillonCommande.montantTotal.toStringAsFixed(2)} XOF',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Bouton de paiement
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: commandeState.estEnChargement
                          ? null
                          : () async {
                              if (modePaiementSelectionne == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez sélectionner un mode de paiement.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              
                              if (user == null || user.uid.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erreur : Aucun utilisateur connecté.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final commandeFinale = widget.brouillonCommande.copyWith(
                                parentId: user.uid,
                                modePaiement: modePaiementSelectionne,
                                dateCreation: DateTime.now(),
                              );

                              bool succes = await ref
                                  .read(commandeProvider.notifier)
                                  .passerCommande(commandeFinale);

                              if (succes && context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfirmationPage(commande: commandeFinale),
                                  ),
                                  (route) => route.isFirst,
                                );
                              } else if (commandeState.messageErreur != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(commandeState.messageErreur!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: commandeState.estEnChargement
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Payer ${widget.brouillonCommande.montantTotal.toStringAsFixed(2)} XOF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget personnalisé avec de très grandes tailles pour les logos
  Widget _buildPaymentOption(String title) {
    bool isSelected = modePaiementSelectionne == title;
    
    return GestureDetector(
      onTap: () => setState(() => modePaiementSelectionne = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Texte du mode de paiement
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            
            // Logos très grand format
            if (title == 'Mobile Money') ...[
              Image.asset(
                'assets/icons/logo.MM.png',
                width: 48,
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/icons/logo.OM.jpg',
                width: 48,
                height: 35,
                fit: BoxFit.contain,
              ),
            ] else if (title == 'Carte bancaire') ...[
              Image.asset(
                'assets/icons/LOGO visa.jpg',
                width: 75,
                height: 45,
                fit: BoxFit.contain,
              ),
            ],
            
            const SizedBox(width: 12),
            
            // Cercle avec le 'v' (coche) à droite
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}