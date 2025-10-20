import 'package:flutter_test/flutter_test.dart';
import 'package:daily_habits/features/habits/models/habit_model.dart';

void main() {
  group('HabitSchedule', () {
    test('serializes and deserializes correctly', () {
      const schedule = HabitSchedule(
        type: ScheduleType.specificDays,
        days: [1, 3, 5],
        times: 2,
      );

      final json = schedule.toJson();
      final deserialized = HabitSchedule.fromJson(json);

      expect(deserialized.type, schedule.type);
      expect(deserialized.days, schedule.days);
      expect(deserialized.times, schedule.times);
    });

    test('handles daily schedule', () {
      const schedule = HabitSchedule(type: ScheduleType.daily);
      final json = schedule.toJson();
      
      expect(json, 'daily||');
    });

    test('handles custom schedule with days', () {
      const schedule = HabitSchedule(
        type: ScheduleType.custom,
        days: [2, 4, 6],
      );
      
      final json = schedule.toJson();
      expect(json, 'custom|2,4,6|');
    });
  });

  group('Habit', () {
    test('creates habit with default values', () {
      final habit = Habit(
        userID: 1,
        name: 'Test Habit',
        frequency: 'daily',
      );

      expect(habit.category, HabitCategory.other);
      expect(habit.targetType, TargetType.yesNo);
      expect(habit.target, 1);
      expect(habit.isActive, true);
      expect(habit.schedule.type, ScheduleType.daily);
    });

    test('serializes to map correctly', () {
      final habit = Habit(
        habitID: 1,
        userID: 1,
        name: 'Morning Run',
        description: 'Run 5km',
        category: HabitCategory.exercise,
        frequency: 'daily',
        schedule: const HabitSchedule(type: ScheduleType.daily),
        targetType: TargetType.duration,
        target: 30,
        icon: '🏃',
        color: '#FF5733',
        reminderTimes: ['07:00', '19:00'],
      );

      final map = habit.toMap();

      expect(map['HabitID'], 1);
      expect(map['UserID'], 1);
      expect(map['Name'], 'Morning Run');
      expect(map['Description'], 'Run 5km');
      expect(map['Category'], 'exercise');
      expect(map['TargetType'], 'duration');
      expect(map['Target'], 30);
      expect(map['ReminderTimes'], '07:00,19:00');
    });

    test('deserializes from map correctly', () {
      final map = {
        'HabitID': 1,
        'UserID': 1,
        'Name': 'Drink Water',
        'Description': 'Stay hydrated',
        'Category': 'hydration',
        'Frequency': 'daily',
        'Schedule': 'daily||',
        'TargetType': 'count',
        'Target': 8,
        'Icon': '💧',
        'Color': '#3498db',
        'IsActive': 1,
        'CreatedAt': '2024-01-01T10:00:00.000',
        'ReminderTimes': '08:00,12:00,16:00',
      };

      final habit = Habit.fromMap(map);

      expect(habit.habitID, 1);
      expect(habit.name, 'Drink Water');
      expect(habit.category, HabitCategory.hydration);
      expect(habit.targetType, TargetType.count);
      expect(habit.target, 8);
      expect(habit.reminderTimes?.length, 3);
      expect(habit.isActive, true);
    });

    test('isScheduledFor returns true for daily habit', () {
      final habit = Habit(
        userID: 1,
        name: 'Test',
        frequency: 'daily',
        schedule: const HabitSchedule(type: ScheduleType.daily),
      );

      expect(habit.isScheduledFor(DateTime.now()), true);
      expect(habit.isScheduledFor(DateTime.now().add(const Duration(days: 5))), true);
    });

    test('isScheduledFor respects specific days', () {
      final habit = Habit(
        userID: 1,
        name: 'Weekday Habit',
        frequency: 'weekly',
        schedule: const HabitSchedule(
          type: ScheduleType.specificDays,
          days: [1, 2, 3, 4, 5], // Mon-Fri
        ),
      );

      // Test with a known Monday (2024-01-01 is a Monday)
      final monday = DateTime(2024, 1, 1);
      expect(habit.isScheduledFor(monday), true); // Monday
      expect(habit.isScheduledFor(monday.add(const Duration(days: 5))), false); // Saturday
      expect(habit.isScheduledFor(monday.add(const Duration(days: 6))), false); // Sunday
    });

    test('getCategoryName returns correct name', () {
      final habit = Habit(
        userID: 1,
        name: 'Test',
        frequency: 'daily',
        category: HabitCategory.exercise,
      );

      expect(habit.getCategoryName(), 'Exercise');
    });

    test('getCategoryIcon returns correct emoji', () {
      final habit = Habit(
        userID: 1,
        name: 'Test',
        frequency: 'daily',
        category: HabitCategory.hydration,
      );

      expect(habit.getCategoryIcon(), '💧');
    });

    test('copyWith creates new instance with updated values', () {
      final original = Habit(
        habitID: 1,
        userID: 1,
        name: 'Original',
        frequency: 'daily',
        target: 1,
      );

      final updated = original.copyWith(
        name: 'Updated',
        target: 5,
      );

      expect(updated.name, 'Updated');
      expect(updated.target, 5);
      expect(updated.habitID, original.habitID);
      expect(updated.userID, original.userID);
    });

    test('handles null reminder times', () {
      final habit = Habit(
        userID: 1,
        name: 'Test',
        frequency: 'daily',
        reminderTimes: null,
      );

      final map = habit.toMap();
      expect(map['ReminderTimes'], null);
    });

    test('handles backward compatibility with missing fields', () {
      final map = {
        'HabitID': 1,
        'UserID': 1,
        'Name': 'Old Habit',
        'Frequency': 'daily',
        'Target': 1,
        'IsActive': 1,
      };

      final habit = Habit.fromMap(map);

      expect(habit.category, HabitCategory.other);
      expect(habit.targetType, TargetType.yesNo);
      expect(habit.schedule.type, ScheduleType.daily);
    });
  });

  group('HabitCategory', () {
    test('all categories are defined', () {
      expect(HabitCategory.values.length, 10);
      expect(HabitCategory.values.contains(HabitCategory.exercise), true);
      expect(HabitCategory.values.contains(HabitCategory.sleep), true);
      expect(HabitCategory.values.contains(HabitCategory.hydration), true);
    });
  });

  group('TargetType', () {
    test('all target types are defined', () {
      expect(TargetType.values.length, 3);
      expect(TargetType.values.contains(TargetType.yesNo), true);
      expect(TargetType.values.contains(TargetType.count), true);
      expect(TargetType.values.contains(TargetType.duration), true);
    });
  });

  group('ScheduleType', () {
    test('all schedule types are defined', () {
      expect(ScheduleType.values.length, 3);
      expect(ScheduleType.values.contains(ScheduleType.daily), true);
      expect(ScheduleType.values.contains(ScheduleType.specificDays), true);
      expect(ScheduleType.values.contains(ScheduleType.custom), true);
    });
  });
}
