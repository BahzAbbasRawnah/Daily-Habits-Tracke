import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/core/providers/theme_provider.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';
import 'package:daily_habits/shared/widgets/custom_card.dart';
import 'package:daily_habits/utils/language_util.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // Logout user
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    // Clear user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserToken);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserRole);

    // Simulate logout delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Navigate to habits screen and clear all previous routes
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.habits,
        (route) => false,
      );
    }
  }

  // Show theme selection dialog
  void _showThemeSelectionDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('theme'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              title: 'lightMode'.tr(),
              icon: Icons.light_mode,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              title: 'darkMode'.tr(),
              icon: Icons.dark_mode,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              title: 'systemDefault'.tr(),
              icon: Icons.settings_suggest,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show language selection dialog
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              title: 'english'.tr(),
              languageCode: 'en',
              isSelected: context.locale.languageCode == 'en',
              onTap: () {
                LanguageUtil.changeLanguage(context, 'en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              title: 'arabic'.tr(),
              languageCode: 'ar',
              isSelected: context.locale.languageCode == 'ar',
              onTap: () {
                LanguageUtil.changeLanguage(context, 'ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build theme option
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : Colors.grey.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  // Build language option
  Widget _buildLanguageOption({
    required String title,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : Colors.grey.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              languageCode == 'en' ? '🇺🇸' : '🇦🇪',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isRtl = LanguageUtil.isRtl(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: TextStyle(
            color: AppTheme.primaryDarkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppTheme.primaryDarkColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account section
                Text(
                  'accountSettings'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkColor,
                      ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.person_outline,
                        title: 'personalInformation'.tr(),
                        onTap: () {
                          // Navigate to personal information screen
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                      const Divider(),
                      _buildSettingsItem(
                        icon: Icons.security,
                        title: 'security'.tr(),
                        onTap: () {
                          // Navigate to security screen
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                      const Divider(),
                      _buildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'notificationPreferences'.tr(),
                        onTap: () {
                          // Navigate to notification preferences screen
                          Navigator.pushNamed(context, AppRoutes.profile);

                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance section
                Text(
                  'appearance'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkColor,
                      ),
                ),
                const SizedBox(height: 16),
                CustomCard(
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.language,
                        title: 'language'.tr(),
                        subtitle: context.locale.languageCode == 'en'
                            ? 'English'
                            : 'العربية',
                        onTap: _showLanguageSelectionDialog,
                      ),
                      const Divider(),
                      _buildSettingsItem(
                        icon: themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        title: 'theme'.tr(),
                        subtitle: themeProvider.themeMode == ThemeMode.system
                            ? 'systemDefault'.tr()
                            : themeProvider.isDarkMode
                                ? 'darkMode'.tr()
                                : 'lightMode'.tr(),
                        onTap: _showThemeSelectionDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout button
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
                    text: 'logout'.tr(),
                    onPressed: _logout,
                    isLoading: _isLoading,
                    type: ButtonType.primary,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
