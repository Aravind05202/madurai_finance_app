import '../core/utils.dart';

/// Mirrors `user_info` (password column always stripped server-side).
class AppUser {
  final String pkUserId;
  final String userOrgId;
  final String userName;
  final String userEmail;
  final String? dob;
  final String? panNo;
  final String userRoleId;
  final String status;

  AppUser({
    required this.pkUserId,
    required this.userOrgId,
    required this.userName,
    required this.userEmail,
    this.dob,
    this.panNo,
    required this.userRoleId,
    required this.status,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        pkUserId: asStr(j['pk_user_id']),
        userOrgId: asStr(j['user_org_id']),
        userName: asStr(j['user_name']),
        userEmail: asStr(j['user_email']),
        dob: j['dob']?.toString(),
        panNo: j['pan_no']?.toString(),
        userRoleId: asStr(j['user_role_id']),
        status: asStr(j['status']),
      );
}

/// Mirrors `role_master`.
class AppRole {
  final String pkRoleId;
  final String roleName;
  final String? roleDescription;

  AppRole({required this.pkRoleId, required this.roleName, this.roleDescription});

  factory AppRole.fromJson(Map<String, dynamic> j) => AppRole(
        pkRoleId: asStr(j['pk_role_id']),
        roleName: asStr(j['role_name']),
        roleDescription: j['role_description']?.toString(),
      );
}

/// Well-known role names from role_master seed data — used for client-side
/// UI branching only. The server re-checks every permission independently
/// (see helpers.php `can()`), so this is convenience, not security.
class RoleNames {
  static const financier = 'Financier';
  static const collectionAgent = 'Collection Agent';
  static const customer = 'Customer';
  static const security = 'Security';
  static const dataEntryOperator = 'Data Entry Operator';
}
