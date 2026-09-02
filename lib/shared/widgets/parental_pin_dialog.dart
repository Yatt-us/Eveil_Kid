import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
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
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ParentalPinDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return ParentalPinDialog(
          mode: mode,
          title: title,
          subtitle: subtitle,
        );
      },
    );
  }

  @override
  ConsumerState<ParentalPinDialog> createState() => _ParentalPinDialogState();
}

class _ParentalPinDialogState extends ConsumerState<ParentalPinDialog>
    with TickerProviderStateMixin {
  static const int _pinLength = 4;
  static const int _maxFailedAttemptsBeforeCooldown = 3;
  static const int _cooldownDurationSeconds = 5;

  String _currentInput = '';
  String _firstPinEntry = '';
  int _step = 0; // Setup: 0=saisie, 1=confirmation. Change: 0=ancien, 1=nouveau, 2=confirmation.
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSuccess = false;

  int _failedAttempts = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _successController;
  late final Animation<double> _successScaleAnimation;

  final FocusNode _focusNode = FocusNode();

  // Mapping des sous-titres alphabétiques (style dialer téléphonique)
  static const Map<String, String> _digitLetters = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '0': '+',
  };

  @override
  void initState() {
    super.initState();

    // Animation de secousse en cas d'erreur
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -4.0), weight: 1.5),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1.5),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    // Animation d'apparition du checkmark de succès
    _successController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _successScaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );

    // Demande de focus pour supporter le clavier physique
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    _successController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isLockedOut => _lockoutSeconds > 0;

  void _startLockoutTimer() {
    setState(() {
      _lockoutSeconds = _cooldownDurationSeconds;
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockoutSeconds = 0;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _lockoutSeconds--;
        });
      }
    });
  }

  void _triggerError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
      _currentInput = '';
    });
    _shakeController.forward(from: 0.0);
  }

  void _onDigitPressed(String digit) {
    if (_isLoading || _isSuccess || _isLockedOut || _currentInput.length >= _pinLength) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;
      _currentInput += digit;
    });

    if (_currentInput.length == _pinLength) {
      _processCompletePin(_currentInput);
    }
  }

  void _onBackspacePressed() {
    if (_isLoading || _isSuccess || _isLockedOut || _currentInput.isEmpty) return;

    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _onClearAllPressed() {
    if (_isLoading || _isSuccess || _isLockedOut || _currentInput.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _errorMessage = null;
      _currentInput = '';
    });
  }

  void _onPreviousStep() {
    if (_isLoading || _isSuccess || _step == 0) return;

    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      _currentInput = '';
      if (widget.mode == ParentalPinMode.setup) {
        _step = 0;
        _firstPinEntry = '';
      } else if (widget.mode == ParentalPinMode.change) {
        _step--;
        if (_step == 1) {
          _firstPinEntry = '';
        }
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (!_isLoading && !_isSuccess) {
        Navigator.of(context).pop(false);
      }
      return;
    }

    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      _onBackspacePressed();
      return;
    }

    // Chiffres 0 à 9
    final digitMap = {
      LogicalKeyboardKey.digit0: '0',
      LogicalKeyboardKey.numpad0: '0',
      LogicalKeyboardKey.digit1: '1',
      LogicalKeyboardKey.numpad1: '1',
      LogicalKeyboardKey.digit2: '2',
      LogicalKeyboardKey.numpad2: '2',
      LogicalKeyboardKey.digit3: '3',
      LogicalKeyboardKey.numpad3: '3',
      LogicalKeyboardKey.digit4: '4',
      LogicalKeyboardKey.numpad4: '4',
      LogicalKeyboardKey.digit5: '5',
      LogicalKeyboardKey.numpad5: '5',
      LogicalKeyboardKey.digit6: '6',
      LogicalKeyboardKey.numpad6: '6',
      LogicalKeyboardKey.digit7: '7',
      LogicalKeyboardKey.numpad7: '7',
      LogicalKeyboardKey.digit8: '8',
      LogicalKeyboardKey.numpad8: '8',
      LogicalKeyboardKey.digit9: '9',
      LogicalKeyboardKey.numpad9: '9',
    };

    if (digitMap.containsKey(key)) {
      _onDigitPressed(digitMap[key]!);
    }
  }

  Future<void> _completeWithSuccess() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSuccess = true;
      _errorMessage = null;
    });
    _successController.forward(from: 0.0);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _processCompletePin(String pin) async {
    final pinService = ref.read(parentalPinServiceProvider);

    switch (widget.mode) {
      case ParentalPinMode.setup:
        if (_step == 0) {
          // Étape 1 terminée : passer à la confirmation
          HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 150));
          if (!mounted) return;
          setState(() {
            _firstPinEntry = pin;
            _currentInput = '';
            _step = 1;
          });
        } else {
          // Étape 2 : vérification de la correspondance
          if (pin == _firstPinEntry) {
            setState(() => _isLoading = true);
            await pinService.setPin(pin);
            await _completeWithSuccess();
          } else {
            _triggerError('Les codes ne correspondent pas. Recommencez.');
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
          _failedAttempts = 0;
          await _completeWithSuccess();
        } else {
          _failedAttempts++;
          if (_failedAttempts >= _maxFailedAttemptsBeforeCooldown) {
            _triggerError(
              'Code PIN incorrect. Trop de tentatives.',
            );
            _startLockoutTimer();
          } else {
            final remaining = _maxFailedAttemptsBeforeCooldown - _failedAttempts;
            _triggerError(
              'Code PIN incorrect ($remaining tentative${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}).',
            );
          }
        }
        break;

      case ParentalPinMode.change:
        if (_step == 0) {
          setState(() => _isLoading = true);
          final isValid = await pinService.verifyPin(pin);
          setState(() => _isLoading = false);

          if (isValid) {
            HapticFeedback.mediumImpact();
            setState(() {
              _currentInput = '';
              _step = 1;
            });
          } else {
            _triggerError('Code PIN actuel incorrect.');
          }
        } else if (_step == 1) {
          HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 150));
          if (!mounted) return;
          setState(() {
            _firstPinEntry = pin;
            _currentInput = '';
            _step = 2;
          });
        } else {
          if (pin == _firstPinEntry) {
            setState(() => _isLoading = true);
            await pinService.setPin(pin);
            await _completeWithSuccess();
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
          'Pour protéger l\'accès à l\'application, la réinitialisation du code PIN nécessite de vous déconnecter de votre compte.\n\nVoulez-vous réinitialiser le code et vous déconnecter ?',
      confirmText: 'Réinitialiser & Déconnecter',
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

  int get _totalSteps {
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return 2;
      case ParentalPinMode.verify:
        return 1;
      case ParentalPinMode.change:
        return 3;
    }
  }

  String _getTitle() {
    if (widget.title != null && _step == 0) return widget.title!;
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return _step == 0
            ? 'Créer le code parental'
            : 'Confirmer le code';
      case ParentalPinMode.verify:
        return 'Contrôle Parental';
      case ParentalPinMode.change:
        if (_step == 0) return 'Code PIN actuel';
        if (_step == 1) return 'Nouveau code PIN';
        return 'Confirmer le nouveau code';
    }
  }

  String _getSubtitle() {
    if (_isLockedOut) {
      return 'Veuillez patienter $_lockoutSeconds seconde${_lockoutSeconds > 1 ? 's' : ''} avant de réessayer.';
    }
    if (widget.subtitle != null && _step == 0) return widget.subtitle!;
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return _step == 0
            ? 'Définissez 4 chiffres pour sécuriser l\'accès parent.'
            : 'Saisissez à nouveau le code pour confirmer.';
      case ParentalPinMode.verify:
        return 'Entrez votre code à 4 chiffres pour continuer.';
      case ParentalPinMode.change:
        if (_step == 0) return 'Entrez votre code PIN actuel.';
        if (_step == 1) return 'Choisissez un nouveau code à 4 chiffres.';
        return 'Confirmez le nouveau code PIN.';
    }
  }

  IconData _getHeaderIcon() {
    if (_isSuccess) return Icons.check_circle_rounded;
    switch (widget.mode) {
      case ParentalPinMode.setup:
        return _step == 0 ? Icons.shield_outlined : Icons.lock_clock_outlined;
      case ParentalPinMode.verify:
        return Icons.lock_outline_rounded;
      case ParentalPinMode.change:
        return Icons.vpn_key_outlined;
    }
  }

  Color _getAccentColor(ThemeData theme) {
    if (_isSuccess) return AppColors.success;
    if (_errorMessage != null) return theme.colorScheme.error;
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final accentColor = _getAccentColor(theme);
    final surfaceBg = isDark ? const Color(0xFF1E212D) : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = min(screenWidth - 32, 360.0);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: PopScope(
        canPop: !_isLoading && !_isSuccess,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.18),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                  if (_isSuccess)
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Décoration subtile en arrière-plan
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barre supérieure : Bouton retour d'étape & Bouton Fermer
                          _buildTopBar(theme, isDark),
                          const SizedBox(height: 8),

                          // Icône d'en-tête animée avec halo
                          _buildHeaderBadge(accentColor, isDark),
                          const SizedBox(height: 14),

                          // Indicateur d'étapes (Setup & Change)
                          if (_totalSteps > 1) ...[
                            _buildStepIndicator(theme, isDark),
                            const SizedBox(height: 10),
                          ],

                          // Titre
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _getTitle(),
                              key: ValueKey('${widget.mode}_${_step}_title'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18.5,
                                    letterSpacing: -0.2,
                                    color: theme.colorScheme.onSurface,
                                  ) ??
                                  TextStyle(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Sous-titre informatif
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _getSubtitle(),
                              key: ValueKey('${widget.mode}_${_step}_${_isLockedOut}_subtitle'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: _isLockedOut
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                  ) ??
                                  TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: _isLockedOut
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Indicateurs des 4 chiffres PIN
                          _buildPinIndicators(theme, isDark, accentColor),
                          const SizedBox(height: 12),

                          // Message d'erreur
                          _buildErrorBanner(theme),
                          const SizedBox(height: 12),

                          // Pavé numérique tactile interactif
                          _buildKeypad(theme, isDark, primaryColor),
                          const SizedBox(height: 10),

                          // Action "Code PIN oublié" en mode vérification
                          if (widget.mode == ParentalPinMode.verify) ...[
                            TextButton.icon(
                              onPressed: (_isLoading || _isSuccess) ? null : _handleForgotPin,
                              icon: Icon(
                                Icons.help_outline_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              label: Text(
                                'Code PIN oublié ?',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Overlay de chargement
                    if (_isLoading && !_isSuccess)
                      Positioned.fill(
                        child: Container(
                          color: surfaceBg.withValues(alpha: 0.65),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    final canGoBack = _step > 0 && !_isLoading && !_isSuccess;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canGoBack)
          IconButton(
            onPressed: _onPreviousStep,
            icon: const Icon(Icons.arrow_back_rounded),
            iconSize: 20,
            tooltip: 'Étape précédente',
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          )
        else
          const SizedBox(width: 36, height: 36),

        // Bouton de fermeture / annulation
        IconButton(
          onPressed: (_isLoading || _isSuccess) ? null : () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
          iconSize: 20,
          tooltip: 'Annuler',
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge(Color accentColor, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: isDark ? 0.25 : 0.14),
            accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.5,
        ),
      ),
      child: Center(
        child: _isSuccess
            ? ScaleTransition(
                scale: _successScaleAnimation,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 32,
                ),
              )
            : Icon(
                _getHeaderIcon(),
                color: accentColor,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (index) {
        final isCompleted = index < _step;
        final isCurrent = index == _step;
        final stepColor = isCompleted
            ? AppColors.success
            : (isCurrent
                ? theme.colorScheme.primary
                : (isDark ? const Color(0xFF4A5568) : theme.dividerColor.withValues(alpha: 0.4)));

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: stepColor,
          ),
        );
      }),
    );
  }

  Widget _buildPinIndicators(ThemeData theme, bool isDark, Color accentColor) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pinLength, (index) {
          final isFilled = index < _currentInput.length;
          final isCurrent = index == _currentInput.length && !_isLockedOut;
          final isError = _errorMessage != null;

          Color dotColor;
          Color borderColor;

          if (_isSuccess) {
            dotColor = AppColors.success;
            borderColor = AppColors.success;
          } else if (isError) {
            dotColor = theme.colorScheme.error.withValues(alpha: 0.15);
            borderColor = theme.colorScheme.error;
          } else if (isFilled) {
            dotColor = theme.colorScheme.primary;
            borderColor = theme.colorScheme.primary;
          } else if (isCurrent) {
            dotColor = Colors.transparent;
            borderColor = theme.colorScheme.primary.withValues(alpha: 0.7);
          } else {
            dotColor = isDark
                ? const Color(0xFF2A3142)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
            borderColor = isDark
                ? const Color(0xFF3F4B66)
                : theme.dividerColor.withValues(alpha: 0.4);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 9),
            width: isFilled ? 20 : 18,
            height: isFilled ? 20 : 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? dotColor : dotColor,
              border: Border.all(
                color: borderColor,
                width: isCurrent ? 2.5 : 2,
              ),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: _isSuccess
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    if (_errorMessage == null && !_isLockedOut) {
      return const SizedBox(height: 18);
    }

    final message = _isLockedOut
        ? 'Délai de sécurité actif ($_lockoutSeconds s)'
        : _errorMessage!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLockedOut ? Icons.timer_outlined : Icons.error_outline_rounded,
              size: 14,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme, bool isDark, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('1', theme, isDark),
            _buildDigitButton('2', theme, isDark),
            _buildDigitButton('3', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('4', theme, isDark),
            _buildDigitButton('5', theme, isDark),
            _buildDigitButton('6', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('7', theme, isDark),
            _buildDigitButton('8', theme, isDark),
            _buildDigitButton('9', theme, isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Bouton gauche contextuel : Vider la saisie ou Retour
            _buildActionKeypadButton(
              icon: Icons.refresh_rounded,
              onPressed: _currentInput.isNotEmpty ? _onClearAllPressed : null,
              theme: theme,
              isDark: isDark,
              tooltip: 'Effacer tout',
            ),
            _buildDigitButton('0', theme, isDark),
            // Bouton droit : Effacer (appui simple = 1 chiffre, appui long = tout effacer)
            _buildActionKeypadButton(
              icon: Icons.backspace_outlined,
              onPressed: _currentInput.isNotEmpty ? _onBackspacePressed : null,
              onLongPress: _currentInput.isNotEmpty ? _onClearAllPressed : null,
              theme: theme,
              isDark: isDark,
              tooltip: 'Effacer (maintenir pour tout effacer)',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitButton(String digit, ThemeData theme, bool isDark) {
    final letters = _digitLetters[digit] ?? '';
    final isEnabled = !_isLoading && !_isSuccess && !_isLockedOut;

    final bgColor = isDark
        ? const Color(0xFF2B3347)
        : const Color(0xFFF3F2F8);
    final borderColor = isDark
        ? const Color(0xFF3F4B66).withValues(alpha: 0.6)
        : const Color(0xFFE2E0EC);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isEnabled ? () => _onDigitPressed(digit) : null,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.18),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled ? bgColor : bgColor.withValues(alpha: 0.5),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: isEnabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.1,
                    color: isEnabled
                        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75)
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionKeypadButton({
    required IconData icon,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    required ThemeData theme,
    required bool isDark,
    required String tooltip,
  }) {
    final isEnabled = onPressed != null && !_isLoading && !_isSuccess && !_isLockedOut;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onPressed : null,
          onLongPress: isEnabled ? onLongPress : null,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          child: Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isEnabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
    );
  }
}
