import '../core/utils.dart';

/// Mirrors `loan_collection`.
class LoanCollection {
  final String pkCollectionId;
  final String collectionOrgId;
  final String collectionLoanId;
  final String collectionUserId;
  final num collectionAmount;
  final String collectionDate;
  final String paymentMode; // CASH | UPI | BANK_TRANSFER | CHEQUE | CARD
  final String? referenceNo;
  final String? collectedByUserId;
  final String? remarks;
  final String status; // SUCCESS

  LoanCollection({
    required this.pkCollectionId,
    required this.collectionOrgId,
    required this.collectionLoanId,
    required this.collectionUserId,
    required this.collectionAmount,
    required this.collectionDate,
    required this.paymentMode,
    this.referenceNo,
    this.collectedByUserId,
    this.remarks,
    required this.status,
  });

  factory LoanCollection.fromJson(Map<String, dynamic> j) => LoanCollection(
        pkCollectionId: asStr(j['pk_collection_id']),
        collectionOrgId: asStr(j['collection_org_id']),
        collectionLoanId: asStr(j['collection_loan_id']),
        collectionUserId: asStr(j['collection_user_id']),
        collectionAmount: asNum(j['collection_amount']),
        collectionDate: asStr(j['collection_date']),
        paymentMode: asStr(j['payment_mode']),
        referenceNo: j['reference_no']?.toString(),
        collectedByUserId: j['collected_by_user_id']?.toString(),
        remarks: j['remarks']?.toString(),
        status: asStr(j['status']),
      );
}

const List<String> kPaymentModes = ['UPI', 'CASH', 'BANK_TRANSFER', 'CHEQUE', 'CARD'];
