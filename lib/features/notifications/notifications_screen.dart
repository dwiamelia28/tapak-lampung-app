import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/state_views.dart';
import '../../models/notification_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifikasi')),
        body: const NotificationsView(showHeader: false),
      );
}

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key, this.showHeader = true});
  final bool showHeader;

  IconData _icon(String type) {
    switch (type) {
      case 'fcm':
        return Icons.campaign;
      case 'achievement':
        return Icons.emoji_events;
      case 'chapter_unlock':
        return Icons.lock_open;
      case 'chapter_complete':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _open(BuildContext context, WidgetRef ref, NotificationModel n) async {
    if (!n.isRead) {
      try {
        await ref.read(firestoreServiceProvider).markNotificationRead(n.id);
      } catch (_) {}
    }
    if (!context.mounted) return;
    if (n.route.startsWith('/')) {
      context.push(n.route);
    } else if (n.type == 'achievement') {
      context.push('/progress');
    } else if (n.targetId.isNotEmpty) {
      context.push('/chapter/${n.targetId}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(onRetry: () => ref.invalidate(notificationsProvider)),
      data: (list) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Expanded(child: Text('Notifikasi', style: AppTheme.heading(26))),
                    if (unread > 0 && uid != null)
                      TextButton(
                        onPressed: () =>
                            ref.read(firestoreServiceProvider).markAllNotificationsRead(uid),
                        child: const Text('Tandai dibaca'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyView(
                      title: 'Belum ada notifikasi',
                      note: 'Selesaikan bab atau raih lencana, dan pemberitahuan akan muncul di sini.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final n = list[i];
                        return Material(
                          color: n.isRead ? Colors.white : AppColors.goldLight.withValues(alpha: .3),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _open(context, ref, n),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.sand, width: 1.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.terracotta.withValues(alpha: .14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(_icon(n.type), color: AppColors.terracotta),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        Text(n.body, style: const TextStyle(height: 1.35)),
                                        const SizedBox(height: 4),
                                        Text(formatDate(n.createdAt),
                                            style: const TextStyle(
                                                fontSize: 11, color: AppColors.brownSoft)),
                                      ],
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: const BoxDecoration(
                                          color: AppColors.terracotta, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
