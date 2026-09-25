import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../apply/apply_loan_screen.dart';
import '../auth/customer_login_screen.dart';
import '../auth/staff_login_screen.dart';
import '../widgets/app_logo.dart';
import 'widgets/live_activity_ticker.dart';
import 'widgets/live_rate_ticker.dart';
import 'widgets/loan_calculator_card.dart';
import 'widgets/product_showcase_card.dart';

/// Real-Time Luxury Home Portal for Madurai Finance
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  final List<ProductCardData> _products = const [
    ProductCardData(
      title: 'Personal Loan',
      tag: 'FASTEST APPROVAL',
      rate: '10.5% p.a.',
      maxAmount: '₹5,00,000',
      tenure: '48 Months',
      speed: '15 Mins',
      icon: Icons.person_rounded,
      perks: [
        'Zero collateral required',
        'Minimal KYC documents',
        'Instant bank disbursal via IMPS',
      ],
    ),
    ProductCardData(
      title: 'Business Growth Loan',
      tag: 'HIGH VALUE',
      rate: '12.0% p.a.',
      maxAmount: '₹25,00,000',
      tenure: '60 Months',
      speed: '24 Hours',
      icon: Icons.storefront_rounded,
      perks: [
        'Working capital & expansion',
        'Flexible weekly/monthly repayment',
        'Tax deductible interest',
      ],
    ),
    ProductCardData(
      title: 'Gold / Asset Backed',
      tag: 'LOWEST INTEREST',
      rate: '8.5% p.a.',
      maxAmount: '₹15,00,000',
      tenure: '36 Months',
      speed: '10 Mins',
      icon: Icons.stars_rounded,
      perks: [
        'Highest per-gram valuation (90% LTV)',
        'Insured & secure locker storage',
        'Zero prepayment penalties',
      ],
    ),
    ProductCardData(
      title: 'Daily Micro-Finance',
      tag: 'DAILY COLLECTION',
      rate: '14.0% p.a.',
      maxAmount: '₹1,00,000',
      tenure: '100 Days',
      speed: 'Instant',
      icon: Icons.receipt_long_rounded,
      perks: [
        'Doorstep collection agent visit',
        'Instant digital UPI receipts',
        'Build credit score easily',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = _currentTime.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm:ss a').format(_currentTime);
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(_currentTime);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Real-Time Live Top App Bar
            _buildRealtimeHeader(dateStr, timeStr),

            // Live Rate Ticker
            const LiveRateTicker(),

            // Main Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.deepGreen,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) setState(() {});
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      _buildHeroBanner(),

                      // Real-time Verified Activity Stream
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stream_rounded, size: 16, color: AppColors.mint),
                                const SizedBox(width: 6),
                                Text(
                                  'LIVE DISBURSAL STREAM',
                                  style: AppText.badge(size: 11, color: AppColors.textMuted, weight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const LiveActivityTicker(),
                          ],
                        ),
                      ),

                      // Quick Service Portals Hub
                      _buildServiceHub(),

                      // Loan Products Carousel
                      _buildProductsSection(),

                      // Trust, Security & Compliance
                      _buildTrustBadges(),

                      // FAQ & Support
                      _buildFaqSection(),

                      // Bottom Spacing
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildRealtimeHeader(String dateStr, String timeStr) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 1)),
      ),
      child: Row(
        children: [
          const AppLogo(size: 38, showGlow: true, showBorder: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Madurai Finance',
                      style: AppText.display(size: 17, color: Colors.white, weight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    const LiveServerBadge(label: 'LIVE'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.white30, fontSize: 11)),
                    Text(
                      timeStr,
                      style: AppText.mono(size: 11, color: AppColors.goldLight, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.goldLight, size: 18),
            ),
            tooltip: 'Security & RBI Compliance',
            onPressed: () => _showSecurityDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F3D2C),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold, width: 0.8),
                ),
                child: Text(
                  '✨ $_greeting',
                  style: AppText.badge(size: 11, color: AppColors.goldLight, weight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '15-Min Disbursal',
                      style: AppText.badge(size: 10.5, color: Colors.white, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart, Secure &\nInstant Lending in Madurai',
            style: AppText.display(size: 24, color: Colors.white, weight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'From personal credit to business expansion. Transparent repayment schedules (RPS), zero hidden costs, and seamless UPI payments.',
            style: AppText.body(size: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
          ),
          const SizedBox(height: 20),

          // Primary & Secondary Actions
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.deepGreen,
                      elevation: 4,
                      shadowColor: AppColors.gold.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_turned_in, size: 18, color: AppColors.deepGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Apply for Loan',
                          style: AppText.heading(size: 14.5, color: AppColors.deepGreen, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: AppColors.gold.withValues(alpha: 0.8), width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showEmiCalculatorModal(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calculate_rounded, size: 16, color: AppColors.goldLight),
                        const SizedBox(width: 6),
                        Text(
                          'EMI Calc',
                          style: AppText.heading(size: 13.5, color: Colors.white, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Real-Time Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _StatCol(value: '₹15 Cr+', label: 'Disbursed'),
                _DividerVertical(),
                const _StatCol(value: '12,500+', label: 'Borrowers'),
                _DividerVertical(),
                const _StatCol(value: '99.8%', label: 'Approval'),
                _DividerVertical(),
                const _StatCol(value: '4.9 ★', label: 'Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmiCalculatorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calculate_rounded, color: AppColors.goldDark, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('EMI Calculator', style: AppText.heading(size: 17, color: AppColors.textDark, weight: FontWeight.w800)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const LoanCalculatorCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHub() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Access Portals', style: AppText.heading(size: 18, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Select your access mode below', style: AppText.body(size: 12, color: AppColors.textMuted)),
                ],
              ),
              const AppLogo(size: 28, showGlow: false),
            ],
          ),
          const SizedBox(height: 14),

          // Grid of 4 Core Pillars
          Row(
            children: [
              Expanded(
                child: _PortalCard(
                  title: 'Apply for Loan',
                  subtitle: '3-Step Instant Form',
                  icon: Icons.edit_document,
                  gradient: const [AppColors.green, AppColors.deepGreen],
                  accentColor: AppColors.gold,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApplyLoanScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PortalCard(
                  title: 'EMI Calculator',
                  subtitle: 'Estimate Monthly EMI',
                  icon: Icons.calculate_rounded,
                  gradient: const [AppColors.primary, AppColors.deepGreen],
                  accentColor: AppColors.goldLight,
                  onTap: () => _showEmiCalculatorModal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PortalCard(
                  title: 'Customer Login',
                  subtitle: 'RPS, Loans & UPI',
                  icon: Icons.person_rounded,
                  gradient: const [Color(0xFF1B4332), Color(0xFF081C15)],
                  accentColor: AppColors.mint,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PortalCard(
                  title: 'Staff Management',
                  subtitle: 'Financier / Agent / DEO',
                  icon: Icons.badge_outlined,
                  gradient: const [Color(0xFF2D6A4F), Color(0xFF1B4332)],
                  accentColor: AppColors.gold,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffLoginScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Products & Rates', style: AppText.heading(size: 18, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Custom financing plans tailored for you', style: AppText.body(size: 12, color: AppColors.textMuted)),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApplyLoanScreen())),
                child: Row(
                  children: [
                    Text('View All', style: AppText.heading(size: 13, color: AppColors.green, weight: FontWeight.w700)),
                    const Icon(Icons.chevron_right, color: AppColors.green, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 315,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: _products.length,
            itemBuilder: (context, index) => ProductShowcaseCard(product: _products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    final features = [
      {'icon': Icons.security, 'title': '256-Bit SSL Security', 'desc': 'End-to-end encrypted financial data'},
      {'icon': Icons.verified, 'title': '100% Transparent RPS', 'desc': 'Full principal & interest schedule clarity'},
      {'icon': Icons.speed, 'title': 'Fast-Track Disbursal', 'desc': 'Direct bank account transfer via IMPS/NEFT'},
      {'icon': Icons.support_agent, 'title': 'Local Madurai Support', 'desc': 'Dedicated doorstep agents & customer desk'},
    ];

    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.mint, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why Madurai Finance?', style: AppText.heading(size: 17, color: AppColors.textDark)),
                  Text('Trusted by 12,000+ local families & enterprises', style: AppText.body(size: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.deepGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(f['icon'] as IconData, size: 16, color: AppColors.deepGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['title'] as String, style: AppText.heading(size: 13.5, color: AppColors.textDark, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(f['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently Asked Questions', style: AppText.heading(size: 17, color: AppColors.textDark)),
          const SizedBox(height: 10),
          const _FaqTile(
            question: 'How fast is the loan disbursed?',
            answer: 'Once your application is approved by our Financier, the funds are credited directly to your bank account via IMPS within 15 to 30 minutes.',
          ),
          const _FaqTile(
            question: 'What is a Repayment Schedule (RPS)?',
            answer: 'An RPS is an official statement breaking down every installment date, principal portion, interest component, and outstanding balance. You can view & download it anytime from the Customer Portal.',
          ),
          const _FaqTile(
            question: 'How do I repay using UPI?',
            answer: 'Log in to Customer Self-Service, tap "Pay via UPI", and choose your preferred app (GPay, PhonePe, Paytm). After payment, enter the UTR reference to verify.',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTab,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          setState(() => _selectedTab = index);
          if (index == 1) {
            // Scroll to calculator
            _scrollController.animateTo(480, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApplyLoanScreen()));
          } else if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));
          } else if (index == 4) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffLoginScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), label: 'EMI Calc'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Apply'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Customer'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Staff'),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified_user, color: AppColors.green),
            const SizedBox(width: 10),
            Text('Bank-Grade Security', style: AppText.heading(size: 18, color: AppColors.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Madurai Finance operates with strict 256-bit SSL encryption, session cookie protection, and conforms to state non-banking financial guidelines.',
              style: AppText.body(size: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            const Text('• Backend API: Encrypted Production Endpoints', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
            const Text('• Payments: Verified UPI Deep-linking & UTR Tracking', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
            const Text('• Data: Zero third-party telemetry sharing', style: TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  const _StatCol({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppText.mono(size: 14, color: AppColors.goldLight, weight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
      ],
    );
  }
}

class _DividerVertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: Colors.white12);
  }
}

class _PortalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(height: 12),
                Text(title, style: AppText.heading(size: 14.5, color: Colors.white, weight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Text(question, style: AppText.heading(size: 13.5, color: AppColors.textDark, weight: FontWeight.w700)),
        children: [
          Text(answer, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
        ],
      ),
    );
  }
}
