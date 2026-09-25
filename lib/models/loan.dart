import '../core/utils.dart';

/// Mirrors `loan_info`.
class Loan {
  final String pkLoanId;
  final String loanOrgId;
  final String loanUserId;
  final num loanAmount;
  final num interestRate;
  final int tenureMonths;
  final String? purpose;
  final String? applicationDate;
  final String? approvalDate;
  final String? disbursementDate;
  final String? dueDate;
  final num? outstandingAmount;
  final bool received;
  final String status; // PENDING | APPROVED | REJECTED | DISBURSED | CLOSED
  final String? upcomingEmiDate; // only present on customer_login.php response

  Loan({
    required this.pkLoanId,
    required this.loanOrgId,
    required this.loanUserId,
    required this.loanAmount,
    required this.interestRate,
    required this.tenureMonths,
    this.purpose,
    this.applicationDate,
    this.approvalDate,
    this.disbursementDate,
    this.dueDate,
    this.outstandingAmount,
    required this.received,
    required this.status,
    this.upcomingEmiDate,
  });

  factory Loan.fromJson(Map<String, dynamic> j) => Loan(
        pkLoanId: asStr(j['pk_loan_id']),
        loanOrgId: asStr(j['loan_org_id']),
        loanUserId: asStr(j['loan_user_id']),
        loanAmount: asNum(j['loan_amount']),
        interestRate: asNum(j['interest_rate']),
        tenureMonths: asNum(j['tenure_months']).toInt(),
        purpose: j['purpose']?.toString(),
        applicationDate: j['application_date']?.toString(),
        approvalDate: j['approval_date']?.toString(),
        disbursementDate: j['disbursement_date']?.toString(),
        dueDate: j['due_date']?.toString(),
        outstandingAmount: j['outstanding_amount'] == null ? null : asNum(j['outstanding_amount']),
        received: asNum(j['received']).toInt() == 1,
        status: asStr(j['status']),
        upcomingEmiDate: j['upcoming_emi_date']?.toString(),
      );

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isDisbursed => status == 'DISBURSED';
  bool get isClosed => status == 'CLOSED';
  bool get isRejected => status == 'REJECTED';
}

/// Mirrors `repayment_details` — one row per installment.
class RepaymentDetail {
  final String pkRepaymentId;
  final String fkLoanId;
  final int instlNum;
  final String dueDate;
  final num openingPrincipal;
  final num instAmt;
  final num principal;
  final num interest;
  final String advFlag;
  final num closingPrincipal;
  final num rate;

  RepaymentDetail({
    required this.pkRepaymentId,
    required this.fkLoanId,
    required this.instlNum,
    required this.dueDate,
    required this.openingPrincipal,
    required this.instAmt,
    required this.principal,
    required this.interest,
    required this.advFlag,
    required this.closingPrincipal,
    required this.rate,
  });

  factory RepaymentDetail.fromJson(Map<String, dynamic> j) => RepaymentDetail(
        pkRepaymentId: asStr(j['pk_repayment_id']),
        fkLoanId: asStr(j['fk_loan_id']),
        instlNum: asNum(j['instl_num']).toInt(),
        dueDate: asStr(j['due_date']),
        openingPrincipal: asNum(j['opening_principal']),
        instAmt: asNum(j['inst_amt']),
        principal: asNum(j['principal']),
        interest: asNum(j['interest']),
        advFlag: asStr(j['adv_flag']),
        closingPrincipal: asNum(j['closing_principal']),
        rate: asNum(j['rate']),
      );

  bool get isOverdue => DateTime.tryParse(dueDate)?.isBefore(DateTime.now()) ?? false;
}
