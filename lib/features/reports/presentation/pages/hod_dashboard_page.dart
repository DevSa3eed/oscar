import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/reports_controller.dart';
import '../widgets/issue_list_item.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/navigation/app_navigation.dart';

@RoutePage()
class HodDashboardPage extends ConsumerStatefulWidget {
  const HodDashboardPage({super.key});

  @override
  ConsumerState<HodDashboardPage> createState() => _HodDashboardPageState();
}

class _HodDashboardPageState extends ConsumerState<HodDashboardPage> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    try {
      print('📊 [HOD_DASHBOARD] Building HodDashboardPage');
      final reportsState = ref.watch(reportsControllerProvider);
      print(
        '📊 [HOD_DASHBOARD] Reports state: isLoading=${reportsState.isLoading}, error=${reportsState.errorMessage}',
      );

      // Initialize reports controller on first build only
      if (!_isInitialized) {
        print('📊 [HOD_DASHBOARD] Initializing reports controller...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isInitialized) {
            _isInitialized = true;
            print('📊 [HOD_DASHBOARD] Calling loadDashboardData...');
            ref.read(reportsControllerProvider.notifier).loadDashboardData();
          }
        });
      }

      return AppNavigation(
        currentRoute: '/hod-dashboard',
        child: SafeArea(
          child: reportsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reportsState.errorMessage != null
              ? _buildErrorState(context, reportsState.errorMessage!)
              : _buildDashboardContent(context, reportsState),
        ),
      );
    } catch (e, stackTrace) {
      print('📊 [HOD_DASHBOARD] CRITICAL ERROR building HodDashboardPage: $e');
      print('📊 [HOD_DASHBOARD] Stack trace: $stackTrace');
      print('📊 [HOD_DASHBOARD] Error type: ${e.runtimeType}');

      return Scaffold(
        backgroundColor: Colors.red.shade100,
        appBar: AppBar(
          title: const Text('HOD Dashboard Error'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'HodDashboardPage Build Error:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Error: $e'),
              const SizedBox(height: 16),
              const Text(
                'Stack Trace:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                stackTrace.toString(),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Retry Build'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref
                  .read(reportsControllerProvider.notifier)
                  .loadDashboardData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    ReportsState reportsState,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards Row
            _buildStatsRow(context, theme, reportsState),
            const SizedBox(height: 24),

            // Issues Section
            _buildIssuesSection(context, theme, reportsState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    ThemeData theme,
    ReportsState reportsState,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Personnel',
            reportsState.totalDutyPersons.toString(),
            Icons.people,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Active Issues',
            reportsState.issuesCount.toString(),
            Icons.warning,
            theme.colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Compliance',
            '${reportsState.compliancePercentage.toStringAsFixed(0)}%',
            Icons.trending_up,
            theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesSection(
    BuildContext context,
    ThemeData theme,
    ReportsState reportsState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Issues',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (reportsState.issuesCount > 0)
              TextButton.icon(
                onPressed: () => context.router.push(ReminderEmailRoute()),
                icon: const Icon(Icons.email, size: 16),
                label: const Text('Send Reminders'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: reportsState.currentReport?.issues.isEmpty ?? true
              ? _buildNoIssuesState(context, theme)
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: reportsState.currentReport?.issues.length ?? 0,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final issue = reportsState.currentReport!.issues[index];
                    return IssueListItem(
                      issue: issue,
                      onSendReminder: () =>
                          context.router.push(ReminderEmailRoute(issue: issue)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoIssuesState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'All Clear!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No issues reported today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
