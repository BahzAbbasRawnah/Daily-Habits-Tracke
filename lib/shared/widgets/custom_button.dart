import 'package:flutter/material.dart';
import 'package:daily_habits/config/theme.dart';

/// Custom button widget with different styles
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine button style based on type
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = _buildElevatedButton(
          context,
          backgroundColor ?? theme.colorScheme.primary,
          textColor ?? theme.colorScheme.onPrimary,
        );
        break;
      case ButtonType.secondary:
        button = _buildOutlinedButton(
          context,
          backgroundColor ?? Colors.transparent,
          textColor ?? theme.colorScheme.primary,
          theme.colorScheme.primary,
        );
        break;
      case ButtonType.text:
        button = _buildTextButton(
          context,
          backgroundColor ?? Colors.transparent,
          textColor ?? theme.colorScheme.primary,
        );
        break;
      case ButtonType.accent:
        button = _buildElevatedButton(
          context,
          backgroundColor ?? AppTheme.accentColor,
          textColor ?? Colors.white,
        );
        break;
      case ButtonType.success:
        button = _buildElevatedButton(
          context,
          backgroundColor ?? AppTheme.successColor,
          textColor ?? Colors.white,
        );
        break;
      case ButtonType.warning:
        button = _buildElevatedButton(
          context,
          backgroundColor ?? AppTheme.warningColor,
          textColor ?? Colors.black,
        );
        break;
      case ButtonType.error:
        button = _buildElevatedButton(
          context,
          backgroundColor ?? AppTheme.errorColor,
          textColor ?? Colors.white,
        );
        break;
    }

    // Apply width constraints
    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (width != null) {
      return SizedBox(width: width, child: button);
    } else {
      return button;
    }
  }

  // Build elevated button
  Widget _buildElevatedButton(
      BuildContext context, Color backgroundColor, Color textColor) {
    return ElevatedButton(
      onPressed: isLoading || onPressed == null ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(width ?? 0, height),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  // Build outlined button
  Widget _buildOutlinedButton(BuildContext context, Color backgroundColor,
      Color textColor, Color borderColor) {
    return OutlinedButton(
      onPressed: isLoading || onPressed == null ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: BorderSide(color: borderColor, width: 1.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(width ?? 0, height),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  // Build text button
  Widget _buildTextButton(
      BuildContext context, Color backgroundColor, Color textColor) {
    return TextButton(
      onPressed: isLoading || onPressed == null ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(width ?? 0, height),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  // Build button content with loading indicator or text with optional icon
  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        ],
      );
    } else {
      return Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor));
    }
  }
}

/// Button types
enum ButtonType {
  primary,
  secondary,
  text,
  accent,
  success,
  warning,
  error,
}
