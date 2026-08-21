// lib/features/parent/presentation/pages/parametres_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/themes/theme_provider.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import 'controle_parental_page.dart';
import 'notification_settings_page.dart';
import 'securite_page.dart';

class ParametresPage extends ConsumerStatefulWidget {
  const ParametresPage({super.key});

  @override
  ConsumerState<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends ConsumerState<ParametresPage> {
  String _selectedLanguage = 'Français';

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choisir la langue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Français'),
                trailing: _selectedLanguage == 'Français'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Français');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Bambara'),
                trailing: _selectedLanguage == 'Bambara'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Bambara');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: _selectedLanguage == 'English'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'English');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSelector(ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choisir le thème',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined, color: AppColors.primary),
                title: const Text('Clair'),
                trailing: currentMode == ThemeMode.light
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                title: const Text('Sombre'),
                trailing: currentMode == ThemeMode.dark
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_suggest_outlined, color: AppColors.primary),
                title: const Text('Système (Automatique)'),
                trailing: currentMode == ThemeMode.system
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: AppPadding.screenLarge,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.verticalLg,
                const Text(
                  'Accès Restreint',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSm,
                Text(
                  'Veuillez vous connecter à votre compte parent pour modifier vos paramètres et préférences.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalXl,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSm,

            // ── Section Générale ──
            _buildSectionTitle('Générale'),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                icon: Icons.language_rounded,
                title: 'Langue',
                trailingText: _selectedLanguage,
                onTap: _showLanguageSelector,
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildRow(
                icon: Icons.nightlight_round_outlined,
                title: 'Thème',
                trailingText: _getThemeLabel(currentThemeMode),
                onTap: () => _showThemeSelector(currentThemeMode),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                  );
                },
              ),
            ]),
            AppSpacing.verticalLg,

            // ── Section Sécurité ──
            _buildSectionTitle('Sécurité'),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                icon: Icons.verified_user_outlined,
                title: 'Sécurité',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecuritePage()),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildRow(
                icon: Icons.lock_outline_rounded,
                title: 'Changer le mot de passe',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecuritePage()),
                  );
                },
              ),
            ]),
            AppSpacing.verticalLg,

            // ── Section Confidentialité ──
            _buildSectionTitle('Confidentialité'),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                icon: Icons.shield_outlined,
                title: 'Confidentialité',
                onTap: () {
                  AppDialogs.showSnackBar(
                    context: context,
                    message: 'Vos données personnelles sont strictement confidentielles et protégées.',
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildRow(
                icon: Icons.people_outline_rounded,
                title: 'Contrôle parental',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ControleParentalPage()),
                  );
                },
              ),
            ]),
            AppSpacing.verticalLg,

            // ── Section Autres ──
            _buildSectionTitle('Autres'),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                icon: Icons.help_outline_rounded,
                title: 'Aide et support',
                onTap: () {
                  AppDialogs.showSnackBar(
                    context: context,
                    message: 'Support client : support@eveilkid.com / +223 70 00 00 00',
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildRow(
                icon: Icons.info_outline_rounded,
                title: 'A propos',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Éveil Kid',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Éveil Kid. Tous droits réservés.',
                  );
                },
              ),
            ]),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
