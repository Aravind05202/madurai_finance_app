import '../core/api_client.dart';
import '../models/application.dart';

/// applications.php — pending public loan applications (from apply.php) that
/// Financier/DEO review. Approving auto-creates the customer account + loan.
class ApplicationService {
  final _api = ApiClient.instance;

  Future<List<LoanApplication>> pending() async {
    final res = await _api.get('applications.php');
    return (res['applications'] as List).map((e) => LoanApplication.fromJson(e)).toList();
  }

  /// Returns the new pk_loan_id.
  Future<String> approve(String ref) async {
    final res = await _api.post('applications.php', body: {'action': 'approve', 'ref': ref});
    return res['pk_loan_id'].toString();
  }

  Future<void> reject(String ref) => _api.post('applications.php', body: {'action': 'reject', 'ref': ref});
}
