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
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
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
  late TextEditingController _ageController;

  late String _selectedLevel;
  bool _isLoading = false;

  final List<String> _availableLevels = [
    'Niveau 1',
    'Niveau 2',
    'Niveau 3',
    'Niveau 4',
    'Niveau 5',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.enfant.nom);
    _ageController = TextEditingController(text: widget.enfant.age.toString());

    _selectedLevel = _availableLevels[1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedChild = widget.enfant.copyWith(
      nom: _nameController.text.trim(),
      dateNaissance: DateTime(
        DateTime.now().year -
            (int.tryParse(_ageController.text.trim()) ?? widget.enfant.age),
        1,
        1,
      ),
    );

    try {
      await ref
          .read(parentNotifierProvider.notifier)
          .modifierEnfant(updatedChild);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil de ${updatedChild.nom} mis à jour avec succès !',
            ),
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

  Future<void> _deleteChild() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer ${widget.enfant.nom} ?',
      message: 'Êtes-vous sûr de vouloir supprimer cet enfant ?',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(parentNotifierProvider.notifier)
            .supprimerEnfant(widget.enfant.enfantId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.enfant.nom} a été supprimé.'),
              backgroundColor: AppColors.danger,
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Modifier ${widget.enfant.nom}',
          style: AppTextStyles.headingSmall,
        ),
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
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.face_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
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

              AppTextField(
                controller: _ageController,
                label: 'Âge',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.cake_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Âge requis';
                  final num = int.tryParse(val);
                  if (num == null || num < 1 || num > 14)
                    return 'Entre 1 et 14 ans';
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              const Text(
                'Niveau',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.input,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLevel,
                    isExpanded: true,
                    items: _availableLevels.map((lvl) {
                      return DropdownMenuItem(
                        value: lvl,
                        child: Text(lvl, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLevel = val);
                    },
                  ),
                ),
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
