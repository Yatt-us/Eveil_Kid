// lib/features/parent/presentation/pages/controle_parental_page.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_dialogs.dart';

class ControleParentalPage extends StatefulWidget {
  const ControleParentalPage({super.key});

  @override
  State<ControleParentalPage> createState() => _ControleParentalPageState();
}

class _ControleParentalPageState extends State<ControleParentalPage> {
  bool _isParentalControlEnabled = false;

  bool _autoriseActivites = true;
  bool _autoriseDefis = true;
  bool _autoriseTutoriels = true;
  bool _autoriseCatalogue = true;

  String _tempsQuotidien = '1h 30min';
  String _heuresAutorisees = '08:00-20:00';

  @override
  Widget build(BuildContext context) {
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
          'Contrôle parental',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 24),
            onPressed: () {
              AppDialogs.showSnackBar(
                context: context,
                message: 'Le contrôle parental vous permet de limiter le temps d\'écran et de filtrer les activités autorisées.',
              );
            },
          ),
          AppSpacing.horizontalSm,
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalSm,

            // ── Switch Principal Contrôle Parental ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  AppSpacing.horizontalMd,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Controle parentale',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Gerer l\'accès et le temps d\'utilisation de vos enfants',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Switch(
                    value: _isParentalControlEnabled,
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight.withValues(alpha: 0.5),
                    onChanged: (val) {
                      setState(() => _isParentalControlEnabled = val);
                      AppDialogs.showSnackBar(
                        context: context,
                        message: val
                            ? 'Contrôle parental activé.'
                            : 'Contrôle parental désactivé.',
                      );
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // ── Section Enfants concernés ──
            _buildSectionTitle('Enfants concernés'),
            AppSpacing.verticalSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
              ),
              child: Row(
                children: [
                  // Enfant 1
                  _buildChildAvatarMini(
                    name: 'Lucas',
                    age: '5 ans',
                    iconBg: const Color(0xFF1E1B2E),
                    iconColor: AppColors.white,
                    icon: Icons.person_rounded,
                  ),
                  AppSpacing.horizontalLg,
                  // Enfant 2
                  _buildChildAvatarMini(
                    name: 'Emma',
                    age: '7 ans',
                    iconBg: const Color(0xFFD7CCC8),
                    iconColor: const Color(0xFF5D4037),
                    icon: Icons.face_3_rounded,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // ── Section Limites de temps ──
            _buildSectionTitle('Limites de temps'),
            AppSpacing.verticalSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
              ),
              child: Column(
                children: [
                  _buildTimeRow(
                    label: 'Temps quotidien',
                    value: _tempsQuotidien,
                    onTap: () {
                      _showTimeLimitPicker();
                    },
                  ),
                  AppSpacing.verticalSm,
                  _buildTimeRow(
                    label: 'Heures autorisées',
                    value: _heuresAutorisees,
                    onTap: () {
                      _showAllowedHoursPicker();
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // ── Section Contenu autorisé ──
            _buildSectionTitle('Contenu autorisé'),
            AppSpacing.verticalSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
              ),
              child: Column(
                children: [
                  _buildCheckItem(
                    title: 'Activités',
                    checked: _autoriseActivites,
                    onToggle: () => setState(() => _autoriseActivites = !_autoriseActivites),
                  ),
                  _buildCheckItem(
                    title: 'Défis',
                    checked: _autoriseDefis,
                    onToggle: () => setState(() => _autoriseDefis = !_autoriseDefis),
                  ),
                  _buildCheckItem(
                    title: 'Tutoriels',
                    checked: _autoriseTutoriels,
                    onToggle: () => setState(() => _autoriseTutoriels = !_autoriseTutoriels),
                  ),
                  _buildCheckItem(
                    title: 'Catalogue jouets',
                    checked: _autoriseCatalogue,
                    onToggle: () => setState(() => _autoriseCatalogue = !_autoriseCatalogue),
                  ),
                ],
              ),
            ),
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

  Widget _buildChildAvatarMini({
    required String name,
    required String age,
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 22),
        ),
        AppSpacing.horizontalSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              age,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required bool checked,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Icon(
              checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: checked ? const Color(0xFF22C55E) : AppColors.border,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeLimitPicker() {
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
                child: Text('Temps quotidien', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              ...['30 min', '1h 00min', '1h 30min', '2h 00min', '3h 00min'].map((t) {
                return ListTile(
                  title: Text(t),
                  trailing: _tempsQuotidien == t ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _tempsQuotidien = t);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAllowedHoursPicker() {
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
                child: Text('Heures autorisées', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              ...['08:00-18:00', '08:00-20:00', '09:00-21:00', 'Illimité'].map((h) {
                return ListTile(
                  title: Text(h),
                  trailing: _heuresAutorisees == h ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() => _heuresAutorisees = h);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
