// lib/features/parents/presentation/pages/securite_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/provider/bottom_nav_bar_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../enfant/providers/enfant_providers.dart';
import '../../providers/parent_provider.dart';

import '../../../../core/constants/AppRadius.dart';

class SecuritePage extends ConsumerWidget {
  const SecuritePage({super.key});

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final initialEmail = FirebaseAuth.instance.currentUser?.email ??
        authState.utilisateur?.email ??
        ref.read(parentNotifierProvider).value?.email ??
        '';

    final emailController = TextEditingController(text: initialEmail);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          backgroundColor: theme.colorScheme.surface,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_lock_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Text(
                  'Réinitialiser le mot de passe',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleMedium?.color ??
                        (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,
              Text(
                'Un lien de réinitialisation sécurisé sera envoyé à votre adresse email :',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ??
                      (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  height: 1.4,
                ),
              ),
              AppSpacing.verticalMd,
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color ??
                      (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
                decoration: InputDecoration(
                  labelText: 'Adresse Email',
                  hintText: 'exemple@domaine.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                foregroundColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  AppDialogs.showSnackBar(
                    context: context,
                    message: 'Veuillez saisir une adresse email valide.',
                    isError: true,
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final success = await ref
                    .read(authProvider.notifier)
                    .resetPassword(email: email);

                if (context.mounted) {
                  if (success) {
                    AppDialogs.showSnackBar(
                      context: context,
                      message:
                          'Lien envoyé à $email ! Vérifiez votre boîte de réception et vos spams.',
                    );
                  } else {
                    final err = ref.read(authProvider).errorMessage;
                    AppDialogs.showSnackBar(
                      context: context,
                      message: err ?? 'Erreur lors de l\'envoi de l\'email.',
                      isError: true,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                elevation: 0,
              ),
              child: const Text(
                'Envoyer le lien',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    AppDialogs.showConfirmDialog(
      context: context,
      title: 'Archiver et désactiver le compte ?',
      message:
          'Votre compte ainsi que toutes vos données (profils enfants, favoris, historique) seront archivés et désactivés en toute sécurité. Vous serez automatiquement déconnecté.',
      confirmText: 'Archiver mon compte',
      cancelText: 'Annuler',
      isDanger: true,
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        // Afficher indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

        final success = await ref.read(authProvider.notifier).archiverCompte();

        if (context.mounted) {
          Navigator.pop(context); // Fermer le loader

          if (success) {
            ref.invalidate(parentNotifierProvider);
            ref.invalidate(enfantNotifierProvider);
            ref.read(bottomIndexProvider.notifier).setIndex(0);
            context.go(AppRoutes.home);

            AppDialogs.showSnackBar(
              context: context,
              message: 'Votre compte a été archivé et désactivé avec succès.',
            );
          } else {
            final err = ref.read(authProvider).errorMessage;
            AppDialogs.showSnackBar(
              context: context,
              message: err ?? 'Erreur lors de l\'archivage du compte.',
              isError: true,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sécurité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenLarge,
        child: Column(
          children: [
            AppSpacing.verticalMd,

            // --- CARTE D'ACTIONS DE SÉCURITÉ ---
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.textPrimary)
                        .withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSecurityTile(
                    theme: theme,
                    icon: Icons.lock_outline_rounded,
                    title: 'Changer le mot de passe',
                    onTap: () => _showChangePasswordDialog(context, ref),
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildSecurityTile(
                    theme: theme,
                    icon: Icons.login_rounded,
                    title: 'Session actives',
                    onTap: () {
                      AppDialogs.showSnackBar(
                        context: context,
                        message: '1 session active sur cet appareil.',
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildSecurityTile(
                    theme: theme,
                    icon: Icons.stay_current_portrait_rounded,
                    title: 'Appareils connectés',
                    onTap: () {
                      AppDialogs.showSnackBar(
                        context: context,
                        message: 'Appareil actuel : Android / iOS',
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildSecurityTile(
                    theme: theme,
                    icon: Icons.delete_outline_rounded,
                    title: 'Supprimer le compte',
                    isDanger: true,
                    onTap: () => _showDeleteAccountDialog(context, ref),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXxxl,

            // --- CARTE STATUT DE SÉCURITÉ ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : const Color(0xFFF1F3F8),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.textPrimary)
                        .withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildShieldBadge(),
                  AppSpacing.horizontalLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre compte est sécurisé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        AppSpacing.verticalXs,
                        Text(
                          'Dernière activité\nAujourd\'hui à 08:45',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger
        ? theme.colorScheme.error
        : (theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldBadge() {
    return Container(
      width: 68,
      height: 76,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: CustomPaint(painter: _ShieldPainter()),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Forme du bouclier
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.95, h * 0.15);
    path.lineTo(w * 0.95, h * 0.55);
    path.quadraticBezierTo(w * 0.95, h * 0.85, w * 0.5, h);
    path.quadraticBezierTo(w * 0.05, h * 0.85, w * 0.05, h * 0.55);
    path.lineTo(w * 0.05, h * 0.15);
    path.close();

    // Bordure grise
    final borderPaint = Paint()
      ..color = const Color(0xFF6B7280)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Remplissage 4 quadrants
    canvas.save();
    canvas.clipPath(path);

    final pTopLeft = Paint()..color = const Color(0xFF6B7280);
    final pTopRight = Paint()..color = const Color(0xFFD97706);
    final pBottomLeft = Paint()..color = const Color(0xFFF59E0B);
    final pBottomRight = Paint()..color = const Color(0xFF4B5563);

    // 4 quadrants
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.5, h * 0.5), pTopLeft);
    canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.5), pTopRight);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.5, w * 0.5, h * 0.5), pBottomLeft);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.5, w * 0.5, h * 0.5),
      pBottomRight,
    );

    canvas.restore();
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
