import '../core/api_client.dart';
import '../models/application.dart';

/// rates.php — public GET of the financier rate card (financier_master.csv).
class RatesService {
  final _api = ApiClient.instance;

  Future<List<FinancierRateCard>> masterList() async {
    final res = await _api.get('rates.php');
    return (res['master'] as List).map((e) => FinancierRateCard.fromJson(e)).toList();
  }
}
