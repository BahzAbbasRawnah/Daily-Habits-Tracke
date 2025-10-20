import 'package:uuid/uuid.dart';

/// Model for habit notes
class HabitNote {
  final String id;
  final String habitId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HabitNote({
    String? id,
    required this.habitId,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create from database map
  factory HabitNote.fromMap(Map<String, dynamic> map) {
    return HabitNote(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  HabitNote copyWith({
    String? id,
    String? habitId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitNote(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HabitNote(id: $id, habitId: $habitId, content: $content, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitNote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
