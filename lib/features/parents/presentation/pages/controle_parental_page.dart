// lib/features/parents/presentation/pages/controle_parental_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';

class ControleParentalPage extends ConsumerStatefulWidget {
  const ControleParentalPage({super.key});

  @override
  ConsumerState<ControleParentalPage> createState() =>
      _ControleParentalPageState();
}

class _ControleParentalPageState extends ConsumerState<ControleParentalPage> {
  bool _isParentalControlEnabled = true;

  // Enfants sélectionnés par leur ID
  final Set<String> _selectedChildrenIds = {};

  // Temps quotidien (en minutes)
  int _dailyLimitMinutes = 90; // 1h30

  // Plage horaire autorisée
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);

  // Contenus autorisés
  bool _autoriseActivites = true;
  bool _autoriseDefis = true;
  bool _autoriseCatalogue = true;

  @override
  void initState() {
    super.initState();
    // Initialise la sélection de tous les enfants par défaut
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parentAsync = ref.read(parentNotifierProvider);
      parentAsync.whenData((parent) {
        if (mounted && parent.enfants.isNotEmpty) {
          setState(() {
            for (final e in parent.enfants) {
              _selectedChildrenIds.add(e.enfantId);
            }
          });
        }
      });
    });
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins min';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'Heure de début autorisée' : 'Heure de fin autorisée',
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentNotifierProvider);
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
          'Contrôle parental',
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

            // ── 1. CARTE SWITCH PRINCIPALE ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.textPrimary)
                        .withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activer le contrôle parental',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isParentalControlEnabled
                              ? 'Les restrictions définies ci-dessous sont actives'
                              : 'Toutes les restrictions sont actuellement désactivées',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isParentalControlEnabled
                                ? const Color(0xFF10B981)
                                : (theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7) ??
                                    theme.colorScheme.onSurfaceVariant),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSm,
                  Switch(
                    value: _isParentalControlEnabled,
                    activeThumbColor: theme.colorScheme.primary,
                    activeTrackColor: theme.colorScheme.primary.withValues(
                      alpha: 0.4,
                    ),
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
            AppSpacing.verticalLg,

            // ── SECTIONS CONDITIONNELLES AVEC GRISAGE SI DÉSACTIVÉ ──
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isParentalControlEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !_isParentalControlEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 2. ENFANTS CONCERNÉS (DYNAMIQUE) ──
                    _buildSectionTitle('Enfants concernés', theme),
                    AppSpacing.verticalSm,
                    parentAsync.when(
                      data: (parent) =>
                          _buildChildrenSection(context, parent.enfants, theme, isDark),
                      loading: () => Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppRadius.card,
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      error: (err, stack) => _buildEmptyChildrenCard(context, theme),
                    ),
                    AppSpacing.verticalLg,

                    // ── 3. LIMITES DE TEMPS INTERACTIVES ──
                    _buildSectionTitle('Limites de temps', theme),
                    AppSpacing.verticalSm,
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : AppColors.textPrimary)
                                .withValues(alpha: isDark ? 0.25 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Temps quotidien avec Slider interactif
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Temps quotidien maximum',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleSmall?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatMinutes(_dailyLimitMinutes),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _dailyLimitMinutes.toDouble(),
                            min: 15,
                            max: 240,
                            divisions: 15, // tranches de 15 min
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: theme.dividerColor.withValues(alpha: 0.2),
                            label: _formatMinutes(_dailyLimitMinutes),
                            onChanged: (val) {
                              setState(() => _dailyLimitMinutes = val.toInt());
                            },
                          ),

                          // Raccourcis de temps rapides (chips)
                          Wrap(
                            spacing: 8,
                            children: [30, 60, 90, 120, 180].map((mins) {
                              final isSelected = _dailyLimitMinutes == mins;
                              return ChoiceChip(
                                label: Text(_formatMinutes(mins)),
                                selected: isSelected,
                                selectedColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : (theme.textTheme.bodyMedium?.color ??
                                          theme.colorScheme.onSurface),
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                backgroundColor: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.dividerColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _dailyLimitMinutes = mins);
                                  }
                                },
                              );
                            }).toList(),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              color: theme.dividerColor.withValues(alpha: 0.2),
                            ),
                          ),

                          // Heures autorisées avec TimePicker interactif
                          Text(
                            'Plage horaire autorisée',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleSmall?.color ??
                                  theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'L\'enfant peut utiliser l\'application uniquement entre ces deux heures',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7) ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(isStart: true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? theme.colorScheme.surfaceContainerHighest
                                          : theme.colorScheme.primary.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'De :',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.textTheme.bodySmall?.color
                                                    ?.withValues(alpha: 0.7) ??
                                                theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _formatTimeOfDay(_startTime),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.bodyLarge?.color ??
                                                theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalSm,
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(isStart: false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? theme.colorScheme.surfaceContainerHighest
                                          : theme.colorScheme.primary.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'À :',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.textTheme.bodySmall?.color
                                                    ?.withValues(alpha: 0.7) ??
                                                theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _formatTimeOfDay(_endTime),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.bodyLarge?.color ??
                                                theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalLg,

                    // ── 4. CONTENU AUTORISÉ INTERACTIF ──
                    _buildSectionTitle('Contenu autorisé', theme),
                    AppSpacing.verticalSm,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : AppColors.textPrimary)
                                .withValues(alpha: isDark ? 0.25 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildCheckItem(
                            theme: theme,
                            icon: Icons.school_outlined,
                            title: 'Activités éducatives',
                            subtitle: 'Quiz, calculs, leçons interactives',
                            checked: _autoriseActivites,
                            onToggle: () => setState(
                              () => _autoriseActivites = !_autoriseActivites,
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                          _buildCheckItem(
                            theme: theme,
                            icon: Icons.sports_esports_outlined,
                            title: 'Jeux et Défis',
                            subtitle: 'Mini-jeux de mémoire, puzzles, logique',
                            checked: _autoriseDefis,
                            onToggle: () => setState(
                              () => _autoriseDefis = !_autoriseDefis,
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                          _buildCheckItem(
                            theme: theme,
                            icon: Icons.shopping_bag_outlined,
                            title: 'Catalogue jouets',
                            subtitle:
                                'Consultation du catalogue et fiches jouets',
                            checked: _autoriseCatalogue,
                            onToggle: () => setState(
                              () => _autoriseCatalogue = !_autoriseCatalogue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.verticalXxl,

                    // ── BOUTON ENREGISTRER ──
                    AppButton(
                      text: 'Enregistrer les modifications',
                      onPressed: () {
                        AppDialogs.showSnackBar(
                          context: context,
                          message:
                              'Paramètres de contrôle parental enregistrés avec succès !',
                        );
                      },
                    ),
                    AppSpacing.verticalXxl,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
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

  Widget _buildChildrenSection(
    BuildContext context,
    List<EnfantModel> enfants,
    ThemeData theme,
    bool isDark,
  ) {
    if (enfants.isEmpty) {
      return _buildEmptyChildrenCard(context, theme);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textPrimary)
                .withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: enfants.asMap().entries.map((entry) {
          final idx = entry.key;
          final enfant = entry.value;
          final isSelected = _selectedChildrenIds.contains(enfant.enfantId);

          final Color iconBg = idx % 2 == 0
              ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
              : (isDark ? const Color(0xFF831843) : const Color(0xFFFDF2F8));
          final Color iconColor = idx % 2 == 0
              ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6))
              : (isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899));

          return Column(
            children: [
              if (idx > 0)
                Divider(
                  height: 16,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedChildrenIds.remove(enfant.enfantId);
                    } else {
                      _selectedChildrenIds.add(enfant.enfantId);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: iconBg,
                        child: Icon(
                          Icons.face_rounded,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      AppSpacing.horizontalMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              enfant.nom,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleSmall?.color ??
                                    theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${enfant.age} ans',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7) ??
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedChildrenIds.add(enfant.enfantId);
                            } else {
                              _selectedChildrenIds.remove(enfant.enfantId);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyChildrenCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 40,
            color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.verticalSm,
          Text(
            'Aucun profil enfant associé',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleSmall?.color ??
                  theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            'Ajoutez votre premier enfant pour configurer des restrictions sur-mesure.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                  theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalMd,
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Ajouter un enfant',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool checked,
    required VoidCallback onToggle,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: theme.colorScheme.primary),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleSmall?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7) ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: checked,
              activeColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
