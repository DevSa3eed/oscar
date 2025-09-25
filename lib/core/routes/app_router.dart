import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/duty/presentation/pages/supervisor_home_page.dart';
import '../../features/duty/presentation/pages/duty_check_page.dart';
import '../../features/duty/presentation/pages/duty_assignment_page.dart';
import '../../features/reports/presentation/pages/hod_dashboard_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/reports/presentation/pages/reminder_email_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/duty/domain/entities/duty_person.dart';
import '../../features/reports/domain/entities/duty_report.dart';
import '../navigation/auth_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash screen (initial route)
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),

    // Public auth routes (no authentication required)
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Protected routes (require authentication)
    AutoRoute(
      page: SupervisorHomeRoute.page,
      path: '/supervisor-home',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: DutyCheckRoute.page,
      path: '/duty-check',
      guards: [AuthGuard()],
    ),

    // HOD routes (require authentication)
    AutoRoute(
      page: HodDashboardRoute.page,
      path: '/hod-dashboard',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: DutyAssignmentRoute.page,
      path: '/duty-assignment',
      guards: [AuthGuard()],
    ),
    AutoRoute(page: ReportsRoute.page, path: '/reports', guards: [AuthGuard()]),
    AutoRoute(
      page: ReminderEmailRoute.page,
      path: '/reminder-email',
      guards: [AuthGuard()],
    ),

    // Profile route (require authentication)
    AutoRoute(page: ProfileRoute.page, path: '/profile', guards: [AuthGuard()]),
  ];
}
