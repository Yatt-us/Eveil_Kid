// lib/features/commandes/presentation/pages/adresse_page.dart

import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/commandes/models/commande_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import 'paiement_page.dart';

class AdressePage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;

  const AdressePage({
    super.key,
    required this.brouillonCommande,
  });

  @override
  ConsumerState<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends ConsumerState<AdressePage> {
  late String _adresseLivraison;
  late String _numeroTelephone;
  static const Color primaryColor = Color(0xFF7E3DBE);

  @override
  void initState() {
    super.initState();
    _adresseLivraison = '';
    _numeroTelephone = '';
  }

  void _ouvrirDialogueModification() {
    final adresseController = TextEditingController(text: _adresseLivraison);
    final telephoneController = TextEditingController(text: _numeroTelephone);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Modifier les informations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: 'Ex: +223 70 00 00 00',
                  prefixIcon: const Icon(Icons.phone_outlined, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adresseController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                  hintText: 'Ex: Baco-Djicoroni/Bamako',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _adresseLivraison = adresseController.text.trim();
                _numeroTelephone = telephoneController.text.trim();
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final Utilisateur? utilisateur = authState.utilisateur;
    
    final nomParent = utilisateur?.nom ?? '';
    final affichageNom = nomParent.isNotEmpty ? nomParent : 'Parent';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Adresse',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator('1', 'Adresse', true),
                  _buildStepLine(),
                  _buildStepIndicator('2', 'Paiement', false),
                  _buildStepLine(),
                  _buildStepIndicator('3', 'Confirmation', false),
                ],
              ),
              const SizedBox(height: 28),
              
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle, 
                          color: Colors.green, 
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          affichageNom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _ouvrirDialogueModification,
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // 1. Récupération de l'ID du parent connecté depuis l'objet utilisateur
                    final String? parentId = utilisateur?.uid; 
                    if (parentId == null || parentId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur : Utilisateur non identifié'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 2. Injection du parentId et de l'adresse dans le modèle via copyWith
                    final commandeMiseAJour = widget.brouillonCommande.copyWith(
                      parentId: parentId,
                      adresseLivraison: _adresseLivraison,
                    );

                    // 3. Navigation vers l'écran de paiement avec le modèle complété
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaiementPage(
                          brouillonCommande: commandeMiseAJour,
                          adresseLivraison: _adresseLivraison,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirmer la commande',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black87 : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      ),
    );
  }
}