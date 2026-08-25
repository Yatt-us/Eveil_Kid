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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activer les notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Switch(
                    value: _enableAllNotifications,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight.withValues(
                      alpha: 0.5,
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
            const Text(
              'Recevoir des notifications pour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSm,

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  _buildNotificationTile(
                    title: 'Activités et défis',
                    icon: Icons.notifications_rounded,
                    iconBg: const Color(0xFF00BFA5),
                    iconColor: AppColors.white,
                    value: _notifActivites,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifActivites = v)
                        : null,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildNotificationTile(
                    title: 'Nouveaux jouets',
                    icon: Icons.star_rounded,
                    iconBg: const Color(0xFFFFE0DB),
                    iconColor: const Color(0xFFFF6D00),
                    value: _notifJouets,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifJouets = v)
                        : null,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildNotificationTile(
                    title: 'Tutoriels',
                    icon: Icons.play_arrow_rounded,
                    iconBg: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF2979FF),
                    value: _notifTutoriels,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifTutoriels = v)
                        : null,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildNotificationTile(
                    title: 'Nouvelles commandes',
                    icon: Icons.calendar_month_rounded,
                    iconBg: const Color(0xFF00E5FF),
                    iconColor: const Color(0xFFD500F9),
                    value: _notifCommandes,
                    onChanged: _enableAllNotifications
                        ? (v) => setState(() => _notifCommandes = v)
                        : null,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildNotificationTile(
                    title: 'Promotions',
                    icon: Icons.campaign_rounded,
                    iconBg: const Color(0xFFBCAAA4),
                    iconColor: const Color(0xFFFFD600),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight.withValues(alpha: 0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
