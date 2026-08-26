import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StatutCommandeWidget extends StatelessWidget {
  final String statut;

  const StatutCommandeWidget({super.key, required this.statut});

  static const Map<String, Map<String, dynamic>> _infoStatut = {
    'en_attente': {'libelle': 'En attente', 'couleur': Color(0xFFF59E0B)},
    'confirmee': {'libelle': 'Confirmée', 'couleur': Color(0xFF3B82F6)},
    'en_preparation': {'libelle': 'En préparation', 'couleur': Color(0xFF8B5CF6)},
    'expediee': {'libelle': 'Expédiée', 'couleur': Color(0xFF06B6D4)},
    'livree': {'libelle': 'Livrée', 'couleur': Color(0xFF10B981)},
    'annulee': {'libelle': 'Annulée', 'couleur': Color(0xFFEF4444)},
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final info = _infoStatut[statut.toLowerCase()] ??
        {'libelle': statut, 'couleur': theme.colorScheme.primary};

    final Color color = info['couleur'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        info['libelle'] as String,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class SuiviCommandeChronologie extends StatelessWidget {
  final String statutActuel;

  const SuiviCommandeChronologie({super.key, required this.statutActuel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final etapes = [
      {'cle': 'en_attente', 'libelle': 'Commandée'},
      {'cle': 'confirmee', 'libelle': 'Confirmée'},
      {'cle': 'en_preparation', 'libelle': 'En préparation'},
      {'cle': 'expediee', 'libelle': 'Expédiée'},
      {'cle': 'livree', 'libelle': 'Livrée'},
    ];

    int indexActuel = etapes.indexWhere((e) => e['cle'] == statutActuel);
    if (indexActuel == -1 && statutActuel == 'annulee') {
      return Center(
        child: Text(
          'Cette commande a été annulée.',
          style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: List.generate(etapes.length, (index) {
        bool estFait = index <= indexActuel;
        bool estEnCours = index == indexActuel;

        return Row(
          children: [
            Column(
              children: [
                Icon(
                  estFait ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: estFait ? const Color(0xFF10B981) : (isDark ? Colors.white30 : Colors.grey.shade400),
                  size: 22,
                ),
                if (index < etapes.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: index < indexActuel
                        ? const Color(0xFF10B981)
                        : (isDark ? theme.dividerColor : Colors.grey.shade300),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              etapes[index]['libelle']!,
              style: TextStyle(
                fontWeight: estEnCours ? FontWeight.bold : FontWeight.w500,
                color: estFait
                    ? (theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface)
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
          ],
        );
      }),
    );
  }
}