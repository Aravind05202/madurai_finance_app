import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../state/app_state.dart';
import '../widgets/primary_button.dart';

/// Financier can create any role; Data Entry Operator can only ever create
/// Customer accounts (the server silently forces this — see users.php).
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});
  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _svc = UserService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _pan = TextEditingController();
  DateTime? _dob;
  AppRole? _role;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isFinancier = appState.roleName == RoleNames.financier;
    final roles = appState.roles;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Add User'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _name, decoration: _decoration('Full name')),
          const SizedBox(height: 14),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _decoration('Email')),
          const SizedBox(height: 14),
          TextField(controller: _password, obscureText: true, decoration: _decoration('Temporary password')),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 25),
                firstDate: DateTime(now.year - 80),
                lastDate: now,
              );
              if (picked != null) setState(() => _dob = picked);
            },
            child: InputDecorator(
              decoration: _decoration('Date of birth (customers: 18–50 yrs)'),
              child: Text(_dob == null ? 'Select date (optional)' : DateFormat('dd MMM yyyy').format(_dob!)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(controller: _pan, decoration: _decoration('PAN number (optional)')),
          if (isFinancier) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<AppRole>(
              decoration: _decoration('Role'),
              initialValue: _role,
              items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r.roleName))).toList(),
              onChanged: (v) => setState(() => _role = v),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('This will be created as a Customer account.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
            ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Create User', onPressed: _submit, loading: _saving),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      return _snack('Name, email and password are required.');
    }
    setState(() => _saving = true);
    try {
      final userId = await _svc.create(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        dob: _dob == null ? null : DateFormat('yyyy-MM-dd').format(_dob!),
        panNo: _pan.text.trim().isEmpty ? null : _pan.text.trim(),
        roleId: _role?.pkRoleId,
      );
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $userId created.')));
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
