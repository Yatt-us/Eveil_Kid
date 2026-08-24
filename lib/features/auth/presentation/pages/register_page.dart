import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_google_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nom: _nomController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      AppDialogs.showSnackBar(
        context: context,
        message:
            'Compte créé avec succès ! Un email de confirmation vous a été envoyé.',
      );
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: error ?? 'Une erreur est survenue lors de l’inscription.',
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
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: error ?? 'Échec de la connexion avec Google.',
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
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO OFFICIEL
                    const Center(child: AppLogo(size: 76)),

                    const SizedBox(height: 16),

                    // EN-TÊTE CENTRÉ & ÉPURÉ
                    const Text(
                      'Créer un compte',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingLarge,
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Remplissez les informations ci-dessous pour créer votre compte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // NOM COMPLET
                    AppTextField(
                      controller: _nomController,
                      labelText: 'Nom complet',
                      hintText: 'Marie Dupont',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    AppTextField(
                      controller: _emailController,
                      labelText: 'Adresse email',
                      hintText: 'marie.dupont@email.com',
                      prefixIcon: Icons.mail_outline_rounded,
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

                    const SizedBox(height: 16),

                    // MOT DE PASSE
                    AppTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      hintText: '6 caractères minimum',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est obligatoire';
                        }
                        if (value.length < 6) {
                          return 'Au moins 6 caractères requis';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // CONFIRMATION DU MOT DE PASSE
                    AppTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmer le mot de passe',
                      hintText: 'Répétez votre mot de passe',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!authState.isLoading) {
                          _register();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmation requise';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // BOUTON PRINCIPAL D'ACTION
                    AppButton(
                      text: 'Créer mon compte',
                      size: AppButtonSize.medium,
                      isLoading: authState.isLoading,
                      onPressed: _register,
                    ),

                    const SizedBox(height: 18),

                    // SÉPARATEUR
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.border, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
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

                    const SizedBox(height: 18),

                    // BOUTON GOOGLE SIGN-IN
                    AppGoogleButton(
                      text: "S'inscrire avec Google",
                      isLoading: authState.isLoading,
                      onPressed: _signInWithGoogle,
                    ),

                    const SizedBox(height: 20),

                    // LIEN RETOUR CONNEXION SOBRE & ÉLÉGANT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // LIEN RETOUR ACCUEIL
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('Continuer sans se connecter'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
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
