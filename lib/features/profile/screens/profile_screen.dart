import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:daily_habits/shared/widgets/ai_chat_fab.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/features/auth/services/auth_service.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/core/providers/theme_provider.dart';
import 'package:daily_habits/features/profile/providers/user_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_provider.dart';
import 'package:daily_habits/features/habits/services/analytics_service.dart';
import 'package:daily_habits/utils/language_util.dart';

/// Profile screen for Daily Habit Tracker
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load user data and habits
  Future<void> _loadData() async {
    if (!mounted) return;
    
    await Future.wait([
      context.read<UserProvider>().fetchUser(),
      context.read<HabitProvider>().loadHabits(1),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'profile'.tr(),
        showBackButton: false,
        actions: [
          // Notifications icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.surfaceLightColor,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              // Badge for unread notifications
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<UserProvider, HabitProvider>(
        builder: (context, userProvider, habitProvider, child) {
          final user = userProvider.user;
          final habits = habitProvider.habits;
          final activeHabits = habits.where((h) => h.isActive).toList();
          
          // Calculate longest streak from all habits
          int longestStreak = 0;
          if (habits.isNotEmpty) {
            for (final habit in habits) {
              final insights = AnalyticsService.getHabitInsights([], habit);
              final currentStreak = insights['currentStreak'] as int? ?? 0;
              if (currentStreak > longestStreak) {
                longestStreak = currentStreak;
              }
            }
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                // Profile header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'Daily Habits User',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'member_since'.tr() + ' ${user?.createdAt != null ? DateFormat('MMMM yyyy').format(user!.createdAt!) : DateFormat('MMMM yyyy').format(DateTime.now())}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'total_habits'.tr(),
                        '${activeHabits.length}',
                        Icons.track_changes,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'streak'.tr(),
                        '$longestStreak',
                        Icons.local_fire_department,
                        AppTheme.streakColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Daily Streak Summary
                if (longestStreak > 0)
                  Card(
                    color: AppTheme.streakColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: AppTheme.streakColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'your_current_streak'.tr(),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$longestStreak ${'days_strong'.tr()} 🎯',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Settings Section
                _buildProfileSection(
                  'settings'.tr(),
                  [
                    _buildInlineLanguageSwitcher(),
                    _buildInlineThemeSwitcher(),
                    _buildProfileItem(
                      Icons.notifications_outlined,
                      'notifications'.tr(),
                      subtitle: 'manage_your_reminders'.tr(),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                    ),
                    _buildProfileItem(
                      Icons.info_outline,
                      'about_app'.tr(),
                      subtitle: 'app_info_and_team'.tr(),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Analytics Section
                _buildProfileSection(
                  'analytics'.tr(),
                  [
                    _buildProfileItem(
                      Icons.analytics_outlined,
                      'analytics'.tr(),
                      subtitle: 'view_your_progress'.tr(),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
                    ),
                    _buildProfileItem(
                      Icons.emoji_events_outlined,
                      'achievements'.tr(),
                      subtitle: 'your_milestones'.tr(),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.achievements),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout section
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red[600]),
                    title: Text(
                      'logout'.tr(),
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'sign_out_of_your_account'.tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: _showLogoutDialog,
                  ),
                ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Build inline language switcher with bottom sheet
  Widget _buildInlineLanguageSwitcher() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentLocale = context.locale.languageCode;
        final languageName = currentLocale == 'en' ? 'English' : 'العربية';

        return ListTile(
          leading: const Icon(Icons.language, color: AppTheme.primaryColor),
          title: Text('language'.tr()),
          subtitle: Text(
            languageName,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showLanguageBottomSheet,
        );
      },
    );
  }

  /// Build inline theme switcher with bottom sheet
  Widget _buildInlineThemeSwitcher() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        String themeName;
        IconData themeIcon;

        switch (themeProvider.themeMode) {
          case ThemeMode.light:
            themeName = 'lightMode'.tr();
            themeIcon = Icons.light_mode;
            break;
          case ThemeMode.dark:
            themeName = 'darkMode'.tr();
            themeIcon = Icons.dark_mode;
            break;
          case ThemeMode.system:
            themeName = 'systemDefault'.tr();
            themeIcon = Icons.settings_suggest;
            break;
        }

        return ListTile(
          leading: Icon(themeIcon, color: AppTheme.primaryColor),
          title: Text('theme'.tr()),
          subtitle: Text(
            themeName,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showThemeBottomSheet,
        );
      },
    );
  }

  /// Show language selection bottom sheet
  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(
              title: 'English',
              languageCode: 'en',
              flag: '🇺🇸',
              isSelected: context.locale.languageCode == 'en',
              onTap: () {
                LanguageUtil.changeLanguage(context, 'en');
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              },
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              title: 'العربية',
              languageCode: 'ar',
              flag: '🇸🇦',
              isSelected: context.locale.languageCode == 'ar',
              onTap: () {
                LanguageUtil.changeLanguage(context, 'ar');
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Show theme selection bottom sheet
  void _showThemeBottomSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'theme'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              title: 'lightMode'.tr(),
              icon: Icons.light_mode,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              title: 'darkMode'.tr(),
              icon: Icons.dark_mode,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              title: 'systemDefault'.tr(),
              icon: Icons.settings_suggest,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build language option widget
  Widget _buildLanguageOption({
    required String title,
    required String languageCode,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  /// Build theme option widget
  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  /// Show enhanced logout dialog with confirmation
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            const SizedBox(width: 12),
            Text('logout'.tr()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('logoutConfirmation'.tr()),
            const SizedBox(height: 12),
            Text(
              'see_you_tomorrow'.tr() + ' 👋',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Perform complete logout process
  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );

      // Clear user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefUserToken);
      await prefs.remove(AppConstants.prefUserId);
      await prefs.remove(AppConstants.prefUserRole);
      
      // Clear auth state
      await AuthService.clearLoginState();

      // Clear user provider
      if (mounted) {
        context.read<UserProvider>().clearUser();
      }

      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Navigate to login screen and clear all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('logged_out_successfully'.tr()),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}