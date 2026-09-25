import '../core/api_client.dart';

/// Wraps bootstrap.php — called once right after login (and on pull-to-refresh)
/// to fetch everything the app needs to render the role-scoped dashboard:
/// org info, modules/permissions/roles, users, loans, collections, audit, applications.
/// The server filters every list by role/org already — the app never re-derives
/// visibility client-side beyond choosing which screens to show.
class BootstrapService {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> fetch() => _api.get('bootstrap.php');
}
