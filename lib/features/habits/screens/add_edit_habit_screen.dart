import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../services/notification_service.dart';
import '../../../config/theme.dart';

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
    
    if (widget.habit != null) {
      _initializeWithHabit(widget.habit!);
    }
  }

  void _initializeWithHabit(Habit habit) {
    _nameController.text = habit.name;
    _descriptionController.text = habit.description ?? '';
    _selectedCategory = habit.category;
    _selectedTargetType = habit.targetType;
    _target = habit.target;
    _selectedIcon = habit.icon;
    
    // Safely parse color
    if (habit.color != null) {
      try {
        final cleanColor = habit.color!.replaceFirst('#', '0xff');
        _selectedColor = Color(int.parse(cleanColor));
      } catch (e) {
        _selectedColor = AppTheme.primaryColor;
      }
    } else {
      _selectedColor = AppTheme.primaryColor;
    }
    
    _isActive = habit.isActive;
    _scheduleType = habit.schedule.type;
    _selectedDays = habit.schedule.days ?? [];
    
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Name field
        _buildSectionTitle('habit_name'.tr()),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'enter_habit_name'.tr(),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
        const SizedBox(height: 24),

        // Description
        _buildSectionTitle('description'.tr()),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'enter_description'.tr(),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
        const SizedBox(height: 24),

        // Color
        _buildSectionTitle('color'.tr()),
        const SizedBox(height: 12),
        _buildColorPicker(),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
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
      ],
    );
  }

  Widget _buildRemindersTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('reminder_times'.tr()),
        const SizedBox(height: 12),
        
        if (_reminderTimes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'no_reminders_set'.tr(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ..._reminderTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return _buildReminderTimeCard(time, index);
          }),
        
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addReminderTime,
          icon: const Icon(Icons.add),
          label: Text('add_reminder'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
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

  Widget _buildColorPicker() {
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = _selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.5 : 0.3),
                  blurRadius: isSelected ? 12 : 6,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        );
      }).toList(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.alarm, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Text(
            time.format(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _reminderTimes.removeAt(index)),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
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
        child: ElevatedButton(
          onPressed: _saveHabit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isEditing ? 'update_habit'.tr() : 'create_habit'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
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
        ),
      );
      return;
    }

    final reminderTimeStrings = _reminderTimes
        .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final habit = Habit(
        habitID: widget.habit?.habitID,
        userID: 1,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        category: _selectedCategory,
        frequency: 'daily', // Keep for backward compatibility
        schedule: HabitSchedule(
          type: _scheduleType,
          days: _selectedDays.isEmpty ? null : _selectedDays,
        ),
        targetType: _selectedTargetType,
        target: _target,
        icon: _selectedIcon,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        isActive: _isActive,
        reminderTimes: reminderTimeStrings.isEmpty ? null : reminderTimeStrings,
    );

    final provider = context.read<HabitProvider>();
    if (widget.habit != null) {
      await provider.updateHabit(habit);
    } else {
      await provider.addHabit(habit);
    }

    // Schedule notifications
    if (reminderTimeStrings.isNotEmpty) {
      await NotificationService().scheduleHabitNotifications(habit);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.habit != null ? 'habit_updated'.tr() : 'habit_created'.tr(),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
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
