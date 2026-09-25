import '../core/api_client.dart';
import '../models/loan.dart';

class LoanService {
  final _api = ApiClient.instance;

  Future<List<Loan>> list() async {
    final res = await _api.get('loans.php');
    return (res['loans'] as List).map((e) => Loan.fromJson(e)).toList();
  }

  Future<List<RepaymentDetail>> repaymentSchedule(String loanId) async {
    final res = await _api.get('loans.php', query: {'loan_id': loanId});
    return (res['repayment_details'] as List).map((e) => RepaymentDetail.fromJson(e)).toList();
  }

  /// Financier / Data Entry Operator: create a new loan for an existing customer.
  Future<String> create({
    required String customerId,
    required num amount,
    required num interestRate,
    required int tenureMonths,
    String? purpose,
  }) async {
    final res = await _api.post('loans.php', body: {
      'action': 'create',
      'loan_user_id': customerId,
      'loan_amount': amount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'purpose': purpose,
    });
    return res['pk_loan_id'].toString();
  }

  Future<void> approve(String loanId) => _api.post('loans.php', body: {'action': 'approve', 'pk_loan_id': loanId});

  Future<void> reject(String loanId) => _api.post('loans.php', body: {'action': 'reject', 'pk_loan_id': loanId});

  Future<void> disburse(String loanId) => _api.post('loans.php', body: {'action': 'disburse', 'pk_loan_id': loanId});

  /// Customer acknowledges receipt of a disbursed loan.
  Future<void> acknowledgeReceipt(String loanId) =>
      _api.post('loans.php', body: {'action': 'receive', 'pk_loan_id': loanId});
}
