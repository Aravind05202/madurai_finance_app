import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import '../../services/loan_service.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/loan_card.dart';
import 'loan_detail_screen.dart';
import 'rps_sheet.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {

  Future<void> _refresh() async {
    try {
      await context.read<AppState>().refreshBootstrap();
    } catch (_) {
      // surfaced via list staying stale; user can pull again
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loans = appState.loans;
    final activeLoan = loans.firstWhere(
      (l) => l.isDisbursed,
      orElse: () => loans.isNotEmpty
          ? loans.first
          : Loan(
              pkLoanId: '',
              loanOrgId: '',
              loanUserId: '',
              loanAmount: 0,
              interestRate: 0,
              tenureMonths: 0,
              received: false,
              status: '',
            ),
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomView(
          appState: appState,
          loans: loans,
          activeLoan: loans.isEmpty ? null : activeLoan,
        ),
      ),
    );
  }
}

class CustomView extends StatelessWidget {
  final AppState appState;
  final List<Loan> loans;
  final Loan? activeLoan;
  const CustomView({super.key, required this.appState, required this.loans, this.activeLoan});

  Future<void> _open1ClickRps(BuildContext context, Loan loan) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final schedule = await LoanService().repaymentSchedule(loan.pkLoanId);
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        RpsSheet.show(
          context,
          loan: loan,
          schedule: schedule,
          userName: appState.currentUser?.userName ?? 'Customer',
          orgName: appState.org?['org_name']?.toString(),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading RPS: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Hero Gradient Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
          decoration: const BoxDecoration(
            gradient: AppGradients.hero,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x330B192C),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${appState.currentUser?.userName.split(' ').first ?? ''} 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      const Text('Madurai Finance', style: TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: const Icon(Icons.account_balance, color: AppColors.gold, size: 22),
                  ),
                ],
              ),
              if (activeLoan != null && activeLoan!.pkLoanId.isNotEmpty) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Outstanding on ${activeLoan!.pkLoanId}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activeLoan!.status,
                              style: const TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatMoney(activeLoan!.outstandingAmount ?? activeLoan!.loanAmount),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      if (activeLoan!.upcomingEmiDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.goldLight, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Next EMI due: ${formatDate(activeLoan!.upcomingEmiDate)}',
                              style: const TextStyle(color: AppColors.goldLight, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.deepGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () => _open1ClickRps(context, activeLoan!),
                              icon: const Icon(Icons.table_chart_rounded, size: 18),
                              label: const Text('1-Click View RPS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: activeLoan!)),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Loans',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Text(
                '${loans.length} Total',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (loans.isEmpty)
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No loans yet',
            subtitle: 'Once your loan application is approved, it will show up here.',
          )
        else
          ...loans.map((l) => LoanCard(
                loan: l,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: l))),
              )),
      ],
    );
  }
}
