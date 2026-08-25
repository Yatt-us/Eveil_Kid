// lib/features/parents/presentation/pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_dialogs.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _enableAllNotifications = true;

  bool _notifActivites = true;
  bool _notifJouets = true;
  bool _notifTutoriels = true;
  bool _notifCommandes = true;
  bool _notifPromos = true;

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
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
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

            // ── Switch Activation Principale ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.textPrimary)
                        .withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activer les notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleMedium?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                  Switch(
                    value: _enableAllNotifications,
                    activeThumbColor: theme.colorScheme.primary,
                    activeTrackColor: theme.colorScheme.primary.withValues(
                      alpha: 0.4,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _enableAllNotifications = val;
                        if (!val) {
                          _notifActivites = false;
                          _notifJouets = false;
                          _notifTutoriels = false;
                          _notifCommandes = false;
                          _notifPromos = false;
                        } else {
                          _notifActivites = true;
                          _notifJouets = true;
                          _notifTutoriels = true;
                          _notifCommandes = true;
                          _notifPromos = true;
                        }
                      });
                      AppDialogs.showSnackBar(
                        context: context,
                        message: val
                            ? 'Notifications activées'
                            : 'Notifications désactivées',
                      );
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // ── Section Thématiques ──
            Text(
              'Recevoir des notifications pour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleMedium?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSm,

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
                        .withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildNotificationTile(
                    theme: theme,
                    title: 'Activités et défis',
                    icon: Icons.notifications_rounded,
                    iconBg: isDark
                        ? const Color(0xFF004D40)
                        : const Color(0xFFE0F2F1),
                    iconColor: isDark
                        ? const Color(0xFF80CBC4)
                        : const Color(0xFF00897B),
                    value: _notifActivites,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifActivites = v)
                        : null,
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildNotificationTile(
                    theme: theme,
                    title: 'Nouveaux jouets',
                    icon: Icons.star_rounded,
                    iconBg: isDark
                        ? const Color(0xFF4E2A00)
                        : const Color(0xFFFFE0DB),
                    iconColor: isDark
                        ? const Color(0xFFFFB74D)
                        : const Color(0xFFFF6D00),
                    value: _notifJouets,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifJouets = v)
                        : null,
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildNotificationTile(
                    theme: theme,
                    title: 'Tutoriels',
                    icon: Icons.play_arrow_rounded,
                    iconBg: isDark
                        ? const Color(0xFF1A237E)
                        : const Color(0xFFEDE7F6),
                    iconColor: isDark
                        ? const Color(0xFF90CAF9)
                        : const Color(0xFF2979FF),
                    value: _notifTutoriels,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifTutoriels = v)
                        : null,
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildNotificationTile(
                    theme: theme,
                    title: 'Nouvelles commandes',
                    icon: Icons.calendar_month_rounded,
                    iconBg: isDark
                        ? const Color(0xFF311B92)
                        : const Color(0xFFEDE9FE),
                    iconColor: isDark
                        ? const Color(0xFFCE93D8)
                        : const Color(0xFF763CD1),
                    value: _notifCommandes,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifCommandes = v)
                        : null,
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  _buildNotificationTile(
                    theme: theme,
                    title: 'Promotions',
                    icon: Icons.campaign_rounded,
                    iconBg: isDark
                        ? const Color(0xFF3E2723)
                        : const Color(0xFFFFF8E1),
                    iconColor: isDark
                        ? const Color(0xFFFFE082)
                        : const Color(0xFFFFA000),
                    value: _notifPromos,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifPromos = v)
                        : null,
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

  Widget _buildNotificationTile({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
