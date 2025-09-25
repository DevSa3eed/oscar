import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/duty_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/services/dependency_injection.dart';

part 'reports_controller.g.dart';

class ReportsState {
  final bool isLoading;
  final List<DutyReport> reports;
  final DutyReport? currentReport;
  final String? errorMessage;
  final int totalDutyPersons;
  final int issuesCount;
  final double compliancePercentage;

  const ReportsState({
    this.isLoading = false,
    this.reports = const [],
    this.currentReport,
    this.errorMessage,
    this.totalDutyPersons = 0,
    this.issuesCount = 0,
    this.compliancePercentage = 0.0,
  });

  ReportsState copyWith({
    bool? isLoading,
    List<DutyReport>? reports,
    DutyReport? currentReport,
    String? errorMessage,
    int? totalDutyPersons,
    int? issuesCount,
    double? compliancePercentage,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      currentReport: currentReport ?? this.currentReport,
      errorMessage: errorMessage ?? this.errorMessage,
      totalDutyPersons: totalDutyPersons ?? this.totalDutyPersons,
      issuesCount: issuesCount ?? this.issuesCount,
      compliancePercentage: compliancePercentage ?? this.compliancePercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportsState &&
        other.isLoading == isLoading &&
        _listEquals(other.reports, reports) &&
        other.currentReport == currentReport &&
        other.errorMessage == errorMessage &&
        other.totalDutyPersons == totalDutyPersons &&
        other.issuesCount == issuesCount &&
        other.compliancePercentage == compliancePercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      Object.hashAll(reports),
      currentReport,
      errorMessage,
      totalDutyPersons,
      issuesCount,
      compliancePercentage,
    );
  }

  @override
  String toString() {
    return 'ReportsState(isLoading: $isLoading, reports: $reports, currentReport: $currentReport, errorMessage: $errorMessage, totalDutyPersons: $totalDutyPersons, issuesCount: $issuesCount, compliancePercentage: $compliancePercentage)';
  }
}

// Helper function for list equality
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

@riverpod
class ReportsController extends _$ReportsController {
  late final ReportsRepository _reportsRepository;

  @override
  ReportsState build() {
    _reportsRepository = getIt<ReportsRepository>();
    return const ReportsState();
  }

  Future<void> loadDashboardData() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _reportsRepository.generateDailyReport(
        DateTime.now(),
      );
      if (!ref.mounted) return;

      result.when(
        success: (report) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            currentReport: report,
            totalDutyPersons: report.totalDutyPersons,
            issuesCount: report.issuesCount,
            compliancePercentage: report.compliancePercentage,
          );
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data: $e',
      );
    }
  }

  Future<void> generateWeeklyReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _reportsRepository.generateWeeklyReport(
        startDate: startDate,
        endDate: endDate,
      );

      result.when(
        success: (report) {
          state = state.copyWith(isLoading: false, currentReport: report);
        },
        failure: (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate weekly report: $e',
      );
    }
  }

  Future<void> generateMonthlyReport({
    required int year,
    required int month,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _reportsRepository.generateMonthlyReport(
        year: year,
        month: month,
      );

      result.when(
        success: (report) {
          state = state.copyWith(isLoading: false, currentReport: report);
        },
        failure: (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate monthly report: $e',
      );
    }
  }

  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverError: (message) => message,
      networkError: (message) => message,
      authError: (message) => message,
      validationError: (message) => message,
      notFoundError: (message) => message,
      permissionError: (message) => message,
      unknownError: (message) => message,
    );
  }
}
