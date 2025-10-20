import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:daily_habits/features/analytics/providers/analytics_provider.dart';
import 'package:daily_habits/features/analytics/models/analytics_model.dart';

/// Analytics screen showing habit statistics and insights
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'analytics'.tr(),
        showBackButton: false,
      ),
      body: Consumer<AnalyticsProvider>(
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
                    'Error loading analytics',
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

          final data = provider.analyticsData;

          return RefreshIndicator(
            onRefresh: () => provider.refresh(1),
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(provider),
                  const SizedBox(height: 24),

                  // Overview Stats
                  _buildOverviewStats(data),
                  const SizedBox(height: 24),

                  // Weekly Progress Chart
                  _buildSectionTitle('weekly_progress'.tr()),
                  const SizedBox(height: 16),
                  _buildProgressChart(data.weeklyProgress),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  if (data.categoryBreakdown.isNotEmpty) ...[
                    _buildSectionTitle('category_breakdown'.tr()),
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(data.categoryBreakdown),
                    const SizedBox(height: 24),
                  ],

                  // Top Habits
                  _buildSectionTitle('habit_statistics'.tr()),
                  const SizedBox(height: 16),
                  _buildHabitStats(provider.habitStats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(AnalyticsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodButton(
            '7 Days',
            provider.selectedPeriod == 7,
            () => provider.changePeriod(7, 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton(
            '30 Days',
            provider.selectedPeriod == 30,
            () => provider.changePeriod(30, 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton(
            '90 Days',
            provider.selectedPeriod == 90,
            () => provider.changePeriod(90, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(AnalyticsData data) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'total_habits'.tr(),
            '${data.totalHabits}',
            Icons.track_changes,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'completion'.tr(),
            '${data.completionRate.toStringAsFixed(0)}%',
            Icons.check_circle,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'streak'.tr(),
            '${data.currentStreak}',
            Icons.local_fire_department,
            AppTheme.streakColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(List<DailyProgress> progress) {
    if (progress.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'no_data_available'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < progress.length) {
                        return Text(
                          progress[value.toInt()].weekday,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: progress.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.percentage);
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, int> categories) {
    final total = categories.values.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categories.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHabitStats(List<HabitStats> stats) {
    if (stats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'no_habits_yet'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                stat.habitName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              stat.habitName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Completed ${stat.totalCompletions} times • ${stat.completionRate.toStringAsFixed(0)}% rate',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, size: 16, color: AppTheme.streakColor),
                    const SizedBox(width: 4),
                    Text(
                      '${stat.currentStreak}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.streakColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
}
