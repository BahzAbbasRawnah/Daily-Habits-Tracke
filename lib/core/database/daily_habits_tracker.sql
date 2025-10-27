-- daily_habits_schema.sql
-- Schema exported from the Flutter HabitDatabaseService
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (reverse order to avoid FK problems)
DROP INDEX IF EXISTS idx_habit_reminders;
DROP INDEX IF EXISTS idx_habit_notes_created_at;
DROP INDEX IF EXISTS idx_habit_notes_habit_id;
DROP INDEX IF EXISTS idx_achievement_def;
DROP INDEX IF EXISTS idx_user_achievements;
DROP INDEX IF EXISTS idx_user_analytics;
DROP INDEX IF EXISTS idx_habit_records;
DROP INDEX IF EXISTS idx_user_habits;

DROP TABLE IF EXISTS Sync_Log;
DROP TABLE IF EXISTS User_Achievements;
DROP TABLE IF EXISTS Achievement_Definitions;
DROP TABLE IF EXISTS Analytics;
DROP TABLE IF EXISTS Reminders;
DROP TABLE IF EXISTS Habit_Notes;
DROP TABLE IF EXISTS Habit_Records;
DROP TABLE IF EXISTS Habits;
DROP TABLE IF EXISTS Users;

-- Users table
CREATE TABLE Users (
  UserID INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT NOT NULL,
  Email TEXT UNIQUE,
  Password TEXT,
  Language TEXT DEFAULT 'en',
  Theme TEXT DEFAULT 'light',
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Habits table
CREATE TABLE Habits (
  HabitID INTEGER PRIMARY KEY AUTOINCREMENT,
  UserID INTEGER NOT NULL,
  Name TEXT NOT NULL,
  Description TEXT,
  Category TEXT DEFAULT 'other',
  Frequency TEXT CHECK(Frequency IN ('daily','weekly','monthly')),
  Schedule TEXT,
  TargetType TEXT DEFAULT 'yesNo',
  Target INTEGER DEFAULT 1,
  Icon TEXT,
  Color TEXT,
  IsActive BOOLEAN DEFAULT 1,
  ReminderTimes TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE INDEX idx_user_habits ON Habits(UserID);

-- Habit_Records table
CREATE TABLE Habit_Records (
  RecordID INTEGER PRIMARY KEY AUTOINCREMENT,
  HabitID INTEGER NOT NULL,
  UserID INTEGER NOT NULL,
  Date DATE NOT NULL,
  Progress INTEGER DEFAULT 0,
  Status TEXT CHECK(Status IN ('done','missed','partial')),
  Note TEXT,
  Timestamp INTEGER,
  NoteID TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (HabitID) REFERENCES Habits(HabitID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
  UNIQUE(HabitID, Date)
);

CREATE INDEX idx_habit_records ON Habit_Records(HabitID, Date);

-- Habit_Notes table
-- Note: original Flutter code stores habit_id as TEXT (no FK defined)
CREATE TABLE Habit_Notes (
  id TEXT PRIMARY KEY,
  habit_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER
);

CREATE INDEX idx_habit_notes_habit_id ON Habit_Notes(habit_id);
CREATE INDEX idx_habit_notes_created_at ON Habit_Notes(created_at DESC);

-- Reminders table (enhanced)
CREATE TABLE Reminders (
  ReminderID INTEGER PRIMARY KEY AUTOINCREMENT,
  HabitID INTEGER NOT NULL,
  Time TEXT NOT NULL,
  Weekdays TEXT,
  IsActive BOOLEAN DEFAULT 1,
  IsRecurring BOOLEAN DEFAULT 1,
  ScheduledDate DATETIME,
  SnoozeMinutes INTEGER DEFAULT 10,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (HabitID) REFERENCES Habits(HabitID) ON DELETE CASCADE
);

CREATE INDEX idx_habit_reminders ON Reminders(HabitID);

-- Analytics table
CREATE TABLE Analytics (
  AnalyticsID INTEGER PRIMARY KEY AUTOINCREMENT,
  UserID INTEGER NOT NULL,
  Period TEXT CHECK(Period IN ('weekly','monthly')),
  TotalHabits INTEGER DEFAULT 0,
  CompletedHabits INTEGER DEFAULT 0,
  SuccessRate REAL DEFAULT 0,
  GeneratedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE INDEX idx_user_analytics ON Analytics(UserID);

-- Achievement_Definitions table
CREATE TABLE Achievement_Definitions (
  AchievementDefID TEXT PRIMARY KEY,
  Title TEXT NOT NULL,
  Description TEXT,
  Icon TEXT,
  Type TEXT CHECK(Type IN ('streak','completion','perfect','habits','category')),
  Target INTEGER NOT NULL,
  Color TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- User_Achievements table
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
);

CREATE INDEX idx_user_achievements ON User_Achievements(UserID);
CREATE INDEX idx_achievement_def ON User_Achievements(AchievementDefID);

-- Sync_Log table
CREATE TABLE Sync_Log (
  SyncID INTEGER PRIMARY KEY AUTOINCREMENT,
  UserID INTEGER NOT NULL,
  TableName TEXT NOT NULL,
  LastSync DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- End of schema
