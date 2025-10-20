class HabitRecord {
  final int? recordID;
  final int habitID;
  final int userID;
  final DateTime date;
  final int progress;
  final String status;
  final String? note;
  final DateTime? createdAt;

  HabitRecord({
    this.recordID,
    required this.habitID,
    required this.userID,
    required this.date,
    this.progress = 0,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory HabitRecord.fromMap(Map<String, dynamic> map) {
    return HabitRecord(
      recordID: map['RecordID'],
      habitID: map['HabitID'],
      userID: map['UserID'],
      date: DateTime.parse(map['Date']),
      progress: map['Progress'] ?? 0,
      status: map['Status'],
      note: map['Note'],
      createdAt: map['CreatedAt'] != null ? DateTime.parse(map['CreatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'RecordID': recordID,
      'HabitID': habitID,
      'UserID': userID,
      'Date': date.toIso8601String().split('T')[0],
      'Progress': progress,
      'Status': status,
      'Note': note,
      'CreatedAt': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this HabitRecord with the given fields replaced with new values
  HabitRecord copyWith({
    int? recordID,
    int? habitID,
    int? userID,
    DateTime? date,
    int? progress,
    String? status,
    String? note,
    DateTime? createdAt,
  }) {
    return HabitRecord(
      recordID: recordID ?? this.recordID,
      habitID: habitID ?? this.habitID,
      userID: userID ?? this.userID,
      date: date ?? this.date,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}