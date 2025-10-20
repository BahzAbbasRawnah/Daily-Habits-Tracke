import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:daily_habits/features/achievements/providers/achievement_provider.dart';
import 'package:daily_habits/features/achievements/models/achievement_model.dart';

/// Achievements screen showing unlocked and locked achievements
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadAchievements(1);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'achievements'.tr(),
        showBackButton: false,
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading achievements',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.refresh(1),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress Overview
              _buildProgressOverview(provider),
              
              // Category Tabs
              _buildCategoryTabs(),
              
              // Achievement List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(1),
                  color: AppTheme.primaryColor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementList(provider.achievements),
                      _buildAchievementList(provider.getAchievementsByType(AchievementType.streak)),
                      _buildAchievementList(provider.getAchievementsByType(AchievementType.completion)),
                      _buildAchievementList(provider.getAchievementsByType(AchievementType.perfect)),
                      _buildAchievementList(provider.getAchievementsByType(AchievementType.habits)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(AchievementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat(
                '${provider.unlockedCount}',
                'unlocked'.tr(),
                Icons.emoji_events,
              ),
              _buildOverviewStat(
                '${provider.totalAchievements}',
                'total'.tr(),
                Icons.stars,
              ),
              _buildOverviewStat(
                '${provider.completionPercentage.toStringAsFixed(0)}%',
                'complete'.tr(),
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: provider.completionPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.grey[100],
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.primaryColor,
        tabs: [
          Tab(text: 'all'.tr()),
          Tab(text: 'streak'.tr()),
          Tab(text: 'completion_achievements'.tr()),
          Tab(text: 'perfect_achievements'.tr()),
          Tab(text: 'habits_achievements'.tr()),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'no_achievements_category'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Separate unlocked and locked
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unlocked.isNotEmpty) ...[
          _buildSectionHeader('${'unlocked'.tr()} (${unlocked.length})'),
          const SizedBox(height: 12),
          ...unlocked.map((achievement) => _buildAchievementCard(achievement, true)),
          const SizedBox(height: 24),
        ],
        if (locked.isNotEmpty) ...[
          _buildSectionHeader('${'in_progress'.tr()} (${locked.length})'),
          const SizedBox(height: 12),
          ...locked.map((achievement) => _buildAchievementCard(achievement, false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    final color = _parseColor(achievement.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: () => _showAchievementDialog(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              // Achievement Badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked ? color.withOpacity(0.2) : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: isUnlocked ? null : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Achievement Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? color : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'more_to_unlock'.tr().replaceAll('{count}', '${achievement.remaining}'),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status Icon
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 32,
                )
              else
                Icon(
                  Icons.lock_outline,
                  color: Colors.grey[400],
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDialog(Achievement achievement) {
    final color = _parseColor(achievement.color);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Progress
              if (!achievement.isUnlocked) ...[
                LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${achievement.current} / ${achievement.target}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'more_to_unlock'.tr().replaceAll('{count}', '${achievement.remaining}'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'unlocked_achievement'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (achievement.unlockedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'on_date'.tr().replaceAll('{date}', DateFormat('MMM d, yyyy').format(achievement.unlockedAt!)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              
              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('close'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }
}
