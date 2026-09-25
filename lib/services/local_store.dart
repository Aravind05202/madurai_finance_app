import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only record of a UPI payment the customer says they've made, kept
/// on-device until the Collection Agent confirms it server-side via
/// collections.php (the Customer role has VIEW but not COLLECT permission,
/// so the app cannot write directly to loan_collection — see
/// role_permission_mapping in schema_madurai_finance.sql).
class PendingUpiPayment {
  final String loanId;
  final num amount;
  final String utr;
  final DateTime date;

  PendingUpiPayment({required this.loanId, required this.amount, required this.utr, required this.date});

  Map<String, dynamic> toJson() =>
      {'loanId': loanId, 'amount': amount, 'utr': utr, 'date': date.toIso8601String()};

  factory PendingUpiPayment.fromJson(Map<String, dynamic> j) => PendingUpiPayment(
        loanId: j['loanId'],
        amount: j['amount'],
        utr: j['utr'],
        date: DateTime.parse(j['date']),
      );
}

class LocalStore {
  static const _key = 'mf_pending_upi_payments';
  static const _upiIdKey = 'mf_org_upi_id';

  static Future<List<PendingUpiPayment>> pendingPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(PendingUpiPayment.fromJson).toList();
  }

  static Future<void> addPendingPayment(PendingUpiPayment p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await pendingPayments();
    list.add(p);
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearPendingForLoan(String loanId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await pendingPayments();
    list.removeWhere((p) => p.loanId == loanId);
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  static Future<String> orgUpiId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_upiIdKey) ?? 'madurai.finance@upi';
  }

  static Future<void> setOrgUpiId(String upiId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_upiIdKey, upiId);
  }
}
