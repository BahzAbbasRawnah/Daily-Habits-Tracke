/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int target;
  final int current;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String color;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.target,
    required this.current,
    required this.isUnlocked,
    this.unlockedAt,
    this.color = '#FFD700',
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  int get remaining => (target - current).clamp(0, target);

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${map['type']}',
        orElse: () => AchievementType.streak,
      ),
      target: map['target'] as int,
      current: map['current'] as int,
      isUnlocked: map['isUnlocked'] as bool,
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
      color: map['color'] as String? ?? '#FFD700',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString().split('.').last,
      'target': target,
      'current': current,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'color': color,
    };
  }
}

/// Achievement types
enum AchievementType {
  streak,      // Consecutive days
  completion,  // Total completions
  habits,      // Number of habits
  perfect,     // Perfect days
  category,    // Category-specific
}

/// Predefined achievements
class AchievementDefinitions {
  static List<Achievement> getDefaultAchievements() {
    return [
      // Streak Achievements
      Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Complete habits for 3 days in a row',
        icon: '🔥',
        type: AchievementType.streak,
        target: 3,
        current: 0,
        isUnlocked: false,
        color: '#FF6B6B',
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '⚡',
        type: AchievementType.streak,
        target: 7,
        current: 0,
        isUnlocked: false,
        color: '#4ECDC4',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Month Master',
        description: 'Keep going for 30 days straight',
        icon: '🏆',
        type: AchievementType.streak,
        target: 30,
        current: 0,
        isUnlocked: false,
        color: '#FFD700',
      ),
      Achievement(
        id: 'streak_100',
        title: 'Century Club',
        description: 'Achieve a 100-day streak',
        icon: '👑',
        type: AchievementType.streak,
        target: 100,
        current: 0,
        isUnlocked: false,
        color: '#9B59B6',
      ),
      
      // Completion Achievements
      Achievement(
        id: 'complete_10',
        title: 'First Steps',
        description: 'Complete 10 habits',
        icon: '🎯',
        type: AchievementType.completion,
        target: 10,
        current: 0,
        isUnlocked: false,
        color: '#3498DB',
      ),
      Achievement(
        id: 'complete_50',
        title: 'Half Century',
        description: 'Complete 50 habits',
        icon: '🌟',
        type: AchievementType.completion,
        target: 50,
        current: 0,
        isUnlocked: false,
        color: '#E74C3C',
      ),
      Achievement(
        id: 'complete_100',
        title: 'Centurion',
        description: 'Complete 100 habits',
        icon: '💫',
        type: AchievementType.completion,
        target: 100,
        current: 0,
        isUnlocked: false,
        color: '#F39C12',
      ),
      Achievement(
        id: 'complete_500',
        title: 'Habit Master',
        description: 'Complete 500 habits',
        icon: '🎖️',
        type: AchievementType.completion,
        target: 500,
        current: 0,
        isUnlocked: false,
        color: '#1ABC9C',
      ),
      
      // Perfect Day Achievements
      Achievement(
        id: 'perfect_1',
        title: 'Perfect Day',
        description: 'Complete all habits in one day',
        icon: '✨',
        type: AchievementType.perfect,
        target: 1,
        current: 0,
        isUnlocked: false,
        color: '#F1C40F',
      ),
      Achievement(
        id: 'perfect_7',
        title: 'Perfect Week',
        description: 'Complete all habits for 7 days',
        icon: '🌈',
        type: AchievementType.perfect,
        target: 7,
        current: 0,
        isUnlocked: false,
        color: '#E67E22',
      ),
      Achievement(
        id: 'perfect_30',
        title: 'Perfection',
        description: 'Complete all habits for 30 days',
        icon: '💎',
        type: AchievementType.perfect,
        target: 30,
        current: 0,
        isUnlocked: false,
        color: '#8E44AD',
      ),
      
      // Habit Count Achievements
      Achievement(
        id: 'habits_5',
        title: 'Habit Builder',
        description: 'Create 5 active habits',
        icon: '📝',
        type: AchievementType.habits,
        target: 5,
        current: 0,
        isUnlocked: false,
        color: '#16A085',
      ),
      Achievement(
        id: 'habits_10',
        title: 'Habit Collector',
        description: 'Manage 10 active habits',
        icon: '📚',
        type: AchievementType.habits,
        target: 10,
        current: 0,
        isUnlocked: false,
        color: '#27AE60',
      ),
    ];
  }
}
