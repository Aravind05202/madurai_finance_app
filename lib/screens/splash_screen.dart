import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/fonts.dart';
import '../state/app_state.dart';
import 'customer/customer_shell.dart';
import 'home/home_screen.dart';
import 'staff/staff_shell.dart';
import 'widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _statusText = 'Connecting to Secure Server...';
  late AnimationController _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _fadeAnim.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _statusText = 'Initializing 256-Bit SSL Client...');
    await ApiClient.instance.init();
    if (!mounted) return;

    final appState = context.read<AppState>();
    if (mounted) setState(() => _statusText = 'Verifying Authenticated Session...');
    final restored = await appState.restoreSession();
    if (!mounted) return;

    setState(() => _statusText = 'Ready! Launching Portal...');
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final nav = Navigator.of(context);
    if (restored) {
      nav.pushReplacement(MaterialPageRoute(
        builder: (_) => appState.isCustomer ? const CustomerShell() : const StaffShell(),
      ));
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Color(0xFF145C45),
              Color(0xFF0F3D2C),
              Color(0xFF062319),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 96, showGlow: true, animated: true),
                const SizedBox(height: 24),
                Text(
                  'Madurai Finance',
                  style: AppText.display(
                    size: 26,
                    color: Colors.white,
                    weight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Loans Made Simple, Smart & Secure',
                  style: AppText.body(
                    size: 13,
                    color: AppColors.goldLight,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 38),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                    strokeWidth: 2.6,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    _statusText,
                    style: AppText.mono(size: 11.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

