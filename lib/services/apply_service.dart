import '../core/api_client.dart';

/// apply.php — public "Apply for Loan" form submission. No session required.
class ApplyService {
  final _api = ApiClient.instance;

  /// Returns the application reference number (e.g. "MF-12345678") on success.
  Future<String> submit({
    required String name,
    required String phone,
    required String email,
    required String dob, // yyyy-MM-dd
    required String pan,
    required String city,
    required String address,
    required String financierKey,
    required num amount,
    required int tenure,
  }) async {
    final res = await _api.post('apply.php', body: {
      'customer': {
        'name': name,
        'phone': phone,
        'email': email,
        'dob': dob,
        'pan': pan,
        'city': city,
        'address': address,
      },
      'financierKey': financierKey,
      'amount': amount,
      'tenure': tenure,
    });
    return res['ref'].toString();
  }
}
