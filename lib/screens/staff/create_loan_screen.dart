import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/loan_service.dart';
import '../../state/app_state.dart';
import '../widgets/primary_button.dart';

class CreateLoanScreen extends StatefulWidget {
  const CreateLoanScreen({super.key});
  @override
  State<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends State<CreateLoanScreen> {
  final _svc = LoanService();
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  final _purpose = TextEditingController();
  AppUser? _customer;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<AppState>().users.where((u) {
      final role = context.read<AppState>().roles.firstWhere(
            (r) => r.pkRoleId == u.userRoleId,
            orElse: () => AppRole(pkRoleId: '', roleName: ''),
          );
      return role.roleName == RoleNames.customer;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Create Loan'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<AppUser>(
            decoration: _decoration('Customer'),
            initialValue: _customer,
            items: customers.map((c) => DropdownMenuItem(value: c, child: Text('${c.userName} (${c.pkUserId})'))).toList(),
            onChanged: (v) => setState(() => _customer = v),
          ),
          const SizedBox(height: 14),
          TextField(controller: _amount, keyboardType: TextInputType.number, decoration: _decoration('Loan amount (₹)')),
          const SizedBox(height: 14),
          TextField(controller: _rate, keyboardType: TextInputType.number, decoration: _decoration('Interest rate (% p.a.)')),
          const SizedBox(height: 14),
          TextField(controller: _tenure, keyboardType: TextInputType.number, decoration: _decoration('Tenure (months)')),
          const SizedBox(height: 14),
          TextField(controller: _purpose, decoration: _decoration('Purpose (optional)')),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Create Loan', onPressed: _submit, loading: _saving),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_customer == null) return _snack('Select a customer.');
    final amount = num.tryParse(_amount.text.trim());
    final rate = num.tryParse(_rate.text.trim()) ?? 0;
    final tenure = int.tryParse(_tenure.text.trim());
    if (amount == null || amount <= 0 || tenure == null || tenure <= 0) {
      return _snack('Enter a valid amount and tenure.');
    }
    setState(() => _saving = true);
    try {
      final loanId = await _svc.create(
        customerId: _customer!.pkUserId,
        amount: amount,
        interestRate: rate,
        tenureMonths: tenure,
        purpose: _purpose.text.trim().isEmpty ? null : _purpose.text.trim(),
      );
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loan $loanId created.')));
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
