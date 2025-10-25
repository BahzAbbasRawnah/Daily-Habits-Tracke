import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit_model.dart';
import '../models/habit_record_model.dart';
import '../providers/habit_record_provider.dart';
import '../providers/habit_note_provider.dart';
import '../services/analytics_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../config/theme.dart';
import '../../auth/services/auth_service.dart';
import 'add_edit_habit_screen.dart';
import 'package:table_calendar/table_calendar.dart';

/// Detailed view of a single habit with history, streaks, and notes
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isMarkingDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitRecordProvider>().loadRecordsByHabit(widget.habit.habitID!);
      context.read<HabitNoteProvider>().loadNotes(widget.habit.habitID.toString());
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.habit.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditHabitScreen(habit: widget.habit),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HabitRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          final records = provider.records;
          final insights = AnalyticsService.getHabitInsights(records, widget.habit);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitHeader(),
                _buildMarkAsDoneButton(provider, records),
                _buildCalendarView(records),
                _buildInsightsSection(insights),
                _buildWeeklyChart(records),
                _buildStreakSection(insights),
                _buildNotesSection(),
                const SizedBox(height: 24), // Bottom padding for better scrolling
              ],
            ),
          );
        },
      ),
     
    );
  }

  Widget _buildHabitHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _parseColor(widget.habit.color),
            _parseColor(widget.habit.color).withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.habit.getCategoryIcon(),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.habit.getCategoryName().tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.habit.description != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.habit.description!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.repeat,
                _getFrequencyText(),
                Colors.white,
              ),
              _buildInfoChip(
                Icons.flag,
                'target'.tr() + ': ${widget.habit.target}',
                Colors.white,
              ),
              if (widget.habit.reminderTimes != null && widget.habit.reminderTimes!.isNotEmpty)
                _buildInfoChip(
                  Icons.notifications,
                  '${widget.habit.reminderTimes!.length} ${'reminders'.tr()}',
                  Colors.white,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAsDoneButton(HabitRecordProvider provider, List<HabitRecord> records) {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    
    // Check if already marked as done today
    final isDoneToday = records.any((record) {
      final recordDate = DateFormat('yyyy-MM-dd').format(record.date);
      return recordDate == todayStr && record.status == 'done';
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isDoneToday || _isMarkingDone
              ? null
              : () => _markHabitAsDone(provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDoneToday ? AppTheme.successColor : AppTheme.primaryColor,
            disabledBackgroundColor: AppTheme.successColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isDoneToday ? 0 : 2,
          ),
          child: _isMarkingDone
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDoneToday ? Icons.check_circle : Icons.check_circle_outline,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDoneToday ? 'completed_today'.tr() : 'mark_as_done'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _markHabitAsDone(HabitRecordProvider provider) async {
    setState(() => _isMarkingDone = true);

    try {
      // Get current user ID
      final userId = await AuthService.getSavedUserId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error_user_not_found'.tr())),
          );
        }
        return;
      }

      // Create habit record
      final record = HabitRecord(
        habitID: widget.habit.habitID!,
        userID: userId,
        date: DateTime.now(),
        progress: 1,
        status: 'done',
        createdAt: DateTime.now(),
      );

      await provider.createRecord(record);

      // Reload records to refresh the UI in real-time
      await provider.loadRecordsByHabit(widget.habit.habitID!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('habit_marked_done'.tr(namedArgs: {'habit': widget.habit.name})),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_marking_habit'.tr()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingDone = false);
      }
    }
  }

  Widget _buildCalendarView(List<HabitRecord> records) {
    // Create a map of dates with completion status
    final Map<DateTime, bool> completedDates = {};
    for (final record in records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      completedDates[date] = record.status == 'done';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'progress_calendar'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    final isCompleted = completedDates[normalizedDay] == true;
                    
                    if (isCompleted) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.successColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    final isCompleted = completedDates[normalizedDay] == true;
                    
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: isCompleted
                            ? Border.all(color: AppTheme.successColor.withOpacity(0.5), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isCompleted ? Colors.white : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(AppTheme.successColor, 'completed'.tr()),
                  const SizedBox(width: 16),
                  _buildLegendItem(Colors.grey.shade300, 'not_completed'.tr()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  String _getFrequencyText() {
    switch (widget.habit.schedule.type) {
      case ScheduleType.daily:
        return 'daily'.tr();
      case ScheduleType.specificDays:
        final days = widget.habit.schedule.days ?? [];
        if (days.length == 7) return 'daily'.tr();
        if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
          return 'weekdays'.tr();
        }
        return '${days.length} ${'days_per_week'.tr()}';
      case ScheduleType.custom:
        return 'custom'.tr();
    }
  }

  Widget _buildInsightsSection(Map<String, dynamic> insights) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insights'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'current_streak'.tr(),
                  '${insights['currentStreak']}',
                  'days'.tr(),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  'longest_streak'.tr(),
                  '${insights['longestStreak']}',
                  'days'.tr(),
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'weekly_rate'.tr(),
                  '${insights['weeklyCompletionRate'].toStringAsFixed(0)}',
                  '%',
                  Icons.trending_up,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  'monthly_rate'.tr(),
                  '${insights['monthlyCompletionRate'].toStringAsFixed(0)}',
                  '%',
                  Icons.calendar_month,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<HabitRecord> records) {
    final weeklyData = AnalyticsService.getWeeklyCompletionData(records, widget.habit);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'this_week'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      weeklyData.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[index],
                            color: weeklyData[index] > 0
                                ? AppTheme.successColor
                                : Colors.grey.shade300,
                            width: 24,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection(Map<String, dynamic> insights) {
    final currentStreak = insights['currentStreak'] as int;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'streak_tracker'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (currentStreak > 0) ...[
                Text(
                  'keep_it_up'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentStreak % 7) / 7,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  '${7 - (currentStreak % 7)} ${'days_to_next_milestone'.tr()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                Text(
                  'start_your_streak'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Consumer<HabitNoteProvider>(
      builder: (context, noteProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'notes'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${noteProvider.notes.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Note composer
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'enter_note'.tr(),
                            border: InputBorder.none,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                        onPressed: () => _addNote(noteProvider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (noteProvider.notes.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'no_notes_yet'.tr(),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                )
              else
                ...noteProvider.notes.map((note) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy • h:mm a').format(note.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteNote(note.id, noteProvider);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                  const SizedBox(width: 8),
                                  Text('delete'.tr()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  void _addNote(HabitNoteProvider noteProvider) async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    final note = await noteProvider.addNote(
      widget.habit.habitID.toString(),
      content,
    );

    if (note != null && mounted) {
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('note_added'.tr())),
      );
    }
  }

  void _deleteNote(String noteId, HabitNoteProvider noteProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_note'.tr()),
        content: Text('delete_note_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await noteProvider.deleteNote(noteId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('note_deleted'.tr())),
        );
      }
    }
  }

  void _showAddNoteDialog() {
    // This method is no longer needed but kept for compatibility
    // Notes are now added inline
  }

  /// Safely parse color string to Color object
  Color _parseColor(String? colorString) {
    if (colorString == null) return AppTheme.primaryColor;
    
    try {
      final cleanColor = colorString.replaceFirst('#', '0xff');
      return Color(int.parse(cleanColor));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }
}
