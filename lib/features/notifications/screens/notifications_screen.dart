import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/features/notifications/providers/notification_provider.dart';
import 'package:daily_habits/features/notifications/widgets/empty_notifications.dart';
import 'package:daily_habits/features/notifications/widgets/notification_filter.dart';
import 'package:daily_habits/features/notifications/widgets/notification_item.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';

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
    await notificationProvider.markAllAsRead();
  }
  
  /// Delete all notifications
  Future<void> _deleteAllNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteAllNotifications'.tr()),
        content: Text('deleteAllNotificationsConfirmation'.tr()),
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
      await notificationProvider.deleteAllNotifications();
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
    
    return Scaffold(
        appBar: CustomAppBar(
        title: 'notifications'.tr(),
        showBackButton: true,
        actions: [
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (isFiltered)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            color: AppTheme.primaryColor,
            onPressed: _showFilterBottomSheet,
          ),
          
          // More options button
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.primaryColor,
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
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Text('markAllAsRead'.tr()),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20),
                    const SizedBox(width: 8),
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
                      child: ListView.builder(
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
                            
                            return Column(
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
                            );
                          }
                        },
                      ),
                    ),
    );
  }
}
