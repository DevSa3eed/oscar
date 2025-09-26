import '../../domain/entities/duty_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Parses Firestore Timestamp/String/DateTime into DateTime
DateTime? _parseFirestoreTimestamp(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else if (timestamp is DateTime) {
    return timestamp;
  }
  return null;
}

class DutyReportModel {
  final String id;
  final DateTime reportDate;
  final int totalDutyPersons;
  final int presentCount;
  final int absentCount;
  final int issuesCount;
  final double compliancePercentage;
  final List<DutyIssueModel> issues;
  final String generatedBy;
  final DateTime? createdAt;

  const DutyReportModel({
    required this.id,
    required this.reportDate,
    required this.totalDutyPersons,
    required this.presentCount,
    required this.absentCount,
    required this.issuesCount,
    required this.compliancePercentage,
    required this.issues,
    required this.generatedBy,
    this.createdAt,
  });

  factory DutyReportModel.fromJson(Map<String, dynamic> json) {
    return DutyReportModel(
      id: json['id'] as String,
      reportDate: _parseFirestoreTimestamp(json['reportDate'])!,
      totalDutyPersons: json['totalDutyPersons'] as int,
      presentCount: json['presentCount'] as int,
      absentCount: json['absentCount'] as int,
      issuesCount: json['issuesCount'] as int,
      compliancePercentage: (json['compliancePercentage'] as num).toDouble(),
      issues: (json['issues'] as List<dynamic>)
          .map((e) => DutyIssueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedBy: json['generatedBy'] as String,
      createdAt: _parseFirestoreTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportDate': reportDate.toIso8601String(),
      'totalDutyPersons': totalDutyPersons,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'issuesCount': issuesCount,
      'compliancePercentage': compliancePercentage,
      'issues': issues.map((e) => e.toJson()).toList(),
      'generatedBy': generatedBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory DutyReportModel.fromEntity(DutyReport report) {
    return DutyReportModel(
      id: report.id,
      reportDate: report.reportDate,
      totalDutyPersons: report.totalDutyPersons,
      presentCount: report.presentCount,
      absentCount: report.absentCount,
      issuesCount: report.issuesCount,
      compliancePercentage: report.compliancePercentage,
      issues: report.issues
          .map((issue) => DutyIssueModel.fromEntity(issue))
          .toList(),
      generatedBy: report.generatedBy,
      createdAt: report.createdAt,
    );
  }

  DutyReport toEntity() {
    return DutyReport(
      id: id,
      reportDate: reportDate,
      totalDutyPersons: totalDutyPersons,
      presentCount: presentCount,
      absentCount: absentCount,
      issuesCount: issuesCount,
      compliancePercentage: compliancePercentage,
      issues: issues.map((issue) => issue.toEntity()).toList(),
      generatedBy: generatedBy,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyReportModel &&
        other.id == id &&
        other.reportDate == reportDate &&
        other.totalDutyPersons == totalDutyPersons &&
        other.presentCount == presentCount &&
        other.absentCount == absentCount &&
        other.issuesCount == issuesCount &&
        other.compliancePercentage == compliancePercentage &&
        _listEquals(other.issues, issues) &&
        other.generatedBy == generatedBy &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      reportDate,
      totalDutyPersons,
      presentCount,
      absentCount,
      issuesCount,
      compliancePercentage,
      Object.hashAll(issues),
      generatedBy,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'DutyReportModel(id: $id, reportDate: $reportDate, totalDutyPersons: $totalDutyPersons, presentCount: $presentCount, absentCount: $absentCount, issuesCount: $issuesCount, compliancePercentage: $compliancePercentage, issues: $issues, generatedBy: $generatedBy, createdAt: $createdAt)';
  }
}

class DutyIssueModel {
  final String dutyPersonId;
  final String dutyPersonName;
  final String dutyPersonRole;
  final String dutyPersonEmail;
  final List<String> issues;
  final DateTime checkDate;
  final String checkedBy;

  const DutyIssueModel({
    required this.dutyPersonId,
    required this.dutyPersonName,
    required this.dutyPersonRole,
    required this.dutyPersonEmail,
    required this.issues,
    required this.checkDate,
    required this.checkedBy,
  });

  factory DutyIssueModel.fromJson(Map<String, dynamic> json) {
    return DutyIssueModel(
      dutyPersonId: json['dutyPersonId'] as String,
      dutyPersonName: json['dutyPersonName'] as String,
      dutyPersonRole: json['dutyPersonRole'] as String,
      dutyPersonEmail: json['dutyPersonEmail'] as String,
      issues: (json['issues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      checkDate: _parseFirestoreTimestamp(json['checkDate'])!,
      checkedBy: json['checkedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dutyPersonId': dutyPersonId,
      'dutyPersonName': dutyPersonName,
      'dutyPersonRole': dutyPersonRole,
      'dutyPersonEmail': dutyPersonEmail,
      'issues': issues,
      'checkDate': checkDate.toIso8601String(),
      'checkedBy': checkedBy,
    };
  }

  factory DutyIssueModel.fromEntity(DutyIssue issue) {
    return DutyIssueModel(
      dutyPersonId: issue.dutyPersonId,
      dutyPersonName: issue.dutyPersonName,
      dutyPersonRole: issue.dutyPersonRole,
      dutyPersonEmail: issue.dutyPersonEmail,
      issues: issue.issues,
      checkDate: issue.checkDate,
      checkedBy: issue.checkedBy,
    );
  }

  DutyIssue toEntity() {
    return DutyIssue(
      dutyPersonId: dutyPersonId,
      dutyPersonName: dutyPersonName,
      dutyPersonRole: dutyPersonRole,
      dutyPersonEmail: dutyPersonEmail,
      issues: issues,
      checkDate: checkDate,
      checkedBy: checkedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyIssueModel &&
        other.dutyPersonId == dutyPersonId &&
        other.dutyPersonName == dutyPersonName &&
        other.dutyPersonRole == dutyPersonRole &&
        other.dutyPersonEmail == dutyPersonEmail &&
        _listEquals(other.issues, issues) &&
        other.checkDate == checkDate &&
        other.checkedBy == checkedBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      dutyPersonId,
      dutyPersonName,
      dutyPersonRole,
      dutyPersonEmail,
      Object.hashAll(issues),
      checkDate,
      checkedBy,
    );
  }

  @override
  String toString() {
    return 'DutyIssueModel(dutyPersonId: $dutyPersonId, dutyPersonName: $dutyPersonName, dutyPersonRole: $dutyPersonRole, dutyPersonEmail: $dutyPersonEmail, issues: $issues, checkDate: $checkDate, checkedBy: $checkedBy)';
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
