import 'package:flutter/material.dart';
import 'package:daily_habits/config/theme.dart';

/// Widget for displaying a loading indicator
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryDarkColor,
        ),
        strokeWidth: size / 10,
      ),
    );
  }
}
