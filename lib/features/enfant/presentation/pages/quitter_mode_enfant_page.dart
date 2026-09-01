import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';

/// Page de sortie du mode enfant vers l'espace parent avec vérification du code PIN.
class QuitterModeEnfantPage extends ConsumerWidget {
  const QuitterModeEnfantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrôle Parental'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => ParentalPinHelper.exitChildSpace(
            context: context,
            ref: ref,
          ),
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Quitter l\'espace enfant'),
        ),
      ),
    );
  }
}
