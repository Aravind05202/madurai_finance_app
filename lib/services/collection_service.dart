import '../core/api_client.dart';
import '../models/collection.dart';

class CollectionService {
  final _api = ApiClient.instance;

  Future<List<LoanCollection>> list() async {
    final res = await _api.get('collections.php');
    return (res['collections'] as List).map((e) => LoanCollection.fromJson(e)).toList();
  }

  /// Collection Agent (or any role with COLLECTION:COLLECT) records a payment
  /// against a disbursed loan. paymentMode must be one of kPaymentModes.
  /// For UPI, pass the UPI app's transaction/UTR number as referenceNo.
  Future<String> record({
    required String loanId,
    required num amount,
    required String paymentMode,
    String? referenceNo,
    String? remarks,
    DateTime? date,
  }) async {
    final res = await _api.post('collections.php', body: {
      'collection_loan_id': loanId,
      'collection_amount': amount,
      'payment_mode': paymentMode,
      'reference_no': referenceNo,
      'remarks': remarks,
      if (date != null) 'collection_date': date.toIso8601String().substring(0, 10),
    });
    return res['pk_collection_id'].toString();
  }
}
