import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../../patient_profiles/presentation/widgets/profile_switcher_sheet.dart';
import '../../data/models/home_dashboard.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 14) return 'Chào buổi trưa';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final profile = ref.watch(activeProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeDashboardProvider),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                greeting: _greeting,
                name: profile?.fullName ?? '...',
                initials: profile?.initials ?? '',
                unreadCount: unreadCount,
                onAvatarTap: () => ProfileSwitcherSheet.open(context),
                onBellTap: () => context.go(AppRoutes.notifications),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: AsyncValueView<HomeDashboard>(
                  value: dashboardAsync,
                  onRetry: () => ref.invalidate(homeDashboardProvider),
                  loadingBuilder: (_) => const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SkeletonListTile(),
                  ),
                  data: (context, dashboard) => Column(
                    children: [
                      const SizedBox(height: 4),
                      if (dashboard.todayAppointment != null)
                        Transform.translate(
                          offset: const Offset(0, -36),
                          child: _TodayAppointmentCard(
                              appointment: dashboard.todayAppointment!),
                        ),
                      _ShortcutsGrid(
                          offsetTop: dashboard.todayAppointment != null),
                      if (dashboard.reminder != null) ...[
                        const SizedBox(height: 22),
                        const _SectionTitle('Nhắc hôm nay'),
                        const SizedBox(height: 10),
                        _ReminderCard(reminder: dashboard.reminder!),
                      ],
                      if (dashboard.newResult != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const _SectionTitle('Kết quả mới'),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.results),
                              child: Text(
                                'Xem tất cả ›',
                                style: AppTypography.bodySecondary.copyWith(
                                    color: AppColors.primary, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _NewResultCard(result: dashboard.newResult!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.name,
    required this.initials,
    required this.unreadCount,
    required this.onAvatarTap,
    required this.onBellTap,
  });

  final String greeting;
  final String name;
  final String initials;
  final int unreadCount;
  final VoidCallback onAvatarTap;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 56),
      decoration: const BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Row(
              children: [
                AppAvatar(
                  initials: initials,
                  background: Colors.white,
                  foreground: AppColors.primaryDark,
                  ringColor: AppColors.greenAvatarRing,
                  size: 46,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting 👋',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8))),
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.expand_more,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onBellTap,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 20),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primaryDark, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayAppointmentCard extends StatelessWidget {
  const _TodayAppointmentCard({required this.appointment});
  final TodayAppointmentSummary appointment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(
                    label: appointment.timeLabel, tone: StatusTone.success),
                const SizedBox(width: 8),
                StatusBadge(
                    label: appointment.statusLabel, tone: StatusTone.warning),
              ],
            ),
            const SizedBox(height: 10),
            Text(appointment.title, style: AppTypography.titleSmall),
            const SizedBox(height: 3),
            Text(appointment.doctorAndRoom,
                style: AppTypography.caption.copyWith(fontSize: 15)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Check-in',
                    height: 46,
                    onPressed: () => context.push(AppRoutes.checkin),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Chi tiết',
                    height: 46,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context
                        .push(AppRoutes.appointmentDetailPath(appointment.id)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutsGrid extends StatelessWidget {
  const _ShortcutsGrid({required this.offsetTop});
  final bool offsetTop;

  // Emoji + background colors match the mockup (📅 green, 📄 pink, 💊 yellow, 💳 blue).
  static const _shortcuts = [
    (emoji: '📅', label: 'Đặt lịch', bg: AppColors.greenTint),
    (emoji: '📄', label: 'Kết quả', bg: AppColors.accentTint),
    (emoji: '💊', label: 'Đơn thuốc', bg: AppColors.warningTint),
    (emoji: '💳', label: 'Thanh toán', bg: AppColors.infoTint),
  ];

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push(AppRoutes.bookAppointment);
        break;
      case 1:
        context.go(AppRoutes.results);
        break;
      case 2:
        context.push(AppRoutes.medicationReminders);
        break;
      case 3:
        context.push(AppRoutes.payments);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetTop ? -20 : 0),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
        children: List.generate(_shortcuts.length, (i) {
          final s = _shortcuts[i];
          return AppCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            onTap: () => _onTap(context, i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: s.bg, borderRadius: BorderRadius.circular(14)),
                  child: Text(s.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 8),
                Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBody),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});
  final MedicationReminderSummary reminder;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.medicationReminders),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(13)),
            child: const Text('💊', style: TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title,
                    style: AppTypography.bodyBold.copyWith(fontSize: 15.5)),
                Text(reminder.subtitle,
                    style: AppTypography.caption.copyWith(fontSize: 14)),
              ],
            ),
          ),
          Text(
            '${reminder.remainingCount} nhắc ›',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _NewResultCard extends StatelessWidget {
  const _NewResultCard({required this.result});
  final NewResultSummary result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.resultDetailPath(result.id)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(13)),
            child: const Text('📄', style: TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.title,
                    style: AppTypography.bodyBold.copyWith(fontSize: 15.5)),
                Text(result.subtitle,
                    style: AppTypography.caption.copyWith(fontSize: 14)),
              ],
            ),
          ),
          const UnreadDot(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.bodyBold.copyWith(fontSize: 16));
  }
}
