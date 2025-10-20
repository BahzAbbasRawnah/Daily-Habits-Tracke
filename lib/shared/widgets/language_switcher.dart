import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/utils/language_util.dart';

/// A widget to switch between languages
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: AppTheme.primaryColor,
      ),
      onSelected: (String languageCode) {
        LanguageUtil.changeLanguage(context, languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸 '),
              const SizedBox(width: 8),
              Text('english'.tr()),
              if (context.locale.languageCode == 'en')
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ar',
          child: Row(
            children: [
              const Text('🇦🇪 '),
              const SizedBox(width: 8),
              Text('arabic'.tr()),
              if (context.locale.languageCode == 'ar')
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
