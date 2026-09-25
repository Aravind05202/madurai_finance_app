import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AppState>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final org = context.watch<AppState>().org;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.deepGreen,
            child: Text(
              (user?.userName.isNotEmpty == true ? user!.userName[0] : '?').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text(user?.userName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          Center(child: Text(user?.userEmail ?? '', style: const TextStyle(color: AppColors.textMuted))),
          const SizedBox(height: 24),
          _tile('Customer ID', user?.pkUserId ?? '—'),
          _tile('PAN', user?.panNo ?? '—'),
          _tile('Date of Birth', user?.dob ?? '—'),
          _tile('Organization', org?['org_name']?.toString() ?? '—'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _tile(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
