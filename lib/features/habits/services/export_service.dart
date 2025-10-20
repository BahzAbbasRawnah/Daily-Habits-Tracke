import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:daily_habits/features/habits/models/habit_model.dart';
import 'package:daily_habits/features/habits/models/habit_record_model.dart';
import 'package:daily_habits/features/habits/services/analytics_service.dart';

/// Service for exporting habit data to CSV and PDF formats
class ExportService {
  /// Export habits and records to CSV format
  static Future<File> exportToCSV({
    required List<Habit> habits,
    required Map<int, List<HabitRecord>> habitRecords,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Habit ID,Habit Name,Category,Date,Status,Progress,Note,Created At');
    
    // Write data
    for (final habit in habits) {
      final records = habitRecords[habit.habitID] ?? [];
      
      // Filter by date range if provided
      final filteredRecords = records.where((record) {
        if (startDate != null && record.date.isBefore(startDate)) return false;
        if (endDate != null && record.date.isAfter(endDate)) return false;
        return true;
      }).toList();
      
      for (final record in filteredRecords) {
        buffer.writeln(
          '${habit.habitID},'
          '"${_escapeCsv(habit.name)}",'
          '${habit.category.name},'
          '${DateFormat('yyyy-MM-dd').format(record.date)},'
          '${record.status},'
          '${record.progress},'
          '"${_escapeCsv(record.note ?? '')}",'
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(record.createdAt ?? DateTime.now())}'
        );
      }
    }
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/habits_export_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }

  /// Export habits summary to PDF format
  static Future<File> exportToPDF({
    required List<Habit> habits,
    required Map<int, List<HabitRecord>> habitRecords,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('MMMM dd, yyyy');
    
    // Calculate statistics
    final stats = AnalyticsService.getUserStatistics(habits, habitRecords);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              'Daily Habits Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on ${dateFormatter.format(now)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          
          // Overall Statistics
          pw.Header(
            level: 1,
            child: pw.Text(
              'Overall Statistics',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildStatisticsTable(stats),
          pw.SizedBox(height: 20),
          
          // Habits Summary
          pw.Header(
            level: 1,
            child: pw.Text(
              'Habits Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          ...habits.map((habit) => _buildHabitSection(habit, habitRecords[habit.habitID] ?? [])),
        ],
      ),
    );
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/habits_report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Build statistics table for PDF
  static pw.Widget _buildStatisticsTable(Map<String, dynamic> stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('Total Habits', '${stats['totalHabits']}'),
        _buildTableRow('Active Habits', '${stats['activeHabits']}'),
        _buildTableRow('Completed Today', '${stats['completedToday']} / ${stats['scheduledToday']}'),
        _buildTableRow('Today\'s Completion Rate', '${stats['todayCompletionRate'].toStringAsFixed(1)}%'),
        _buildTableRow('Average Streak', '${stats['averageStreak'].toStringAsFixed(1)} days'),
      ],
    );
  }

  /// Build table row for PDF
  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Build habit section for PDF
  static pw.Widget _buildHabitSection(Habit habit, List<HabitRecord> records) {
    final insights = AnalyticsService.getHabitInsights(records, habit);
    
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            habit.name,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Category: ${habit.getCategoryName()} | Target: ${habit.target}x',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInsightItem('Current Streak', '${insights['currentStreak']} days'),
              _buildInsightItem('Longest Streak', '${insights['longestStreak']} days'),
              _buildInsightItem('Weekly Rate', '${insights['weeklyCompletionRate'].toStringAsFixed(1)}%'),
              _buildInsightItem('Total', '${insights['totalCompletions']}'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build insight item for PDF
  static pw.Widget _buildInsightItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// Escape CSV special characters
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return value.replaceAll('"', '""');
    }
    return value;
  }

  /// Export single habit detailed report
  static Future<File> exportHabitDetailToPDF({
    required Habit habit,
    required List<HabitRecord> records,
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMMM dd, yyyy');
    final insights = AnalyticsService.getHabitInsights(records, habit);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              habit.name,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Category: ${habit.getCategoryName()}',
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
          if (habit.description != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              habit.description!,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
          ],
          pw.SizedBox(height: 20),
          
          // Insights
          pw.Header(
            level: 1,
            child: pw.Text(
              'Performance Insights',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildHabitInsightsTable(insights),
          pw.SizedBox(height: 20),
          
          // Recent Records
          pw.Header(
            level: 1,
            child: pw.Text(
              'Recent Activity',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          _buildRecordsTable(records.take(30).toList()),
        ],
      ),
    );
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = habit.name.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final file = File('${directory.path}/habit_${fileName}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Build habit insights table
  static pw.Widget _buildHabitInsightsTable(Map<String, dynamic> insights) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('Current Streak', '${insights['currentStreak']} days'),
        _buildTableRow('Longest Streak', '${insights['longestStreak']} days'),
        _buildTableRow('Weekly Completion Rate', '${insights['weeklyCompletionRate'].toStringAsFixed(1)}%'),
        _buildTableRow('Monthly Completion Rate', '${insights['monthlyCompletionRate'].toStringAsFixed(1)}%'),
        _buildTableRow('Total Completions', '${insights['totalCompletions']}'),
        if (insights['bestTimeOfDay'] != null)
          _buildTableRow('Best Time of Day', '${insights['bestTimeOfDay']}'),
      ],
    );
  }

  /// Build records table
  static pw.Widget _buildRecordsTable(List<HabitRecord> records) {
    if (records.isEmpty) {
      return pw.Text('No records available', style: const pw.TextStyle(color: PdfColors.grey600));
    }
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Status', isHeader: true),
            _buildTableCell('Progress', isHeader: true),
            _buildTableCell('Note', isHeader: true),
          ],
        ),
        // Data rows
        ...records.map((record) => pw.TableRow(
          children: [
            _buildTableCell(DateFormat('MMM dd, yyyy').format(record.date)),
            _buildTableCell(record.status),
            _buildTableCell('${record.progress}'),
            _buildTableCell(record.note ?? '-'),
          ],
        )),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
