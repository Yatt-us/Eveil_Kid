import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String modePaiementSelectionne = 'Mobile Money';

  @override
  Widget build(BuildContext context) {
    // On écoute l'état global du provider Riverpod
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Méthode de paiement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption('Mobile Money', Icons.phone_android),
                  _buildPaymentOption('Carte bancaire', Icons.credit_card),
                  _buildPaymentOption('Paiement à la livraison', Icons.local_shipping),
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
                  const Spacer(),
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
                              final commandeFinale = widget.brouillonCommande.copyWith(
                                modePaiement: modePaiementSelectionne,
                                dateCreation: DateTime.now(),
                              );

                              // Appel de la méthode du Notifier via ref.read
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    bool isSelected = modePaiementSelectionne == title;
    return GestureDetector(
      onTap: () => setState(() => modePaiementSelectionne = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}