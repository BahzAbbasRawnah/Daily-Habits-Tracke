import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/features/notifications/providers/notification_provider.dart';
import 'package:daily_habits/features/notifications/widgets/empty_notifications.dart';
import 'package:daily_habits/features/notifications/widgets/notification_filter.dart';
import 'package:daily_habits/features/notifications/widgets/notification_item.dart';

/// Notifications screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  List<NotificationType> _selectedTypes = NotificationType.values.toList();
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }
  
  /// Fetch notifications
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.fetchNotifications();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => NotificationFilter(
        selectedTypes: _selectedTypes,
        startDate: _startDate,
        endDate: _endDate,
        onApplyFilter: (types, startDate, endDate) {
          setState(() {
            _selectedTypes = types;
            _startDate = startDate;
            _endDate = endDate;
          });
        },
        onResetFilter: _resetFilters,
      ),
    );
  }
  
  /// Reset filters
  void _resetFilters() {
    setState(() {
      _selectedTypes = NotificationType.values.toList();
      _startDate = null;
      _endDate = null;
    });
  }
  
  /// Get filtered notifications
  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> notifications) {
    // Filter by type
    var filtered = notifications.where((notification) => 
        _selectedTypes.contains(notification.type)).toList();
    
    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((notification) => 
          notification.createdAt.isAfter(_startDate!) && 
          notification.createdAt.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    
    return filtered;
  }
  
  /// Group notifications by date
  Map<String, List<NotificationModel>> _groupNotificationsByDate(List<NotificationModel> notifications) {
    final groupedNotifications = <String, List<NotificationModel>>{};
    
    for (final notification in notifications) {
      final date = notification.getFormattedDate();
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }
    
    return groupedNotifications;
  }
  
  /// Mark all notifications as read
  Future<void> _markAllAsRead() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (notificationProvider.unreadCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no_unread_notifications'.tr()),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    await notificationProvider.markAllAsRead();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.done_all, color: Colors.white),
              const SizedBox(width: 12),
              Text('all_notifications_marked_read'.tr()),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Delete all notifications
  Future<void> _deleteAllNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (notificationProvider.notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no_notifications_to_delete'.tr()),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Text('deleteAllNotifications'.tr()),
          ],
        ),
        content: Text('deleteAllNotificationsConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'delete'.tr(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final count = notificationProvider.notifications.length;
      await notificationProvider.deleteAllNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_sweep, color: Colors.white),
                const SizedBox(width: 12),
                Text('deleted_notifications'.tr(args: [count.toString()])),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    final filteredNotifications = _getFilteredNotifications(notifications);
    final groupedNotifications = _groupNotificationsByDate(filteredNotifications);
    final isFiltered = _selectedTypes.length < NotificationType.values.length || 
                       _startDate != null || 
                       _endDate != null;
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.streakColor,
        title: Text(
          'notifications'.tr(),
          style: const TextStyle(
            color: AppTheme.surfaceLightColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  color: AppTheme.surfaceLightColor,
                ),
                if (isFiltered)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
          
          // More options button
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppTheme.surfaceLightColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'delete_all') {
                _deleteAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text('markAllAsRead'.tr()),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 20, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Text('deleteAll'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : notifications.isEmpty
              ? EmptyNotifications(
                  onRefresh: _fetchNotifications,
                )
              : filteredNotifications.isEmpty
                  ? EmptyNotifications(
                      isFiltered: true,
                      onResetFilter: _resetFilters,
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      color: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: groupedNotifications.length * 2, // For date headers and notification groups
                        itemBuilder: (context, index) {
                          // Date headers are at even indices, notification groups at odd indices
                          if (index.isEven) {
                            final dateIndex = index ~/ 2;
                            if (dateIndex >= groupedNotifications.length) return const SizedBox.shrink();
                            
                            final date = groupedNotifications.keys.elementAt(dateIndex);
                            return NotificationDateHeader(date: date);
                          } else {
                            final dateIndex = index ~/ 2;
                            if (dateIndex >= groupedNotifications.length) return const SizedBox.shrink();
                            
                            final date = groupedNotifications.keys.elementAt(dateIndex);
                            final dateNotifications = groupedNotifications[date]!;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                children: dateNotifications.map((notification) => 
                                  NotificationItem(
                                    notification: notification,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.notificationDetail,
                                        arguments: notification.id,
                                      );
                                      
                                      // Mark as read when tapped
                                      if (!notification.isRead) {
                                        notificationProvider.markAsRead(notification.id);
                                      }
                                    },
                                    onMarkAsRead: !notification.isRead
                                        ? () => notificationProvider.markAsRead(notification.id)
                                        : null,
                                    onDelete: () => notificationProvider.deleteNotification(notification.id),
                                  ),
                                ).toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
    );
  }
}
