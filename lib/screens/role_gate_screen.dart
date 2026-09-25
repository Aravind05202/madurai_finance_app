import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/fonts.dart';
import 'apply/apply_loan_screen.dart';
import 'auth/customer_login_screen.dart';
import 'auth/staff_login_screen.dart';
import 'widgets/app_logo.dart';

class RoleGateScreen extends StatelessWidget {
  const RoleGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  gradient: AppGradients.hero,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x330F3D2C),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const AppLogo(size: 76, showGlow: true, showBorder: true),
                    const SizedBox(height: 16),
                    Text(
                      'Madurai Finance',
                      style: AppText.display(
                        color: Colors.white,
                        size: 24,
                        weight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loans made simple, smart & secure',
                      style: AppText.body(color: AppColors.goldLight, size: 13.5, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text('Select an option below to proceed', style: TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
                    const SizedBox(height: 24),
                    _RoleTile(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Apply for a Loan',
                      subtitle: 'New customer? Submit a loan application directly.',
                      color: AppColors.gold,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApplyLoanScreen())),
                    ),
                    const SizedBox(height: 14),
                    _RoleTile(
                      icon: Icons.person_rounded,
                      title: 'Customer Self-Service',
                      subtitle: 'View loan details, RPS statements & pay via UPI.',
                      color: AppColors.green,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen())),
                    ),
                    const SizedBox(height: 14),
                    _RoleTile(
                      icon: Icons.badge_outlined,
                      title: 'Staff Portal Login',
                      subtitle: 'Financier, Agent, Security or Data Entry login.',
                      color: AppColors.deepGreen,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffLoginScreen())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _RoleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.3)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
