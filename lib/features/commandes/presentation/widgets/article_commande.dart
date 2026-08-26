import 'package:flutter/material.dart';
import '../../models/commande_model.dart';

class ArticleCommandeWidget extends StatelessWidget {
  final ArticleCommandeModel article;

  const ArticleCommandeWidget({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: article.urlImage != null && article.urlImage!.isNotEmpty
                ? Image.network(article.urlImage!, fit: BoxFit.cover)
                : const Icon(Icons.toys, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.titre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Quantité : ${article.quantite}'),
              ],
            ),
          ),
          Text(
            '${(article.prix * article.quantite).toStringAsFixed(0)} FCFA',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}