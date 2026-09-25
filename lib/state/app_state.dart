import 'package:flutter/foundation.dart';

import '../models/application.dart';
import '../models/audit_entry.dart';
import '../models/collection.dart';
import '../models/loan.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/bootstrap_service.dart';

enum SessionType { none, staff, customer }

/// Central app state: who is logged in, their role, and the org-scoped
/// data snapshot from bootstrap.php. Screens read this via Provider instead
/// of each re-fetching independently.
class AppState extends ChangeNotifier {
  final _auth = AuthService();
  final _bootstrapSvc = BootstrapService();

  SessionType sessionType = SessionType.none;
  AppUser? currentUser;
  AppRole? currentRole;
  bool loading = false;
  String? error;

  Map<String, dynamic>? org;
  List<AppRole> roles = [];
  List<Loan> loans = [];
  List<LoanCollection> collections = [];
  List<AuditEntry> audit = [];
  List<LoanApplication> applications = [];
  List<AppUser> users = [];

  bool get isLoggedIn => currentUser != null;
  bool get isStaff => sessionType == SessionType.staff;
  bool get isCustomer => sessionType == SessionType.customer;

  String get roleName => currentRole?.roleName ?? '';

  Future<bool> restoreSession() async {
    try {
      final user = await _auth.session();
      if (user == null) return false;
      currentUser = user;
      sessionType = SessionType.staff;
      await refreshBootstrap();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loginStaff(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final user = await _auth.staffLogin(email: email, password: password);
      currentUser = user;
      sessionType = SessionType.staff;
      await refreshBootstrap();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns a pending-application map if the phone/DOB matched an application
  /// that hasn't become an account yet (financier still needs to approve it).
  Future<Map<String, dynamic>?> loginCustomer(String phone, String verification) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _auth.customerLogin(phone: phone, verification: verification);
      if (res['type'] == 'application') {
        return res['application'] as Map<String, dynamic>;
      }
      currentUser = AppUser.fromJson(res['user']);
      sessionType = SessionType.customer;
      if (res['loans'] != null) {
        loans = (res['loans'] as List).map((e) => Loan.fromJson(e)).toList();
      }
      await refreshBootstrap();
      return null;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBootstrap() async {
    final res = await _bootstrapSvc.fetch();
    currentUser = AppUser.fromJson(res['me']);
    org = res['org'] as Map<String, dynamic>?;
    roles = ((res['roles'] as List?) ?? []).map((e) => AppRole.fromJson(e)).toList();
    currentRole = roles.firstWhere(
      (r) => r.pkRoleId == currentUser!.userRoleId,
      orElse: () => AppRole(pkRoleId: currentUser!.userRoleId, roleName: 'Customer'),
    );
    sessionType = currentRole!.roleName == RoleNames.customer ? SessionType.customer : SessionType.staff;
    loans = ((res['loans'] as List?) ?? []).map((e) => Loan.fromJson(e)).toList();
    collections = ((res['collections'] as List?) ?? []).map((e) => LoanCollection.fromJson(e)).toList();
    audit = ((res['audit'] as List?) ?? []).map((e) => AuditEntry.fromJson(e)).toList();
    applications = ((res['applications'] as List?) ?? []).map((e) => LoanApplication.fromJson(e)).toList();
    users = ((res['users'] as List?) ?? []).map((e) => AppUser.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // best-effort — clear local state regardless
    }
    currentUser = null;
    currentRole = null;
    sessionType = SessionType.none;
    loans = [];
    collections = [];
    audit = [];
    applications = [];
    users = [];
    notifyListeners();
  }
}
