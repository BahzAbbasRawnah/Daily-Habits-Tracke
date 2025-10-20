import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_habits/config/constants.dart';

/// Utility class to handle language switching and RTL support
class LanguageUtil {
  /// Change the app language
  static Future<void> changeLanguage(BuildContext context, String languageCode) async {
    if (context.locale.languageCode != languageCode) {
      await context.setLocale(Locale(languageCode));
      
      // Save the language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefLanguage, languageCode);
    }
  }

  /// Check if the current language is RTL
  static bool isRtl(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  /// Get the text direction based on the current locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRtl(context) ? TextDirection.RTL : TextDirection.LTR;
  }

  /// Get the language name based on the language code
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'Unknown';
    }
  }
}
