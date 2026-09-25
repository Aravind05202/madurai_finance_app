import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../state/app_state.dart';
import '../customer/customer_shell.dart';
import '../widgets/app_logo.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen>
    with TickerProviderStateMixin {
  final _phone = TextEditingController();
  final _verification = TextEditingController();
  final _phoneFocus = FocusNode();
  final _verFocus = FocusNode();

  late AnimationController _entryAnim;
  late AnimationController _pulseAnim;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _pulseAnim = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fadeIn = CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryAnim, curve: Curves.easeOutCubic));
    _cardScale = Tween<double>(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: _entryAnim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _phone.dispose();
    _verification.dispose();
    _phoneFocus.dispose();
    _verFocus.dispose();
    _entryAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_phone.text.trim().length < 10 || _verification.text.trim().isEmpty) {
      _snack('Enter a valid 10-digit mobile number and your DOB or PAN.');
      return;
    }
    final appState = context.read<AppState>();
    try {
      final pendingApp = await appState.loginCustomer(_phone.text.trim(), _verification.text.trim());
      if (!mounted) return;
      if (pendingApp != null) {
        _showPendingApplication(pendingApp);
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerShell()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) _snack(e.toString());
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppText.body(size: 13, color: Colors.white)),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPendingApplication(Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.goldTint, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.pending_actions, color: AppColors.gold),
            ),
            const SizedBox(width: 10),
            Text('Application Found', style: AppText.heading(size: 17, color: AppColors.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Reference', value: '${app['ref']}'),
            const SizedBox(height: 6),
            _InfoRow(label: 'Status', value: '${app['status']}'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Your loan account will be created automatically once a financier approves your application. Please check back later.',
                style: AppText.body(size: 13, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, Got It'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppState>().loading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Deep forest gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.hero,
            ),
          ),
          // Top mint orb
          Positioned(
            top: -size.height * 0.08,
            right: -size.width * 0.2,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.mint.withValues(alpha: 0.08 + _pulseAnim.value * 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          // Bottom gold orb
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.gold.withValues(alpha: 0.07 + _pulseAnim.value * 0.03),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          // Kolam dot texture
          Positioned.fill(
            child: CustomPaint(painter: _DotTexturePainter()),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Brand row
                      Row(
                        children: [
                          const AppLogo(size: 56, showGlow: true),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Madurai Finance', style: AppText.display(size: 20, color: Colors.white, weight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text('Customer Portal', style: AppText.body(size: 12.5, color: AppColors.goldLight, weight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome back 👋', style: AppText.display(size: 30, color: Colors.white, weight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to view your loans, repayment schedules & make UPI payments securely.',
                        style: AppText.body(size: 13, color: Colors.white.withValues(alpha: 0.65)),
                      ),
                      const SizedBox(height: 28),

                      // Login Card
                      ScaleTransition(
                        scale: _cardScale,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: AppColors.deepGreen.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
                              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [AppColors.deepGreen, AppColors.primary]),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Secure Sign In', style: AppText.heading(size: 18, color: AppColors.textDark)),
                                        Text('Your data is encrypted & safe', style: AppText.body(size: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Divider(height: 28, color: Color(0xFFEEF2EF)),

                                // Mobile field
                                const _FieldLabel(label: 'Mobile Number', icon: Icons.phone_android_rounded),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phone,
                                  focusNode: _phoneFocus,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: AppText.mono(size: 15, color: AppColors.textDark),
                                  decoration: _fieldDecoration(
                                    hint: '10-digit registered mobile',
                                    icon: Icons.phone_android_rounded,
                                    suffix: _phone.text.length == 10
                                        ? const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 20)
                                        : null,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () => _verFocus.requestFocus(),
                                ),
                                const SizedBox(height: 16),

                                // Verification field
                                const _FieldLabel(label: 'Date of Birth or PAN', icon: Icons.shield_outlined),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _verification,
                                  focusNode: _verFocus,
                                  style: AppText.mono(size: 15, color: AppColors.textDark),
                                  decoration: _fieldDecoration(
                                    hint: 'yyyy-mm-dd  or  ABCDE1234F',
                                    icon: Icons.shield_outlined,
                                  ),
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 12),

                                // Info hint
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, color: AppColors.goldDark, size: 16),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          'Use the mobile & DOB/PAN from your loan application.',
                                          style: AppText.body(size: 11.5, color: AppColors.goldDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sign In Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.deepGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shadowColor: AppColors.deepGreen.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: loading ? null : _submit,
                                    child: loading
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.login_rounded, size: 20),
                                              const SizedBox(width: 10),
                                              Text('Continue to Portal',
                                                  style: AppText.heading(size: 15.5, color: Colors.white, weight: FontWeight.w800)),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Feature highlights
                      const _FeatureRow(icon: Icons.receipt_long_rounded, title: 'Repayment Schedule', subtitle: 'Download official RPS statement anytime'),
                      const SizedBox(height: 12),
                      const _FeatureRow(icon: Icons.qr_code_2_rounded, title: 'UPI Payments', subtitle: 'Pay instalments instantly via GPay / PhonePe'),
                      const SizedBox(height: 12),
                      const _FeatureRow(icon: Icons.history_rounded, title: 'Full Loan History', subtitle: 'Track all loans & payment records in one place'),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData icon, Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.55), fontSize: 13.5),
        filled: true,
        fillColor: AppColors.bg,
        prefixIcon: Icon(icon, color: AppColors.green, size: 20),
        suffixIcon: suffix,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.green, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      );
}

// ── Supporting Widgets ──

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FieldLabel({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(label, style: AppText.body(size: 12, color: AppColors.textMuted, weight: FontWeight.w700)),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text('$label: ', style: AppText.body(size: 13, color: AppColors.textMuted, weight: FontWeight.w600)),
          Text(value, style: AppText.mono(size: 13, color: AppColors.textDark, weight: FontWeight.w700)),
        ],
      );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F3D2C), Color(0xFF1B5C42)]),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: AppColors.goldLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(size: 13, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.body(size: 11.5, color: Colors.white.withValues(alpha: 0.55))),
              ],
            ),
          ),
        ],
      );
}

class _DotTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.035);
    const spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
