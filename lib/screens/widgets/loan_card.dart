import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/loan.dart';
import 'status_badge.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onTap;
  const LoanCard({super.key, required this.loan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final outstanding = loan.outstandingAmount ?? loan.loanAmount;
    final progress = loan.loanAmount > 0
        ? ((loan.loanAmount - outstanding) / loan.loanAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.06),
            blurRadius: 16,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.deepGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: AppColors.deepGreen, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.pkLoanId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepGreen,
                                fontSize: 14.5,
                              ),
                            ),
                            Text(
                              '${loan.interestRate}% p.a. · ${loan.tenureMonths} Mos',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    StatusBadge(loan.status),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Loan Amount', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          formatMoney(loan.loanAmount),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (loan.isDisbursed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Outstanding', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            formatMoney(outstanding),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (loan.isDisbursed) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.toDouble(),
                      minHeight: 6,
                      backgroundColor: AppColors.deepGreen.withValues(alpha: 0.08),
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Repaid',
                        style: const TextStyle(color: AppColors.green, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const Row(
                        children: [
                          Text('View Details', style: TextStyle(color: AppColors.deepGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.deepGreen),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
