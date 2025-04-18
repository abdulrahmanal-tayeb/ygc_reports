import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/features/home/presentation/screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      name: "home",
      pageBuilder: (context, state) => NoTransitionPage(
        child: HomeScreen(),
      )
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text(state.error.toString())),
  ),
);
