import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/features/creation/presentation/screens/create_report_screen.dart';
import 'package:ygc_reports/features/reports/picker/presentation/screens/report_picker_screen.dart';
import 'package:ygc_reports/features/reports/saved/presentation/screens/saved_reports_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  routes: [
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
