import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_google_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Vérification du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Appel du Provider
    final success = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Connexion réussie !',
      );
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: errorMessage ?? 'Échec de la connexion. Veuillez réessayer.',
        isError: true,
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Veuillez saisir votre adresse email pour réinitialiser le mot de passe.',
        isError: true,
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(email: email);

    if (!mounted) return;

    if (success) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Email de réinitialisation envoyé avec succès.',
      );
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: errorMessage ?? 'Impossible d’envoyer l’email de réinitialisation.',
        isError: true,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;

    if (success) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Connexion Google réussie !',
      );
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: errorMessage ?? 'Échec de la connexion avec Google.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPadding.screenLarge,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.verticalLg,

                    // LOGO BRANDING
                    const Center(
                      child: AppLogo(size: 90),
                    ),

                    AppSpacing.verticalLg,

                    // TITRE & SOUS-TITRE
                    const Text(
                      'Bienvenue !',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingLarge,
                    ),

                    AppSpacing.verticalXs,

                    const Text(
                      'Connectez-vous pour accéder à votre espace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.verticalXxxl,

                    // CHAMP EMAIL
                    AppTextField(
                      controller: _emailController,
                      labelText: 'Adresse email',
                      hintText: 'exemple@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L’adresse email est obligatoire';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Adresse email invalide';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.verticalLg,

                    // CHAMP MOT DE PASSE
                    AppTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!authState.isLoading) {
                          _login();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est obligatoire';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.verticalXs,

                    // MOT DE PASSE OUBLIÉ
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading ? null : _forgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),

                    AppSpacing.verticalXl,

                    // BOUTON DE CONNEXION
                    AppButton(
                      text: 'Se connecter',
                     // icon: Icons.login_rounded,
                      size: AppButtonSize.large,
                      isLoading: authState.isLoading,
                      onPressed: _login,
                    ),

                    AppSpacing.verticalXxxl,

                    // SÉPARATEUR
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.border, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.border, thickness: 1),
                        ),
                      ],
                    ),

                    AppSpacing.verticalXl,

                    // BOUTON GOOGLE
                    AppGoogleButton(
                      text: 'Continuer avec Google',
                      isLoading: authState.isLoading,
                      onPressed: _signInWithGoogle,
                    ),

                    AppSpacing.verticalXxl,

                    // LIEN VERS INSCRIPTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas encore de compte ?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('S’inscrire'),
                        ),
                      ],
                    ),

                    AppSpacing.verticalLg,
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
