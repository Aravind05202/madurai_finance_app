import 'package:intl/intl.dart';

final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final NumberFormat _inrClean = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final NumberFormat _numFmt = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2);
final NumberFormat _numFmtClean = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);
final DateFormat _shortDate = DateFormat('dd MMM yyyy');

String formatMoney(dynamic value, {bool round = true}) {
  if (value == null) return '—';
  final n = value is num ? value : num.tryParse(value.toString());
  if (n == null) return '—';
  if (round) {
    return _inrClean.format(n.round());
  }
  if (n % 1 == 0) {
    return _inrClean.format(n);
  }
  return _inr.format(n);
}

String formatMoneyNumeric(dynamic value, {bool round = false}) {
  if (value == null) return '—';
  final n = value is num ? value : num.tryParse(value.toString());
  if (n == null) return '—';
  if (round) return _numFmtClean.format(n.round());
  if (n % 1 == 0) return _numFmtClean.format(n);
  return _numFmt.format(n);
}

String formatDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return '—';
  try {
    final d = DateTime.parse(value.toString());
    return _shortDate.format(d);
  } catch (_) {
    return value.toString();
  }
}

num asNum(dynamic v, [num fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? fallback;
}

String asStr(dynamic v) => v == null ? '' : v.toString();

/// Alias for formatMoney — formats a number as INR currency (₹).
String formatCurrency(num value, {bool round = false}) => formatMoney(value, round: round);
