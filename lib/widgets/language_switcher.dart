import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return DropdownButton<Locale>(
      value: localeProvider.locale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          localeProvider.setLocale(newLocale);
        }
      },
      items: context.supportedLocales.map((locale) {
        final flag = locale.languageCode == 'ar' ? '🇸🇦 Arabic' : '🇺🇸 English';
        return DropdownMenuItem(
          value: locale,
          child: Text(flag),
        );
      }).toList(),
    );
  }
}