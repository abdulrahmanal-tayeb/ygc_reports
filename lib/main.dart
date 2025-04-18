import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/config/router/app_router.dart';
import 'package:ygc_reports/config/theme/dark_theme.dart';
import 'package:ygc_reports/config/theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
      debugPrint("Access Granted");

      runApp(
        MultiProvider(
          providers: [
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
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'YGCReports',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}