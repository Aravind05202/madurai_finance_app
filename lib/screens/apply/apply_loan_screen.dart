import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../core/utils.dart';
import '../../models/application.dart';
import '../../services/apply_service.dart';
import '../../services/rates_service.dart';

// Loan repayment types sourced from master
const List<_LoanType> _kLoanTypes = [
  _LoanType(key: 'DAILY', label: 'Daily', icon: Icons.today_rounded, subtitle: 'Repay every day'),
  _LoanType(key: 'WEEKLY', label: 'Weekly', icon: Icons.date_range_rounded, subtitle: 'Repay every week'),
  _LoanType(key: 'MONTHLY', label: 'Monthly', icon: Icons.calendar_month_rounded, subtitle: 'Repay once a month'),
  _LoanType(key: 'YEARLY', label: 'Yearly', icon: Icons.event_note_rounded, subtitle: 'Repay once a year'),
];

class _LoanType {
  final String key;
  final String label;
  final IconData icon;
  final String subtitle;
  const _LoanType({required this.key, required this.label, required this.icon, required this.subtitle});
}

class ApplyLoanScreen extends StatefulWidget {
  final int? initialAmount;
  final int? initialTenure;

  const ApplyLoanScreen({super.key, this.initialAmount, this.initialTenure});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> with SingleTickerProviderStateMixin {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final _ratesSvc = RatesService();
  final _applySvc = ApplyService();

  int _currentStep = 0; // 0: Personal, 1: Loan, 2: Sanction Review

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pan = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  late final TextEditingController _amount;
  DateTime? _dob;
  int? _tenure;
  String _loanType = 'MONTHLY'; // default

  FinancierRateCard? _selectedFinancier;
  bool _loadingRates = true;
  bool _submitting = false;
  String? _loadError;

  late AnimationController _anim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: (widget.initialAmount ?? 50000).toString());
    _tenure = widget.initialTenure;
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _loadRates();
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _email.dispose();
    _pan.dispose(); _city.dispose(); _address.dispose();
    _amount.dispose(); _anim.dispose(); _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() { _loadingRates = true; _loadError = null; });
    try {
      final list = await _ratesSvc.masterList();
      final activeList = list.where((f) => f.status == 'ACTIVE' && f.rates.isNotEmpty).toList();
      setState(() {
        // Hardcode Madurai Finance as default & primary financier
        if (activeList.isNotEmpty) {
          _selectedFinancier = activeList.firstWhere(
            (f) => f.key.toLowerCase().contains('madurai') || f.label.toLowerCase().contains('madurai'),
            orElse: () => activeList.first,
          );
          if (_tenure == null && _selectedFinancier!.rates.isNotEmpty) {
            final sortedTenures = _selectedFinancier!.rates.keys.toList()..sort();
            _tenure = sortedTenures.contains(12) ? 12 : sortedTenures.first;
          }
        }
        _loadingRates = false;
      });
    } catch (e) {
      setState(() { _loadError = e.toString(); _loadingRates = false; });
    }
  }

  num? get _amountValue => num.tryParse(_amount.text.trim());

  num? get _estimatedRate {
    if (_selectedFinancier == null || _tenure == null) return null;
    final base = _selectedFinancier!.rates[_tenure];
    if (base == null) return null;
    final amt = _amountValue ?? 0;
    double adj = 0;
    if (amt >= 500000) { adj = -0.5; }
    else if (amt >= 200000) { adj = -0.25; }
    else if (amt < 50000) { adj = 0.5; }
    final r = (base + adj);
    return r < 8 ? 8 : (r * 100).round() / 100;
  }

  /// Compute EMI, total payable, total interest based on selected values
  Map<String, num>? get _sanctionDetails {
    final amt = _amountValue;
    final rate = _estimatedRate;
    final tenure = _tenure;
    if (amt == null || rate == null || tenure == null || amt <= 0) return null;

    // Monthly EMI = P * r * (1+r)^n / ((1+r)^n - 1)
    final monthlyRate = rate / 12 / 100;
    late num emi;
    if (monthlyRate == 0) {
      emi = amt / tenure;
    } else {
      final pow = (1 + monthlyRate).toDouble();
      double powN = 1;
      for (int i = 0; i < tenure; i++) { powN *= pow; }
      emi = (amt * monthlyRate * powN) / (powN - 1);
    }

    // Adjust for loan type display (the EMI formula above is monthly-based)
    num displayEmi = emi;
    int installments = tenure;
    switch (_loanType) {
      case 'DAILY':
        // approx 30 days per month
        displayEmi = emi / 30;
        installments = tenure * 30;
        break;
      case 'WEEKLY':
        // approx 4.33 weeks per month
        displayEmi = emi / 4.33;
        installments = (tenure * 4.33).round();
        break;
      case 'MONTHLY':
        displayEmi = emi;
        installments = tenure;
        break;
      case 'YEARLY':
        // aggregate 12 monthly EMIs into one annual
        displayEmi = emi * 12;
        installments = (tenure / 12).ceil();
        break;
    }

    final roundedEmi = displayEmi.round();
    final totalPayable = (roundedEmi * installments).round();
    final totalInterest = (totalPayable - amt).round();

    return {
      'emi': roundedEmi,
      'total_payable': totalPayable,
      'total_interest': totalInterest < 0 ? 0 : totalInterest,
      'installments': installments,
    };
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextFromStep1() {
    if (!_step1FormKey.currentState!.validate()) return;
    if (_dob == null) {
      _snack('Please select your date of birth.');
      return;
    }
    _goToStep(1);
  }

  void _nextFromStep2() {
    if (!_step2FormKey.currentState!.validate()) return;
    if (_tenure == null) {
      _snack('Please select a loan tenure.');
      return;
    }
    if (_amountValue == null || _amountValue! < 6000) {
      _snack('Minimum loan amount is ₹6,000.');
      return;
    }
    _goToStep(2);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 18),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (_dob == null || _selectedFinancier == null || _tenure == null) {
      _snack('Please complete all required fields.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final ref = await _applySvc.submit(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        dob: DateFormat('yyyy-MM-dd').format(_dob!),
        pan: _pan.text.trim(),
        city: _city.text.trim(),
        address: _address.text.trim(),
        financierKey: _selectedFinancier!.key,
        amount: _amountValue ?? 0,
        tenure: _tenure!,
      );
      if (!mounted) return;
      _showSuccessDialog(ref);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog(String ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.deepGreen, AppColors.primary]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            Text('Application Submitted!', style: AppText.heading(size: 18, color: AppColors.textDark), textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  Text('Your Reference Number', style: AppText.body(size: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(ref, style: AppText.mono(size: 18, color: AppColors.deepGreen, weight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Save this reference. You can check your application status by signing in with your mobile number and DOB/PAN once reviewed by Madurai Finance.',
              style: AppText.body(size: 12.5, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.of(context).pop(); // go back
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: AppText.body(size: 13, color: Colors.white)),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loadingRates
          ? _buildLoading()
          : _loadError != null
              ? _buildError()
              : _buildWizard(),
    );
  }

  Widget _buildLoading() => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.deepGreen)),
      );

  Widget _buildError() => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.textMuted),
              const SizedBox(height: 14),
              Text('Could not load rates', style: AppText.heading(size: 16, color: AppColors.textDark)),
              const SizedBox(height: 6),
              Text(_loadError!, textAlign: TextAlign.center, style: AppText.body(size: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepGreen, foregroundColor: Colors.white),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                onPressed: _loadRates,
              ),
            ]),
          ),
        ),
      );

  Widget _buildWizard() {
    return FadeTransition(
      opacity: _fadeIn,
      child: Column(
        children: [
          // Fixed Top Header & Step Progress Bar
          _buildHeader(),
          _buildStepBar(),

          // PageView with 3 distinct screens
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1PersonalDetails(),
                _buildStep2LoanDetails(),
                _buildStep3SanctionReview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top Header
  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: const BoxDecoration(
          gradient: AppGradients.hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_currentStep > 0) {
                      _goToStep(_currentStep - 1);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apply for a Loan', style: AppText.display(size: 20, color: Colors.white, weight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text('Madurai Finance Official Portal', style: AppText.body(size: 11.5, color: AppColors.goldLight, weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  /// 3-Step Bar Indicator
  Widget _buildStepBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _StepItem(stepIndex: 0, title: 'Personal', currentStep: _currentStep, onTap: () { if (_currentStep > 0) _goToStep(0); }),
            _StepDivider(active: _currentStep >= 1),
            _StepItem(stepIndex: 1, title: 'Loan Details', currentStep: _currentStep, onTap: () { if (_currentStep > 1) _goToStep(1); }),
            _StepDivider(active: _currentStep >= 2),
            _StepItem(stepIndex: 2, title: 'Sanction Review', currentStep: _currentStep, onTap: () {}),
          ],
        ),
      );

  // ──────────────────────── SCREEN 1: PERSONAL DETAILS ────────────────────────
  Widget _buildStep1PersonalDetails() {
    return Form(
      key: _step1FormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const _SectionHeader(title: 'Step 1 of 3: Personal Details', icon: Icons.person_outline_rounded),
          const SizedBox(height: 6),
          Text(
            'Please fill in your exact personal information as per official KYC documents.',
            style: AppText.body(size: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          _field(_name, 'Full Name', Icons.badge_outlined, TextInputType.name),
          _field(_phone, 'Mobile Number (10 digits)', Icons.phone_android_rounded, TextInputType.phone, maxLength: 10),
          _field(_email, 'Email Address', Icons.email_outlined, TextInputType.emailAddress),

          // DOB Picker
          const _FieldLabel(label: 'Date of Birth'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDob,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, color: AppColors.green, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _dob == null ? 'Select date of birth' : DateFormat('dd MMM yyyy').format(_dob!),
                    style: _dob == null
                        ? AppText.body(size: 13.5, color: AppColors.textMuted.withValues(alpha: 0.55))
                        : AppText.mono(size: 14, color: AppColors.textDark),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_rounded, color: AppColors.green, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          _field(_pan, 'PAN Number (e.g. ABCDE1234F)', Icons.credit_card_outlined, TextInputType.text),
          _field(_city, 'City', Icons.location_city_outlined, TextInputType.text),
          _field(_address, 'Full Address', Icons.home_outlined, TextInputType.streetAddress, maxLines: 2),

          const SizedBox(height: 24),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _nextFromStep1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue to Loan Details', style: AppText.heading(size: 15.5, color: Colors.white, weight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── SCREEN 2: LOAN DETAILS ────────────────────────
  Widget _buildStep2LoanDetails() {
    return Form(
      key: _step2FormKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const _SectionHeader(title: 'Step 2 of 3: Loan Requirements', icon: Icons.account_balance_outlined),
          const SizedBox(height: 6),
          Text(
            'Select your desired loan amount, tenure, and repayment schedule.',
            style: AppText.body(size: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Hardcoded Madurai Finance Financier Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2C), Color(0xFF145C45)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: AppColors.deepGreen.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.goldLight, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financier Provider', style: AppText.body(size: 11.5, color: AppColors.goldLight, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Madurai Finance', style: AppText.heading(size: 17, color: Colors.white, weight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('VERIFIED', style: AppText.badge(size: 10, color: Colors.white, weight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Loan Amount
          _field(_amount, 'Loan Amount (₹ — min ₹6,000)', Icons.currency_rupee_rounded, TextInputType.number),

          // Tenure selector
          const _FieldLabel(label: 'Tenure (Months)'),
          const SizedBox(height: 8),
          if (_selectedFinancier != null && _selectedFinancier!.rates.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              decoration: _fieldDeco('Select tenure (months)', Icons.timelapse_rounded),
              initialValue: _tenure,
              items: (_selectedFinancier!.rates.keys.toList()..sort())
                  .map((t) => DropdownMenuItem(value: t, child: Text('$t months')))
                  .toList(),
              onChanged: (v) => setState(() => _tenure = v),
              validator: (v) => v == null ? 'Please select a tenure' : null,
            ),
          ] else ...[
            Text('Loading available tenures...', style: AppText.body(size: 13, color: AppColors.textMuted)),
          ],

          const SizedBox(height: 20),

          // Repayment Type (from Master)
          const _SectionHeader(title: 'Repayment Schedule Type', icon: Icons.repeat_rounded),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: _kLoanTypes.map((lt) {
              final selected = _loanType == lt.key;
              return GestureDetector(
                onTap: () => setState(() => _loanType = lt.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.deepGreen : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.deepGreen : AppColors.cardBorder,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: AppColors.deepGreen.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(lt.icon, color: selected ? AppColors.goldLight : AppColors.textMuted, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lt.label,
                                style: AppText.body(size: 13, color: selected ? Colors.white : AppColors.textDark, weight: FontWeight.w700)),
                            Text(lt.subtitle,
                                style: AppText.body(size: 10, color: selected ? Colors.white54 : AppColors.textMuted),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.goldLight, size: 16),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Bottom Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _goToStep(0),
                  child: Text('← Back', style: AppText.heading(size: 14.5, color: AppColors.textMuted, weight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _nextFromStep2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sanction Review', style: AppText.heading(size: 14.5, color: Colors.white, weight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────── SCREEN 3: SANCTION DETAILS & SUBMIT ────────────────────────
  Widget _buildStep3SanctionReview() {
    final details = _sanctionDetails;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SectionHeader(title: 'Step 3 of 3: Sanction Review', icon: Icons.verified_rounded),
        const SizedBox(height: 6),
        Text(
          'Review your full sanction details and submit your application for approval.',
          style: AppText.body(size: 12.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),

        // Sanction Summary Card
        if (details != null && _estimatedRate != null && _tenure != null)
          _SanctionSummaryCard(
            loanAmount: _amountValue ?? 0,
            loanType: _loanType,
            rate: _estimatedRate!,
            tenure: _tenure!,
            details: details,
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Text('Please complete loan details in Step 2.', style: AppText.body(size: 13, color: AppColors.textMuted)),
          ),

        const SizedBox(height: 18),

        // Applicant Information Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded, color: AppColors.green, size: 20),
                  const SizedBox(width: 8),
                  Text('Applicant Summary', style: AppText.heading(size: 14, color: AppColors.textDark, weight: FontWeight.w700)),
                ],
              ),
              const Divider(height: 20, color: AppColors.cardBorder),
              _ReviewRow(label: 'Applicant Name', value: _name.text.trim()),
              _ReviewRow(label: 'Mobile Number', value: _phone.text.trim()),
              _ReviewRow(label: 'Email', value: _email.text.trim()),
              _ReviewRow(label: 'City', value: _city.text.trim()),
              const _ReviewRow(label: 'Financier', value: 'Madurai Finance'),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submitting ? null : () => _goToStep(1),
                child: Text('← Edit Details', style: AppText.heading(size: 13.5, color: AppColors.textMuted, weight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6,
                  shadowColor: AppColors.deepGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Submit Application', style: AppText.heading(size: 14.5, color: Colors.white, weight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Center(
          child: Text(
            'Final rate & EMI will be confirmed by Madurai Finance upon review.',
            style: AppText.body(size: 11.5, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.55), fontSize: 13.5),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: AppColors.green, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.green, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      );

  Widget _field(TextEditingController c, String label, IconData icon, TextInputType type, {int? maxLength, int maxLines = 1}) {
    final labelText = label.split('(').first.trim().split(' — ').first.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: labelText),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: c,
            keyboardType: type,
            maxLength: maxLength,
            maxLines: maxLines,
            style: AppText.body(size: 14, color: AppColors.textDark),
            decoration: _fieldDeco(label, icon),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }
}

// ── Supporting Widgets ──

class _StepItem extends StatelessWidget {
  final int stepIndex;
  final String title;
  final int currentStep;
  final VoidCallback onTap;

  const _StepItem({
    required this.stepIndex,
    required this.title,
    required this.currentStep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.mint
                  : isActive
                      ? AppColors.deepGreen
                      : AppColors.bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone
                    ? AppColors.mint
                    : isActive
                        ? AppColors.deepGreen
                        : AppColors.cardBorder,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text(
                      '${stepIndex + 1}',
                      style: AppText.body(
                        size: 12,
                        color: isActive ? Colors.white : AppColors.textMuted,
                        weight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppText.body(
              size: 12,
              color: isActive
                  ? AppColors.deepGreen
                  : isDone
                      ? AppColors.textDark
                      : AppColors.textMuted,
              weight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  final bool active;
  const _StepDivider({required this.active});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: active ? AppColors.green : AppColors.cardBorder,
        ),
      );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.body(size: 12.5, color: AppColors.textMuted)),
            Text(value.isEmpty ? '—' : value, style: AppText.body(size: 13, color: AppColors.textDark, weight: FontWeight.w700)),
          ],
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(label, style: AppText.body(size: 12, color: AppColors.textMuted, weight: FontWeight.w700)),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.deepGreen, AppColors.primary]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppText.heading(size: 14, color: AppColors.textDark, weight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
        ],
      );
}

/// Sanction Summary Card — shows all computed loan details live
class _SanctionSummaryCard extends StatelessWidget {
  final num loanAmount;
  final String loanType;
  final num rate;
  final int tenure;
  final Map<String, num> details;

  const _SanctionSummaryCard({
    required this.loanAmount,
    required this.loanType,
    required this.rate,
    required this.tenure,
    required this.details,
  });

  String get _emiLabel {
    switch (loanType) {
      case 'DAILY': return 'Daily Instalment';
      case 'WEEKLY': return 'Weekly Instalment';
      case 'YEARLY': return 'Annual Instalment';
      default: return 'Monthly EMI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.deepGreen.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Subtle dot texture
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CustomPaint(painter: _MiniDotPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.goldLight, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sanction Summary', style: AppText.heading(size: 14, color: Colors.white, weight: FontWeight.w800)),
                          Text('Madurai Finance Terms', style: AppText.body(size: 10.5, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Text('$rate% p.a.', style: AppText.badge(size: 11, color: AppColors.goldLight, weight: FontWeight.w700)),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 16),

                // Principal highlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Loan Principal', style: AppText.body(size: 12.5, color: Colors.white60)),
                    Text(formatMoney(loanAmount), style: AppText.mono(size: 15, color: Colors.white, weight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),

                // EMI highlight row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, color: AppColors.goldLight, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_emiLabel, style: AppText.body(size: 13, color: AppColors.goldLight, weight: FontWeight.w600))),
                      Text(formatMoney(details['emi']!), style: AppText.mono(size: 17, color: AppColors.goldLight, weight: FontWeight.w800)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Detail rows
                _SummaryRow(label: 'Tenure', value: '$tenure months (${details['installments']!.toInt()} instalments)'),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Total Interest', value: formatMoney(details['total_interest']!)),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Total Payable', value: formatMoney(details['total_payable']!), highlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({required this.label, required this.value, this.highlight = false});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(size: 12.5, color: highlight ? Colors.white70 : Colors.white54)),
          Text(value,
              style: AppText.mono(size: 13, color: highlight ? Colors.white : Colors.white70, weight: highlight ? FontWeight.w800 : FontWeight.w600)),
        ],
      );
}

class _MiniDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    const spacing = 20.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
