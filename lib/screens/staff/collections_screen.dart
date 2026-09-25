import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final collections = [...appState.collections]..sort((a, b) => b.collectionDate.compareTo(a.collectionDate));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Collections'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: collections.isEmpty
          ? const EmptyState(icon: Icons.payments_outlined, title: 'No collections recorded yet')
          : RefreshIndicator(
              onRefresh: () => appState.refreshBootstrap(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: collections.length,
                itemBuilder: (context, i) {
                  final c = collections[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.success.withValues(alpha: 0.12),
                        child: const Icon(Icons.south_west, color: AppColors.success, size: 18),
                      ),
                      title: Text(formatMoney(c.collectionAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Loan ${c.collectionLoanId} · ${c.paymentMode}'
                          '${c.referenceNo != null && c.referenceNo!.isNotEmpty ? ' · Ref ${c.referenceNo}' : ''}\n'
                          '${formatDate(c.collectionDate)}'),
                      isThreeLine: true,
                      trailing: StatusBadge(c.status),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
