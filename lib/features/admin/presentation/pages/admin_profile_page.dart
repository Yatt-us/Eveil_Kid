import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_theme_mode_sheet.dart';
import '../../../auth/models/utilisateur.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../parents/providers/parent_provider.dart';
import '../../core/models/admin_role.dart';
import '../../core/providers/admin_role_provider.dart';
import '../widgets/admin_drawer.dart';

class AdminProfilePage extends ConsumerStatefulWidget {
  const AdminProfilePage({super.key});

  @override
  ConsumerState<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends ConsumerState<AdminProfilePage> {
  bool _isResettingPassword = false;
  bool _isCheckingVerification = false;

  Future<void> _logout() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Déconnexion Administrateur',
      message:
          'Êtes-vous sûr de vouloir vous déconnecter de votre session d\'administration ?',
      confirmText: 'Se déconnecter',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _resetPassword(String email) async {
    if (email.isEmpty) return;

    setState(() => _isResettingPassword = true);
    final success =
        await ref.read(authProvider.notifier).resetPassword(email: email);
    if (!mounted) return;
    setState(() => _isResettingPassword = false);

    if (success) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Un email de réinitialisation a été envoyé à $email.',
      );
    } else {
      final error = ref.read(authProvider).errorMessage;
      AppDialogs.showSnackBar(
        context: context,
        message: error ?? 'Impossible d\'envoyer l\'email de réinitialisation.',
        isError: true,
      );
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isCheckingVerification = true);
    try {
      final isVerified =
          await ref.read(authProvider.notifier).reloadAndCheckEmailVerified();
      if (!mounted) return;
      if (isVerified) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Votre adresse email est bien vérifiée !',
        );
      } else {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Votre adresse email n\'est pas encore vérifiée.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingVerification = false);
    }
  }

  Future<void> _showEditProfileDialog(Utilisateur utilisateur) async {
    final nameController = TextEditingController(text: utilisateur.nom);
    final phoneController =
        TextEditingController(text: utilisateur.telephone ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              backgroundColor: theme.colorScheme.surface,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Modifier mes informations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: nameController,
                          labelText: 'Nom complet',
                          hintText: 'Ex: Jean Dupont',
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est obligatoire';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.verticalMd,
                        AppTextField(
                          controller: phoneController,
                          labelText: 'Numéro de téléphone',
                          hintText: 'Ex: +33 6 12 34 56 78',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);

                          final updated = utilisateur.copyWith(
                            nom: nameController.text.trim(),
                            telephone: phoneController.text.trim(),
                          );

                          try {
                            final repo = ref.read(parentRepositoryProvider);
                            await repo.updateParentProfile(updated);

                            await ref
                                .read(authProvider.notifier)
                                .reloadAndCheckEmailVerified();

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              AppDialogs.showSnackBar(
                                context: context,
                                message: 'Profil mis à jour avec succès !',
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() => isSaving = false);
                              AppDialogs.showSnackBar(
                                context: context,
                                message: 'Erreur lors de la mise à jour : $e',
                                isError: true,
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non renseigné';
    try {
      return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
    } catch (_) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year à $hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.utilisateur;
    final adminRole = ref.watch(adminRoleProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);

    final isAdmin = adminRole == AdminRole.admin;
    final roleColor = isAdmin ? theme.colorScheme.error : const Color(0xFFD97706);
    final roleIcon =
        isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded;

    final displayName = (user != null && user.nom.trim().isNotEmpty)
        ? user.nom.trim()
        : (isAdmin ? 'Super Administrateur' : 'Manager Opérationnel');
    final displayEmail = (user != null && user.email.isNotEmpty)
        ? user.email
        : 'Non renseigné';
    final displayPhone = (user != null && user.telephone != null && user.telephone!.isNotEmpty)
        ? user.telephone!
        : 'Non renseigné';

    final createdFormatted = _formatDate(user?.dateCreation);

    return AdminScaffold(
      currentRoute: AdminNavRoute.profile,
      appBar: AppBar(
        title: Text(
          'Profil Administrateur',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMultiColumn = constraints.maxWidth >= 720;
          final contentPadding = EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 400 ? 12 : 18,
            vertical: 16,
          );

          return SingleChildScrollView(
            padding: contentPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. CARTE EN-TÊTE PROFIL (Pleine largeur)
                    _buildHeaderCard(
                      theme: theme,
                      isDark: isDark,
                      user: user,
                      displayName: displayName,
                      displayEmail: displayEmail,
                      adminRole: adminRole,
                      roleColor: roleColor,
                      roleIcon: roleIcon,
                      isWide: constraints.maxWidth >= 520,
                    ),

                    AppSpacing.verticalLg,

                    // 2. DISPOSITION RESPONSIVE (1 COLONNE SUR MOBILE, 2 COLONNES SUR TABLETTE/DESKTOP)
                    if (isMultiColumn)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Colonne de gauche
                          Expanded(
                            child: Column(
                              children: [
                                _buildPersonalInfoCard(
                                  theme: theme,
                                  user: user,
                                  displayName: displayName,
                                  displayEmail: displayEmail,
                                  displayPhone: displayPhone,
                                  createdFormatted: createdFormatted,
                                  isEmailVerified: authState.isEmailVerified,
                                ),
                                AppSpacing.verticalLg,
                                _buildSecurityCard(
                                  theme: theme,
                                  isDark: isDark,
                                  displayEmail: displayEmail,
                                  isEmailVerified: authState.isEmailVerified,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Colonne de droite
                          Expanded(
                            child: Column(
                              children: [
                                _buildPrivilegesCard(
                                  theme: theme,
                                  isDark: isDark,
                                  adminRole: adminRole,
                                  isAdmin: isAdmin,
                                  roleColor: roleColor,
                                ),
                                AppSpacing.verticalLg,
                                _buildAppearanceCard(
                                  theme: theme,
                                  currentThemeMode: currentThemeMode,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildPersonalInfoCard(
                            theme: theme,
                            user: user,
                            displayName: displayName,
                            displayEmail: displayEmail,
                            displayPhone: displayPhone,
                            createdFormatted: createdFormatted,
                            isEmailVerified: authState.isEmailVerified,
                          ),
                          AppSpacing.verticalLg,
                          _buildPrivilegesCard(
                            theme: theme,
                            isDark: isDark,
                            adminRole: adminRole,
                            isAdmin: isAdmin,
                            roleColor: roleColor,
                          ),
                          AppSpacing.verticalLg,
                          _buildSecurityCard(
                            theme: theme,
                            isDark: isDark,
                            displayEmail: displayEmail,
                            isEmailVerified: authState.isEmailVerified,
                          ),
                          AppSpacing.verticalLg,
                          _buildAppearanceCard(
                            theme: theme,
                            currentThemeMode: currentThemeMode,
                          ),
                        ],
                      ),

                    AppSpacing.verticalXl,

                    // 3. BOUTON DÉCONNEXION
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AppButton(
                          text: 'Se déconnecter de la session',
                          icon: Icons.logout_rounded,
                          variant: AppButtonVariant.danger,
                          onPressed: _logout,
                        ),
                      ),
                    ),

                    AppSpacing.verticalXxl,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 1. CARTE EN-TÊTE PROFIL ────────────────────────────────────────────────
  Widget _buildHeaderCard({
    required ThemeData theme,
    required bool isDark,
    required Utilisateur? user,
    required String displayName,
    required String displayEmail,
    required AdminRole adminRole,
    required Color roleColor,
    required IconData roleIcon,
    required bool isWide,
  }) {
    final avatar = AppAvatar(
      name: displayName,
      imageUrl: user?.photoUrl,
      radius: isWide ? 38 : 32,
      isOnline: true,
      defaultIcon: Icons.admin_panel_settings_rounded,
    );

    final details = Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          style: TextStyle(
            fontSize: isWide ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          displayEmail,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: roleColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(roleIcon, size: 15, color: roleColor),
              const SizedBox(width: 6),
              Text(
                adminRole.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return _buildCard(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isWide
            ? Row(
                children: [
                  avatar,
                  const SizedBox(width: 18),
                  Expanded(child: details),
                ],
              )
            : Column(
                children: [
                  avatar,
                  const SizedBox(height: 14),
                  details,
                ],
              ),
      ),
    );
  }

  // ── 2. INFORMATIONS PERSONNELLES ──────────────────────────────────────────
  Widget _buildPersonalInfoCard({
    required ThemeData theme,
    required Utilisateur? user,
    required String displayName,
    required String displayEmail,
    required String displayPhone,
    required String createdFormatted,
    required bool isEmailVerified,
  }) {
    return _buildCard(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSectionIcon(
                  theme: theme,
                  icon: Icons.person_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations Personnelles',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Données de votre compte gestionnaire',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user != null)
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(user),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: const Size(54, 30),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 13),
                    label: const Text('Modifier', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(
              theme: theme,
              icon: Icons.badge_outlined,
              title: 'Nom complet',
              value: displayName,
            ),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(
              theme: theme,
              icon: Icons.email_outlined,
              title: 'Adresse email',
              value: displayEmail,
              badge: isEmailVerified
                  ? const Tooltip(
                      message: 'Email vérifié',
                      child: Icon(Icons.verified_rounded,
                          size: 15, color: AppColors.success),
                    )
                  : const Tooltip(
                      message: 'Email non vérifié',
                      child: Icon(Icons.warning_amber_rounded,
                          size: 15, color: AppColors.warning),
                    ),
            ),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(
              theme: theme,
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              value: displayPhone,
            ),
            if (user != null && user.utilisateurId.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSimpleInfoRow(
                theme: theme,
                icon: Icons.fingerprint_rounded,
                title: 'Identifiant UID',
                value: user.utilisateurId,
                canCopy: true,
              ),
            ],
            if (user != null && user.dateCreation != null) ...[
              const SizedBox(height: 12),
              _buildSimpleInfoRow(
                theme: theme,
                icon: Icons.calendar_today_outlined,
                title: 'Date de création',
                value: createdFormatted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 3. RÔLE & PRIVILÈGES ───────────────────────────────────────────────────
  Widget _buildPrivilegesCard({
    required ThemeData theme,
    required bool isDark,
    required AdminRole adminRole,
    required bool isAdmin,
    required Color roleColor,
  }) {
    return _buildCard(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSectionIcon(
                  theme: theme,
                  icon: Icons.shield_outlined,
                  color: roleColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rôle & Privilèges',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        adminRole.description,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildPermissionItem(
              theme: theme,
              title: 'Catalogue & Produits',
              description: 'Gestion des articles, stocks et visuels',
              isAllowed: true,
            ),
            _buildPermissionItem(
              theme: theme,
              title: 'Catégories & Rubriques',
              description: 'Structure et organisation de la boutique',
              isAllowed: true,
            ),
            _buildPermissionItem(
              theme: theme,
              title: 'Commandes & Ventes',
              description: 'Traitement et expédition des achats',
              isAllowed: true,
            ),
            _buildPermissionItem(
              theme: theme,
              title: 'Gestion des Utilisateurs',
              description: 'Attribution des rôles et modération',
              isAllowed: isAdmin,
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. SÉCURITÉ & AUTHENTIFICATION ─────────────────────────────────────────
  Widget _buildSecurityCard({
    required ThemeData theme,
    required bool isDark,
    required String displayEmail,
    required bool isEmailVerified,
  }) {
    return _buildCard(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSectionIcon(
                  theme: theme,
                  icon: Icons.lock_clock_outlined,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sécurité du Compte',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Protection et vérification d\'accès',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Email verification status
            Row(
              children: [
                Icon(
                  isEmailVerified
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                  size: 18,
                  color: isEmailVerified ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut email',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isEmailVerified
                            ? 'Adresse validée et sécurisée'
                            : 'Adresse email non validée',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isEmailVerified)
                  OutlinedButton(
                    onPressed: _isCheckingVerification
                        ? null
                        : _checkEmailVerification,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: const Size(54, 30),
                    ),
                    child: _isCheckingVerification
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Vérifier',
                            style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Password Reset
            Row(
              children: [
                const Icon(Icons.password_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Envoyer un lien de réinitialisation',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7) ??
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isResettingPassword ||
                          displayEmail == 'Non renseigné'
                      ? null
                      : () => _resetPassword(displayEmail),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(60, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  icon: _isResettingPassword
                      ? const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 12),
                  label: const Text('Envoyer', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. APPARENCE & THÈME ───────────────────────────────────────────────────
  Widget _buildAppearanceCard({
    required ThemeData theme,
    required ThemeMode currentThemeMode,
  }) {
    return _buildCard(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _buildSectionIcon(
              theme: theme,
              icon: Icons.palette_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apparence',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    switch (currentThemeMode) {
                      ThemeMode.system => 'Thème Système (Auto)',
                      ThemeMode.light => 'Thème Clair',
                      ThemeMode.dark => 'Thème Sombre',
                    },
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7) ??
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => AppThemeModeSheet.show(context),
              style: OutlinedButton.styleFrom(
                shape:
                    RoundedRectangleBorder(borderRadius: AppRadius.button),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(60, 30),
              ),
              icon: const Icon(Icons.tune_rounded, size: 13),
              label: const Text('Changer', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS UI ─────────────────────────────────────────────────────────────
  Widget _buildCard({
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionIcon({
    required ThemeData theme,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildSimpleInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    Widget? badge,
    bool canCopy = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.iconTheme.color?.withValues(alpha: 0.65) ?? AppColors.icon,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                      AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    badge,
                  ],
                ],
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            tooltip: 'Copier',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.copy_rounded, size: 14),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              AppDialogs.showSnackBar(
                context: context,
                message: '$title copié dans le presse-papier !',
              );
            },
          ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required ThemeData theme,
    required String title,
    required String description,
    required bool isAllowed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: (isAllowed ? AppColors.success : AppColors.textSecondary)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAllowed ? Icons.check_rounded : Icons.lock_outline_rounded,
              size: 12,
              color: isAllowed ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isAllowed
                        ? (theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface)
                        : theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7) ??
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isAllowed)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Admin requis',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
