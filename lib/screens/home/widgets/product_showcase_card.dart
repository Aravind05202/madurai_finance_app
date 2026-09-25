import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/fonts.dart';
import '../../apply/apply_loan_screen.dart';

/// Product Showcase Item Model & Card Widget
class ProductCardData {
  final String title;
  final String tag;
  final String rate;
  final String maxAmount;
  final String tenure;
  final String speed;
  final IconData icon;
  final List<String> perks;

  const ProductCardData({
    required this.title,
    required this.tag,
    required this.rate,
    required this.maxAmount,
    required this.tenure,
    required this.speed,
    required this.icon,
    required this.perks,
  });
}

class ProductShowcaseCard extends StatelessWidget {
  final ProductCardData product;
  const ProductShowcaseCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.deepGreen,
                  AppColors.heroMid,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(product.icon, color: AppColors.deepGreen, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        product.tag,
                        style: AppText.badge(size: 9.5, color: AppColors.goldLight, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  product.title,
                  style: AppText.heading(size: 16, color: Colors.white, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('From ', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    Text(product.rate, style: AppText.mono(size: 14, color: AppColors.goldLight, weight: FontWeight.w800)),
                    const Spacer(),
                    Text('⏱ ${product.speed}', style: const TextStyle(color: AppColors.mint, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeatureMetric(label: 'Max Loan', value: product.maxAmount),
                    _FeatureMetric(label: 'Max Tenure', value: product.tenure),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 10),
                ...product.perks.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.green, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(p, style: const TextStyle(fontSize: 11.5, color: AppColors.textDark)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepGreen,
                      side: const BorderSide(color: AppColors.green, width: 1.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ApplyLoanScreen()),
                      );
                    },
                    child: Text('Apply Now', style: AppText.heading(size: 13, color: AppColors.deepGreen, weight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureMetric extends StatelessWidget {
  final String label;
  final String value;
  const _FeatureMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppText.mono(size: 13, color: AppColors.deepGreen, weight: FontWeight.w700)),
      ],
    );
  }
}
