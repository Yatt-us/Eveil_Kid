import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class EmailVerificationBanner extends ConsumerStatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  ConsumerState<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState
    extends ConsumerState<EmailVerificationBanner>
    with WidgetsBindingObserver {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authProvider.notifier).reloadAndCheckEmailVerified();
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authProvider.notifier).sendEmailVerification();
      if (!mounted) return;
      AppDialogs.showSnackBar(
        context: context,
        message: 'Un nouvel email de confirmation a été envoyé.',
      );
    } catch (e) {
      if (!mounted) return;
      AppDialogs.showSnackBar(
        context: context,
        message: 'Échec de l\'envoi de l\'email. Veuillez réessayer plus tard.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);
    try {
      final isVerified =
          await ref.read(authProvider.notifier).reloadAndCheckEmailVerified();
      if (!mounted) return;

      if (isVerified) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Votre adresse email a été vérifiée avec succès !',
        );
      } else {
        AppDialogs.showSnackBar(
          context: context,
          message:
              'Email non vérifié. Veuillez cliquer sur le lien reçu dans votre boîte de réception (vérifiez vos spams).',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userEmail = authState.utilisateur?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bannerBg = isDark ? const Color(0xFF332005) : const Color(0xFFFFFBEB);
    final bannerBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
    final iconBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
    final iconBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFCD34D);
    final iconColor = const Color(0xFFF59E0B);
    final titleColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
    final bodyColor = isDark ? const Color(0xFFFCD34D).withValues(alpha: 0.8) : const Color(0xFFB45309);
    final emailColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F);

    return Container(
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: bannerBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBorder),
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmez votre adresse email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: bodyColor,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Un email de validation a été envoyé à ',
                          ),
                          TextSpan(
                            text: userEmail.isNotEmpty
                                ? userEmail
                                : 'votre adresse',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: emailColor,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Cliquez sur le lien reçu pour valider votre compte.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: BorderSide(color: bannerBorder),
                    backgroundColor: isDark
                        ? Theme.of(context).colorScheme.surface
                        : Colors.white.withValues(alpha: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isResending
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: titleColor,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: const Text(
                    'Renvoyer',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isChecking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 16),
                  label: const Text(
                    'J\'ai vérifié',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
