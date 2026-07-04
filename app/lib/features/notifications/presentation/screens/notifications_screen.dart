import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/notification_item.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final filter = ref.watch(notificationFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông báo', style: AppTypography.tabTitle),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                        label: 'Tất cả',
                        selected: filter == null,
                        onTap: () => _setFilter(ref, null)),
                    _FilterChip(
                      label: 'Lịch hẹn',
                      selected: filter == NotificationType.appointment,
                      onTap: () =>
                          _setFilter(ref, NotificationType.appointment),
                    ),
                    _FilterChip(
                      label: 'Kết quả',
                      selected: filter == NotificationType.result,
                      onTap: () => _setFilter(ref, NotificationType.result),
                    ),
                    _FilterChip(
                      label: 'Thuốc',
                      selected: filter == NotificationType.medication,
                      onTap: () => _setFilter(ref, NotificationType.medication),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AsyncValueView<List<NotificationItem>>(
                  value: notificationsAsync,
                  isEmpty: (data) => data.isEmpty,
                  onRetry: () => ref.invalidate(notificationsProvider),
                  emptyBuilder: (_) => const EmptyStateView(
                    icon: Icons.notifications_none_rounded,
                    title: 'Chưa có thông báo',
                    message:
                        'Thông báo về lịch hẹn, kết quả và nhắc thuốc sẽ hiện ở đây.',
                  ),
                  data: (context, items) => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _NotificationTile(item: items[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setFilter(WidgetRef ref, NotificationType? type) {
    ref.read(notificationFilterProvider.notifier).state = type;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppChip(label: label, selected: selected, onTap: onTap),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final NotificationItem item;

  void _onTap(BuildContext context) {
    switch (item.type) {
      case NotificationType.result:
        context.push(AppRoutes.resultDetailPath('r1'));
        break;
      case NotificationType.appointment:
        context.push(AppRoutes.appointmentDetailPath('a1'));
        break;
      case NotificationType.medication:
        context.push(AppRoutes.medicationReminders);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _onTap(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: item.iconBackground,
                borderRadius: BorderRadius.circular(13)),
            child: Text(item.emoji, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTypography.bodyBold.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(item.body,
                    style: AppTypography.caption
                        .copyWith(fontSize: 14, height: 1.45)),
                const SizedBox(height: 5),
                Text(item.time,
                    style: AppTypography.caption
                        .copyWith(fontSize: 12.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (item.unread)
            const Padding(padding: EdgeInsets.only(top: 5), child: UnreadDot()),
        ],
      ),
    );
  }
}
