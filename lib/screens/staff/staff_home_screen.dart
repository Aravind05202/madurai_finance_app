import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import 'applications_screen.dart';
import 'collections_screen.dart';
import 'loans_screen.dart';
import 'record_collection_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final String role;
  const StaffHomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loans = appState.loans;
    final applications = appState.applications;
    final collections = appState.collections;

    final pendingApplications = applications.where((a) => a.status == 'Pending Review').length;
    final pendingLoans = loans.where((l) => l.isPending).length;
    final approvedLoans = loans.where((l) => l.isApproved).length;
    final disbursedLoans = loans.where((l) => l.isDisbursed).length;
    final totalDisbursedAmount = loans.where((l) => l.isDisbursed || l.isClosed).fold<num>(0, (a, l) => a + l.loanAmount);
    final totalCollected = collections.where((c) => c.status == 'SUCCESS').fold<num>(0, (a, c) => a + c.collectionAmount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard('Pending Applications', '$pendingApplications', Icons.fact_check_outlined, AppColors.warning),
            _statCard('Pending Loans', '$pendingLoans', Icons.hourglass_empty, AppColors.warning),
            _statCard('Approved (awaiting disbursal)', '$approvedLoans', Icons.verified_outlined, AppColors.green),
            _statCard('Active Loans', '$disbursedLoans', Icons.account_balance_wallet_outlined, AppColors.deepGreen),
            _statCard('Total Disbursed', formatMoney(totalDisbursedAmount), Icons.north_east, AppColors.deepGreen),
            _statCard('Total Collected', formatMoney(totalCollected), Icons.south_west, AppColors.success),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if ([RoleNames.financier, RoleNames.dataEntryOperator].contains(role))
              _actionChip(context, 'Review Applications', Icons.fact_check_outlined, const ApplicationsScreen()),
            if ([RoleNames.financier, RoleNames.security, RoleNames.dataEntryOperator].contains(role))
              _actionChip(context, 'View Loans', Icons.account_balance_outlined, const LoansScreen()),
            if (role == RoleNames.collectionAgent)
              _actionChip(context, 'Record Payment', Icons.point_of_sale_outlined, const RecordCollectionScreen()),
            if ([RoleNames.financier, RoleNames.collectionAgent, RoleNames.security].contains(role))
              _actionChip(context, 'View Collections', Icons.payments_outlined, const CollectionsScreen()),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionChip(BuildContext context, String label, IconData icon, Widget screen) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.deepGreen),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.15)),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
    );
  }
}
