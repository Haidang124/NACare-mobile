import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/keys.dart';
import '../../../core/widgets/nav/app_bottom_nav.dart';

/// Shell holding the 5 tabs (Home, Appointments, Results, Notifications, Profile) —
/// ui-ux-app-benh-nhan.md section 3. Each branch keeps its own navigator/stack, so
/// switching tabs and coming back preserves the previous tab's scroll/navigation position.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    BottomNavItemData(emoji: '🏠', label: 'Trang chủ', tabKey: AppKeys.tabHome),
    BottomNavItemData(
        emoji: '🗓', label: 'Lịch khám', tabKey: AppKeys.tabAppointments),
    BottomNavItemData(
        emoji: '📄', label: 'Kết quả', tabKey: AppKeys.tabResults),
    BottomNavItemData(
        emoji: '🔔', label: 'Thông báo', tabKey: AppKeys.tabNotifications),
    BottomNavItemData(
        emoji: '👤', label: 'Cá nhân', tabKey: AppKeys.tabProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
