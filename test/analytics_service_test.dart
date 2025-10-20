import 'package:flutter_test/flutter_test.dart';
import 'package:daily_habits/features/habits/models/habit_model.dart';
import 'package:daily_habits/features/habits/models/habit_record_model.dart';
import 'package:daily_habits/features/habits/services/analytics_service.dart';

void main() {
  group('AnalyticsService - Streak Calculation', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Test Habit',
        frequency: 'daily',
        schedule: const HabitSchedule(type: ScheduleType.daily),
      );
    });

    test('calculates current streak correctly for consecutive days', () {
      final now = DateTime.now();
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now,
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 1)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 2)),
          status: 'done',
          progress: 1,
        ),
      ];

      final streak = AnalyticsService.calculateStreak(records, testHabit);
      expect(streak, 3);
    });

    test('returns 0 streak when no records exist', () {
      final streak = AnalyticsService.calculateStreak([], testHabit);
      expect(streak, 0);
    });

    test('streak breaks on missed day', () {
      final now = DateTime.now();
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now,
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 1)),
          status: 'missed',
          progress: 0,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 2)),
          status: 'done',
          progress: 1,
        ),
      ];

      final streak = AnalyticsService.calculateStreak(records, testHabit);
      expect(streak, 1);
    });

    test('calculates longest streak correctly', () {
      final now = DateTime.now();
      final records = [
        // Current streak: 2 days
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now,
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 1)),
          status: 'done',
          progress: 1,
        ),
        // Break
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 2)),
          status: 'missed',
          progress: 0,
        ),
        // Previous streak: 4 days
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 3)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 4)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 5)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: now.subtract(const Duration(days: 6)),
          status: 'done',
          progress: 1,
        ),
      ];

      final longestStreak = AnalyticsService.calculateLongestStreak(records, testHabit);
      expect(longestStreak, 4);
    });
  });

  group('AnalyticsService - Completion Rate', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Test Habit',
        frequency: 'daily',
        schedule: const HabitSchedule(type: ScheduleType.daily),
      );
    });

    test('calculates 100% completion rate when all days completed', () {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));
      
      final records = List.generate(7, (index) {
        return HabitRecord(
          habitID: 1,
          userID: 1,
          date: startDate.add(Duration(days: index)),
          status: 'done',
          progress: 1,
        );
      });

      final rate = AnalyticsService.calculateCompletionRate(
        records,
        testHabit,
        startDate,
        endDate,
      );
      
      expect(rate, 100.0);
    });

    test('calculates 50% completion rate correctly', () {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 3));
      
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: startDate,
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: startDate.add(const Duration(days: 1)),
          status: 'missed',
          progress: 0,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: startDate.add(const Duration(days: 2)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: startDate.add(const Duration(days: 3)),
          status: 'missed',
          progress: 0,
        ),
      ];

      final rate = AnalyticsService.calculateCompletionRate(
        records,
        testHabit,
        startDate,
        endDate,
      );
      
      expect(rate, 50.0);
    });

    test('returns 0% when no records exist', () {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));

      final rate = AnalyticsService.calculateCompletionRate(
        [],
        testHabit,
        startDate,
        endDate,
      );
      
      expect(rate, 0.0);
    });
  });

  group('AnalyticsService - Specific Days Schedule', () {
    test('calculates streak correctly for weekday-only habit', () {
      // Habit scheduled for Mon-Fri only
      final habit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Weekday Habit',
        frequency: 'weekly',
        schedule: const HabitSchedule(
          type: ScheduleType.specificDays,
          days: [1, 2, 3, 4, 5], // Mon-Fri
        ),
      );

      // Create records for a week including weekend
      final monday = DateTime(2024, 1, 1); // Assuming this is a Monday
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: monday.add(const Duration(days: 4)), // Friday
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: monday.add(const Duration(days: 3)), // Thursday
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: monday.add(const Duration(days: 2)), // Wednesday
          status: 'done',
          progress: 1,
        ),
        // Weekend - no records needed
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: monday.add(const Duration(days: 1)), // Tuesday
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: monday, // Monday
          status: 'done',
          progress: 1,
        ),
      ];

      final streak = AnalyticsService.calculateStreak(records, habit);
      expect(streak, 5); // Full week of weekdays
    });

    test('habit is scheduled for correct days', () {
      final habit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Weekday Habit',
        frequency: 'weekly',
        schedule: const HabitSchedule(
          type: ScheduleType.specificDays,
          days: [1, 3, 5], // Mon, Wed, Fri
        ),
      );

      final monday = DateTime(2024, 1, 1); // Monday
      expect(habit.isScheduledFor(monday), true);
      expect(habit.isScheduledFor(monday.add(const Duration(days: 1))), false); // Tuesday
      expect(habit.isScheduledFor(monday.add(const Duration(days: 2))), true); // Wednesday
    });
  });

  group('AnalyticsService - Best Time of Day', () {
    test('identifies morning as best time', () {
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: DateTime.now(),
          status: 'done',
          progress: 1,
          createdAt: DateTime(2024, 1, 1, 8, 0), // 8 AM
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'done',
          progress: 1,
          createdAt: DateTime(2024, 1, 1, 9, 0), // 9 AM
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: 'done',
          progress: 1,
          createdAt: DateTime(2024, 1, 1, 20, 0), // 8 PM
        ),
      ];

      final bestTime = AnalyticsService.getBestTimeOfDay(records);
      expect(bestTime, 'morning');
    });

    test('returns null when no completed records', () {
      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: DateTime.now(),
          status: 'missed',
          progress: 0,
        ),
      ];

      final bestTime = AnalyticsService.getBestTimeOfDay(records);
      expect(bestTime, null);
    });
  });

  group('AnalyticsService - Weekly Data', () {
    test('generates correct weekly completion data', () {
      final habit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Test Habit',
        frequency: 'daily',
        schedule: const HabitSchedule(type: ScheduleType.daily),
      );

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final records = [
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: weekStart,
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: weekStart.add(const Duration(days: 1)),
          status: 'done',
          progress: 1,
        ),
        HabitRecord(
          habitID: 1,
          userID: 1,
          date: weekStart.add(const Duration(days: 2)),
          status: 'missed',
          progress: 0,
        ),
      ];

      final weeklyData = AnalyticsService.getWeeklyCompletionData(records, habit);
      
      expect(weeklyData.length, 7);
      expect(weeklyData[0], 1.0); // Monday completed
      expect(weeklyData[1], 1.0); // Tuesday completed
      expect(weeklyData[2], 0.0); // Wednesday missed
    });
  });

  group('AnalyticsService - User Statistics', () {
    test('calculates overall user statistics correctly', () {
      final habits = [
        Habit(
          habitID: 1,
          userID: 1,
          name: 'Habit 1',
          frequency: 'daily',
          isActive: true,
        ),
        Habit(
          habitID: 2,
          userID: 1,
          name: 'Habit 2',
          frequency: 'daily',
          isActive: true,
        ),
        Habit(
          habitID: 3,
          userID: 1,
          name: 'Habit 3',
          frequency: 'daily',
          isActive: false,
        ),
      ];

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final habitRecords = {
        1: [
          HabitRecord(
            habitID: 1,
            userID: 1,
            date: todayStart,
            status: 'done',
            progress: 1,
          ),
        ],
        2: [
          HabitRecord(
            habitID: 2,
            userID: 1,
            date: todayStart,
            status: 'missed',
            progress: 0,
          ),
        ],
      };

      final stats = AnalyticsService.getUserStatistics(habits, habitRecords);

      expect(stats['totalHabits'], 3);
      expect(stats['activeHabits'], 2);
      expect(stats['completedToday'], 1);
      expect(stats['scheduledToday'], 2);
      expect(stats['todayCompletionRate'], 50.0);
    });
  });
}
