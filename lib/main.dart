import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart'; // Generated localization file
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/config/router/app_router.dart';
import 'package:ygc_reports/config/theme/dark_theme.dart';
import 'package:ygc_reports/config/theme/light_theme.dart';
import 'package:ygc_reports/providers/locale_provider.dart';

import 'providers/ygc_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
      debugPrint("Access Granted");

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => YgcProvider()),
            ChangeNotifierProvider(create: (_) => LocaleProvider())
          ],
          child: const YGCReports(),
        ),
      );
    } else {
      debugPrint("Permission denied");
      await openAppSettings();
    }
  } catch (e) {
    debugPrint("Permission request encountered an error: $e");
  }
}

class YGCReports extends StatelessWidget {
  const YGCReports({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'YGCReports',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,

      locale: localeProvider.locale,
      // 🔤 Localization settings
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated class
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (localeProvider.locale != null) return localeProvider.locale;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
