import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/provider/bottom_nav_bar_provider.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/core/services/parental_pin_service.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/kid_switch_transition.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/parental_pin_dialog.dart';

/// Helper facilitant la navigation sécurisée entre l'espace Parent et l'espace Enfant.
class ParentalPinHelper {
  ParentalPinHelper._();

  /// Bascule vers l'espace enfant :
  /// - Si le code PIN n'a jamais été défini : invite le parent à configurer son code PIN 4 chiffres.
  /// - Si le code PIN existe déjà : active le mode enfant persistant, lance la transition magique
  ///   et bascule directement vers l'espace enfant.
  static Future<bool> enterChildSpace({
    required BuildContext context,
    required WidgetRef ref,
    required String enfantId,
    EnfantModel? enfant,
    String? enfantNom,
  }) async {
    final pinService = ref.read(parentalPinServiceProvider);
    final hasPin = await pinService.hasPin();

    if (!hasPin) {
      if (!context.mounted) return false;

      final success = await ParentalPinDialog.show(
        context,
        mode: ParentalPinMode.setup,
        title: 'Sécurisation de l\'espace enfant',
        subtitle:
            'Définissez un code PIN à 4 chiffres pour empêcher l\'enfant de quitter son espace sans votre accord.',
      );

      if (success != true) {
        if (context.mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message:
                'Le code PIN est obligatoire pour activer l\'espace enfant.',
            isError: true,
          );
        }
        return false;
      }

      if (context.mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Code PIN parental configuré avec succès !',
        );
      }
    }

    if (!context.mounted) return false;

    // 1. Active le mode enfant de façon persistante dans Riverpod & SharedPreferences
    await ref.read(childModeProvider.notifier).enterChildMode(
          childId: enfantId,
          child: enfant,
        );

    // 2. Affiche l'animation magique de basculement immersif
    if (context.mounted) {
      await KidSwitchTransitionOverlay.show(
        context,
        enfant: enfant,
        enfantNom: enfantNom ?? enfant?.nom,
      );
    }

    if (!context.mounted) return false;

    // 3. Bascule vers l'espace de l'enfant
    context.go(AppRoutes.espaceEnfantFor(enfantId));
    return true;
  }

  /// Quitte l'espace enfant pour revenir vers l'espace parent :
  /// - Demande la saisie du code PIN parental à 4 chiffres.
  /// - Si le code est validé : désactive la persistance du mode enfant et redirige vers l'accueil parent.
  /// - Si annulé ou invalide : reste dans l'espace enfant.
  static Future<bool> exitChildSpace({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final pinService = ref.read(parentalPinServiceProvider);
    final hasPin = await pinService.hasPin();

    if (hasPin) {
      if (!context.mounted) return false;

      final verified = await ParentalPinDialog.show(
        context,
        mode: ParentalPinMode.verify,
        title: 'Espace Réservé aux Parents',
        subtitle:
            'Entrez votre code PIN à 4 chiffres pour quitter le mode enfant.',
      );

      if (verified != true) return false;
    }

    if (!context.mounted) return false;

    // Désactive le mode enfant persistant
    await ref.read(childModeProvider.notifier).exitChildMode();

    if (!context.mounted) return false;

    // Réinitialise l'index de navigation et revient à l'accueil parent
    ref.read(bottomIndexProvider.notifier).setIndex(0);
    context.go(AppRoutes.home);
    return true;
  }

  /// Ouvre la modification du code PIN parental depuis l'espace parent.
  static Future<bool> changePin({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final success = await ParentalPinDialog.show(
      context,
      mode: ParentalPinMode.change,
    );

    if (success == true && context.mounted) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Code PIN modifié avec succès.',
      );
      return true;
    }
    return false;
  }
}

