import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../routes/app_router.dart';
import '../constants/app_constants.dart';
import '../utils/flutter_logging_config.dart';
import '../../shared/widgets/app_bar_widget.dart';

/// Navigation system with role-based layouts
class AppNavigation extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AppNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      return child; // No navigation for unauthenticated users
    }

    return Scaffold(
      appBar: _buildUniversalAppBar(context, ref, user),
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context, ref, user.role),
    );
  }

  PreferredSizeWidget _buildUniversalAppBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    final title = _getAppBarTitle(currentRoute, user.role);
    final actions = _getAppBarActions(context, ref, currentRoute, user.role);

    return AppBarWidget(
      title: title,
      showBackButton: false, // No back buttons anywhere
      actions: actions,
    );
  }

  String _getAppBarTitle(String route, String role) {
    if (route.contains('supervisor-home')) return 'Duty List';
    if (route.contains('profile')) return 'Profile';
    if (route.contains('hod-dashboard')) return 'HOD Dashboard';
    if (route.contains('duty-assignment')) return 'Duty Assignments';
    if (route.contains('reports')) return 'Reports';
    if (route.contains('reminder-email')) return 'Send Reminders';
    if (route.contains('duty-check')) return 'Duty Check';

    // Default titles based on role
    if (role == AppConstants.supervisorRole) {
      return 'Duty List';
    } else {
      return 'HOD Dashboard';
    }
  }

  List<Widget> _getAppBarActions(
    BuildContext context,
    WidgetRef ref,
    String route,
    String role,
  ) {
    // Simplified - no refresh buttons or complex actions in app bar
    return [];
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    String role,
  ) {
    final currentIndex = _getCurrentIndex(currentRoute, role);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getBottomNavItems(context, ref, role)
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToRoute(context, item.route),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline
                                          .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Text(
                                item.label,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 10,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }

  List<BottomNavItem> _getBottomNavItems(
    BuildContext context,
    WidgetRef ref,
    String role,
  ) {
    if (role == AppConstants.supervisorRole) {
      return [
        BottomNavItem(
          icon: Icons.dashboard,
          label: 'Duty List',
          route: const SupervisorHomeRoute(),
        ),
        BottomNavItem(
          icon: Icons.person,
          label: 'Profile',
          route: const ProfileRoute(),
        ),
      ];
    } else {
      return [
        BottomNavItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: const HodDashboardRoute(),
        ),
        BottomNavItem(
          icon: Icons.assignment_ind,
          label: 'Assignments',
          route: const DutyAssignmentRoute(),
        ),
        BottomNavItem(
          icon: Icons.assessment,
          label: 'Reports',
          route: const ReportsRoute(),
        ),
        BottomNavItem(
          icon: Icons.person,
          label: 'Profile',
          route: const ProfileRoute(),
        ),
      ];
    }
  }

  int _getCurrentIndex(String currentRoute, String role) {
    if (role == AppConstants.supervisorRole) {
      if (currentRoute.contains('supervisor-home')) return 0;
      if (currentRoute.contains('profile')) return 1;
      return 0; // Default to duty list
    } else {
      if (currentRoute.contains('hod-dashboard')) return 0;
      if (currentRoute.contains('duty-assignment')) return 1;
      if (currentRoute.contains('reports')) return 2;
      if (currentRoute.contains('profile')) return 3;
      return 0; // Default to dashboard
    }
  }

  void _navigateToRoute(BuildContext context, PageRouteInfo route) {
    // Add navigation debugging
    FlutterLoggingConfig.oscarLog(
      'Navigating to route: ${route.routeName}',
      category: 'NAVIGATION',
    );

    // Use navigate for clean navigation without stack issues
    try {
      context.router.navigate(route);
    } catch (e) {
      FlutterLoggingConfig.oscarLog('Navigation error: $e', category: 'ERROR');
      // Fallback to push
      context.router.push(route);
    }
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final PageRouteInfo route;

  BottomNavItem({required this.icon, required this.label, required this.route});
}
