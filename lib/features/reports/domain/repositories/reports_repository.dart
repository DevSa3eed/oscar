import '../entities/duty_report.dart';
import '../../../../core/utils/result.dart';

abstract class ReportsRepository {
  Future<Result<DutyReport>> generateDailyReport(DateTime date);

  Future<Result<DutyReport>> generateWeeklyReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<DutyReport>> generateMonthlyReport({
    required int year,
    required int month,
  });

  Future<Result<List<DutyReport>>> getReportsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<void>> saveReport(DutyReport report);
}
