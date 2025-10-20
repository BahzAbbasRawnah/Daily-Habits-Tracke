import 'package:flutter/material.dart';

/// Custom card widget with various customization options
class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final double elevation;
  final VoidCallback? onTap;
  final bool hasShadow;
  final Gradient? gradient;

  const CustomCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.width,
    this.height,
    this.elevation = 2,
    this.onTap,
    this.hasShadow = true,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine if the card is tappable
    final isClickable = onTap != null;
    
    // Create the card content
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(
          color: borderColor!,
          width: borderWidth,
        ) : null,
        gradient: gradient,
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ] : null,
      ),
      child: child,
    );
    
    // Wrap with InkWell if tappable
    if (isClickable) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: cardContent,
          ),
        ),
      );
    }
    
    // Return the card with margin
    return Padding(
      padding: margin,
      child: cardContent,
    );
  }
}

/// Gold card with gradient background
class GoldCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;
  final double elevation;

  const GoldCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.width,
    this.height,
    this.borderRadius = 12,
    this.onTap,
    this.hasShadow = true,
    this.elevation = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      onTap: onTap,
      hasShadow: hasShadow,
      elevation: elevation,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFD700), // Gold
          Color(0xFFDAA520), // Golden rod
        ],
      ),
      child: child,
    );
  }
}

/// Premium dark card with gold border
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;
  final double elevation;

  const PremiumCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.width,
    this.height,
    this.borderRadius = 12,
    this.onTap,
    this.hasShadow = true,
    this.elevation = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      onTap: onTap,
      hasShadow: hasShadow,
      elevation: elevation,
      backgroundColor: const Color(0xFF1E1E1E),
      borderColor: const Color(0xFFFFD700),
      borderWidth: 1.5,
      child: child,
    );
  }
}
