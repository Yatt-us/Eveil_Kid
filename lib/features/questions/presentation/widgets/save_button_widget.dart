import 'package:flutter/material.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const SaveButtonWidget({
    super.key,
    required this.onPressed,
    this.label = 'Enregistrer la question',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_circle_outline_rounded, size: 19),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
        ),
      ),
    );
  }
}
