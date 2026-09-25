import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/application.dart';
import '../../services/application_service.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final _svc = ApplicationService();
  List<LoanApplication> _apps = [];
  bool _loading = true;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final apps = await _svc.pending();
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _approve(LoanApplication app) async {
    setState(() => _busy.add(app.id));
    try {
      final loanId = await _svc.approve(app.ref);
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Approved. Loan $loanId created for ${app.custName}.')));
      }
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy.remove(app.id));
    }
  }

  Future<void> _reject(LoanApplication app) async {
    setState(() => _busy.add(app.id));
    try {
      await _svc.reject(app.ref);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy.remove(app.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pending Applications'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _apps.isEmpty
              ? const EmptyState(icon: Icons.fact_check_outlined, title: 'No pending applications')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _apps.length,
                    itemBuilder: (context, i) {
                      final app = _apps[i];
                      final busy = _busy.contains(app.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(app.custName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                                  ),
                                  Text(app.ref, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${app.custPhone} · ${app.custCity}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              const SizedBox(height: 10),
                              Text(formatMoney(app.loanAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                              Text('${app.financierLabel} · ${app.interestRate}% · ${app.tenureMonths} months',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                              Text('EMI ${formatMoney(app.emi)}', style: const TextStyle(fontSize: 12.5)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: busy ? null : () => _reject(app),
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: busy ? null : () => _approve(app),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
                                      child: busy
                                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Approve'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
