import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/commandes/models/commande_model.dart';
import 'features/commandes/providers/commande_provider.dart';
import 'features/commandes/presentation/pages/adresse_page.dart'; // 👈 Import de AdressePage au lieu de ConfirmationPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommandeProvider()),
      ],
      child: const MonApp(),
    ),
  );
}

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final commandeTest = CommandeModel(
      id: 'CMD-TEST-123',
      parentId: 'sam@gmail.com',
      articles: [
        ArticleCommandeModel(
          produitId: 'j1',
          titre: 'Jeu de construction en bois',
          quantite: 2,
          prix: 5000,
        ),
      ],
      montantTotal: 12000,
      fraisLivraison: 2000,
      adresseLivraison: 'Bamako, Quartier Hippodrome',
      numeroTelephone: '+223 70 00 00 00',
      dateCreation: DateTime.now(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eveil Kid',
      home: AdressePage(
        brouillonCommande: commandeTest, // 👈 Redirection sur AdressePage avec la commande de test
      ),
    );
  }
}