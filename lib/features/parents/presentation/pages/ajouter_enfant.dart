// lib/features/parents/presentation/pages/ajouter_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_date_picker.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';

class AjouterEnfantPage extends ConsumerStatefulWidget {
  const AjouterEnfantPage({super.key});

  @override
  ConsumerState<AjouterEnfantPage> createState() => _AjouterEnfantPageState();
}

class _AjouterEnfantPageState extends ConsumerState<AjouterEnfantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 5));
  String _selectedGenre = 'Garçon';
  String? _selectedAvatarUrl;
  final List<String> _selectedSouhaits = [];
  bool _isLoading = false;

  final List<String> _availableSouhaits = [
    '🧩 Puzzles',
    '🤖 Robots & Tech',
    '🎨 Dessin & Arts',
    '📚 Livres & Contes',
    '🎵 Musique & Sons',
    '⚽ Sport & Plein air',
    '🔬 Découvertes',
    '🧱 Construction',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    var age = now.year - _selectedDate.year;
    if (now.month < _selectedDate.month ||
        (now.month == _selectedDate.month && now.day < _selectedDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    setState(() => _isLoading = true);

    final newChild = EnfantModel.creerNouveau(
      utilisateurId: '',
      nom: name,
      dateNaissance: _selectedDate,
      genre: _selectedGenre,
      avatarUrl: _selectedAvatarUrl,
    ).copyWith(
      souhait: _selectedSouhaits,
      codeSecuriteHash: _pinController.text.trim(),
    );

    try {
      await ref.read(parentNotifierProvider.notifier).ajouterEnfant(newChild);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name a été ajouté avec succès !'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajouter un enfant',
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
              AppSpacing.verticalSm,

              // ── SÉLECTION AVATAR ──
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEDE9FE),
                        border: Border.all(
                          color: const Color(0xFF763CD1).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _selectedGenre == 'Fille'
                              ? Icons.face_3_rounded
                              : Icons.face_rounded,
                          size: 60,
                          color: const Color(0xFF763CD1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF763CD1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalXl,

              // ── PRÉNOM / NOM DE L'ENFANT ──
              AppTextField(
                controller: _nameController,
                label: 'Prénom de l\'enfant',
                hintText: 'Ex: Lucas, Sarah, Noah...',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez renseigner le prénom de l\'enfant';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              // ── SÉLECTION DU GENRE ──
              const Text(
                'Genre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalXs,
              Row(
                children: [
                  Expanded(
                    child: _buildGenreCard(
                      label: 'Garçon',
                      icon: Icons.face_rounded,
                      isSelected: _selectedGenre == 'Garçon',
                      onTap: () => setState(() => _selectedGenre = 'Garçon'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenreCard(
                      label: 'Fille',
                      icon: Icons.face_3_rounded,
                      isSelected: _selectedGenre == 'Fille',
                      onTap: () => setState(() => _selectedGenre = 'Fille'),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,

              // ── DATE DE NAISSANCE & ÂGE CALCULÉ ──
              Row(
                children: [
                  Expanded(
                    child: AppDatePicker(
                      label: 'Date de naissance',
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Âge estimé',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Text(
                          '$_calculatedAge ans',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF763CD1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalMd,

              // ── CENTRES D'INTÉRÊT & SOUHAITS ──
              const Text(
                'Centres d\'intérêt & Préférences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalXs,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSouhaits.map((item) {
                  final isSelected = _selectedSouhaits.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSouhaits.add(item);
                        } else {
                          _selectedSouhaits.remove(item);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFEDE9FE),
                    checkmarkColor: const Color(0xFF763CD1),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF763CD1)
                            : AppColors.border,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF763CD1)
                          : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.verticalMd,

              // ── CODE PIN SÉCURITÉ OPTIONNEL ──
              AppTextField(
                controller: _pinController,
                label: 'Code PIN enfant (optionnel)',
                hintText: 'Ex: 1234',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_outline_rounded,
                helperText: 'Permet de sécuriser ou déverrouiller l\'espace enfant',
              ),
              AppSpacing.verticalXxl,

              // ── BOUTON D'ENREGISTREMENT ──
              AppButton(
                text: 'Enregistrer l\'enfant',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              AppSpacing.verticalLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE9FE) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF763CD1) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF763CD1) : AppColors.icon,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF763CD1) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
