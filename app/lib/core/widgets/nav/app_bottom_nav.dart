import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BottomNavItemData {
  const BottomNavItemData({
    required this.emoji,
    required this.label,
    this.tabKey,
  });

  /// Emoji-style icon to match the mockup (🏠🗓📄🔔👤).
  final String emoji;
  final String label;

  /// Optional stable key for the tab, so tests can tap it reliably (see core/keys.dart).
  final Key? tabKey;
}

/// Matrix that turns the emoji grayscale (for inactive tabs) — reproduces the
/// mockup's `filter: grayscale(1)` effect.
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// 5-tab bottom navigation (Home, Appointments, Results, Notifications, Profile) —
/// see ui-ux-app-benh-nhan.md section 3.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav(
      {super.key,
      required this.items,
      required this.currentIndex,
      required this.onTap});

  final List<BottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderCard)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              final emoji =
                  Text(item.emoji, style: const TextStyle(fontSize: 21));
              return Expanded(
                child: InkWell(
                  key: item.tabKey,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selected
                          ? emoji
                          : Opacity(
                              opacity: 0.55,
                              child: ColorFiltered(
                                colorFilter:
                                    const ColorFilter.matrix(_grayscaleMatrix),
                                child: emoji,
                              ),
                            ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primaryDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
