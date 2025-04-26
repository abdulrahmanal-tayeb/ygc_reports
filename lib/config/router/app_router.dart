import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/features/creation/presentation/screens/create_report_screen.dart';
import 'package:ygc_reports/features/reports/picker/presentation/screens/report_picker_screen.dart';
import 'package:ygc_reports/features/reports/saved/presentation/screens/saved_reports_screen.dart';

/// Define the navigator key thay might be used for splash-screen navitation purposes.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Defines the parent router
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  routes: [

    // The home screen here is the [CreateReportScreen]
    GoRoute(
      path: '/',
      name: "home",
      pageBuilder: (context, state) => NoTransitionPage(
        child: CreateReportScreen(),
      )
    ),
    GoRoute(
      name: 'reportPicker',
      path: '/reportPicker',
      builder: (context, state) => const ReportPickerScreen(),
    ),
    GoRoute(
      name: 'savedReports',
      path: '/saved',
      builder: (context, state) => const SavedReportsScreen(),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text("Error Occured")),
  ),
);
