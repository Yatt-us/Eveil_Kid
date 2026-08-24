// lib/features/parent/presentation/pages/modifier_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_date_picker.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';

class ModifierEnfantPage extends ConsumerStatefulWidget {
  final EnfantModel enfant;

  const ModifierEnfantPage({super.key, required this.enfant});

  @override
  ConsumerState<ModifierEnfantPage> createState() => _ModifierEnfantPageState();
}

class _ModifierEnfantPageState extends ConsumerState<ModifierEnfantPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  late String _selectedGenre;
  String? _avatarUrl;
  bool _isLoading = false;

  final List<Map<String, String>> _genres = [
    {'value': 'GARCON', 'label': 'Garçon'},
    {'value': 'FILLE', 'label': 'Fille'},
    {'value': 'NON_SPECIFIE', 'label': 'Non spécifié'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.enfant.nom);
    _selectedDate = widget.enfant.dateNaissance;
    _selectedGenre = widget.enfant.genre;
    _avatarUrl = widget.enfant.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedChild = widget.enfant.copyWith(
      nom: _nameController.text.trim(),
      dateNaissance: _selectedDate,
      genre: _selectedGenre,
      avatarUrl: _avatarUrl,
    );

    try {
      await ref.read(parentNotifierProvider.notifier).modifierEnfant(updatedChild);

      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Profil de ${updatedChild.nom} mis à jour avec succès !',
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

  Future<void> _deleteChild() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer ${widget.enfant.name} ?',
      message: 'Êtes-vous sûr de vouloir supprimer cet enfant ?',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(parentNotifierProvider.notifier).supprimerEnfant(widget.enfant.enfantId);
        if (mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: '${widget.enfant.nom} a été supprimé.',
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Modifier ${widget.enfant.name}', style: AppTextStyles.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            tooltip: 'Supprimer',
            onPressed: _deleteChild,
          ),
        ],
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
                  children: [
                    AppAvatar(
                      imageUrl: _avatarUrl,
                      radius: 50,
                      defaultIcon: Icons.face_rounded,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: () {
                            AppDialogs.showSnackBar(context: context, message: 'Sélecteur d\'image bientôt disponible');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              AppTextField(
                controller: _nameController,
                label: 'Prénom de l\'enfant',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Prénom requis';
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              AppDatePicker(
                label: 'Date de naissance',
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              AppSpacing.verticalMd,

              const Text(
                'Genre',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              AppSpacing.verticalXs,
              Row(
                children: _genres.map((genre) {
                  final isSelected = _selectedGenre == genre['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(genre['label']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedGenre = genre['value']!);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.verticalXxl,

              AppButton(
                text: 'Sauvegarder les modifications',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              AppSpacing.verticalMd,
              AppButton(
                text: 'Supprimer cet enfant',
                variant: AppButtonVariant.danger,
                icon: Icons.delete_outline,
                onPressed: _deleteChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
