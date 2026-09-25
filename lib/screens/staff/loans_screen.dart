import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/loan_card.dart';
import 'loan_detail_staff_screen.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loans = appState.loans;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Loans'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: loans.isEmpty
          ? const EmptyState(icon: Icons.account_balance_outlined, title: 'No loans yet')
          : RefreshIndicator(
              onRefresh: () => appState.refreshBootstrap(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: loans.length,
                itemBuilder: (context, i) => LoanCard(
                  loan: loans[i],
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoanDetailStaffScreen(loan: loans[i]))),
                ),
              ),
            ),
    );
  }
}
