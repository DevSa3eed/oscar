class DutyCheck {
  final String id;
  final String dutyPersonId;
  final String dutyPersonName;
  final String dutyPersonRole;
  final DateTime checkDate;
  final String status; // present/absent
  final bool isOnPhone;
  final bool isWearingVest;
  final bool isOnTime;
  final String? notes;
  final String checkedBy;
  final String checkedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DutyCheck({
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

  factory DutyCheck.fromJson(Map<String, dynamic> json) {
    return DutyCheck(
      id: json['id'] as String,
      dutyPersonId: json['dutyPersonId'] as String,
      dutyPersonName: json['dutyPersonName'] as String,
      dutyPersonRole: json['dutyPersonRole'] as String,
      checkDate: DateTime.parse(json['checkDate'] as String),
      status: json['status'] as String,
      isOnPhone: json['isOnPhone'] as bool,
      isWearingVest: json['isWearingVest'] as bool,
      isOnTime: json['isOnTime'] as bool? ?? false,
      notes: json['notes'] as String?,
      checkedBy: json['checkedBy'] as String,
      checkedByName: json['checkedByName'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
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

  DutyCheck copyWith({
    String? id,
    String? dutyPersonId,
    String? dutyPersonName,
    String? dutyPersonRole,
    DateTime? checkDate,
    String? status,
    bool? isOnPhone,
    bool? isWearingVest,
    bool? isOnTime,
    String? notes,
    String? checkedBy,
    String? checkedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DutyCheck(
      id: id ?? this.id,
      dutyPersonId: dutyPersonId ?? this.dutyPersonId,
      dutyPersonName: dutyPersonName ?? this.dutyPersonName,
      dutyPersonRole: dutyPersonRole ?? this.dutyPersonRole,
      checkDate: checkDate ?? this.checkDate,
      status: status ?? this.status,
      isOnPhone: isOnPhone ?? this.isOnPhone,
      isWearingVest: isWearingVest ?? this.isWearingVest,
      isOnTime: isOnTime ?? this.isOnTime,
      notes: notes ?? this.notes,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedByName: checkedByName ?? this.checkedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyCheck &&
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
    return 'DutyCheck(id: $id, dutyPersonId: $dutyPersonId, dutyPersonName: $dutyPersonName, dutyPersonRole: $dutyPersonRole, checkDate: $checkDate, status: $status, isOnPhone: $isOnPhone, isWearingVest: $isWearingVest, isOnTime: $isOnTime, notes: $notes, checkedBy: $checkedBy, checkedByName: $checkedByName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
