import '../../domain/entities/duty_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/firestore_reports_datasource.dart';
import '../models/duty_report_model.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

class FirestoreReportsRepositoryImpl implements ReportsRepository {
  final FirestoreReportsDataSource _dataSource;

  FirestoreReportsRepositoryImpl({
    required FirestoreReportsDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<DutyReport>> generateDailyReport(DateTime date) async {
    try {
      final reportModel = await _dataSource.generateTodayReport();
      return Result.success(reportModel.toEntity());
    } catch (e) {
      return Result.failure(ServerError('Failed to generate daily report: $e'));
    }
  }

  @override
  Future<Result<DutyReport>> generateWeeklyReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportModels = await _dataSource.getReportsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (reportModels.isNotEmpty) {
        // Aggregate weekly data from daily reports
        final weeklyReport = _aggregateWeeklyReport(
          reportModels,
          startDate,
          endDate,
        );
        return Result.success(weeklyReport);
      } else {
        // Generate a basic weekly report if no daily reports exist
        final weeklyReport = _generateEmptyWeeklyReport(startDate, endDate);
        return Result.success(weeklyReport);
      }
    } catch (e) {
      return Result.failure(
        ServerError('Failed to generate weekly report: $e'),
      );
    }
  }

  @override
  Future<Result<DutyReport>> generateMonthlyReport({
    required int year,
    required int month,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(
        year,
        month + 1,
        1,
      ).subtract(const Duration(days: 1));

      final reportModels = await _dataSource.getReportsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (reportModels.isNotEmpty) {
        // Aggregate monthly data from daily reports
        final monthlyReport = _aggregateMonthlyReport(
          reportModels,
          year,
          month,
        );
        return Result.success(monthlyReport);
      } else {
        // Generate a basic monthly report if no daily reports exist
        final monthlyReport = _generateEmptyMonthlyReport(year, month);
        return Result.success(monthlyReport);
      }
    } catch (e) {
      return Result.failure(
        ServerError('Failed to generate monthly report: $e'),
      );
    }
  }

  @override
  Future<Result<List<DutyReport>>> getReportsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportModels = await _dataSource.getReportsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      final reports = reportModels.map((model) => model.toEntity()).toList();
      return Result.success(reports);
    } catch (e) {
      return Result.failure(
        ServerError('Failed to get reports by date range: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveReport(DutyReport report) async {
    try {
      final reportModel = DutyReportModel.fromEntity(report);
      await _dataSource.saveReport(reportModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to save report: $e'));
    }
  }

  DutyReport _aggregateWeeklyReport(
    List<DutyReportModel> dailyReports,
    DateTime startDate,
    DateTime endDate,
  ) {
    final totalPersons = dailyReports.isNotEmpty
        ? dailyReports
              .map((r) => r.totalDutyPersons)
              .reduce((a, b) => a > b ? a : b)
        : 0;
    final totalPresentPersons = dailyReports.fold(
      0,
      (sum, r) => sum + r.presentCount,
    );
    final totalAbsentPersons = dailyReports.fold(
      0,
      (sum, r) => sum + r.absentCount,
    );
    final totalIssues = dailyReports.fold(0, (sum, r) => sum + r.issuesCount);

    final avgCompliance = dailyReports.isNotEmpty
        ? dailyReports.fold(0.0, (sum, r) => sum + r.compliancePercentage) /
              dailyReports.length
        : 0.0;

    // Aggregate issues from daily reports
    final aggregatedIssues = <DutyIssue>[];
    for (final dailyReport in dailyReports) {
      for (final issue in dailyReport.issues) {
        aggregatedIssues.add(issue.toEntity());
      }
    }

    return DutyReport(
      id: '',
      reportDate: startDate,
      totalDutyPersons: totalPersons,
      presentCount: totalPresentPersons,
      absentCount: totalAbsentPersons,
      issuesCount: totalIssues,
      compliancePercentage: avgCompliance.toDouble(),
      issues: aggregatedIssues,
      generatedBy: 'system',
      createdAt: DateTime.now(),
    );
  }

  DutyReport _aggregateMonthlyReport(
    List<DutyReportModel> dailyReports,
    int year,
    int month,
  ) {
    final totalPersons = dailyReports.isNotEmpty
        ? dailyReports
              .map((r) => r.totalDutyPersons)
              .reduce((a, b) => a > b ? a : b)
        : 0;
    final totalPresentPersons = dailyReports.fold(
      0,
      (sum, r) => sum + r.presentCount,
    );
    final totalAbsentPersons = dailyReports.fold(
      0,
      (sum, r) => sum + r.absentCount,
    );
    final totalIssues = dailyReports.fold(0, (sum, r) => sum + r.issuesCount);

    final avgCompliance = dailyReports.isNotEmpty
        ? dailyReports.fold(0.0, (sum, r) => sum + r.compliancePercentage) /
              dailyReports.length
        : 0.0;

    // Aggregate issues from daily reports
    final aggregatedIssues = <DutyIssue>[];
    for (final dailyReport in dailyReports) {
      for (final issue in dailyReport.issues) {
        aggregatedIssues.add(issue.toEntity());
      }
    }

    return DutyReport(
      id: '',
      reportDate: DateTime(year, month, 1),
      totalDutyPersons: totalPersons,
      presentCount: totalPresentPersons,
      absentCount: totalAbsentPersons,
      issuesCount: totalIssues,
      compliancePercentage: avgCompliance.toDouble(),
      issues: aggregatedIssues,
      generatedBy: 'system',
      createdAt: DateTime.now(),
    );
  }

  DutyReport _generateEmptyWeeklyReport(DateTime startDate, DateTime endDate) {
    return DutyReport(
      id: '',
      reportDate: startDate,
      totalDutyPersons: 0,
      presentCount: 0,
      absentCount: 0,
      issuesCount: 0,
      compliancePercentage: 0.0,
      issues: [],
      generatedBy: 'system',
      createdAt: DateTime.now(),
    );
  }

  DutyReport _generateEmptyMonthlyReport(int year, int month) {
    return DutyReport(
      id: '',
      reportDate: DateTime(year, month, 1),
      totalDutyPersons: 0,
      presentCount: 0,
      absentCount: 0,
      issuesCount: 0,
      compliancePercentage: 0.0,
      issues: [],
      generatedBy: 'system',
      createdAt: DateTime.now(),
    );
  }
}
