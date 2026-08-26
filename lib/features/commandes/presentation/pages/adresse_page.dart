import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Valeurs par défaut pour le téléphone et l'adresse modifiables
  String telephoneParent = '+223 78049880';
  late String adresseActuelle;
  
  // Le vrai nom récupéré depuis l'authentification ou Firestore
  String nomParent = 'Chargement...';

  @override
  void initState() {
    super.initState();
    adresseActuelle = widget.brouillonCommande.adresseLivraison.isNotEmpty 
        ? widget.brouillonCommande.adresseLivraison 
        : 'ACI 2000';
        
    _recupererVraiNomEtInfosParent();
  }

  // Récupération stricte du vrai nom connecté + téléphone/adresse optionnels
  Future<void> _recupererVraiNomEtInfosParent() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. On cherche d'abord dans Firestore (collection 'parents')
        final docSnapshot = await FirebaseFirestore.instance
            .collection('parents')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data()!;
          setState(() {
            // Priorité absolue au vrai nom stocké dans Firestore
            nomParent = data['nom'] ?? data['displayName'] ?? user.displayName ?? user.email ?? 'Parent';
            
            if (data['telephone'] != null) {
              telephoneParent = data['telephone'];
            }
            if (data['adresse'] != null && widget.brouillonCommande.adresseLivraison.isEmpty) {
              adresseActuelle = data['adresse'];
            }
          });
        } else {
          // 2. Si pas de doc Firestore, on utilise Firebase Auth
          setState(() {
            nomParent = user.displayName ?? user.email ?? 'Parent';
          });
        }
      }
    } catch (e) {
      setState(() {
        nomParent = 'Parent';
      });
    }
  }

  // Boîte de dialogue pour modifier le téléphone et l'adresse
  void _afficherDialogueModification() {
    final TextEditingController adresseController = TextEditingController(text: adresseActuelle);
    final TextEditingController telephoneController = TextEditingController(text: telephoneParent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier les informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adresseController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Adresse de livraison',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                if (adresseController.text.trim().isNotEmpty) {
                  setState(() {
                    adresseActuelle = adresseController.text.trim();
                    if (telephoneController.text.trim().isNotEmpty) {
                      telephoneParent = telephoneController.text.trim();
                    }
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Le vrai nom du parent connecté s'affiche ici
                              Text(
                                nomParent,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                telephoneParent,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                adresseActuelle,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF289F51)),
                            const SizedBox(height: 24),
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