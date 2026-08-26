import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_google_button.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/utilisateur.dart';
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
      AppDialogs.showSnackBar(context: context, message: 'Connexion réussie !');
      final userRole = ref.read(authProvider).utilisateur?.role;
      if (userRole == UserRole.admin || userRole == UserRole.manager) {
        context.go(AppRoutes.admin);
      } else {
        context.go(AppRoutes.home);
      }
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
        message:
            'Veuillez saisir votre adresse email pour réinitialiser le mot de passe.',
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
        message:
            errorMessage ?? 'Impossible d’envoyer l’email de réinitialisation.',
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
      final userRole = ref.read(authProvider).utilisateur?.role;
      if (userRole == UserRole.admin || userRole == UserRole.manager) {
        context.go(AppRoutes.admin);
      } else {
        context.go(AppRoutes.home);
      }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    // BOUTON RETOUR VERS ACCUEIL
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        size: 36,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ),
                    AppSpacing.verticalSm,

                    // LOGO BRANDING
                    const Center(child: AppLogo(size: 90)),

                    AppSpacing.verticalLg,

                    // TITRE & SOUS-TITRE
                    Text(
                      'Bienvenue !',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: titleColor,
                      ),
                    ),

                    AppSpacing.verticalXs,

                    Text(
                      'Connectez-vous pour accéder à votre espace',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                            color: subtitleColor,
                          ) ??
                          TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
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
                          foregroundColor: primaryColor,
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
                      size: AppButtonSize.large,
                      isLoading: authState.isLoading,
                      onPressed: _login,
                    ),

                    AppSpacing.verticalXxxl,

                    // SÉPARATEUR
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor,
                            thickness: 1,
                          ),
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
                        Text(
                          'Pas encore de compte ?',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.go(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
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

                    AppSpacing.verticalSm,

                    // LIEN RETOUR ACCUEIL
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('Continuer sans se connecter'),
                        style: TextButton.styleFrom(
                          foregroundColor: subtitleColor,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
