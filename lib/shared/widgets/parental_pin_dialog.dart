import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/core/services/parental_pin_service.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

enum ParentalPinMode {
  /// Création initiale d'un code PIN (saisie + confirmation).
  setup,

  /// Vérification du code PIN pour quitter l'espace enfant ou accéder à une section protégée.
  verify,

  /// Modification d'un code PIN existant (ancien + nouveau + confirmation).
  change,
}

class ParentalPinDialog extends ConsumerStatefulWidget {
  final ParentalPinMode mode;
  final String? title;
  final String? subtitle;

  const ParentalPinDialog({
    super.key,
    required this.mode,
    this.title,
    this.subtitle,
  });

  /// Méthode statique utilitaire pour afficher le dialogue de code PIN.
  static Future<bool?> show(
    BuildContext context, {
    required ParentalPinMode mode,
    String? title,
    String? subtitle,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParentalPinDialog(
        mode: mode,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  ConsumerState<ParentalPinDialog> createState() => _ParentalPinDialogState();
}

class _ParentalPinDialogState extends ConsumerState<ParentalPinDialog>
    with SingleTickerProviderStateMixin {
  String _currentInput = '';
  String _firstPinEntry = '';
  int _step = 0; // Pour setup (0=saisie, 1=confirmation), pour change (0=ancien, 1=nouveau, 2=confirmation)
  String? _errorMessage;
  bool _isLoading = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerError(String message) {
    setState(() {
      _errorMessage = message;
      _currentInput = '';
    });
    _shakeController.forward(from: 0.0);
  }

  void _onDigitPressed(String digit) {
    if (_isLoading || _currentInput.length >= 4) return;

    setState(() {
      _errorMessage = null;
      _currentInput += digit;
    });

    if (_currentInput.length == 4) {
      _processCompletePin(_currentInput);
    }
  }

  void _onBackspacePressed() {
    if (_isLoading || _currentInput.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _onClearPressed() {
    if (_isLoading) return;
    setState(() {
      _errorMessage = null;
      _currentInput = '';
    });
  }

  Future<void> _processCompletePin(String pin) async {
    final pinService = ref.read(parentalPinServiceProvider);

    switch (widget.mode) {
      case ParentalPinMode.setup:
        if (_step == 0) {
          setState(() {
            _firstPinEntry = pin;
            _currentInput = '';
            _step = 1;
          });
        } else {
          if (pin == _firstPinEntry) {
            setState(() => _isLoading = true);
            await pinService.setPin(pin);
            if (mounted) Navigator.of(context).pop(true);
          } else {
            _triggerError('Les codes PIN ne correspondent pas. Recommencez.');
            setState(() {
              _firstPinEntry = '';
              _step = 0;
            });
          }
        }
        break;

      case ParentalPinMode.verify:
        setState(() => _isLoading = true);
        final isValid = await pinService.verifyPin(pin);
        setState(() => _isLoading = false);
        if (isValid) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          _triggerError('Code PIN incorrect. Veuillez réessayer.');
        }
        break;

      case ParentalPinMode.change:
        if (_step == 0) {
          setState(() => _isLoading = true);
          final isValid = await pinService.verifyPin(pin);
          setState(() => _isLoading = false);
          if (isValid) {
            setState(() {
              _currentInput = '';
              _step = 1;
            });
          } else {
            _triggerError('Code PIN actuel incorrect.');
          }
        } else if (_step == 1) {
          setState(() {
            _firstPinEntry = pin;
            _currentInput = '';
            _step = 2;
          });
        } else {
          if (pin == _firstPinEntry) {
            setState(() => _isLoading = true);
            await pinService.setPin(pin);
            if (mounted) Navigator.of(context).pop(true);
          } else {
            _triggerError('Les nouveaux codes ne correspondent pas.');
            setState(() {
              _firstPinEntry = '';
              _step = 1;
            });
          }
        }
        break;
    }
  }

  Future<void> _handleForgotPin() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Code PIN oublié ?',
      message:
          'Pour des raisons de sécurité, si vous avez oublié votre code parental, vous serez déconnecté de votre compte et le code PIN sera réinitialisé.\n\nVoulez-vous continuer ?',
      confirmText: 'Me déconnecter & Réinitialiser',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final pinService = ref.read(parentalPinServiceProvider);
      await pinService.clearPin();
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pop(false);
        context.go(AppRoutes.home);
        AppDialogs.showSnackBar(
          context: context,
          message:
              'Vous avez été déconnecté et votre code PIN a été réinitialisé.',
        );
      }
    }
  }

  String _getTitle() {
    if (widget.title != null) return widget.title!;
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return _step == 0
            ? 'Créer le code parental'
            : 'Confirmer le code parental';
      case ParentalPinMode.verify:
        return 'Contrôle Parental';
      case ParentalPinMode.change:
        if (_step == 0) return 'Code PIN actuel';
        if (_step == 1) return 'Nouveau code PIN';
        return 'Confirmer le nouveau code';
    }
  }

