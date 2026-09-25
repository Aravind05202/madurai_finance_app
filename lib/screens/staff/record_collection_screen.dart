import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/collection.dart';
import '../../models/loan.dart';
import '../../services/collection_service.dart';
import '../../state/app_state.dart';
import '../widgets/primary_button.dart';

/// Collection Agent screen: pick a disbursed loan, enter amount + payment
/// mode, and post to collections.php. For a customer who paid via UPI in the
/// app, use their saved UTR (shown in the customer's Loan Detail screen /
/// told to the agent) as the reference number here.
class RecordCollectionScreen extends StatefulWidget {
  const RecordCollectionScreen({super.key});
  @override
  State<RecordCollectionScreen> createState() => _RecordCollectionScreenState();
}

class _RecordCollectionScreenState extends State<RecordCollectionScreen> {
  final _svc = CollectionService();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _remarks = TextEditingController();
  Loan? _loan;
  String _mode = 'UPI';
  bool _saving = false;

  num _outstandingFor(Loan loan, List<LoanCollection> collections) {
    final paid = collections
        .where((c) => c.collectionLoanId == loan.pkLoanId && c.status == 'SUCCESS')
        .fold<num>(0, (a, c) => a + c.collectionAmount);
    final o = loan.loanAmount - paid;
    return o < 0 ? 0 : o;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final disbursedLoans = appState.loans.where((l) => l.isDisbursed).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Record Payment'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<Loan>(
            decoration: _decoration('Loan'),
            initialValue: _loan,
            items: disbursedLoans
                .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text('${l.pkLoanId} · ${formatMoney(_outstandingFor(l, appState.collections))} due'),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                _loan = v;
                if (v != null) _amount.text = _outstandingFor(v, appState.collections).toStringAsFixed(2);
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(controller: _amount, keyboardType: TextInputType.number, decoration: _decoration('Amount (₹)')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: _decoration('Payment mode'),
            initialValue: _mode,
            items: kPaymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _mode = v ?? 'UPI'),
          ),
          const SizedBox(height: 14),
          TextField(controller: _reference, decoration: _decoration('Reference / UTR number (optional)')),
          const SizedBox(height: 14),
          TextField(controller: _remarks, decoration: _decoration('Remarks (optional)')),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Record Payment', onPressed: _submit, loading: _saving, color: AppColors.green),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_loan == null) return _snack('Select a loan.');
    final amount = num.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) return _snack('Enter a valid amount.');
    setState(() => _saving = true);
    try {
      await _svc.record(
        loanId: _loan!.pkLoanId,
        amount: amount,
        paymentMode: _mode,
        referenceNo: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
        remarks: _remarks.text.trim().isEmpty ? null : _remarks.text.trim(),
      );
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
