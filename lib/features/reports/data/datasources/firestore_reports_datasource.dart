import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/duty_report_model.dart';
import '../../../duty/data/datasources/firestore_duty_datasource.dart';
import '../../../../core/constants/app_constants.dart';

abstract class FirestoreReportsDataSource {
  Future<List<DutyReportModel>> getReportsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<DutyReportModel?> getReportForDate(DateTime date);
  Future<List<DutyReportModel>> getAllReports();
  Future<DutyReportModel> generateTodayReport();
  Future<void> saveReport(DutyReportModel report);
}

class FirestoreReportsDataSourceImpl implements FirestoreReportsDataSource {
  final FirebaseFirestore _firestore;
  final FirestoreDutyDataSource _dutyDataSource;

  FirestoreReportsDataSourceImpl({
    FirebaseFirestore? firestore,
    required FirestoreDutyDataSource dutyDataSource,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _dutyDataSource = dutyDataSource;

  @override
  Future<List<DutyReportModel>> getReportsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .where(
            'reportDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('reportDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('reportDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DutyReportModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports for date range: $e');
    }
  }

  @override
  Future<DutyReportModel?> getReportForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .where(
            'reportDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('reportDate', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return DutyReportModel.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get report for date: $e');
    }
  }

  @override
  Future<List<DutyReportModel>> getAllReports() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .orderBy('reportDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DutyReportModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all reports: $e');
    }
  }

  @override
  Future<DutyReportModel> generateTodayReport() async {
    try {
      final today = DateTime.now();
      final dutyChecks = await _dutyDataSource.getDutyChecksForDate(today);
      final dutyPersons = await _dutyDataSource.getDutyPersons();

      final totalPersons = dutyPersons.length;
      final checkedPersons = dutyChecks.length;
      final presentPersons = dutyChecks
          .where((check) => check.status == 'present')
          .length;
      final absentPersons = dutyChecks
          .where((check) => check.status == 'absent')
          .length;

      final phoneIssues = dutyChecks.where((check) => check.isOnPhone).length;
      final vestIssues = dutyChecks
          .where((check) => !check.isWearingVest)
          .length;
      final punctualityIssues = dutyChecks
          .where((check) => !check.isOnTime)
          .length;

      final totalIssues = phoneIssues + vestIssues + punctualityIssues;
      final compliancePercentage = checkedPersons > 0
          ? ((checkedPersons - totalIssues) / checkedPersons * 100).round()
          : 0;

      final report = DutyReportModel(
        id: '',
        reportDate: today,
        totalDutyPersons: totalPersons,
        presentCount: presentPersons,
        absentCount: absentPersons,
        issuesCount: totalIssues,
        compliancePercentage: compliancePercentage.toDouble(),
        issues: [], // TODO: Populate with actual issues
        generatedBy: 'system',
        createdAt: DateTime.now(),
      );

      // Save the generated report
      await saveReport(report);

      return report;
    } catch (e) {
      throw Exception('Failed to generate today report: $e');
    }
  }

  @override
  Future<void> saveReport(DutyReportModel report) async {
    try {
      final data = report.toJson();
      data.remove('id'); // Remove ID from data

      if (report.id.isNotEmpty) {
        // Update existing
        await _firestore
            .collection(AppConstants.reportsCollection)
            .doc(report.id)
            .set(data);
      } else {
        // Create new
        await _firestore.collection(AppConstants.reportsCollection).add(data);
      }
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }
}
