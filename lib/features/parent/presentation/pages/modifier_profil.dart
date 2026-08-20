// lib/features/parent/presentation/pages/modifier_profil.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';

class ModifierProfilPage extends ConsumerStatefulWidget {
  final ParentModel parent;

  const ModifierProfilPage({super.key, required this.parent});

  @override
  ConsumerState<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends ConsumerState<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parent.name);
    _emailController = TextEditingController(text: widget.parent.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = widget.parent.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      await ref
          .read(parentNotifierProvider.notifier)
          .updateParentProfile(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Modifier le profil',
          style: AppTextStyles.headingSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalLg,
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: ClipOval(
                        child:
                            widget.parent.photoUrl != null &&
                                widget.parent.photoUrl!.isNotEmpty
                            ? Image.network(
                                widget.parent.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
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
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.white,
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
                label: 'Nom complet',
                child: TextFormField(
                  controller: _nomController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP EMAIL ---
              _buildFieldContainer(
                label: 'Email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
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
                label: 'Téléphone',
                child: TextFormField(
                  controller: _telController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP ADRESSE ---
              _buildFieldContainer(
                label: 'Adresse',
                child: TextFormField(
                  controller: _adresseController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP DATE DE NAISSANCE ---
              _buildFieldContainer(
                label: 'Date de naissance',
                trailing: GestureDetector(
                  onTap: _pickDate,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Text(
                    widget.parent.name.isNotEmpty
                        ? widget.parent.name[0].toUpperCase()
                        : 'P',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXl,

              AppTextField(
                controller: _nameController,
                label: 'Nom complet',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nom requis';
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              AppTextField(
                controller: _emailController,
                label: 'Adresse e-mail',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email requis';
                  if (!val.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              AppSpacing.verticalXxl,

              AppButton(
                text: 'Enregistrer les modifications',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.7),
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
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
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