  String _getSubtitle() {
    if (widget.subtitle != null && _step == 0) return widget.subtitle!;
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return _step == 0
            ? 'Choisissez un code à 4 chiffres pour sécuriser l\'espace enfant.'
            : 'Saisissez à nouveau le code à 4 chiffres pour confirmer.';
      case ParentalPinMode.verify:
        return 'Entrez votre code à 4 chiffres pour quitter l\'espace enfant.';
      case ParentalPinMode.change:
        if (_step == 0) return 'Entrez votre code PIN à 4 chiffres actuel.';
        if (_step == 1) return 'Entrez un nouveau code PIN à 4 chiffres.';
        return 'Confirmez votre nouveau code PIN.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? const Color(0xFF1E2433) : theme.colorScheme.surface,
        elevation: isDark ? 16 : 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.7 : 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF475569).withValues(alpha: 0.8)
                : theme.dividerColor.withValues(alpha: 0.25),
            width: isDark ? 1.6 : 1.2,
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: min(MediaQuery.of(context).size.width, 360),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône d'en-tête
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.mode == ParentalPinMode.verify
                      ? Icons.lock_outline_rounded
                      : Icons.shield_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // Titre
              Text(
                _getTitle(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ) ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Sous-titre
              Text(
                _getSubtitle(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ) ??
                TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Indicateurs des 4 chiffres avec animation de secousse
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _currentInput.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.2),
                        border: Border.all(
                          color: isFilled
                              ? theme.colorScheme.primary
                              : theme.dividerColor.withValues(alpha: isDark ? 0.5 : 0.35),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Message d'erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else
                const SizedBox(height: 14),

              // Pavé numérique tactile
              _buildKeypad(theme, isDark),
              const SizedBox(height: 8),

              // Lien Code PIN oublié (en mode vérification)
              if (widget.mode == ParentalPinMode.verify) ...[
                TextButton(
                  onPressed: _isLoading ? null : _handleForgotPin,
                  child: Text(
                    'Code PIN oublié ?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              // Bouton Annuler
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1', theme, isDark),
            _buildKeypadButton('2', theme, isDark),
            _buildKeypadButton('3', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4', theme, isDark),
            _buildKeypadButton('5', theme, isDark),
            _buildKeypadButton('6', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7', theme, isDark),
            _buildKeypadButton('8', theme, isDark),
            _buildKeypadButton('9', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionKeypadButton(
              icon: Icons.clear_rounded,
              onPressed: _onClearPressed,
              theme: theme,
              isDark: isDark,
              tooltip: 'Effacer tout',
            ),
            _buildKeypadButton('0', theme, isDark),
            _buildActionKeypadButton(
              icon: Icons.backspace_outlined,
              onPressed: _onBackspacePressed,
              theme: theme,
              isDark: isDark,
              tooltip: 'Effacer un chiffre',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit, ThemeData theme, bool isDark) {
    return Material(
      color: isDark
          ? const Color(0xFF2D3748)
          : theme.colorScheme.surfaceContainerLow,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _onDigitPressed(digit),
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF4A5568)
                  : theme.dividerColor.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKeypadButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    required bool isDark,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
