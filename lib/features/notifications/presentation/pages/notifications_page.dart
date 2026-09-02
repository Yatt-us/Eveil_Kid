import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:eveilkid/features/notifications/models/notification_model.dart';
import 'package:eveilkid/features/notifications/providers/notification_provider.dart';
import 'package:eveilkid/features/notifications/repository/notification_repository.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  NotifType? _filterType; // null = Toutes
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _iconForType(NotifType type) {
    switch (type) {
      case NotifType.commande:
        return Icons.receipt_long_rounded;
      case NotifType.livraison:
        return Icons.local_shipping_rounded;
      case NotifType.nouveauJouet:
        return Icons.toys_rounded;
      case NotifType.promo:
        return Icons.local_offer_rounded;
      case NotifType.activite:
        return Icons.sports_esports_rounded;
      case NotifType.tutoriel:
        return Icons.play_circle_rounded;
      case NotifType.enfant:
        return Icons.child_care_rounded;
      case NotifType.systeme:
        return Icons.info_rounded;
    }
  }

  Color _colorForType(NotifType type) {
    switch (type) {
      case NotifType.commande:
        return const Color(0xFF8B5CF6);
      case NotifType.livraison:
        return const Color(0xFF3B82F6);
      case NotifType.nouveauJouet:
        return const Color(0xFF10B981);
      case NotifType.promo:
        return const Color(0xFFF59E0B);
      case NotifType.activite:
        return const Color(0xFFEC4899);
      case NotifType.tutoriel:
        return const Color(0xFF06B6D4);
      case NotifType.enfant:
        return const Color(0xFF84CC16);
      case NotifType.systeme:
        return const Color(0xFF6B7280);
    }
  }

  String _dateRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.12);

    final authState = ref.watch(authProvider);
    final userId = authState.utilisateur?.utilisateurId ?? '';
    final repo = ref.read(notificationRepositoryProvider);

    final notifAsync = ref.watch(notificationsStreamProvider(userId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          notifAsync.when(
            data: (notifs) {
              final nonLues = notifs.where((n) => !n.estLue).toList();
              if (nonLues.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () async {
                  await repo.marquerToutesCommeLues(userId);
                  if (context.mounted) {
                    AppDialogs.showSnackBar(
                      context: context,
                      message: 'Toutes les notifications ont été marquées comme lues.',
                    );
                  }
                },
                icon: Icon(Icons.done_all_rounded, size: 16, color: primaryColor),
                label: Text(
                  'Tout lire',
                  style: TextStyle(fontSize: 12.5, color: primaryColor, fontWeight: FontWeight.bold),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Non lues'),
          ],
        ),
      ),
      body: notifAsync.when(
        loading: () => _buildSkeletonLoader(theme, isDark),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger les notifications',
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        data: (toutes) {
          final nonLues = toutes.where((n) => !n.estLue).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotifList(
                notifs: toutes,
                emptyLabel: 'Aucune notification',
                emptySubLabel: 'Toutes vos activités apparaîtront ici.',
                repo: repo,
                userId: userId,
                theme: theme,
                isDark: isDark,
                dividerColor: dividerColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                showDeleteRead: true,
              ),
              _buildNotifList(
                notifs: nonLues,
                emptyLabel: 'Aucune notification non lue',
                emptySubLabel: 'Vous êtes à jour !',
                repo: repo,
                userId: userId,
                theme: theme,
                isDark: isDark,
                dividerColor: dividerColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                showDeleteRead: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotifList({
    required List<NotificationModel> notifs,
    required String emptyLabel,
    required String emptySubLabel,
    required NotificationRepository repo,
    required String userId,
    required ThemeData theme,
    required bool isDark,
    required Color dividerColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool showDeleteRead,
  }) {
    if (notifs.isEmpty) {
      return _buildEmptyState(theme, emptyLabel, emptySubLabel, textSecondary);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: notifs.length + (showDeleteRead ? 1 : 0),
      itemBuilder: (ctx, idx) {
        // Header "Supprimer les lues" (uniquement dans l'onglet "Toutes")
        if (showDeleteRead && idx == 0) {
          final luees = notifs.where((n) => n.estLue).toList();
          if (luees.isEmpty) {
            return const SizedBox(height: 4);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final ok = await AppDialogs.showConfirmDialog(
                      context: context,
                      title: 'Supprimer les notifications lues ?',
                      message:
                          'Ceci supprimera ${luees.length} notification(s) déjà lue(s) de façon définitive.',
                      confirmText: 'Supprimer',
                      cancelText: 'Annuler',
                      isDanger: true,
                    );
                    if (ok == true && context.mounted) {
                      await repo.supprimerToutesLesLues(userId);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                  label: Text(
                    'Supprimer les lues (${luees.length})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }

        final notif = notifs[showDeleteRead ? idx - 1 : idx];
        return _buildNotifCard(
          notif: notif,
          repo: repo,
          userId: userId,
          theme: theme,
          isDark: isDark,
          dividerColor: dividerColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      },
    );
  }

  Widget _buildNotifCard({
    required NotificationModel notif,
    required NotificationRepository repo,
    required String userId,
    required ThemeData theme,
    required bool isDark,
    required Color dividerColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final color = _colorForType(notif.type);
    final icon = _iconForType(notif.type);

    return Dismissible(
      key: Key(notif.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) async {
        await repo.supprimerNotification(userId, notif.notificationId);
      },
      child: GestureDetector(
        onTap: () async {
          // Marquer comme lue au tap
          if (!notif.estLue) {
            await repo.marquerCommeLue(userId, notif.notificationId);
          }
          // Navigation vers la destination si définie
          if (notif.routeDestination != null && context.mounted) {
            Navigator.of(context).pushNamed(notif.routeDestination!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.estLue
                ? theme.colorScheme.surface
                : color.withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notif.estLue
                  ? dividerColor
                  : color.withValues(alpha: isDark ? 0.35 : 0.25),
              width: notif.estLue ? 1.0 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône du type de notification
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.titre,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: notif.estLue ? FontWeight.w600 : FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Point de non-lecture
                        if (!notif.estLue)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.corps,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notif.type.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _dateRelative(notif.dateCreation),
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    String label,
    String sublabel,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(ThemeData theme, bool isDark) {
    final shimmerBase = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (ctx, idx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: shimmerBase,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 11,
                      width: 200,
                      decoration: BoxDecoration(
                        color: shimmerBase,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 18,
                      width: 70,
                      decoration: BoxDecoration(
                        color: shimmerBase,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
