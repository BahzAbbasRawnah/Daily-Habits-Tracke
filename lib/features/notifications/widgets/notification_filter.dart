import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/features/notifications/models/notification_model.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';

/// Widget for filtering notifications
class NotificationFilter extends StatefulWidget {
  final List<NotificationType> selectedTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(List<NotificationType>, DateTime?, DateTime?) onApplyFilter;
  final VoidCallback onResetFilter;

  const NotificationFilter({
    Key? key,
    required this.selectedTypes,
    this.startDate,
    this.endDate,
    required this.onApplyFilter,
    required this.onResetFilter,
  }) : super(key: key);

  @override
  State<NotificationFilter> createState() => _NotificationFilterState();
}

class _NotificationFilterState extends State<NotificationFilter> {
  late List<NotificationType> _selectedTypes;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  /// Toggle a notification type selection
  void _toggleType(NotificationType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  /// Select a date range
  Future<void> _selectDateRange() async {
    final initialDateRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    }
  }

  /// Reset all filters
  void _resetFilters() {
    setState(() {
      _selectedTypes = NotificationType.values.toList();
      _startDate = null;
      _endDate = null;
    });
    widget.onResetFilter();
  }

  /// Apply the selected filters
  void _applyFilters() {
    widget.onApplyFilter(_selectedTypes, _startDate, _endDate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'filterNotifications'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification types
          Text(
            'notificationType'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NotificationType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.translationKey.tr()),
                selected: isSelected,
                onSelected: (_) => _toggleType(type),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                selectedColor: type.color.withOpacity(0.2),
                checkmarkColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected
                      ? type.color
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Date range
          Text(
            'dateRange'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                          : 'selectDateRange'.tr(),
                      style: TextStyle(
                        color: _startDate != null
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Reset button
              Expanded(
                child: CustomButton(
                  text: 'resetButton'.tr(),
                  onPressed: _resetFilters,
                  type: ButtonType.secondary,
                  textColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),

              // Apply button
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withAlpha(70),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: 'applyButton'.tr(),
                    onPressed: _applyFilters,
                    type: ButtonType.primary,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
