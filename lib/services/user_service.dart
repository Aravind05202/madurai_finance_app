import '../core/api_client.dart';
import '../models/user.dart';

/// users.php — org user directory + creation/toggle.
/// Visibility/creation rights mirror role_permission_mapping:
///   view:   Financier, Security, Data Entry Operator
///   create: Financier (any role), Data Entry Operator (Customer only, enforced server-side)
///   toggle status: Financier only
class UserService {
  final _api = ApiClient.instance;

  Future<List<AppUser>> list() async {
    final res = await _api.get('users.php');
    return (res['users'] as List).map((e) => AppUser.fromJson(e)).toList();
  }

  Future<String> create({
    required String name,
    required String email,
    required String password,
    String? dob,
    String? panNo,
    String? roleId, // ignored server-side unless caller is Financier
  }) async {
    final res = await _api.post('users.php', body: {
      'action': 'create',
      'user_name': name,
      'user_email': email,
      'password': password,
      'dob': dob,
      'pan_no': panNo,
      'user_role_id': roleId,
    });
    return res['pk_user_id'].toString();
  }

  Future<String> toggleStatus(String userId) async {
    final res = await _api.post('users.php', body: {'action': 'toggle', 'pk_user_id': userId});
    return res['status'].toString();
  }
}
