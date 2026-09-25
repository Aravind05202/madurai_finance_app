import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final collections = [...appState.collections]
      ..sort((a, b) => b.collectionDate.compareTo(a.collectionDate));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<AppState>().refreshBootstrap(),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Payment History'),
              backgroundColor: AppColors.bg,
              foregroundColor: AppColors.textDark,
              elevation: 0,
              pinned: true,
            ),
            if (collections.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(icon: Icons.receipt_long_outlined, title: 'No payments recorded yet'),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = collections[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.success.withValues(alpha: 0.12),
                          child: const Icon(Icons.check, color: AppColors.success, size: 18),
                        ),
                        title: Text(formatMoney(c.collectionAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            'Loan ${c.collectionLoanId} · ${c.paymentMode} · ${formatDate(c.collectionDate)}'),
                        trailing: StatusBadge(c.status),
                      ),
                    );
                  },
                  childCount: collections.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
