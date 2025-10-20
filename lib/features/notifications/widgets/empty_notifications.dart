import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';

/// Widget for displaying when there are no notifications
class EmptyNotifications extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isFiltered;
  final VoidCallback? onResetFilter;

  const EmptyNotifications({
    Key? key,
    this.onRefresh,
    this.isFiltered = false,
    this.onResetFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              isFiltered ? Icons.filter_list : Icons.notifications_none,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isFiltered ? 'noNotificationsFound'.tr() : 'noNotifications'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              isFiltered
                  ? 'tryDifferentNotificationFilters'.tr()
                  : 'notificationsWillAppearHere'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action button
            if (isFiltered && onResetFilter != null)
              CustomButton(
                text: 'resetNotificationFilters'.tr(),
                onPressed: () => onResetFilter!(),
                icon: Icons.filter_list_off,
                type: ButtonType.secondary,
                textColor: AppTheme.primaryColor,
                width: 200,
              )
            else if (onRefresh != null)
              CustomButton(
                text: 'refresh'.tr(),
                onPressed: () => onRefresh!(),
                icon: Icons.refresh,
                type: ButtonType.secondary,
                textColor: AppTheme.primaryColor,
                width: 200,
              ),
          ],
        ),
      ),
    );
  }
}
