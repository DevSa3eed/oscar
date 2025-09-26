import '../../domain/entities/duty_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DutyCheckModel {
  final String id;
  final String dutyPersonId;
  final String dutyPersonName;
  final String dutyPersonRole;
  final DateTime checkDate;
  final String status;
  final bool isOnPhone;
  final bool isWearingVest;
  final bool isOnTime;
  final String? notes;
  final String checkedBy;
  final String checkedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DutyCheckModel({
    required this.id,
    required this.dutyPersonId,
    required this.dutyPersonName,
    required this.dutyPersonRole,
    required this.checkDate,
    required this.status,
    required this.isOnPhone,
    required this.isWearingVest,
    this.isOnTime = false,
    this.notes,
    required this.checkedBy,
    required this.checkedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory DutyCheckModel.fromJson(Map<String, dynamic> json) {
    return DutyCheckModel(
      id: json['id'] as String,
      dutyPersonId: json['dutyPersonId'] as String,
      dutyPersonName: json['dutyPersonName'] as String,
      dutyPersonRole: json['dutyPersonRole'] as String,
      checkDate: _parseTimestamp(json['checkDate'])!,
      status: json['status'] as String,
      isOnPhone: json['isOnPhone'] as bool,
      isWearingVest: json['isWearingVest'] as bool,
      isOnTime: json['isOnTime'] as bool? ?? false,
      notes: json['notes'] as String?,
      checkedBy: json['checkedBy'] as String,
      checkedByName: json['checkedByName'] as String,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  /// Helper method to parse timestamps from Firestore
  /// Handles both Timestamp objects and ISO string formats
  static DateTime? _parseTimestamp(dynamic timestamp) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dutyPersonId': dutyPersonId,
      'dutyPersonName': dutyPersonName,
      'dutyPersonRole': dutyPersonRole,
      'checkDate': checkDate.toIso8601String(),
      'status': status,
      'isOnPhone': isOnPhone,
      'isWearingVest': isWearingVest,
      'isOnTime': isOnTime,
      'notes': notes,
      'checkedBy': checkedBy,
      'checkedByName': checkedByName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DutyCheckModel.fromEntity(DutyCheck dutyCheck) {
    return DutyCheckModel(
      id: dutyCheck.id,
      dutyPersonId: dutyCheck.dutyPersonId,
      dutyPersonName: dutyCheck.dutyPersonName,
      dutyPersonRole: dutyCheck.dutyPersonRole,
      checkDate: dutyCheck.checkDate,
      status: dutyCheck.status,
      isOnPhone: dutyCheck.isOnPhone,
      isWearingVest: dutyCheck.isWearingVest,
      isOnTime: dutyCheck.isOnTime,
      notes: dutyCheck.notes,
      checkedBy: dutyCheck.checkedBy,
      checkedByName: dutyCheck.checkedByName,
      createdAt: dutyCheck.createdAt,
      updatedAt: dutyCheck.updatedAt,
    );
  }

  DutyCheck toEntity() {
    return DutyCheck(
      id: id,
      dutyPersonId: dutyPersonId,
      dutyPersonName: dutyPersonName,
      dutyPersonRole: dutyPersonRole,
      checkDate: checkDate,
      status: status,
      isOnPhone: isOnPhone,
      isWearingVest: isWearingVest,
      isOnTime: isOnTime,
      notes: notes,
      checkedBy: checkedBy,
      checkedByName: checkedByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyCheckModel &&
        other.id == id &&
        other.dutyPersonId == dutyPersonId &&
        other.dutyPersonName == dutyPersonName &&
        other.dutyPersonRole == dutyPersonRole &&
        other.checkDate == checkDate &&
        other.status == status &&
        other.isOnPhone == isOnPhone &&
        other.isWearingVest == isWearingVest &&
        other.isOnTime == isOnTime &&
        other.notes == notes &&
        other.checkedBy == checkedBy &&
        other.checkedByName == checkedByName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      dutyPersonId,
      dutyPersonName,
      dutyPersonRole,
      checkDate,
      status,
      isOnPhone,
      isWearingVest,
      isOnTime,
      notes,
      checkedBy,
      checkedByName,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'DutyCheckModel(id: $id, dutyPersonId: $dutyPersonId, dutyPersonName: $dutyPersonName, dutyPersonRole: $dutyPersonRole, checkDate: $checkDate, status: $status, isOnPhone: $isOnPhone, isWearingVest: $isWearingVest, isOnTime: $isOnTime, notes: $notes, checkedBy: $checkedBy, checkedByName: $checkedByName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
