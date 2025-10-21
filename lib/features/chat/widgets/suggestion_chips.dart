import 'package:flutter/material.dart';
import 'package:daily_habits/config/theme.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                suggestions[index],
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                  fontSize: 13,
                ),
              ),
              backgroundColor: isDark
                  ? Colors.grey[800]
                  : AppTheme.primaryColor.withOpacity(0.1),
              side: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
              onPressed: () => onSuggestionTap(suggestions[index]),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }
}
