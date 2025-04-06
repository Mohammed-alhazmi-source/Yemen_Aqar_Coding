class ReportReason {
  ReportReason({required this.id, required this.reason});

  factory ReportReason.fromMap(Map<String, dynamic> map) {
    return ReportReason(
      id: map['id'] as int,
      reason: map['reason'] as String,
    );
  }
  final int id;
  final String reason;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reason': reason,
    };
  }
}
