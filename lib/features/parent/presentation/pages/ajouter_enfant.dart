// lib/features/parent/presentation/pages/ajouter_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';

class AjouterEnfantPage extends ConsumerStatefulWidget {
  const AjouterEnfantPage({super.key});

  @override
  ConsumerState<AjouterEnfantPage> createState() => _AjouterEnfantPageState();
}

class _AjouterEnfantPageState extends ConsumerState<AjouterEnfantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '4');

  String _selectedLevel = 'Niveau 2';
  bool _isLoading = false;

  final List<String> _availableLevels = [
    'Niveau 1',
    'Niveau 2',
    'Niveau 3',
    'Niveau 4',
    'Niveau 5',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 4;

    setState(() => _isLoading = true);

    final newChild = EnfantModel(
      enfantId: '',
      utilisateurId: '',
      nom: name,
      dateNaissance: DateTime(DateTime.now().year - age, 1, 1),
    );

    try {
      await ref.read(parentNotifierProvider.notifier).ajouterEnfant(newChild);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name a été ajouté avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
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
        title: const Text('Ajouter un enfant', style: AppTextStyles.headingSmall),
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
                  child: const Icon(Icons.face_rounded, size: 50, color: AppColors.primary),
                ),
              ),
              AppSpacing.verticalXl,

              AppTextField(
                controller: _nameController,
                label: 'Prénom de l\'enfant',
                hintText: 'Ex: Nour',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez renseigner le prénom de l\'enfant';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              AppTextField(
                controller: _ageController,
                label: 'Âge',
                hintText: 'Ex: 5',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.cake_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Âge requis';
                  final num = int.tryParse(val);
                  if (num == null || num < 1 || num > 14) return 'Entre 1 et 14 ans';
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              const Text(
                'Niveau',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                      return DropdownMenuItem(value: lvl, child: Text(lvl, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLevel = val);
                    },
                  ),
                ),
              ),
              AppSpacing.verticalXxl,

              AppButton(
                text: 'Enregistrer l\'enfant',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
