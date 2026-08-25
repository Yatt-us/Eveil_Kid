// lib/features/parents/presentation/pages/parametre_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import 'aide_support_page.dart';
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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choisir la langue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Français',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: _selectedLanguage == 'Français'
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Français');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'Bambara',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: _selectedLanguage == 'Bambara'
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = 'Bambara');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'English',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: _selectedLanguage == 'English'
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choisir le thème',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.light_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Clair',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: currentMode == ThemeMode.light
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.dark_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Sombre',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: currentMode == ThemeMode.dark
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings_suggest_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Système (Automatique)',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: currentMode == ThemeMode.system
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
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
            'Paramètres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color ??
                  theme.colorScheme.onSurface,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                AppSpacing.verticalLg,
                Text(
                  'Accès Restreint',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: theme.textTheme.titleLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSm,
                Text(
                  'Veuillez vous connecter à votre compte parent pour modifier vos paramètres et préférences.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7) ??
                        theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalXl,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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
          'Paramètres',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSm,

            // ── Section Générale ──
            _buildSectionTitle('Générale', context),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                context: context,
                icon: Icons.language_rounded,
                title: 'Langue',
                trailingText: _selectedLanguage,
                onTap: _showLanguageSelector,
              ),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
              _buildRow(
                context: context,
                icon: Icons.nightlight_round_outlined,
                title: 'Thème',
                trailingText: _getThemeLabel(currentThemeMode),
                onTap: () => _showThemeSelector(currentThemeMode),
              ),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
              _buildRow(
                context: context,
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
            ], context, isDark),
            AppSpacing.verticalLg,

            // ── Section Sécurité ──
            _buildSectionTitle('Sécurité', context),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                context: context,
                icon: Icons.security_rounded,
                title: 'Sécurité du compte',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecuritePage()),
                  );
                },
              ),
            ], context, isDark),
            AppSpacing.verticalLg,

            // ── Section Confidentialité ──
            _buildSectionTitle('Confidentialité', context),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Confidentialité',
                onTap: () {
                  AppDialogs.showSnackBar(
                    context: context,
                    message:
                        'Vos données personnelles sont strictement confidentielles et protégées.',
                  );
                },
              ),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
              _buildRow(
                context: context,
                icon: Icons.people_outline_rounded,
                title: 'Contrôle parental',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ControleParentalPage(),
                    ),
                  );
                },
              ),
            ], context, isDark),
            AppSpacing.verticalLg,

            // ── Section Autres ──
            _buildSectionTitle('Autres', context),
            AppSpacing.verticalSm,
            _buildCard([
              _buildRow(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'Aide et support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AideSupportPage(),
                    ),
                  );
                },
              ),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
              _buildRow(
                context: context,
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
            ], context, isDark),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: theme.textTheme.titleMedium?.color ??
            theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCard(List<Widget> children, BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
      child: Column(children: children),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            AppSpacing.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleMedium?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                      theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
            ],
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
}
