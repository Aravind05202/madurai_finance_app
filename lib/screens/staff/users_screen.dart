import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _svc = UserService();
  final Set<String> _busy = {};

  Future<void> _toggle(AppUser u) async {
    setState(() => _busy.add(u.pkUserId));
    try {
      await _svc.toggleStatus(u.pkUserId);
      if (!mounted) return;
      await context.read<AppState>().refreshBootstrap();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy.remove(u.pkUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final role = appState.roleName;
    final canToggle = role == RoleNames.financier;
    final users = appState.users;
    final roleById = {for (final r in appState.roles) r.pkRoleId: r.roleName};

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Users'), backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
      body: users.isEmpty
          ? const EmptyState(icon: Icons.people_outline, title: 'No users found')
          : RefreshIndicator(
              onRefresh: () => appState.refreshBootstrap(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final u = users[i];
                  final busy = _busy.contains(u.pkUserId);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppColors.deepGreen.withValues(alpha: 0.08)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.deepGreen,
                        child: Text(u.userName.isNotEmpty ? u.userName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(u.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${u.userEmail}\n${roleById[u.userRoleId] ?? u.userRoleId}'),
                      isThreeLine: true,
                      trailing: canToggle
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge(u.status),
                                IconButton(
                                  icon: busy
                                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.power_settings_new, size: 20),
                                  onPressed: busy ? null : () => _toggle(u),
                                ),
                              ],
                            )
                          : StatusBadge(u.status),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
