import 'package:flutter/material.dart';
import '../../models/commande_model.dart';
import '../widgets/checkout_stepper.dart';
import 'paiement_page.dart';

class AdressePage extends StatefulWidget {
  final CommandeModel brouillonCommande;

  const AdressePage({super.key, required this.brouillonCommande});

  @override
  State<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends State<AdressePage> {
  static const Color primaryColor = Color(0xFF7E3DBE);

  // État local pour stocker l'adresse modifiable
  late String adresseActuelle;

  @override
  void initState() {
    super.initState();
    // Initialisation avec l'adresse reçue en paramètre
    adresseActuelle = widget.brouillonCommande.adresseLivraison;
  }

  // Fonction pour afficher la boîte de dialogue de modification
  void _afficherDialogueModification() {
    final TextEditingController controller = TextEditingController(text: adresseActuelle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'adresse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Entrez la nouvelle adresse',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    adresseActuelle = controller.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Adresse', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          const CheckoutStepper(stepActuel: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adresse de livraison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonne de GAUCHE : Nom et adresse dynamique
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Oumou Dia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                adresseActuelle,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Colonne de DROITE : Coche verte + Bouton Modifier aligné à droite
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF289F51)),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _afficherDialogueModification,
                              child: const Text(
                                'Modifier',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Bouton remonté davantage grâce à bottom: 60.0
                  Container(
                    margin: const EdgeInsets.only(bottom: 60.0),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // Mise à jour de la commande avec l'adresse éventuellement modifiée
                        final commandeMiseAJour = widget.brouillonCommande.copyWith(
                          adresseLivraison: adresseActuelle,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaiementPage(brouillonCommande: commandeMiseAJour),
                          ),
                        );
                      },
                      child: const Text(
                        'Confirmer la commande',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
}