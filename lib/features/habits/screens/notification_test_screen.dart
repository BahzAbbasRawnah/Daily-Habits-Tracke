import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../config/theme.dart';
import '../services/notification_service.dart';
import '../services/reminder_manager_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  bool _isLoading = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final manager = ReminderManagerService();
      final count = await manager.getPendingNotificationsCount();
      setState(() {
        _pendingCount = count;
      });
    } catch (e) {
      debugPrint('Error loading pending count: $e');
    }
  }

  Future<void> _testImmediateNotification() async {
    setState(() => _isLoading = true);

    try {
      final notificationService = NotificationService();
      await notificationService.showImmediateTestNotification(
        '🔔 Test notification at ${DateTime.now().toString().substring(11, 16)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification_sent'.tr()),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testScheduledNotification() async {
    setState(() => _isLoading = true);

    try {
      final manager = ReminderManagerService();
      final permissionGranted = await manager.arePermissionsGranted();

      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('permissions_not_granted'.tr()),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await manager.showTestNotification('Test Habit', 999);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification_scheduled'.tr()),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadPendingCount();
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showPendingNotifications() async {
    try {
      final notificationService = NotificationService();
      final pending = await notificationService.getPendingNotifications();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('pending_notifications'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final n = pending[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text('${n.id}',
                          style: TextStyle(color: AppTheme.primaryColor)),
                    ),
                    title: Text(n.title ?? 'no_title'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(n.body ?? 'no_body'.tr()),
                    dense: true,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final manager = ReminderManagerService();
      final permissionGranted = await manager.arePermissionsGranted();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('notification_permissions'.tr()),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: permissionGranted
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: permissionGranted ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      permissionGranted ? Icons.check_circle : Icons.error,
                      color: permissionGranted ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        permissionGranted
                            ? 'all_permissions_granted'.tr()
                            : 'permissions_required'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: permissionGranted
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (permissionGranted) ...[
                  const SizedBox(height: 12),
                  Text('✅ ${'notification_permission'.tr()}: Granted',
                      style: TextStyle(color: Colors.green.shade700)),
                  const SizedBox(height: 4),
                  Text('✅ ${'exact_alarm_permission'.tr()}: Granted',
                      style: TextStyle(color: Colors.green.shade700)),
                ] else ...[
                  const SizedBox(height: 12),
                  Text('permissions_enable_notifications'.tr(),
                      style: TextStyle(color: Colors.orange.shade700)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
            if (!permissionGranted)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await manager.requestPermissions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text('request_permissions'.tr()),
              ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notification_test'.tr()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.primaryColor.withOpacity(0.6),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_active,
                        size: 56, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'test_notification_system'.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${'pending_notifications_colon'.tr()} $_pendingCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Immediate Notification Test
            _buildTestButton(
              icon: Icons.send,
              title: 'test_immediate_notification'.tr(),
              subtitle: 'test_immediate_notification_desc'.tr(),
              color: Colors.green,
              onTap: _testImmediateNotification,
            ),
            const SizedBox(height: 16),

            // Scheduled Notification Test
            _buildTestButton(
              icon: Icons.schedule,
              title: 'test_scheduled_notification'.tr(),
              subtitle: 'test_scheduled_notification_desc'.tr(),
              color: Colors.orange,
              onTap: _testScheduledNotification,
            ),
            const SizedBox(height: 16),

            // Check Permissions
            _buildActionButton(
              icon: Icons.security,
              title: 'check_permissions'.tr(),
              subtitle: 'check_permissions_desc'.tr(),
              onTap: _checkPermissions,
            ),
            const SizedBox(height: 16),

            // Show Pending Notifications
            _buildActionButton(
              icon: Icons.list,
              title: 'view_pending_notifications'.tr(),
              subtitle: 'view_pending_notifications_desc'.tr(),
              onTap: _showPendingNotifications,
            ),
            const SizedBox(height: 16),

            // Refresh Button
            TextButton.icon(
              onPressed: () {
                _loadPendingCount();
              },
              icon: const Icon(Icons.refresh),
              label: Text('refresh_count'.tr()),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}
