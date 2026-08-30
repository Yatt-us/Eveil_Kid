import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour accéder au service de gestion du code PIN parental.
final parentalPinServiceProvider = Provider<ParentalPinService>((ref) {
  return ParentalPinService();
});

/// Service gérant la persistance et la vérification du code PIN parental (4 chiffres)
/// stocké de façon sécurisée et locale dans les [SharedPreferences].
class ParentalPinService {
  static const String _pinKey = 'parental_pin_code';

  /// Vérifie si un code PIN parental à 4 chiffres a déjà été configuré.
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    return pin != null && pin.trim().length == 4;
  }

  /// Récupère le code PIN stocké (ou null si aucun).
  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  /// Définit ou met à jour le code PIN parental (doit faire exactement 4 caractères).
  Future<bool> setPin(String pin) async {
    final cleanPin = pin.trim();
    if (cleanPin.length != 4) {
      throw ArgumentError('Le code PIN doit comporter exactement 4 chiffres.');
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_pinKey, cleanPin);
  }

  /// Vérifie si le code PIN saisi correspond à celui enregistré.
  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await getPin();
    if (storedPin == null) return false;
    return storedPin == enteredPin.trim();
  }

  /// Modifie le code PIN après vérification de l'ancien.
  Future<bool> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    return setPin(newPin);
  }

  /// Supprime le code PIN parental enregistré.
  Future<bool> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_pinKey);
  }
}
