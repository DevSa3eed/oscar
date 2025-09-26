import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../../shared/widgets/microsoft_card.dart';
import '../../../../shared/services/report_share_service.dart';
import '../../domain/entities/duty_report.dart';

@RoutePage()
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _selectedPeriod = 'daily';
  DateTime _selectedDate = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isDatePickerLoading = false;

  @override
  void initState() {
    super.initState();
    // Load initial report
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsControllerProvider);
    final theme = Theme.of(context);

    return AppNavigation(
      currentRoute: '/reports',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Simplified Period Selection
              _buildPeriodSelector(context, theme),
              const SizedBox(height: 16),

              // Content Area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: reportsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : reportsState.errorMessage != null
                      ? _buildErrorState(context, reportsState.errorMessage!)
                      : reportsState.currentReport == null
                      ? _buildEmptyState(context, theme)
                      : _buildReportContent(
                          context,
                          theme,
                          reportsState.currentReport!,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          // Wide layout - horizontal arrangement
          return Row(
            children: [
              // Period Toggle Buttons
              Expanded(
                flex: 2,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'daily',
                      label: Text('Daily'),
                      icon: Icon(Icons.today, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'weekly',
                      label: Text('Weekly'),
                      icon: Icon(Icons.date_range, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'monthly',
                      label: Text('Monthly'),
                      icon: Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (Set<String> selection) {
                    if (selection.isNotEmpty) {
                      _selectPeriod(selection.first);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Date/Period Selection
              Expanded(child: _buildDateSelector(context, theme)),
            ],
          );
        } else {
          // Narrow layout - vertical arrangement
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period Toggle Buttons
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'daily',
                    label: Text('Daily'),
                    icon: Icon(Icons.today, size: 16),
                  ),
                  ButtonSegment<String>(
                    value: 'weekly',
                    label: Text('Weekly'),
                    icon: Icon(Icons.date_range, size: 16),
                  ),
                  ButtonSegment<String>(
                    value: 'monthly',
                    label: Text('Monthly'),
                    icon: Icon(Icons.calendar_month, size: 16),
                  ),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> selection) {
                  if (selection.isNotEmpty) {
                    _selectPeriod(selection.first);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Date/Period Selection
              _buildDateSelector(context, theme),
            ],
          );
        }
      },
    );
  }

  Widget _buildDateSelector(BuildContext context, ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: _isDatePickerLoading ? null : () => _showDatePicker(context),
      icon: _isDatePickerLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_getDateIcon(), size: 16),
      label: Text(_getDateDisplayText()),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  IconData _getDateIcon() {
    switch (_selectedPeriod) {
      case 'daily':
        return Icons.calendar_today;
      case 'weekly':
        return Icons.date_range;
      case 'monthly':
        return Icons.calendar_month;
      default:
        return Icons.calendar_today;
    }
  }

  String _getDateDisplayText() {
    switch (_selectedPeriod) {
      case 'daily':
        return DateFormat('MMMM d, y').format(_selectedDate);
      case 'weekly':
        return 'Week of ${DateFormat('MMM d').format(_selectedDate)}';
      case 'monthly':
        return DateFormat(
          'MMMM y',
        ).format(DateTime(_selectedYear, _selectedMonth));
      default:
        return '';
    }
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: MicrosoftCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _onRefresh(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        // Reset to daily report
                        setState(() {
                          _selectedPeriod = 'daily';
                          _selectedDate = DateTime.now();
                        });
                        _generateReport();
                      },
                      icon: const Icon(Icons.home, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.assessment,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Report Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ThemeData theme, report) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export/Share Actions
          _buildReportActions(context, theme, report),
          const SizedBox(height: 16),

          // Report Summary Card
          MicrosoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getReportDateRange(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Summary Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryStat(
                        context,
                        'Total',
                        report.totalDutyPersons.toString(),
                        Icons.people,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryStat(
                        context,
                        'Present',
                        report.presentCount.toString(),
                        Icons.check_circle,
                        theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryStat(
                        context,
                        'Absent',
                        report.absentCount.toString(),
                        Icons.cancel,
                        theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Compliance Rate
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        (report.compliancePercentage >= 80
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (report.compliancePercentage >= 80
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.error)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: report.compliancePercentage >= 80
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compliance Rate',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${report.compliancePercentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: report.compliancePercentage >= 80
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Issues Section
          if (report.issues.isNotEmpty) ...[
            Text(
              'Issues (${report.issues.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...report.issues
                .map(
                  (issue) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: MicrosoftCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.warning,
                            color: theme.colorScheme.error,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          issue.dutyPersonName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(issue.dutyPersonRole),
                            const SizedBox(height: 4),
                            // Display actual issues
                            if (issue.issues.isNotEmpty) ...[
                              Text(
                                'Issues: ${issue.issues.join(', ')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              DateFormat('MMM d, y').format(issue.checkDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ] else ...[
            MicrosoftCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withValues(
                          alpha: 0.1,
                        ),
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
                      'No Issues Reported',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All personnel are compliant',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportActions(
    BuildContext context,
    ThemeData theme,
    DutyReport report,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          // Wide layout - single share button
          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showShareOptions(context, report),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share Report'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Narrow layout - single share button
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showShareOptions(context, report),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share Report'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSummaryStat(
    BuildContext context,
    String label,
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
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getReportDateRange() {
    switch (_selectedPeriod) {
      case 'daily':
        return DateFormat('EEEE, MMMM d, y').format(_selectedDate);
      case 'weekly':
        final startOfWeek = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, y').format(endOfWeek)}';
      case 'monthly':
        return DateFormat(
          'MMMM y',
        ).format(DateTime(_selectedYear, _selectedMonth));
      default:
        return '';
    }
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _generateReport();
  }

  Future<void> _showDatePicker(BuildContext context) async {
    switch (_selectedPeriod) {
      case 'daily':
        await _selectDate(context);
        break;
      case 'weekly':
        await _selectWeek(context);
        break;
      case 'monthly':
        await _selectMonth(context);
        break;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() {
      _isDatePickerLoading = true;
    });

    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
        _generateReport();
      }
    } finally {
      setState(() {
        _isDatePickerLoading = false;
      });
    }
  }

  Future<void> _selectWeek(BuildContext context) async {
    setState(() {
      _isDatePickerLoading = true;
    });

    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
        _generateReport();
      }
    } finally {
      setState(() {
        _isDatePickerLoading = false;
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    setState(() {
      _isDatePickerLoading = true;
    });

    try {
      final navigator = Navigator.of(context);
      final year = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
        ),
      );

      if (year != null && mounted) {
        final month = await showDialog<int>(
          context: navigator.context,
          builder: (context) => AlertDialog(
            title: const Text('Select Month'),
            content: SizedBox(
              width: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  return ListTile(
                    title: Text(
                      DateFormat('MMMM').format(DateTime(year, month)),
                    ),
                    onTap: () => Navigator.pop(context, month),
                  );
                },
              ),
            ),
          ),
        );

        if (month != null) {
          setState(() {
            _selectedYear = year;
            _selectedMonth = month;
          });
          _generateReport();
        }
      }
    } finally {
      setState(() {
        _isDatePickerLoading = false;
      });
    }
  }

  void _generateReport() {
    switch (_selectedPeriod) {
      case 'daily':
        ref.read(reportsControllerProvider.notifier).loadDashboardData();
        break;
      case 'weekly':
        final startOfWeek = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        ref
            .read(reportsControllerProvider.notifier)
            .generateWeeklyReport(startDate: startOfWeek, endDate: endOfWeek);
        break;
      case 'monthly':
        ref
            .read(reportsControllerProvider.notifier)
            .generateMonthlyReport(year: _selectedYear, month: _selectedMonth);
        break;
    }
  }

  Future<void> _onRefresh() async {
    _generateReport();
    // Wait for the loading state to complete
    while (ref.read(reportsControllerProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Show share options dialog
  void _showShareOptions(BuildContext context, DutyReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ShareOptionsBottomSheet(
        report: report,
        dateRange: _getReportDateRange(),
      ),
    );
  }
}

/// Bottom sheet widget for share options
class _ShareOptionsBottomSheet extends StatelessWidget {
  final DutyReport report;
  final String dateRange;

  const _ShareOptionsBottomSheet({
    required this.report,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Share Report',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateRange,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Share options
          _buildShareOption(
            context,
            icon: Icons.text_fields,
            title: 'Share as Text',
            subtitle: 'Share report summary as text',
            onTap: () => _shareAsText(context),
          ),
          const SizedBox(height: 12),
          _buildShareOption(
            context,
            icon: Icons.picture_as_pdf,
            title: 'Share as PDF',
            subtitle: 'Generate and share PDF document',
            onTap: () => _shareAsPdf(context),
          ),
          const SizedBox(height: 12),
          _buildShareOption(
            context,
            icon: Icons.table_chart,
            title: 'Share as Excel',
            subtitle: 'Generate and share Excel spreadsheet',
            onTap: () => _shareAsExcel(context),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsText(BuildContext context) async {
    Navigator.pop(context);

    try {
      await ReportShareService.shareAsText(
        report: report,
        dateRange: dateRange,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsPdf(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ReportShareService.shareAsPdf(report: report, dateRange: dateRange);

      // Close loading dialog
      if (context.mounted) navigator.pop();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) navigator.pop();

      // Show error message
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsExcel(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ReportShareService.shareAsExcel(
        report: report,
        dateRange: dateRange,
      );

      // Close loading dialog
      if (context.mounted) navigator.pop();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) navigator.pop();

      // Show error message
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to share Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
