import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_strings.dart';
import '../../models/notification_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_toast.dart';

/// Notification centre.
///
/// The list is written by the admin from the API's Swagger UI; the app only
/// reads it and remembers what has been opened, which is what the dot on the
/// bell counts.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    // Loaded after the screen is mounted so the list never shows the previous
    // user's notifications while the request is in flight.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppProvider>().loadNotifications();
    });
  }

  Future<void> _handleMarkAll(AppProvider provider) async {
    if (_markingAll) return;
    final l10n = context.l10n;
    setState(() => _markingAll = true);
    final ok = await provider.markAllNotificationsRead();
    if (!mounted) return;
    setState(() => _markingAll = false);
    if (ok) {
      AppToast.success(l10n.t('notifications.allRead'), context: context);
    } else {
      AppToast.error(
        provider.dataError ?? l10n.t('notifications.failed'),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<AppProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.t('notifications.title')),
        backgroundColor: Colors.transparent,
        actions: [
          if (provider.unreadNotifications > 0)
            TextButton(
              onPressed: _markingAll ? null : () => _handleMarkAll(provider),
              child: _markingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.t('notifications.markAllRead'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 60,
                    color: AppTheme.textHint.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('notifications.empty'),
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: provider.loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildTile(
                  context,
                  notifications[index],
                ),
              ),
            ),
    );
  }

  Widget _buildTile(BuildContext context, AppNotification notification) {
    return GestureDetector(
      onTap: () => context.read<AppProvider>().markNotificationRead(notification.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(color: AppTheme.primary.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  notification.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _NotificationIcon(),
                ),
              )
            else
              const _NotificationIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${notification.date.day}/${notification.date.month}/${notification.date.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.campaign_rounded, color: AppTheme.primary),
    );
  }
}
