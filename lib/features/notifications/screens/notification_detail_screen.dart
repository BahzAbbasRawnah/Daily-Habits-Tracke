import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/features/notifications/providers/notification_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_provider.dart';

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
  Future<void> _handleNotificationAction(NotificationModel notification) async {
    switch (notification.type) {
      case NotificationType.habit:
        if (notification.data != null &&
            notification.data!.containsKey('habitId')) {
          final habitIdData = notification.data!['habitId'];
          final int habitId;
          
          if (habitIdData is int) {
            habitId = habitIdData;
          } else if (habitIdData is String) {
            habitId = int.tryParse(habitIdData) ?? 0;
          } else {
            habitId = 0;
          }
          
          if (habitId == 0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('invalid_habit_id'.tr()),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
            return;
          }
          
          // Show loading indicator
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          );
          
          try {
            // Load habits if not already loaded
            final habitProvider = Provider.of<HabitProvider>(context, listen: false);
            if (habitProvider.habits.isEmpty) {
              await habitProvider.loadHabits(1);
            }
            
            // Verify the habit exists
            habitProvider.habits.firstWhere(
              (h) => h.habitID == habitId,
              orElse: () => throw Exception('Habit not found'),
            );
            
            if (mounted) Navigator.pop(context);
            
            if (mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.habitDetails,
                arguments: habitId.toString(),
              );
            }
          } catch (e) {
            // Close loading dialog
            if (mounted) Navigator.pop(context);
            
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('habit_not_found'.tr()),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.streakColor,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppTheme.surfaceLightColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'details'.tr(),
          style: const TextStyle(
            color: AppTheme.surfaceLightColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.surfaceLightColor,
            onPressed: _deleteNotification,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification header card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: notification.type.color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          notification.type.color.withOpacity(0.15),
                          notification.type.color.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                notification.type.color.withOpacity(0.2),
                                notification.type.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            notification.type.icon,
                            color: notification.type.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Type and time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: notification.type.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notification.type.translationKey.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: notification.type.color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy • HH:mm')
                                        .format(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Message
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional details
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'additional_info'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleNotificationAction(notification),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getActionIcon(notification),
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getActionButtonText(notification),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
              context, 'streak'.tr(), '${data['streak']} ${'days'.tr()}'));
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
            '${data['streak']} ${'days'.tr()}',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
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

  /// Get the action icon based on notification type
  IconData _getActionIcon(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.habit:
        return Icons.visibility_rounded;

      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.system:
        return Icons.arrow_forward_rounded;
    }
  }
}
