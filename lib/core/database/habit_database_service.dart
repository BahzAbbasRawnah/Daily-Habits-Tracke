import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:daily_habits/features/habits/models/user_model.dart';

/// SQLite database service for the Daily Habit Tracker application
class HabitDatabaseService {
  static const String _databaseName = 'daily_habits.db';
  static const int _databaseVersion = 4; // Updated for notes table and habit_records improvements
  static Database? _database;
  static final HabitDatabaseService _instance = HabitDatabaseService._internal();

  factory HabitDatabaseService() => _instance;
  HabitDatabaseService._internal();

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database with schema
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database schema
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Users table
    batch.execute('''
      CREATE TABLE Users (
        UserID INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        Email TEXT UNIQUE,
        Password TEXT,
        Language TEXT DEFAULT 'en',
        Theme TEXT DEFAULT 'light',
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Habits table with enhanced schema
    batch.execute('''
      CREATE TABLE Habits (
        HabitID INTEGER PRIMARY KEY AUTOINCREMENT,
        UserID INTEGER NOT NULL,
        Name TEXT NOT NULL,
        Description TEXT,
        Category TEXT DEFAULT 'other',
        Frequency TEXT CHECK(Frequency IN ('daily', 'weekly', 'monthly')),
        Schedule TEXT,
        TargetType TEXT DEFAULT 'yesNo',
        Target INTEGER DEFAULT 1,
        Icon TEXT,
        Color TEXT,
        IsActive BOOLEAN DEFAULT 1,
        ReminderTimes TEXT,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
      )
    ''');

    // Habit Records table
    batch.execute('''
      CREATE TABLE Habit_Records (
        RecordID INTEGER PRIMARY KEY AUTOINCREMENT,
        HabitID INTEGER NOT NULL,
        UserID INTEGER NOT NULL,
        Date DATE NOT NULL,
        Progress INTEGER DEFAULT 0,
        Status TEXT CHECK(Status IN ('done', 'missed', 'partial')),
        Note TEXT,
        Timestamp INTEGER,
        NoteID TEXT,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (HabitID) REFERENCES Habits(HabitID) ON DELETE CASCADE,
        FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
        UNIQUE(HabitID, Date)
      )
    ''');

    // Habit Notes table
    batch.execute('''
      CREATE TABLE Habit_Notes (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Reminders table
    batch.execute('''
      CREATE TABLE Reminders (
        ReminderID INTEGER PRIMARY KEY AUTOINCREMENT,
        HabitID INTEGER NOT NULL,
        Time TEXT NOT NULL,
        Days TEXT,
        Enabled BOOLEAN DEFAULT 1,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (HabitID) REFERENCES Habits(HabitID) ON DELETE CASCADE
      )
    ''');

    // Analytics table
    batch.execute('''
      CREATE TABLE Analytics (
        AnalyticsID INTEGER PRIMARY KEY AUTOINCREMENT,
        UserID INTEGER NOT NULL,
        Period TEXT CHECK(Period IN ('weekly', 'monthly')),
        TotalHabits INTEGER DEFAULT 0,
        CompletedHabits INTEGER DEFAULT 0,
        SuccessRate REAL DEFAULT 0,
        GeneratedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
      )
    ''');

    // Achievement Definitions table (stores all possible achievements)
    batch.execute('''
      CREATE TABLE Achievement_Definitions (
        AchievementDefID TEXT PRIMARY KEY,
        Title TEXT NOT NULL,
        Description TEXT,
        Icon TEXT,
        Type TEXT CHECK(Type IN ('streak', 'completion', 'perfect', 'habits', 'category')),
        Target INTEGER NOT NULL,
        Color TEXT,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User Achievements table (tracks user progress)
    batch.execute('''
      CREATE TABLE User_Achievements (
        UserAchievementID INTEGER PRIMARY KEY AUTOINCREMENT,
        UserID INTEGER NOT NULL,
        AchievementDefID TEXT NOT NULL,
        CurrentProgress INTEGER DEFAULT 0,
        IsUnlocked BOOLEAN DEFAULT 0,
        UnlockedAt DATETIME,
        FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
        FOREIGN KEY (AchievementDefID) REFERENCES Achievement_Definitions(AchievementDefID),
        UNIQUE(UserID, AchievementDefID)
      )
    ''');

    // Sync Log table
    batch.execute('''
      CREATE TABLE Sync_Log (
        SyncID INTEGER PRIMARY KEY AUTOINCREMENT,
        UserID INTEGER NOT NULL,
        TableName TEXT NOT NULL,
        LastSync DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    batch.execute('CREATE INDEX idx_user_habits ON Habits(UserID)');
    batch.execute('CREATE INDEX idx_habit_records ON Habit_Records(HabitID, Date)');
    batch.execute('CREATE INDEX idx_user_analytics ON Analytics(UserID)');
    batch.execute('CREATE INDEX idx_user_achievements ON User_Achievements(UserID)');
    batch.execute('CREATE INDEX idx_achievement_def ON User_Achievements(AchievementDefID)');
    batch.execute('CREATE INDEX idx_habit_notes_habit_id ON Habit_Notes(habit_id)');
    batch.execute('CREATE INDEX idx_habit_notes_created_at ON Habit_Notes(created_at DESC)');

    await batch.commit();

    // Load achievement definitions from JSON
    await _loadAchievementDefinitions(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to 2: Add new columns
      final batch = db.batch();
      
      // Add new columns to Habits table
      batch.execute('ALTER TABLE Habits ADD COLUMN Category TEXT DEFAULT "other"');
      batch.execute('ALTER TABLE Habits ADD COLUMN Schedule TEXT');
      batch.execute('ALTER TABLE Habits ADD COLUMN TargetType TEXT DEFAULT "yesNo"');
      batch.execute('ALTER TABLE Habits ADD COLUMN ReminderTimes TEXT');
      
      // Update existing records with default schedule
      batch.execute('''
        UPDATE Habits 
        SET Schedule = 'daily||' 
        WHERE Schedule IS NULL
      ''');
      
      await batch.commit();
      debugPrint('Database upgraded from version 1 to 2');
    }
    
    if (oldVersion < 3) {
      // Migration from version 2 to 3: Add achievements tables
      final batch = db.batch();
      
      // Drop old Achievements table if exists
      batch.execute('DROP TABLE IF EXISTS Achievements');
      
      // Create new Achievement_Definitions table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS Achievement_Definitions (
          AchievementDefID TEXT PRIMARY KEY,
          Title TEXT NOT NULL,
          Description TEXT,
          Icon TEXT,
          Type TEXT CHECK(Type IN ('streak', 'completion', 'perfect', 'habits', 'category')),
          Target INTEGER NOT NULL,
          Color TEXT,
          CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      // Create User_Achievements table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS User_Achievements (
          UserAchievementID INTEGER PRIMARY KEY AUTOINCREMENT,
          UserID INTEGER NOT NULL,
          AchievementDefID TEXT NOT NULL,
          CurrentProgress INTEGER DEFAULT 0,
          IsUnlocked BOOLEAN DEFAULT 0,
          UnlockedAt DATETIME,
          FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
          FOREIGN KEY (AchievementDefID) REFERENCES Achievement_Definitions(AchievementDefID),
          UNIQUE(UserID, AchievementDefID)
        )
      ''');
      
      // Create indexes
      batch.execute('CREATE INDEX IF NOT EXISTS idx_user_achievements ON User_Achievements(UserID)');
      batch.execute('CREATE INDEX IF NOT EXISTS idx_achievement_def ON User_Achievements(AchievementDefID)');
      
      await batch.commit();
      
      // Load achievement definitions
      await _loadAchievementDefinitions(db);
      
      debugPrint('Database upgraded from version 2 to 3');
    }
    
    if (oldVersion < 4) {
      // Migration from version 3 to 4: Add notes table and update habit_records
      final batch = db.batch();
      
      // Create Habit_Notes table
      batch.execute('''
        CREATE TABLE IF NOT EXISTS Habit_Notes (
          id TEXT PRIMARY KEY,
          habit_id TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER
        )
      ''');
      
      // Add new columns to Habit_Records table
      try {
        batch.execute('ALTER TABLE Habit_Records ADD COLUMN Timestamp INTEGER');
      } catch (e) {
        debugPrint('Timestamp column may already exist: $e');
      }
      
      try {
        batch.execute('ALTER TABLE Habit_Records ADD COLUMN NoteID TEXT');
      } catch (e) {
        debugPrint('NoteID column may already exist: $e');
      }
      
      // Create indexes for notes
      batch.execute('CREATE INDEX IF NOT EXISTS idx_habit_notes_habit_id ON Habit_Notes(habit_id)');
      batch.execute('CREATE INDEX IF NOT EXISTS idx_habit_notes_created_at ON Habit_Notes(created_at DESC)');
      
      await batch.commit();
      
      debugPrint('Database upgraded from version 3 to 4');
    }
  }

  /// Load achievement definitions from JSON file
  Future<void> _loadAchievementDefinitions(Database db) async {
    try {
      // Load JSON file
      final String jsonString = await rootBundle.loadString('assets/data/achievements.json');
      final List<dynamic> achievementsJson = json.decode(jsonString);
      
      // Insert each achievement definition
      final batch = db.batch();
      for (final achievementData in achievementsJson) {
        batch.insert(
          'Achievement_Definitions',
          {
            'AchievementDefID': achievementData['id'],
            'Title': achievementData['title'],
            'Description': achievementData['description'],
            'Icon': achievementData['icon'],
            'Type': achievementData['type'],
            'Target': achievementData['target'],
            'Color': achievementData['color'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit();
      debugPrint('Loaded ${achievementsJson.length} achievement definitions');
    } catch (e) {
      debugPrint('Error loading achievement definitions: $e');
    }
  }

  /// Insert a new user
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('Users', user.toMap());
  }

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    final db = await database;
    final maps = await db.query(
      'Users',
      where: 'UserID = ?',
      whereArgs: [userId],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'Users',
      where: 'Email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}