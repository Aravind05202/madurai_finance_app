import '../core/api_client.dart';
import '../models/user.dart';

class AuthResult {
  final AppUser user;
  final List<dynamic>? customerLoans; // only for customer_login.php ('type' == 'customer')
  final Map<String, dynamic>? pendingApplication; // only when customer_login finds an application, not yet a user
  AuthResult({required this.user, this.customerLoans, this.pendingApplication});
}

class AuthService {
  final _api = ApiClient.instance;

  /// Staff login (Financier / Collection Agent / Security / Data Entry Operator).
  Future<AppUser> staffLogin({required String email, required String password}) async {
    final res = await _api.post('login.php', body: {'email': email, 'password': password});
    return AppUser.fromJson(res['user']);
  }

  /// Customer self-service login: mobile number + DOB or PAN, no password.
  /// Returns null user + application map if the phone/DOB matches a public
  /// application (loan_applications) that hasn't been turned into an account yet.
  Future<Map<String, dynamic>> customerLogin({required String phone, required String verification}) async {
    return _api.post('customer_login.php', body: {'phone': phone, 'verification': verification});
  }

  /// Re-checks the current session cookie against the server.
  Future<AppUser?> session() async {
    final res = await _api.get('session.php');
    if (res['user'] == null) return null;
    return AppUser.fromJson(res['user']);
  }

  Future<void> logout() async {
    await _api.post('logout.php');
    await _api.clearSession();
  }
}
