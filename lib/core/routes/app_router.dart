import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/duty/presentation/pages/supervisor_home_page.dart';
import '../../features/duty/presentation/pages/duty_check_page.dart';
import '../../features/duty/presentation/pages/duty_assignment_page.dart';
import '../../features/duty/presentation/pages/location_management_page.dart';
import '../../features/reports/presentation/pages/hod_dashboard_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/reports/presentation/pages/reminder_email_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/duty/domain/entities/duty_person.dart';
import '../../features/reports/domain/entities/duty_report.dart';
import '../navigation/auth_guard.dart';
import '../navigation/shared_axis_transition.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash screen (initial route) - no transition needed
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),

    // Public auth routes (no authentication required)
    CustomRoute(
      page: LoginRoute.page,
      path: '/login',
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: RegisterRoute.page,
      path: '/register',
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),

    // Protected routes (require authentication)
    CustomRoute(
      page: SupervisorHomeRoute.page,
      path: '/supervisor-home',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: DutyCheckRoute.page,
      path: '/duty-check',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),

    // HOD routes (require authentication)
    CustomRoute(
      page: HodDashboardRoute.page,
      path: '/hod-dashboard',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: DutyAssignmentRoute.page,
      path: '/duty-assignment',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: LocationManagementRoute.page,
      path: '/location-management',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: ReportsRoute.page,
      path: '/reports',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
    CustomRoute(
      page: ReminderEmailRoute.page,
      path: '/reminder-email',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),

    // Profile route (require authentication)
    CustomRoute(
      page: ProfileRoute.page,
      path: '/profile',
      guards: [AuthGuard()],
      transitionsBuilder: sharedAxisTransition,
      duration: const Duration(milliseconds: 280),
    ),
  ];
}
