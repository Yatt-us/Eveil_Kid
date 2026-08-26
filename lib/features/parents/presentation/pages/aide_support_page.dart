// lib/features/parents/presentation/pages/aide_support_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_dialogs.dart';

class AideSupportPage extends StatefulWidget {
  const AideSupportPage({super.key});

  @override
  State<AideSupportPage> createState() => _AideSupportPageState();
}

class _AideSupportPageState extends State<AideSupportPage> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqItems = const [
    {
      'question': 'Comment ajouter un enfant ?',
      'answer':
          'Rendez-vous dans la section "Mes Enfants" ou depuis l\'écran d\'accueil parent, puis appuyez sur le bouton "+" en bas à droite. Renseignez son prénom, sa date de naissance, son genre et choisissez un avatar pour personnaliser son espace d\'apprentissage.',
    },
    {
      'question': 'Comment fonctionne les actiivtes ?',
      'answer':
          'Les activités (jeux interactifs, puzzles, quiz et ateliers créatifs) sont conçues par des experts pédagogiques et adaptées à chaque tranche d\'âge. Votre enfant progresse à son rythme, gagne des récompenses et vous pouvez suivre son évolution dans le tableau de bord.',
    },
    {
      'question': 'Comment gerer le temps d’ecran ?',
      'answer':
          'Dans les "Paramètres", accédez à l\'option "Contrôle parental". Vous pouvez y définir une limite quotidienne de temps d\'écran (ex: 30 minutes), programmer des plages horaires d\'accès et verrouiller l\'application quand la session est terminée.',
    },
    {
      'question': 'Ou voir mes commandes ?',
      'answer':
          'Vous pouvez consulter l\'historique et le statut de vos commandes de jouets physiques et abonnements dans la section "Boutique / Jouets" ou directement depuis votre "Profil parent" sous l\'onglet "Mes commandes".',
    },
  ];

  void _showContactModal() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contactez notre support',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: theme.textTheme.titleLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.iconTheme.color ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Text(
                  'Notre équipe est disponible 7j/7 pour vous accompagner.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.verticalMd,
                _buildContactOption(
                  theme: theme,
                  icon: Icons.email_outlined,
                  iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEBF3FF),
                  iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF358CED),
                  title: 'Par E-mail',
                  subtitle: 'support@eveilkid.com',
                  onTap: () {
                    Navigator.pop(context);
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'E-mail du support : support@eveilkid.com',
                    );
                  },
                ),
                AppSpacing.verticalSm,
                _buildContactOption(
                  theme: theme,
                  icon: Icons.phone_in_talk_outlined,
                  iconBg: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F8F5),
                  iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF39C0AD),
                  title: 'Par Téléphone',
                  subtitle: '+223 70 00 00 00 / 60 00 00 00',
                  onTap: () {
                    Navigator.pop(context);
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'Numéro du support : +223 70 00 00 00',
                    );
                  },
                ),
                AppSpacing.verticalSm,
                _buildContactOption(
                  theme: theme,
                  icon: Icons.chat_bubble_outline_rounded,
                  iconBg: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  iconColor: theme.colorScheme.primary,
                  title: 'Discussion WhatsApp',
                  subtitle: 'Réponse rapide en moins de 15 min',
                  onTap: () {
                    Navigator.pop(context);
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'Ouverture du support WhatsApp...',
                    );
                  },
                ),
                AppSpacing.verticalSm,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required ThemeData theme,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showFaqDetailModal(String question, String answer) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalMd,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: Text(
                        question,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: theme.textTheme.titleLarge?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Text(
                  answer,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ??
                        theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                AppSpacing.verticalLg,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: const Text(
                      'J\'ai compris',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Aide et support',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero / Support Card ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.surface,
                          theme.colorScheme.surfaceContainerHighest,
                        ]
                      : const [
                          Color(0xFFF3F5FC),
                          Color(0xFFF8F9FE),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : theme.colorScheme.primary)
                        .withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Illustration Avatar
                  _buildSupportIllustration(theme, isDark),
                  AppSpacing.horizontalMd,
                  // Text & Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Besoin d’aide ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nous sommes là pour vous aider',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.verticalMd,
                        ElevatedButton(
                          onPressed: _showContactModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 2,
                            shadowColor: theme.colorScheme.primary
                                .withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Nous contacter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // ── Section Title ──
            Text(
              'Questions fréquentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleMedium?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalMd,

            // ── FAQ Card Container ──
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.textPrimary)
                        .withValues(alpha: isDark ? 0.25 : 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: List.generate(_faqItems.length, (index) {
                    final item = _faqItems[index];
                    final isExpanded = _expandedIndex == index;
                    final isLast = index == _faqItems.length - 1;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
                          onLongPress: () {
                            _showFaqDetailModal(item['question']!, item['answer']!);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['question']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textTheme.bodyLarge?.color ??
                                          theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.25 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: theme.iconTheme.color
                                            ?.withValues(alpha: 0.5) ??
                                        theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 18,
                              right: 18,
                              bottom: 16,
                            ),
                            child: Text(
                              item['answer']!,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.8) ??
                                    theme.colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildSupportIllustration(ThemeData theme, bool isDark) {
    return Container(
      width: 105,
      height: 115,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Positioned(
            bottom: 0,
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Character representation
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Headset band
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3.5,
                      ),
                    ),
                  ),
                  // Avatar Head
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFFD1A9),
                    child: Icon(
                      Icons.face_3_rounded,
                      size: 26,
                      color: Color(0xFF4A2810),
                    ),
                  ),
                  // Headset earpieces
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 8,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Laptop base
              Container(
                width: 58,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF93C5FD),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
