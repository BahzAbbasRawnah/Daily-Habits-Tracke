import 'package:flutter/material.dart';
import 'package:daily_habits/config/theme.dart';

/// Custom app bar widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceLightColor,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppTheme.surfaceLightColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.surfaceLightColor,
                fontSize: 20,
              ),
            ),
      centerTitle: false,
      elevation: elevation,
      backgroundColor:   AppTheme.streakColor ,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.surfaceLightColor,
                ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}
