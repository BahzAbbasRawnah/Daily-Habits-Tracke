import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../services/reminder_manager_service.dart';
import '../../../config/theme.dart';
import '../../auth/services/auth_service.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late TabController _tabController;
  int _currentStep = 0;
  
  // Basic info
  HabitCategory _selectedCategory = HabitCategory.other;
  TargetType _selectedTargetType = TargetType.yesNo;
  int _target = 1;
  String? _selectedIcon;
  Color _selectedColor = AppTheme.primaryColor;
  bool _isActive = true;

  // Schedule
  ScheduleType _scheduleType = ScheduleType.daily;
  List<int> _selectedDays = [];
  
  // Reminders
  List<TimeOfDay> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentStep = _tabController.index;
        });
      }
    });
    
    if (widget.habit != null) {
      _initializeWithHabit(widget.habit!);
    } else {
      // Set random color for new habits
      _selectedColor = _getRandomColor();
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _initializeWithHabit(Habit habit) {
    print('🔍 Initializing with habit: ${habit.name}');
    print('🔍 Habit schedule from DB: ${habit.schedule.toJson()}');
    print('🔍 Schedule type: ${habit.schedule.type}');
    print('🔍 Schedule days: ${habit.schedule.days}');
    
    _nameController.text = habit.name;
    _descriptionController.text = habit.description ?? '';
    _selectedCategory = habit.category;
    _selectedTargetType = habit.targetType;
    _target = habit.target;
    _selectedIcon = habit.icon ?? '🎯';
    
    // Parse color
    try {
      final colorString = habit.color?.replaceFirst('#', '') ?? 'FF6200EE';
      _selectedColor = Color(int.parse('FF$colorString', radix: 16));
    } catch (e) {
      _selectedColor = AppTheme.primaryColor;
    }
    
    _isActive = habit.isActive;
    _scheduleType = habit.schedule.type;
    _selectedDays = habit.schedule.days ?? [];
    
    print('🔍 After initialization:');
    print('🔍 _scheduleType: $_scheduleType');
    print('🔍 _selectedDays: $_selectedDays');
    
    if (habit.reminderTimes != null) {
      _reminderTimes = habit.reminderTimes!.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'edit_habit'.tr() : 'add_habit'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(icon: const Icon(Icons.info_outline), text: 'basic'.tr()),
            Tab(icon: const Icon(Icons.calendar_today), text: 'schedule'.tr()),
            Tab(icon: const Icon(Icons.notifications_outlined), text: 'reminders'.tr()),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildScheduleTab(),
            _buildRemindersTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isEditing),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'habit_name'.tr(),
              hintText: 'enter_habit_name'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'habit_name_required'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'description'.tr(),
              hintText: 'enter_description'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Category
          _buildSectionTitle('category'.tr()),
          const SizedBox(height: 12),
          _buildCategoryGrid(),
          const SizedBox(height: 24),

          // Target Type
          _buildSectionTitle('target_type'.tr()),
          const SizedBox(height: 12),
          _buildTargetTypeSelector(),
          const SizedBox(height: 24),

          // Target Value
          _buildSectionTitle('target'.tr()),
          const SizedBox(height: 12),
          _buildTargetSelector(),
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('schedule_type'.tr()),
          const SizedBox(height: 12),
          _buildScheduleTypeSelector(),
          const SizedBox(height: 24),

          if (_scheduleType == ScheduleType.specificDays || _scheduleType == ScheduleType.custom) ...[
            _buildSectionTitle('select_days'.tr()),
            const SizedBox(height: 12),
            _buildDaySelector(),
          ],
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildRemindersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'reminder_times'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _reminderTimes.isEmpty 
                            ? 'no_reminders_yet'.tr()
                            : '${_reminderTimes.length} ${_reminderTimes.length == 1 ? 'reminder'.tr() : 'reminders'.tr()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          if (_reminderTimes.isEmpty)
            _buildEmptyRemindersState()
          else
            ..._reminderTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return _buildReminderTimeCard(time, index);
            }),
          
          const SizedBox(height: 20),
          
          // Add Reminder Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addReminderTime,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'add_reminder'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildEmptyRemindersState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'no_reminders_set'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'tap_below_to_add'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: HabitCategory.values.length,
      itemBuilder: (context, index) {
        final category = HabitCategory.values[index];
        final isSelected = _selectedCategory == category;
        final habit = Habit(
          userID: 1,
          name: '',
          frequency: 'daily',
          category: category,
        );

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  habit.getCategoryIcon(),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.getCategoryName().tr(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTargetTypeChip(TargetType.yesNo, 'yes_no'.tr(), Icons.check_circle_outline),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTargetTypeChip(TargetType.count, 'count'.tr(), Icons.repeat),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTargetTypeChip(TargetType.duration, 'duration'.tr(), Icons.timer_outlined),
        ),
      ],
    );
  }

  Widget _buildTargetTypeChip(TargetType type, String label, IconData icon) {
    final isSelected = _selectedTargetType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTargetType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _target > 1 ? () => setState(() => _target--) : null,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 36,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _target.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () => setState(() => _target++),
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 36,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }


  Widget _buildScheduleTypeSelector() {
    return Column(
      children: [
        _buildScheduleOption(
          ScheduleType.daily,
          'daily'.tr(),
          'every_day'.tr(),
          Icons.today,
        ),
        const SizedBox(height: 12),
        _buildScheduleOption(
          ScheduleType.specificDays,
          'specific_days'.tr(),
          'select_specific_days'.tr(),
          Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildScheduleOption(
          ScheduleType.custom,
          'custom'.tr(),
          'custom_schedule'.tr(),
          Icons.tune,
        ),
      ],
    );
  }

  Widget _buildScheduleOption(
    ScheduleType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _scheduleType == type;
    return GestureDetector(
      onTap: () => setState(() => _scheduleType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = [
      {'num': 1, 'name': 'monday'.tr(), 'short': 'Mon'},
      {'num': 2, 'name': 'tuesday'.tr(), 'short': 'Tue'},
      {'num': 3, 'name': 'wednesday'.tr(), 'short': 'Wed'},
      {'num': 4, 'name': 'thursday'.tr(), 'short': 'Thu'},
      {'num': 5, 'name': 'friday'.tr(), 'short': 'Fri'},
      {'num': 6, 'name': 'saturday'.tr(), 'short': 'Sat'},
      {'num': 7, 'name': 'sunday'.tr(), 'short': 'Sun'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final dayNum = day['num'] as int;
        final isSelected = _selectedDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNum);
              } else {
                _selectedDays.add(dayNum);
              }
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                day['short'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderTimeCard(TimeOfDay time, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (newTime != null) {
              setState(() {
                _reminderTimes[index] = newTime;
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        AppTheme.primaryColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.alarm,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time.format(context),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'tap_to_edit'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() => _reminderTimes.removeAt(index));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('reminder_removed'.tr()),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'delete_reminder'.tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button (show only if not on first step)
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: Text(
                    'previous'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            
            if (_currentStep > 0) const SizedBox(width: 12),
            
            // Next/Save button
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _currentStep < 2 ? _nextStep : _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep < 2 
                      ? 'next'.tr() 
                      : (isEditing ? 'update_habit'.tr() : 'create_habit'.tr()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    // Validate current step before moving to next
    if (_currentStep == 0) {
      // Validate basic info (name is required)
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('habit_name_required'.tr()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }
    
    if (_currentStep < 2) {
      _tabController.animateTo(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _tabController.animateTo(_currentStep - 1);
    }
  }

  Future<void> _addReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTimes.add(time);
      });
    }
  }

  Future<void> _saveHabit() async {
    // Validate name field (required)
    if (_nameController.text.trim().isEmpty) {
      // Switch to basic tab and show error
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('habit_name_required'.tr()),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Validate schedule - if specific days or custom is selected, at least one day must be selected
    if ((_scheduleType == ScheduleType.specificDays || _scheduleType == ScheduleType.custom) && _selectedDays.isEmpty) {
      _tabController.animateTo(1); // Switch to schedule tab
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_at_least_one_day'.tr()),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );

    try {
      print('🔍 Starting save habit process...');
      
      // Get logged-in user ID
      print('🔍 Getting user ID...');
      final userId = await AuthService.getSavedUserId();
      print('🔍 User ID: $userId');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('🔍 Preparing reminder times...');
      final reminderTimeStrings = _reminderTimes
          .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList();
      print('🔍 Reminder times: $reminderTimeStrings');

      print('🔍 Creating habit object...');
      print('🔍 Name: ${_nameController.text.trim()}');
      print('🔍 Category: $_selectedCategory');
      print('🔍 Schedule type: $_scheduleType');
      print('🔍 Selected days: $_selectedDays');
      print('🔍 Target type: $_selectedTargetType');
      print('🔍 Target: $_target');
      print('🔍 Icon: $_selectedIcon');
      print('🔍 Color: ${_selectedColor.value.toRadixString(16)}');
      
      final habitSchedule = HabitSchedule(
        type: _scheduleType,
        days: _selectedDays.isEmpty ? null : _selectedDays,
      );
      
      print('🔍 Schedule object created: ${habitSchedule.toJson()}');
      
      final habit = Habit(
          habitID: widget.habit?.habitID,
          userID: userId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          category: _selectedCategory,
          frequency: 'daily', // Keep for backward compatibility
          schedule: habitSchedule,
          targetType: _selectedTargetType,
          target: _target,
          icon: _selectedIcon,
          color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
          isActive: _isActive,
          reminderTimes: reminderTimeStrings.isEmpty ? null : reminderTimeStrings,
      );
      print('🔍 Habit object created successfully');
      print('🔍 Habit schedule in object: ${habit.schedule.toJson()}');

      print('🔍 Getting habit provider...');
      final provider = context.read<HabitProvider>();
      
      Habit savedHabit = habit;
      
      if (widget.habit != null) {
        print('🔍 Updating existing habit...');
        await provider.updateHabit(habit);
        savedHabit = habit; // Already has ID
        print('🔍 Habit updated successfully');
      } else {
        print('🔍 Adding new habit...');
        await provider.addHabit(habit);
        print('🔍 Habit added successfully');
        
        // Reload habits to get the newly created habit with its ID
        print('🔍 Reloading habits to get new habit ID...');
        await provider.loadHabits(userId);
        
        // Find the newly created habit by name (it should be the most recent one)
        final newHabit = provider.habits.firstWhere(
          (h) => h.name == habit.name && h.userID == userId,
          orElse: () => habit,
        );
        savedHabit = newHabit;
        print('🔍 New habit ID: ${savedHabit.habitID}');
      }

      // Create and schedule reminders if habit has reminder times and an ID
      if (reminderTimeStrings.isNotEmpty && savedHabit.habitID != null) {
        print('🔍 Creating and scheduling reminders for habit ID: ${savedHabit.habitID}...');
        await ReminderManagerService().createAndScheduleRemindersFromHabit(savedHabit.habitID!);
        print('🔍 Reminders created and scheduled successfully');
      } else if (reminderTimeStrings.isNotEmpty) {
        print('⚠️ Cannot schedule reminders: habit ID is null');
      } else if (savedHabit.habitID != null) {
        // If no reminder times, delete any existing reminders
        print('🔍 No reminder times, cancelling any existing reminders...');
        await ReminderManagerService().cancelHabitReminders(savedHabit.habitID!);
      }

      print('🔍 Habit saved successfully, closing screens...');
      
      if (mounted) {
        print('🔍 Widget is mounted, proceeding to close...');
        
        // Close loading dialog
        print('🔍 Closing loading dialog...');
        Navigator.pop(context);
        
        // Close the add/edit screen
        print('🔍 Closing add/edit screen...');
        Navigator.pop(context);
        
        print('🔍 Showing success message...');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.habit != null ? 'habit_updated'.tr() : 'habit_created'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR occurred while saving habit:');
      print('❌ Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace:');
      print(stackTrace);
      
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'failed_to_save_habit'.tr() + ': ${e.toString()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text('$e\n\n$stackTrace'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
