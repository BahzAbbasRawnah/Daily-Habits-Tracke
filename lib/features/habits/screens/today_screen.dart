import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import '../providers/habit_provider.dart';
import '../providers/habit_record_provider.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../config/theme.dart';
import 'habit_detail_screen.dart';

/// Today's habits checklist screen - primary entry point
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits(1);
      context.read<HabitRecordProvider>().loadTodayRecords(1);
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'today'.tr(),
        subtitle: DateFormat('EEEE, MMMM d').format(now),
      ),
      body: Stack(
        children: [
          Consumer2<HabitProvider, HabitRecordProvider>(
            builder: (context, habitProvider, recordProvider, child) {
              if (habitProvider.isLoading) {
                return const LoadingIndicator();
              }

              // Filter habits scheduled for today
              final todayHabits = habitProvider.habits
                  .where((h) => h.isActive && h.isScheduledFor(today))
                  .toList();

              if (todayHabits.isEmpty) {
                return _buildEmptyState();
              }

              // Calculate completion stats
              final completedCount = todayHabits.where((habit) {
                final record = recordProvider.getTodayRecord(habit.habitID!);
                return record?.status == 'done';
              }).length;

              final completionRate = (completedCount / todayHabits.length * 100).round();

              return RefreshIndicator(
                onRefresh: () async {
                  await habitProvider.loadHabits(1);
                  await recordProvider.loadTodayRecords(1);
                },
                child: CustomScrollView(
                  slivers: [
                    // Progress header
                    SliverToBoxAdapter(
                      child: _buildProgressHeader(completedCount, todayHabits.length, completionRate),
                    ),
                    
                    // Today's habits list
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = todayHabits[index];
                            final record = recordProvider.getTodayRecord(habit.habitID!);
                            
                            return _buildHabitItem(
                              habit,
                              record,
                              recordProvider,
                            );
                          },
                          childCount: todayHabits.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Celebration overlay
          if (_showCelebration)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/confetti.json',
                    controller: _celebrationController,
                    onLoaded: (composition) {
                      _celebrationController.forward().then((_) {
                        setState(() => _showCelebration = false);
                        _celebrationController.reset();
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int completed, int total, int percentage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'daily_progress'.tr(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completed / total,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (completed == total && total > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'all_habits_completed'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitItem(
    Habit habit,
    HabitRecord? record,
    HabitRecordProvider recordProvider,
  ) {
    final isCompleted = record?.status == 'done';
    final progress = record?.progress ?? 0;
    final progressPercentage = habit.target > 0 ? (progress / habit.target * 100).round() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? AppTheme.successColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habit: habit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: () => _toggleHabitCompletion(habit, record, recordProvider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppTheme.successColor
                        : Colors.grey.shade200,
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.successColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.circle_outlined,
                    color: isCompleted ? Colors.white : Colors.grey.shade400,
                    size: 32,
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
                        Text(
                          habit.getCategoryIcon(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.getCategoryName().tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Progress bar for count/duration targets
                    if (habit.targetType != TargetType.yesNo) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress / habit.target,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$progress / ${habit.target}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Reminder times
                    if (habit.reminderTimes != null && habit.reminderTimes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.notifications_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            habit.reminderTimes!.take(2).join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Quick action button
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(habit: habit),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'no_habits_today'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'no_habits_today_desc'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleHabitCompletion(
    Habit habit,
    HabitRecord? record,
    HabitRecordProvider recordProvider,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (record == null) {
      // Create new record
      await recordProvider.createRecord(
        HabitRecord(
          habitID: habit.habitID!,
          userID: habit.userID,
          date: today,
          status: 'done',
          progress: habit.target,
          createdAt: DateTime.now(),
        ),
      );
      
      // Show celebration if all habits completed
      _checkAndCelebrate();
    } else {
      // Toggle existing record
      final newStatus = record.status == 'done' ? 'missed' : 'done';
      final newProgress = newStatus == 'done' ? habit.target : 0;
      
      await recordProvider.updateRecord(
        record.copyWith(
          status: newStatus,
          progress: newProgress,
        ),
      );
      
      if (newStatus == 'done') {
        _checkAndCelebrate();
      }
    }
  }

  void _checkAndCelebrate() {
    final habitProvider = context.read<HabitProvider>();
    final recordProvider = context.read<HabitRecordProvider>();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayHabits = habitProvider.habits
        .where((h) => h.isActive && h.isScheduledFor(today))
        .toList();
    
    final allCompleted = todayHabits.every((habit) {
      final record = recordProvider.getTodayRecord(habit.habitID!);
      return record?.status == 'done';
    });
    
    if (allCompleted && todayHabits.isNotEmpty) {
      setState(() => _showCelebration = true);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${'all_habits_completed'.tr()}'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
