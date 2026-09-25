import '../core/api_client.dart';
import '../models/audit_entry.dart';

class AuditService {
  final _api = ApiClient.instance;

  Future<List<AuditEntry>> recent() async {
    final res = await _api.get('audit.php');
    return (res['audit'] as List).map((e) => AuditEntry.fromJson(e)).toList();
  }
}
