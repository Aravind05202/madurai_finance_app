import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/fonts.dart';
import '../../../core/utils.dart';
import '../../apply/apply_loan_screen.dart';

/// Real-Time Interactive Loan & EMI Calculator Card
class LoanCalculatorCard extends StatefulWidget {
  const LoanCalculatorCard({super.key});

  @override
  State<LoanCalculatorCard> createState() => _LoanCalculatorCardState();
}

class _LoanCalculatorCardState extends State<LoanCalculatorCard> {
  double _amount = 100000;
  int _tenure = 12; // Months
  final double _interestRate = 12.5; // Annual %

  final List<double> _quickAmounts = [25000, 50000, 100000, 250000, 500000];
  final List<int> _tenureOptions = [3, 6, 12, 24, 36, 48];

  // Calculation Formula (EMI rounded to nearest whole rupee)
  double get _monthlyRate => (_interestRate / 12) / 100;

  double get _emi {
    if (_monthlyRate == 0) return (_amount / _tenure).roundToDouble();
    final factor = math.pow(1 + _monthlyRate, _tenure);
    final rawEmi = (_amount * _monthlyRate * factor) / (factor - 1);
    return rawEmi.roundToDouble();
  }

  double get _totalPayable => (_emi * _tenure).roundToDouble();
  double get _totalInterest => (_totalPayable - _amount).roundToDouble();

  @override
  Widget build(BuildContext context) {
    final principalRatio = (_amount / _totalPayable).clamp(0.0, 1.0);
    final interestRatio = (_totalInterest / _totalPayable).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badge
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
                      child: const Icon(Icons.calculate_outlined, color: AppColors.goldDark, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMI Calculator', style: AppText.heading(size: 18, color: AppColors.textDark)),
                        Text('Real-time Repayment Estimator', style: AppText.body(size: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.mint, size: 14),
                      Text('INSTANT', style: AppText.badge(size: 10, color: AppColors.mint, weight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Loan Amount Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loan Amount', style: AppText.body(size: 13, color: AppColors.textMuted, weight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    formatCurrency(_amount),
                    style: AppText.mono(size: 17, color: AppColors.deepGreen, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.green,
                inactiveTrackColor: AppColors.cardBorder,
                thumbColor: AppColors.gold,
                overlayColor: AppColors.gold.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: _amount,
                min: 10000,
                max: 1000000,
                divisions: 99,
                onChanged: (val) => setState(() => _amount = (val / 5000).round() * 5000),
              ),
            ),

            // Quick Amount Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickAmounts.map((amt) {
                  final isSelected = _amount == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(formatCurrency(amt)),
                      selected: isSelected,
                      selectedColor: AppColors.deepGreen,
                      backgroundColor: AppColors.bg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.gold : AppColors.cardBorder,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _amount = amt);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Tenure Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tenure (Months)', style: AppText.body(size: 13, color: AppColors.textMuted, weight: FontWeight.w600)),
                Text('$_tenure Months', style: AppText.mono(size: 15, color: AppColors.deepGreen, weight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: _tenureOptions.map((t) {
                final isSelected = _tenure == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _tenure = t),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.deepGreen : AppColors.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : AppColors.cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${t}M',
                          style: TextStyle(
                            color: isSelected ? AppColors.goldLight : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // Dynamic Result Output Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x330B192C), blurRadius: 12, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Monthly EMI', style: AppText.body(size: 12, color: Colors.white70)),
                          const SizedBox(height: 2),
                          Text(
                            formatCurrency(_emi),
                            style: AppText.mono(size: 24, color: AppColors.goldLight, weight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('Interest Rate', style: AppText.body(size: 10, color: Colors.white60)),
                            Text('$_interestRate% p.a.', style: AppText.mono(size: 12.5, color: Colors.white, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 14),

                  // Split Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetricItem(label: 'Principal Amount', value: formatCurrency(_amount), color: Colors.white),
                      _MetricItem(label: 'Total Interest', value: formatCurrency(_totalInterest), color: AppColors.goldLight),
                      _MetricItem(label: 'Total Payable', value: formatCurrency(_totalPayable), color: AppColors.mint),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Visual Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (principalRatio * 100).round(),
                            child: Container(color: AppColors.gold),
                          ),
                          Expanded(
                            flex: (interestRatio * 100).round(),
                            child: Container(color: AppColors.emeraldLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('● Principal (${(principalRatio * 100).round()}%)', style: const TextStyle(color: AppColors.goldLight, fontSize: 10.5)),
                      Text('● Interest (${(interestRatio * 100).round()}%)', style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deepGreen,
                  elevation: 4,
                  shadowColor: AppColors.gold.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplyLoanScreen(
                        initialAmount: _amount.toInt(),
                        initialTenure: _tenure,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward, color: AppColors.deepGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Apply with this Plan (${formatCurrency(_amount)})',
                      style: AppText.heading(size: 15, color: AppColors.deepGreen, weight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppText.mono(size: 12.5, color: color, weight: FontWeight.w700)),
      ],
    );
  }
}
