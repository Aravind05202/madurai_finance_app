import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final audit = appState.audit;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Audit Log'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: audit.isEmpty
          ? const EmptyState(icon: Icons.history, title: 'No audit entries yet')
          : RefreshIndicator(
              onRefresh: () => appState.refreshBootstrap(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: audit.length,
                itemBuilder: (context, i) {
                  final a = audit[i];
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: AppColors.deepGreen, child: Icon(Icons.receipt_long, color: Colors.white, size: 16)),
                    title: Text(a.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: Text('${a.details ?? ''}\n${a.userName} · ${formatDate(a.createdDatetime)}'),
                    isThreeLine: true,
                  );
                },
              ),
            ),
    );
  }
}
