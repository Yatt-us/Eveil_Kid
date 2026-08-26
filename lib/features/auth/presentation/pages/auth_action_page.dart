import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class AuthActionPage extends ConsumerStatefulWidget {
  final String? mode;
  final String? oobCode;
  final String? apiKey;
  final String? continueUrl;

  const AuthActionPage({
    super.key,
    this.mode,
    this.oobCode,
    this.apiKey,
    this.continueUrl,
  });

  @override
  ConsumerState<AuthActionPage> createState() => _AuthActionPageState();
}

enum _ActionStatus { loading, success, error, form }

class _AuthActionPageState extends ConsumerState<AuthActionPage> {
  _ActionStatus _status = _ActionStatus.loading;
  String _statusMessage = '';
  String? _userEmail;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _processAction();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _processAction() async {
    final mode = widget.mode;
    final oobCode = widget.oobCode;

    if (oobCode == null || oobCode.isEmpty) {
      setState(() {
        _status = _ActionStatus.error;
        _statusMessage = 'Lien de confirmation invalide ou manquant.';
      });
      return;
    }

    try {
      if (mode == 'verifyEmail') {
        // Confirmation d'adresse email
        await FirebaseAuth.instance.applyActionCode(oobCode);

        // Rafraîchir l'état d'authentification Riverpod
        await ref.read(authProvider.notifier).reloadAndCheckEmailVerified();

        if (!mounted) return;
        setState(() {
          _status = _ActionStatus.success;
          _statusMessage = 'Votre adresse email a été confirmée avec succès !';
        });
      } else if (mode == 'resetPassword') {
        // Réinitialisation de mot de passe : vérifier le code et afficher le formulaire
        final email =
            await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
        if (!mounted) return;
        setState(() {
          _userEmail = email;
          _status = _ActionStatus.form;
        });
      } else if (mode == 'recoverEmail') {
        await FirebaseAuth.instance.checkActionCode(oobCode);
        await FirebaseAuth.instance.applyActionCode(oobCode);
        if (!mounted) return;
        setState(() {
          _status = _ActionStatus.success;
          _statusMessage = 'Votre email a été restauré avec succès.';
        });
      } else {
        setState(() {
          _status = _ActionStatus.error;
          _statusMessage = 'Type d\'action inconnu : $mode';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _ActionStatus.error;
        _statusMessage =
            'Le lien est invalide ou a expiré. Veuillez refaire une demande.';
      });
    }
  }

  Future<void> _confirmPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final oobCode = widget.oobCode;
    if (oobCode == null) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: oobCode,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;
      setState(() {
        _status = _ActionStatus.success;
        _statusMessage = 'Votre mot de passe a été réinitialisé avec succès !';
      });
    } catch (e) {
      if (!mounted) return;
      AppDialogs.showSnackBar(
        context: context,
        message: 'Échec de la réinitialisation du mot de passe.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPadding.screenLarge,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AppCard(
                padding: const EdgeInsets.all(28),
                borderRadius: AppRadius.dialog,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO BRANDING
                    const Center(child: AppLogo(size: 80)),
                    AppSpacing.verticalLg,

                    // CONTENU DYNAMIQUE SELON LE STATUT
                    if (_status == _ActionStatus.loading) ...[
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      AppSpacing.verticalMd,
                      Text(
                        'Traitement en cours...',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (_status == _ActionStatus.success) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.teal,
                          size: 56,
                        ),
                      ),
                      AppSpacing.verticalMd,
                      Text(
                        'Succès ! 🎉',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        _statusMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalLg,
                      AppButton(
                        text: 'Accéder à l\'application',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ] else if (_status == _ActionStatus.error) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 56,
                        ),
                      ),
                      AppSpacing.verticalMd,
                      Text(
                        'Lien invalide ou expiré',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        _statusMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalLg,
                      AppButton(
                        text: 'Retourner à l\'accueil',
                        icon: Icons.home_rounded,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ] else if (_status == _ActionStatus.form) ...[
                      Text(
                        'Nouveau mot de passe 🔒',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalSm,
                      if (_userEmail != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _userEmail!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      AppSpacing.verticalMd,
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _passwordController,
                              label: 'Nouveau mot de passe',
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères.';
                                }
                                return null;
                              },
                            ),
                            AppSpacing.verticalMd,
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmer le mot de passe',
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_rounded,
                              isPassword: true,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas.';
                                }
                                return null;
                              },
                            ),
                            AppSpacing.verticalLg,
                            AppButton(
                              text: 'Enregistrer le mot de passe',
                              isLoading: _isSubmitting,
                              onPressed: _confirmPasswordReset,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
