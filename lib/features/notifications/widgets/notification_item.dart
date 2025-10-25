import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';

/// Widget for displaying a notification item
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  
  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.RTL;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.only(
          left: isRtl ? 20 : 0,
          right: isRtl ? 0 : 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.errorColor.withOpacity(0.8),
              AppTheme.errorColor,
            ],
            begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
          return true;
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? Border.all(color: Colors.grey.shade200, width: 1)
              : Border.all(color: notification.type.color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: notification.isRead 
                  ? Colors.black.withOpacity(0.03)
                  : notification.type.color.withOpacity(0.1),
              blurRadius: notification.isRead ? 4 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: notification.isRead
                    ? null
                    : LinearGradient(
                        colors: [
                          notification.type.color.withOpacity(0.03),
                          notification.type.color.withOpacity(0.01),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          notification.type.color.withOpacity(0.15),
                          notification.type.color.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.type.icon,
                      color: notification.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Notification type badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: notification.type.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.type.translationKey.tr(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: notification.type.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Notification time
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.getRelativeTime(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Notification title
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Notification message
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Mark as read button (only for unread notifications)
                        if (!notification.isRead && onMarkAsRead != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: onMarkAsRead,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.done_rounded,
                                        size: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'markAsRead'.tr(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(left: 8, top: 4),
                      decoration: BoxDecoration(
                        color: notification.type.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: notification.type.color.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying a notification date header
class NotificationDateHeader extends StatelessWidget {
  final String date;
  
  const NotificationDateHeader({
    Key? key,
    required this.date,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.primaryColor.withOpacity(0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a notification badge
class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color? color;
  
  const NotificationBadge({
    Key? key,
    required this.count,
    this.size = 20,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
