class DutyReport {
  final String id;
  final DateTime reportDate;
  final int totalDutyPersons;
  final int presentCount;
  final int absentCount;
  final int issuesCount;
  final double compliancePercentage;
  final List<DutyIssue> issues;
  final String generatedBy;
  final DateTime? createdAt;

  const DutyReport({
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

  factory DutyReport.fromJson(Map<String, dynamic> json) {
    return DutyReport(
      id: json['id'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      totalDutyPersons: json['totalDutyPersons'] as int,
      presentCount: json['presentCount'] as int,
      absentCount: json['absentCount'] as int,
      issuesCount: json['issuesCount'] as int,
      compliancePercentage: (json['compliancePercentage'] as num).toDouble(),
      issues: (json['issues'] as List<dynamic>)
          .map((e) => DutyIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedBy: json['generatedBy'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
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

  DutyReport copyWith({
    String? id,
    DateTime? reportDate,
    int? totalDutyPersons,
    int? presentCount,
    int? absentCount,
    int? issuesCount,
    double? compliancePercentage,
    List<DutyIssue>? issues,
    String? generatedBy,
    DateTime? createdAt,
  }) {
    return DutyReport(
      id: id ?? this.id,
      reportDate: reportDate ?? this.reportDate,
      totalDutyPersons: totalDutyPersons ?? this.totalDutyPersons,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      issuesCount: issuesCount ?? this.issuesCount,
      compliancePercentage: compliancePercentage ?? this.compliancePercentage,
      issues: issues ?? this.issues,
      generatedBy: generatedBy ?? this.generatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyReport &&
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
    return 'DutyReport(id: $id, reportDate: $reportDate, totalDutyPersons: $totalDutyPersons, presentCount: $presentCount, absentCount: $absentCount, issuesCount: $issuesCount, compliancePercentage: $compliancePercentage, issues: $issues, generatedBy: $generatedBy, createdAt: $createdAt)';
  }
}

class DutyIssue {
  final String dutyPersonId;
  final String dutyPersonName;
  final String dutyPersonRole;
  final String dutyPersonEmail;
  final List<String> issues;
  final DateTime checkDate;
  final String checkedBy;

  const DutyIssue({
    required this.dutyPersonId,
    required this.dutyPersonName,
    required this.dutyPersonRole,
    required this.dutyPersonEmail,
    required this.issues,
    required this.checkDate,
    required this.checkedBy,
  });

  factory DutyIssue.fromJson(Map<String, dynamic> json) {
    return DutyIssue(
      dutyPersonId: json['dutyPersonId'] as String,
      dutyPersonName: json['dutyPersonName'] as String,
      dutyPersonRole: json['dutyPersonRole'] as String,
      dutyPersonEmail: json['dutyPersonEmail'] as String,
      issues: (json['issues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      checkDate: DateTime.parse(json['checkDate'] as String),
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

  DutyIssue copyWith({
    String? dutyPersonId,
    String? dutyPersonName,
    String? dutyPersonRole,
    String? dutyPersonEmail,
    List<String>? issues,
    DateTime? checkDate,
    String? checkedBy,
  }) {
    return DutyIssue(
      dutyPersonId: dutyPersonId ?? this.dutyPersonId,
      dutyPersonName: dutyPersonName ?? this.dutyPersonName,
      dutyPersonRole: dutyPersonRole ?? this.dutyPersonRole,
      dutyPersonEmail: dutyPersonEmail ?? this.dutyPersonEmail,
      issues: issues ?? this.issues,
      checkDate: checkDate ?? this.checkDate,
      checkedBy: checkedBy ?? this.checkedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyIssue &&
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
    return 'DutyIssue(dutyPersonId: $dutyPersonId, dutyPersonName: $dutyPersonName, dutyPersonRole: $dutyPersonRole, dutyPersonEmail: $dutyPersonEmail, issues: $issues, checkDate: $checkDate, checkedBy: $checkedBy)';
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
