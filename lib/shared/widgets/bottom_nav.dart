import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:daily_habits/config/theme.dart';

/// Enhanced bottom navigation bar with animations
class EnhancedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[
      Icons.dashboard_rounded,
      Icons.list_alt_rounded,
      Icons.notifications_rounded,
      Icons.person_rounded,
    ];

    final labels = [
      'dashboard'.tr(),
      'habits'.tr(),
      'notifications'.tr(),
      'profile'.tr(),
    ];

    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        final color = isActive ? AppTheme.primaryColor : Colors.grey[600];
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconList[index],
              size: isActive ? 28 : 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                color: color,
                fontSize: isActive ? 12 : 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      activeIndex: currentIndex,
      splashColor: AppTheme.primaryColor.withOpacity(0.2),
      splashSpeedInMilliseconds: 300,
      notchSmoothness: NotchSmoothness.defaultEdge,
      gapLocation: GapLocation.none,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: onTap,
      shadow: BoxShadow(
        offset: const Offset(0, -2),
        blurRadius: 12,
        spreadRadius: 0.5,
        color: Colors.grey.withOpacity(0.3),
      ),
      elevation: 8,
    );
  }
}
