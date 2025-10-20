import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daily_habits/features/habits/providers/habit_provider.dart';
import 'package:daily_habits/features/habits/providers/habit_record_provider.dart';
import 'package:daily_habits/features/habits/widgets/habit_card.dart';
import 'package:daily_habits/shared/widgets/custom_app_bar.dart';
import 'package:daily_habits/shared/widgets/loading_indicator.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/habits/screens/habits_list_screen.dart';
import 'package:daily_habits/features/habits/screens/habit_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits(1);
      context.read<HabitRecordProvider>().loadTodayRecords(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'dashboard'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HabitsListScreen()),
            ),
          ),
        ],
      ),
      body: Consumer2<HabitProvider, HabitRecordProvider>(
        builder: (context, habitProvider, recordProvider, child) {
          if (habitProvider.isLoading) {
            return const LoadingIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(habitProvider, recordProvider),
                const SizedBox(height: 24),
                _buildProgressChart(recordProvider),
                const SizedBox(height: 24),
                _buildTodayHabits(habitProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(HabitProvider habitProvider, HabitRecordProvider recordProvider) {
    final totalHabits = habitProvider.habits.length;
    final activeHabits = habitProvider.habits.where((h) => h.isActive).length;
    final completedToday = recordProvider.todayRecords.where((r) => r.status == 'done').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'total_habits'.tr(),
            totalHabits.toString(),
            Icons.track_changes,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'completed_today'.tr(),
            completedToday.toString(),
            Icons.check_circle,
            AppTheme.successColor,
          ),
        ),
      ],
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

  Widget _buildProgressChart(HabitRecordProvider recordProvider) {
    // Get last 7 days of data
    final chartData = _getWeeklyChartData(recordProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'this_week'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                            return Text(
                              chartData[value.toInt()].day,
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHabits(HabitProvider provider) {
    final todayHabits = provider.habits.where((h) => h.isActive).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'today'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HabitsListScreen()),
              ),
              child: Text('view_all'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todayHabits.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('no_habits'.tr()),
              ),
            ),
          )
        else
          ...todayHabits.map((habit) => HabitCard(
            habit: habit,
            onTap: () => _navigateToHabitDetails(habit),
            showActions: false,
          )),
      ],
    );
  }

  void _navigateToHabitDetails(habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      ),
    );
  }

  List<_ChartData> _getWeeklyChartData(HabitRecordProvider recordProvider) {
    final List<_ChartData> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('E').format(date).substring(0, 3);

      // Count completed habits for this day
      final completedCount = recordProvider.todayRecords
          .where((r) => 
            r.date.toIso8601String().split('T')[0] == dateStr && 
            r.status == 'done'
          )
          .length;

      data.add(_ChartData(
        day: dayName,
        value: completedCount.toDouble(),
      ));
    }

    return data;
  }
}

class _ChartData {
  final String day;
  final double value;

  _ChartData({required this.day, required this.value});
}