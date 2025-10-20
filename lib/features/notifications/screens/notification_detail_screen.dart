import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/features/notifications/providers/notification_provider.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_card.dart';

/// Notification detail screen
class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({
    Key? key,
    required this.notificationId,
  }) : super(key: key);

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  /// Mark the notification as read
  Future<void> _markAsRead() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.markAsRead(widget.notificationId);
  }

  /// Delete the notification
  Future<void> _deleteNotification() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteNotification'.tr()),
        content: Text('deleteNotificationConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'delete'.tr(),
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notificationProvider.deleteNotification(widget.notificationId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// Handle notification action based on type
  void _handleNotificationAction(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.habit:
        if (notification.data != null &&
            notification.data!.containsKey('habitId')) {
          Navigator.pushNamed(
            context,
            AppRoutes.habitDetails,
            arguments: notification.data!['habitId'] as String,
          );
        }
        break;
      
      case NotificationType.achievement:
        // Navigator.pushNamed(context, AppRoutes.achievements);
        break;
      case NotificationType.system:
        // No specific action for system notifications
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notification = notificationProvider.notifications.firstWhere(
      (n) => n.id == widget.notificationId,
      orElse: () => throw Exception('Notification not found'),
    );
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification.type.translationKey.tr(),
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppTheme.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorColor,
            onPressed: _deleteNotification,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification header
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: notification.type.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notification.type.icon,
                              color: notification.type.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            notification.type.translationKey.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: notification.type.color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm')
                            .format(notification.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notification title
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Notification message
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification details
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              Text(
                'details'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  children: _buildNotificationDetails(context, notification),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action button
            if (_hasAction(notification))
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(70),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: _getActionButtonText(notification),
                  onPressed: () => _handleNotificationAction(notification),
                  type: ButtonType.primary,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build notification details based on type
  List<Widget> _buildNotificationDetails(
      BuildContext context, NotificationModel notification) {
    final details = <Widget>[];
    final data = notification.data;
    if (data == null) return details;

    switch (notification.type) {
      case NotificationType.habit:
        if (data.containsKey('habitId')) {
          details.add(_buildDetailRow(
              context, 'habitId'.tr(), data['habitId'] as String));
        }
        if (data.containsKey('habitName')) {
          details.add(
              _buildDetailRow(context, 'habitName'.tr(), data['habitName'] as String));
        }
        if (data.containsKey('streak')) {
          details.add(_buildDetailRow(
              context, 'streak'.tr(), '${data['streak']} days'));
        }
        break;

      case NotificationType.achievement:
        if (data.containsKey('badgeName')) {
          details.add(_buildDetailRow(
              context, 'badge'.tr(), data['badgeName'] as String));
        }
        if (data.containsKey('streak')) {
          details.add(_buildDetailRow(
            context,
            'streak'.tr(),
            '${data['streak']} days',
          ));
        }
        break;
      case NotificationType.system:
        // No specific details for system notifications
        break;
    }

    return details;
  }

  /// Build a detail row
  Widget _buildDetailRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Check if the notification has an action
  bool _hasAction(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.habit:
        return notification.data != null &&
            notification.data!.containsKey('habitId');

      case NotificationType.achievement:
        return true;
      case NotificationType.system:
        return false;
    }
  }

  /// Get the action button text based on notification type
  String _getActionButtonText(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.habit:
        return 'viewHabit'.tr();

      case NotificationType.achievement:
        return 'viewAchievement'.tr();
      case NotificationType.system:
        return '';
    }
  }
}
