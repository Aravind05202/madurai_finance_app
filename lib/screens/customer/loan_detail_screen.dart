import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import '../../services/loan_service.dart';
import '../../services/local_store.dart';
import '../../state/app_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';
import 'rps_sheet.dart';
import 'upi_pay_screen.dart';

class LoanDetailScreen extends StatefulWidget {
  final Loan loan;
  const LoanDetailScreen({super.key, required this.loan});
  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final _loanSvc = LoanService();
  List<RepaymentDetail> _schedule = [];
  List<PendingUpiPayment> _pending = [];
  bool _loading = true;
  bool _acknowledging = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final schedule = await _loanSvc.repaymentSchedule(widget.loan.pkLoanId);
      final pending = (await LocalStore.pendingPayments()).where((p) => p.loanId == widget.loan.pkLoanId).toList();
      setState(() {
        _schedule = schedule;
        _pending = pending;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  num get _paid {
    final appState = context.read<AppState>();
    return appState.collections
        .where((c) => c.collectionLoanId == widget.loan.pkLoanId && c.status == 'SUCCESS')
        .fold<num>(0, (a, c) => a + c.collectionAmount);
  }

  num get _outstanding {
    final o = widget.loan.loanAmount - _paid;
    return o < 0 ? 0 : o;
  }

  Future<void> _acknowledge() async {
    setState(() => _acknowledging = true);
    try {
      await _loanSvc.acknowledgeReceipt(widget.loan.pkLoanId);
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt acknowledged.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _acknowledging = false);
    }
  }

  void _openRpsSheet() {
    final appState = context.read<AppState>();
    RpsSheet.show(
      context,
      loan: widget.loan,
      schedule: _schedule,
      userName: appState.currentUser?.userName ?? 'Customer',
      orgName: appState.org?['org_name']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Loan ${loan.pkLoanId}'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(_error!)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
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
                                  StatusBadge(loan.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(formatMoney(loan.loanAmount),
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                              const Divider(height: 28),
                              _row('Interest rate', '${loan.interestRate}% p.a.'),
                              _row('Tenure', '${loan.tenureMonths} months'),
                              _row('Applied on', formatDate(loan.applicationDate)),
                              if (loan.approvalDate != null) _row('Approved on', formatDate(loan.approvalDate)),
                              if (loan.disbursementDate != null) _row('Disbursed on', formatDate(loan.disbursementDate)),
                              if (loan.dueDate != null) _row('Due by', formatDate(loan.dueDate)),
                              if (loan.isDisbursed) ...[
                                const Divider(height: 28),
                                _row('Paid so far', formatMoney(_paid)),
                                _row('Outstanding', formatMoney(_outstanding)),
                              ],
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
                      if (loan.isDisbursed && !loan.received) ...[
                        PrimaryButton(
                          label: 'Acknowledge Loan Received',
                          icon: Icons.check_circle_outline,
                          onPressed: _acknowledge,
                          loading: _acknowledging,
                          color: AppColors.green,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (loan.isDisbursed && _outstanding > 0) ...[
                        PrimaryButton(
                          label: 'Pay via UPI',
                          icon: Icons.qr_code_2,
                          color: AppColors.gold,
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => UpiPayScreen(loan: loan, outstanding: _outstanding)))
                              .then((_) => _load()),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_pending.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Awaiting confirmation',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning)),
                              const SizedBox(height: 6),
                              ..._pending.map((p) => Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('${formatMoney(p.amount)} · UTR ${p.utr} · ${formatDate(p.date.toIso8601String())}',
                                        style: const TextStyle(fontSize: 12.5)),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        ..._schedule.map((r) => Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08))),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: r.isOverdue ? AppColors.danger.withValues(alpha: 0.12) : AppColors.deepGreen.withValues(alpha: 0.08),
                                  child: Text('${r.instlNum}', style: const TextStyle(fontSize: 12)),
                                ),
                                title: Text(formatMoney(r.instAmt), style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('Due ${formatDate(r.dueDate)} · Principal ${formatMoney(r.principal)} · Interest ${formatMoney(r.interest)}'),
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
