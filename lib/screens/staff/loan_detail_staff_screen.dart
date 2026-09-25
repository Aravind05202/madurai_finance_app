import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import '../../models/user.dart';
import '../../services/loan_service.dart';
import '../../state/app_state.dart';
import '../customer/rps_sheet.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';

class LoanDetailStaffScreen extends StatefulWidget {
  final Loan loan;
  const LoanDetailStaffScreen({super.key, required this.loan});
  @override
  State<LoanDetailStaffScreen> createState() => _LoanDetailStaffScreenState();
}

class _LoanDetailStaffScreenState extends State<LoanDetailStaffScreen> {
  final _svc = LoanService();
  List<RepaymentDetail> _schedule = [];
  bool _loading = true;
  bool _acting = false;
  late Loan _loan;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final schedule = await _svc.repaymentSchedule(_loan.pkLoanId);
      setState(() {
        _schedule = schedule;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _act(Future<void> Function() action, String successMsg) async {
    setState(() => _acting = true);
    try {
      await action();
      if (!mounted) return;
      final appState = context.read<AppState>();
      await appState.refreshBootstrap();
      if (!mounted) return;
      final refreshed = appState.loans.firstWhere((l) => l.pkLoanId == _loan.pkLoanId, orElse: () => _loan);
      setState(() => _loan = refreshed);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg)));
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  void _openRpsSheet() {
    final appState = context.read<AppState>();
    RpsSheet.show(
      context,
      loan: _loan,
      schedule: _schedule,
      userName: _loan.loanUserId,
      orgName: appState.org?['org_name']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppState>().roleName;
    final canApprove = role == RoleNames.financier;
    final canDisburse = role == RoleNames.financier;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Loan ${_loan.pkLoanId}'),
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_schedule.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: '1-Click View RPS Table & PDF',
              onPressed: _openRpsSheet,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Loan Amount', style: TextStyle(color: AppColors.textMuted)),
                      StatusBadge(_loan.status),
                    ],
                  ),
                  Text(formatMoney(_loan.loanAmount), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const Divider(height: 28),
                  _row('Customer ID', _loan.loanUserId),
                  _row('Interest rate', '${_loan.interestRate}% p.a.'),
                  _row('Tenure', '${_loan.tenureMonths} months'),
                  _row('Applied on', formatDate(_loan.applicationDate)),
                  if (_loan.approvalDate != null) _row('Approved on', formatDate(_loan.approvalDate)),
                  if (_loan.disbursementDate != null) _row('Disbursed on', formatDate(_loan.disbursementDate)),
                  if (_loan.dueDate != null) _row('Due by', formatDate(_loan.dueDate)),
                  _row('Received by customer', _loan.received ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_schedule.isNotEmpty) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.deepGreen, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.deepGreen.withValues(alpha: 0.04),
              ),
              onPressed: _openRpsSheet,
              icon: const Icon(Icons.table_chart_rounded, color: AppColors.deepGreen, size: 20),
              label: const Text(
                '1-Click View RPS Table & Download PDF',
                style: TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_loan.isPending && canApprove) ...[
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _acting ? null : () => _act(() => _svc.reject(_loan.pkLoanId), 'Loan rejected.'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _acting ? null : () => _act(() => _svc.approve(_loan.pkLoanId), 'Loan approved.'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
                  child: const Text('Approve'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ],
          if (_loan.isApproved && canDisburse) ...[
            PrimaryButton(
              label: 'Disburse Loan',
              icon: Icons.north_east,
              loading: _acting,
              onPressed: () => _act(() => _svc.disburse(_loan.pkLoanId), 'Loan disbursed.'),
            ),
            const SizedBox(height: 12),
          ],
          if (_schedule.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Repayment Schedule', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton.icon(
                  onPressed: _openRpsSheet,
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.deepGreen),
                  label: const Text('Table & PDF', style: TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ..._schedule.map((r) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08))),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${r.instlNum}', style: const TextStyle(fontSize: 12))),
                      title: Text(formatMoney(r.instAmt)),
                      subtitle: Text('Due ${formatDate(r.dueDate)}'),
                      trailing: Text(
                        r.isOverdue ? 'Overdue' : 'Scheduled',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: r.isOverdue ? AppColors.danger : AppColors.deepGreen,
                        ),
                      ),
                    ),
                  )),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
