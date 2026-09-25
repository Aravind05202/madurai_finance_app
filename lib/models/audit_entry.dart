import '../core/utils.dart';

/// Mirrors `audit_log`.
class AuditEntry {
  final String pkAuditId;
  final String orgId;
  final String userId;
  final String userName;
  final String action;
  final String? details;
  final String createdDatetime;

  AuditEntry({
    required this.pkAuditId,
    required this.orgId,
    required this.userId,
    required this.userName,
    required this.action,
    this.details,
    required this.createdDatetime,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
        pkAuditId: asStr(j['pk_audit_id']),
        orgId: asStr(j['org_id']),
        userId: asStr(j['user_id']),
        userName: asStr(j['user_name']),
        action: asStr(j['action']),
        details: j['details']?.toString(),
        createdDatetime: asStr(j['created_datetime']),
      );
}
