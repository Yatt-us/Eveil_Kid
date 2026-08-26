import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

/// Modal sécurisé de confirmation pour la désactivation d'un compte utilisateur.
/// Exige la saisie explicite du mot-clé « DESACTIVER » et la sélection d'un motif.
class AdminDeactivateDialog extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String role; // 'PARENT' ou 'MANAGER'

  const AdminDeactivateDialog({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.role,
  });

  /// Méthode statique pour afficher facilement le dialog.
  /// Retourne le motif de désactivation si confirmé, ou `null` si annulé.
  static Future<String?> show({
    required BuildContext context,
    required String userName,
    required String userEmail,
    required String role,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminDeactivateDialog(
        userName: userName,
        userEmail: userEmail,
        role: role,
      ),
    );
  }

  @override
  State<AdminDeactivateDialog> createState() => _AdminDeactivateDialogState();
}

class _AdminDeactivateDialogState extends State<AdminDeactivateDialog> {
  final _confirmInputController = TextEditingController();
  final _customMotifController = TextEditingController();
  String _selectedMotif = '';

  List<String> get _defaultMotifs {
    if (widget.role == 'MANAGER') {
      return [
        "Fin de mission / Départ",
        "Suspension temporaire",
        "Accès non autorisé",
        "Autre motif",
      ];
    }
    return [
      "Suspicion d'abus / Fraude",
      "Demande du client",
      "Inactivité prolongée",
      "Autre motif",
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedMotif = _defaultMotifs.first;
    _confirmInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _confirmInputController.dispose();
    _customMotifController.dispose();
    super.dispose();
  }

  bool get _isKeywordMatched =>
      _confirmInputController.text.trim().toUpperCase() == 'DESACTIVER';

  String get _finalMotif {
    if (_selectedMotif == "Autre motif" &&
        _customMotifController.text.trim().isNotEmpty) {
      return _customMotifController.text.trim();
    }
    return _selectedMotif;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final errorColor = theme.colorScheme.error;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final isManager = widget.role == 'MANAGER';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: errorColor.withValues(alpha: isDark ? 0.25 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: errorColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isManager ? "Désactiver ce manager ?" : "Désactiver ce compte ?",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récapitulatif utilisateur
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: errorColor.withValues(alpha: 0.15),
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: errorColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName.isNotEmpty
                              ? widget.userName
                              : "Utilisateur sans nom",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.userEmail.isNotEmpty)
                          Text(
                            widget.userEmail,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Motif de désactivation
            Text(
              "MOTIF DU BLOCAGE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _defaultMotifs.map((motif) {
                final isSelected = _selectedMotif == motif;
                return ChoiceChip(
                  label: Text(
                    motif,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary
                      .withValues(alpha: isDark ? 0.25 : 0.12),
                  backgroundColor: isDark
                      ? theme.colorScheme.surface
                      : AppColors.surfaceVariant.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : dividerColor,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMotif = motif);
                    }
                  },
                );
              }).toList(),
            ),

            if (_selectedMotif == "Autre motif") ...[
              const SizedBox(height: 10),
              TextField(
                controller: _customMotifController,
                decoration: InputDecoration(
                  hintText: "Précisez la raison...",
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 14),

            // Saisie du mot-clé de sécurité
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: "Pour confirmer, veuillez saisir "),
                  TextSpan(
                    text: "DESACTIVER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const TextSpan(text: " ci-dessous :"),
                ],
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _confirmInputController,
              autofocus: false,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Tapez DESACTIVER",
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isKeywordMatched ? errorColor : theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: _isKeywordMatched
                    ? Icon(Icons.check_circle_rounded, color: errorColor, size: 20)
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isKeywordMatched ? errorColor : dividerColor,
            foregroundColor: _isKeywordMatched
                ? Colors.white
                : (isDark ? Colors.white38 : Colors.black26),
            elevation: _isKeywordMatched ? 1 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isKeywordMatched
              ? () => Navigator.of(context).pop(_finalMotif)
              : null,
          child: const Text(
            "Désactiver le compte",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
