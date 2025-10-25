import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'about_app'.tr(),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.track_changes,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'appName'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'version_1_0_0'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About Section
            _buildSectionTitle('about_the_app'.tr()),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'about_app_description'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Development Team Section
            _buildSectionTitle('development_team'.tr()),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTeamMember(
                      'JASSER FARAJ AL-MAZROEI',
                      '2240201',
                    ),
                    const Divider(height: 24),
                    _buildTeamMember(
                      'HUSAM MOHAMMED AL-SAIDI',
                      '2240300',
                    ),
                    const Divider(height: 24),
                    _buildTeamMember(
                      'ABDULAZIZ ATTI ALTAYARI',
                      '2240171',
                    ),
                    const Divider(height: 24),
                    _buildTeamMember(
                      'ALWALEED ABDULAZIZ ATAFI',
                      '2242236',
                    ),
                    const Divider(height: 24),
                    _buildTeamMember(
                      'HATEM TALAL BAMAHFOUZ',
                      '2143381',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features Section
            _buildSectionTitle('key_features'.tr()),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      Icons.track_changes,
                      'feature_habit_tracking'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.notifications_active,
                      'feature_reminders'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.analytics,
                      'feature_analytics'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.emoji_events,
                      'feature_achievements'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.language,
                      'feature_multilingual'.tr(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Copyright
            Center(
              child: Text(
                '© 2025 ${'appName'.tr()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTeamMember(String name, String id) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ID: $id',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
