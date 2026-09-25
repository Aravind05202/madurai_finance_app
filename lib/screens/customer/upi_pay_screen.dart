import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import '../../services/local_store.dart';
import '../widgets/primary_button.dart';

/// Builds a standard UPI deep link (upi://pay?...) so the customer's phone
/// offers GPay / PhonePe / Paytm / any UPI app to complete the payment.
///
/// IMPORTANT: the PHP backend has no payment-gateway webhook, and the
/// Customer role only has VIEW (not COLLECT) permission on the Collection
/// module (see role_permission_mapping in schema_madurai_finance.sql) — so
/// this screen cannot write a loan_collection row itself. Instead it:
///   1. Opens the UPI app pre-filled with the amount and a note containing
///      the loan ID (so the org's bank statement is traceable).
///   2. Lets the customer save the UPI transaction reference (UTR) locally.
///   3. The Collection Agent then confirms it against the bank statement
///      via collections.php ("Record Payment" -> mode UPI, using the same
///      reference), which is the actual system-of-record entry.
class UpiPayScreen extends StatefulWidget {
  final Loan loan;
  final num outstanding;
  const UpiPayScreen({super.key, required this.loan, required this.outstanding});

  @override
  State<UpiPayScreen> createState() => _UpiPayScreenState();
}

class _UpiPayScreenState extends State<UpiPayScreen> {
  late final TextEditingController _amount;
  final _utr = TextEditingController();
  String _orgUpiId = '';
  bool _launched = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.outstanding.toStringAsFixed(2));
    LocalStore.orgUpiId().then((id) => setState(() => _orgUpiId = id));
  }

  Future<void> _launchUpi() async {
    final amt = num.tryParse(_amount.text.trim());
    if (amt == null || amt <= 0 || amt > widget.outstanding + 0.005) {
      _snack('Enter a valid amount up to the outstanding balance.');
      return;
    }
    final note = 'Madurai Finance ${widget.loan.pkLoanId}';
    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _orgUpiId,
        'pn': 'Madurai Finance',
        'am': amt.toStringAsFixed(2),
        'cu': 'INR',
        'tn': note,
      },
    );
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      _snack('No UPI app found on this device. Install GPay, PhonePe or Paytm to pay.');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    setState(() => _launched = true);
  }

  Future<void> _saveUtr() async {
    final amt = num.tryParse(_amount.text.trim()) ?? widget.outstanding;
    if (_utr.text.trim().isEmpty) {
      _snack('Enter the UPI transaction / UTR number from your payment app.');
      return;
    }
    setState(() => _saving = true);
    await LocalStore.addPendingPayment(
      PendingUpiPayment(loanId: widget.loan.pkLoanId, amount: amt, utr: _utr.text.trim(), date: DateTime.now()),
    );
    setState(() => _saving = false);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Saved'),
        content: const Text(
            'Thanks. Your payment reference has been saved on this device. Our collection team will confirm it against the loan shortly.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pay via UPI'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.deepGreen, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Outstanding balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatMoney(widget.outstanding),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Loan ${widget.loan.pkLoanId}', style: const TextStyle(color: AppColors.goldLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Amount to pay', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Pay with UPI App', icon: Icons.qr_code_2, onPressed: _launchUpi, color: AppColors.gold),
          const SizedBox(height: 24),
          if (_launched) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text('After paying, enter the transaction reference (UTR):',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _utr,
              decoration: InputDecoration(
                labelText: 'UPI transaction / UTR number',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Save Reference', onPressed: _saveUtr, loading: _saving, color: AppColors.green),
          ],
          const SizedBox(height: 24),
          const Text(
            'Payments are confirmed by the collection team against the bank statement. '
            'Keep your UTR handy in case you need to show proof of payment.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
