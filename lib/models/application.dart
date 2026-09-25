import '../core/utils.dart';

/// Mirrors `loan_applications` — public, pre-login submissions from the
/// "Apply for Loan" flow (apply.php), reviewed by Financier/DEO via applications.php.
class LoanApplication {
  final int id;
  final String ref;
  final String custName;
  final String custPhone;
  final String custEmail;
  final String? custDob;
  final String? custPan;
  final String custCity;
  final String custAddress;
  final String financierKey;
  final String financierLabel;
  final num loanAmount;
  final int tenureMonths;
  final num interestRate;
  final num emi;
  final num totalInterest;
  final num totalPayable;
  final String status; // Pending Review | Approved | Rejected
  final String? createdAt;

  LoanApplication({
    required this.id,
    required this.ref,
    required this.custName,
    required this.custPhone,
    required this.custEmail,
    this.custDob,
    this.custPan,
    required this.custCity,
    required this.custAddress,
    required this.financierKey,
    required this.financierLabel,
    required this.loanAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.emi,
    required this.totalInterest,
    required this.totalPayable,
    required this.status,
    this.createdAt,
  });

  factory LoanApplication.fromJson(Map<String, dynamic> j) => LoanApplication(
        id: asNum(j['id']).toInt(),
        ref: asStr(j['ref']),
        custName: asStr(j['cust_name']),
        custPhone: asStr(j['cust_phone']),
        custEmail: asStr(j['cust_email']),
        custDob: j['cust_dob']?.toString(),
        custPan: j['cust_pan']?.toString(),
        custCity: asStr(j['cust_city']),
        custAddress: asStr(j['cust_address']),
        financierKey: asStr(j['financier_key']),
        financierLabel: asStr(j['financier_label']),
        loanAmount: asNum(j['loan_amount']),
        tenureMonths: asNum(j['tenure_months']).toInt(),
        interestRate: asNum(j['interest_rate']),
        emi: asNum(j['emi']),
        totalInterest: asNum(j['total_interest']),
        totalPayable: asNum(j['total_payable']),
        status: asStr(j['status']),
        createdAt: j['created_at']?.toString(),
      );
}

/// Mirrors the grouped shape rates.php returns: { key, label, rates: {tenure: rate}, status }.
class FinancierRateCard {
  final String key;
  final String label;
  final Map<int, num> rates; // tenure_months -> annual interest rate %
  final String status;

  FinancierRateCard({required this.key, required this.label, required this.rates, required this.status});

  factory FinancierRateCard.fromJson(Map<String, dynamic> j) {
    final ratesJson = (j['rates'] as Map?) ?? {};
    final rates = <int, num>{};
    ratesJson.forEach((k, v) => rates[int.parse(k.toString())] = asNum(v));
    return FinancierRateCard(
      key: asStr(j['key']),
      label: asStr(j['label']),
      rates: rates,
      status: asStr(j['status']),
    );
  }
}
