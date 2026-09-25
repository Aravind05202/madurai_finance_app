import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../home/home_screen.dart';
import 'applications_screen.dart';
import 'audit_screen.dart';
import 'collections_screen.dart';
import 'create_loan_screen.dart';
import 'create_user_screen.dart';
import 'loans_screen.dart';
import 'record_collection_screen.dart';
import 'staff_home_screen.dart';
import 'users_screen.dart';

class StaffShell extends StatelessWidget {
  const StaffShell({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AppState>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final role = appState.roleName;
    final user = appState.currentUser;

    final canLoans = [RoleNames.financier, RoleNames.security, RoleNames.dataEntryOperator].contains(role);
    final canApplications = [RoleNames.financier, RoleNames.dataEntryOperator].contains(role);
    final canCollections = [RoleNames.financier, RoleNames.collectionAgent, RoleNames.security].contains(role);
    final canRecordCollection = role == RoleNames.collectionAgent;
    final canUsers = [RoleNames.financier, RoleNames.security, RoleNames.dataEntryOperator].contains(role);
    final canCreateLoan = [RoleNames.financier, RoleNames.dataEntryOperator].contains(role);
    final canAudit = [RoleNames.financier, RoleNames.collectionAgent, RoleNames.security].contains(role);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(role.isEmpty ? 'Madurai Finance' : role),
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.deepGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.userName ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(role, style: const TextStyle(color: AppColors.goldLight, fontSize: 12.5)),
                  ],
                ),
              ),
              _navTile(context, Icons.dashboard_outlined, 'Dashboard', () => Navigator.pop(context)),
              if (canApplications)
                _navTile(context, Icons.fact_check_outlined, 'Applications', () => _push(context, const ApplicationsScreen())),
              if (canLoans) _navTile(context, Icons.account_balance_outlined, 'Loans', () => _push(context, const LoansScreen())),
              if (canCreateLoan) _navTile(context, Icons.add_card_outlined, 'Create Loan', () => _push(context, const CreateLoanScreen())),
              if (canCollections) _navTile(context, Icons.payments_outlined, 'Collections', () => _push(context, const CollectionsScreen())),
              if (canRecordCollection)
                _navTile(context, Icons.point_of_sale_outlined, 'Record Payment', () => _push(context, const RecordCollectionScreen())),
              if (canUsers) _navTile(context, Icons.people_outline, 'Users', () => _push(context, const UsersScreen())),
              if (canUsers) _navTile(context, Icons.person_add_alt_outlined, 'Add User', () => _push(context, const CreateUserScreen())),
              if (canAudit) _navTile(context, Icons.history, 'Audit Log', () => _push(context, const AuditScreen())),
              const Spacer(),
              const Divider(height: 1),
              _navTile(context, Icons.logout, 'Log Out', () => _logout(context), color: AppColors.danger),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => appState.refreshBootstrap(),
          child: StaffHomeScreen(role: role),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _navTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.deepGreen),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
