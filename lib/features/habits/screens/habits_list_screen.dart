import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/habit_provider.dart';
import '../providers/habit_record_provider.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ai_chat_fab.dart';
import '../../../config/theme.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';

enum HabitFilter { today, tomorrow, thisWeek, thisMonth, all }

/// Enhanced habits list screen with modern UI and filtering
class HabitsListScreen extends StatefulWidget {
  const HabitsListScreen({super.key});

  @override
  State<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends State<HabitsListScreen> {
  HabitFilter _selectedFilter = HabitFilter.today;

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
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'habits'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HabitProvider>().loadHabits(1);
              context.read<HabitRecordProvider>().loadTodayRecords(1);
            },
          ),
        ],
      ),
      body: Consumer2<HabitProvider, HabitRecordProvider>(
        builder: (context, habitProvider, recordProvider, child) {
          if (habitProvider.isLoading) {
            return const LoadingIndicator();
          }

          final filteredHabits = _getFilteredHabits(habitProvider.habits);
          final habitRecords = _getHabitRecords(filteredHabits, recordProvider);

          return RefreshIndicator(
            onRefresh: () async {
              await habitProvider.loadHabits(1);
              await recordProvider.loadTodayRecords(1);
            },
            child: CustomScrollView(
              slivers: [
                // Progress Header
                SliverToBoxAdapter(
                  child: _buildProgressHeader(filteredHabits, habitRecords),
                ),

                // Filter Tabs
                SliverToBoxAdapter(
                  child: _buildFilterTabs(),
                ),

                // Habits List
                if (filteredHabits.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = filteredHabits[index];
                          final record = habitRecords[habit.habitID];
                          return _buildModernHabitCard(habit, record, recordProvider);
                        },
                        childCount: filteredHabits.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const AIChatFAB(),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditHabitScreen(),
                ),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(List<Habit> habits, Map<int?, HabitRecord?> records) {
    final totalHabits = habits.length;
    final completedHabits = records.values.where((r) => r?.status == 'done').length;
    final progressPercentage = totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getFilterTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalHabits ${'habits'.tr()}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Avatar stack (placeholder)
              SizedBox(
                width: 100,
                height: 40,
                child: Stack(
                  children: List.generate(
                    3.clamp(0, totalHabits),
                    (index) => Positioned(
                      left: index * 25.0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            habits[index].getCategoryIcon(),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'progress'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$progressPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completedHabits / (totalHabits > 0 ? totalHabits : 1),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('today'.tr(), HabitFilter.today),
            _buildFilterChip('tomorrow'.tr(), HabitFilter.tomorrow),
            _buildFilterChip('this_week'.tr(), HabitFilter.thisWeek),
            _buildFilterChip('this_month'.tr(), HabitFilter.thisMonth),
            _buildFilterChip('all'.tr(), HabitFilter.all),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, HabitFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildModernHabitCard(
    Habit habit,
    HabitRecord? record,
    HabitRecordProvider recordProvider,
  ) {
    final isCompleted = record?.status == 'done';
    final progress = record?.progress ?? 0;
    final progressPercentage = habit.target > 0 ? (progress / habit.target) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habit: habit),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with colored background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(habit.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      habit.getCategoryIcon(),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (habit.reminderTimes != null && habit.reminderTimes!.isNotEmpty)
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _getTimeDisplay(habit),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(record?.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(record?.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(record?.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressPercentage,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted
                                      ? AppTheme.successColor
                                      : _getCategoryColor(habit.category),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progressPercentage * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Action buttons
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HabitDetailScreen(habit: habit),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(habit),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'no_habits'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'add_first_habit'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case HabitFilter.today:
        return "${'today'.tr()}'s ${'habits'.tr()}";
      case HabitFilter.tomorrow:
        return "${'tomorrow'.tr()}'s ${'habits'.tr()}";
      case HabitFilter.thisWeek:
        return "${'this_week'.tr()}'s ${'habits'.tr()}";
      case HabitFilter.thisMonth:
        return "${'this_month'.tr()}'s ${'habits'.tr()}";
      case HabitFilter.all:
        return "${'all'.tr()} ${'habits'.tr()}";
    }
  }

  List<Habit> _getFilteredHabits(List<Habit> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    return habits.where((habit) {
      if (!habit.isActive) return false;

      switch (_selectedFilter) {
        case HabitFilter.today:
          return habit.isScheduledFor(today);
        case HabitFilter.tomorrow:
          return habit.isScheduledFor(tomorrow);
        case HabitFilter.thisWeek:
          for (int i = 0; i <= 6; i++) {
            if (habit.isScheduledFor(weekStart.add(Duration(days: i)))) {
              return true;
            }
          }
          return false;
        case HabitFilter.thisMonth:
          for (int i = 0; i < monthEnd.day; i++) {
            if (habit.isScheduledFor(monthStart.add(Duration(days: i)))) {
              return true;
            }
          }
          return false;
        case HabitFilter.all:
          return true;
      }
    }).toList();
  }

  Map<int?, HabitRecord?> _getHabitRecords(
    List<Habit> habits,
    HabitRecordProvider recordProvider,
  ) {
    final Map<int?, HabitRecord?> records = {};
    for (final habit in habits) {
      records[habit.habitID] = recordProvider.getTodayRecord(habit.habitID!);
    }
    return records;
  }

  String _getTimeDisplay(Habit habit) {
    if (habit.reminderTimes != null && habit.reminderTimes!.isNotEmpty) {
      return habit.reminderTimes!.first;
    }
    return '--:--';
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'done':
        return 'complete'.tr();
      case 'partial':
        return 'in_progress'.tr();
      default:
        return 'pending'.tr();
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'done':
        return AppTheme.successColor;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.exercise:
        return Colors.orange;
      case HabitCategory.sleep:
        return Colors.indigo;
      case HabitCategory.hydration:
        return Colors.blue;
      case HabitCategory.nutrition:
        return Colors.green;
      case HabitCategory.mindfulness:
        return Colors.purple;
      case HabitCategory.productivity:
        return Colors.teal;
      case HabitCategory.learning:
        return Colors.amber;
      case HabitCategory.social:
        return Colors.pink;
      case HabitCategory.health:
        return Colors.red;
      case HabitCategory.other:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_habit'.tr()),
        content: Text('delete_habit_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<HabitProvider>().deleteHabit(habit.habitID!, habit.userID);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('habit_deleted'.tr())),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}
