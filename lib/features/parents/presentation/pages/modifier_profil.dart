// lib/features/parents/presentation/pages/modifier_profil.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/models/utilisateur.dart';
import '../../providers/parent_provider.dart';

class ModifierProfilPage extends ConsumerStatefulWidget {
  final Utilisateur parent;

  const ModifierProfilPage({super.key, required this.parent});

  @override
  ConsumerState<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends ConsumerState<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.parent.name);
    _emailController = TextEditingController(text: widget.parent.email);
    _telController = TextEditingController(text: widget.parent.telephone ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = widget.parent.copyWith(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
    );

    try {
      await ref
          .read(parentNotifierProvider.notifier)
          .updateParentProfile(updated);
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Profil mis à jour avec succès !',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Modifier mon profil',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.verticalSm,

              // --- AVATAR DU PROFIL AVEC BADGE CAMÉRA ---
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.surfaceVariant,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: widget.parent.photoUrl != null &&
                                widget.parent.photoUrl!.isNotEmpty
                            ? Image.network(
                                widget.parent.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.person_rounded,
                                  size: 55,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 55,
                                color: theme.colorScheme.primary,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: () {
                          AppDialogs.showSnackBar(
                            context: context,
                            message: 'Sélecteur de photo bientôt disponible.',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXxl,

              // --- CHAMP NOM COMPLET ---
              _buildFieldContainer(
                context: context,
                label: 'Nom complet',
                child: TextFormField(
                  controller: _nomController,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Votre nom complet',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          AppColors.textSecondary,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP EMAIL ---
              _buildFieldContainer(
                context: context,
                label: 'Adresse email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'exemple@email.com',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          AppColors.textSecondary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP TÉLÉPHONE ---
              _buildFieldContainer(
                context: context,
                label: 'Numéro de téléphone',
                child: TextFormField(
                  controller: _telController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '+223 ...',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXxl,

              // --- BOUTON ENREGISTRER ---
              AppButton(
                text: 'Enregistrer les modifications',
                size: AppButtonSize.large,
                isLoading: _isLoading,
                onPressed: _save,
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({
    required BuildContext context,
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.8) ??
                        AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
