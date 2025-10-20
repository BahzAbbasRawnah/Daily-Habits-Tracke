import 'package:flutter/material.dart';

/// A widget that provides styled text components based on the app's theme
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final TextDecoration? decoration;
  final bool softWrap;

  const AppText._({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.decoration,
    this.softWrap = true,
  }) : super(key: key);

  /// Display large text style
  static Widget displayLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Display medium text style
  static Widget displayMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Display small text style
  static Widget displaySmall(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Headline large text style
  static Widget headlineLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Headline medium text style
  static Widget headlineMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Headline small text style
  static Widget headlineSmall(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Title large text style
  static Widget titleLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Title medium text style
  static Widget titleMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Title small text style
  static Widget titleSmall(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Body large text style
  static Widget bodyLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Body medium text style
  static Widget bodyMedium(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Body small text style
  static Widget bodySmall(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  /// Label large text style
  static Widget labelLarge(
    String text, {
    Key? key,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    bool softWrap = true,
  }) {
    return AppText._(
      key: key,
      text: text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      softWrap: softWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Determine the base style based on the constructor used
    TextStyle baseStyle;
    if (style != null) {
      baseStyle = style!;
    } else if (fontSize != null) {
      baseStyle = TextStyle(fontSize: fontSize);
    } else {
      // Default to body medium if no specific style is provided
      baseStyle = textTheme.bodyMedium ?? const TextStyle();
    }
    
    // Apply custom styling
    final textStyle = baseStyle.copyWith(
      color: color ?? (theme.brightness == Brightness.dark 
          ? theme.textTheme.bodyMedium?.color 
          : theme.textTheme.bodyMedium?.color),
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
    );
    
    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
