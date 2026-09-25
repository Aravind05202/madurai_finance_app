import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/fonts.dart';

/// Real-Time Live Activity & Verification Feed
class LiveActivityTicker extends StatefulWidget {
  const LiveActivityTicker({super.key});

  @override
  State<LiveActivityTicker> createState() => _LiveActivityTickerState();
}

class _LiveActivityTickerState extends State<LiveActivityTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      title: 'Loan Disbursed',
      detail: '₹50,000 credited to S. Kumar via IMPS',
      time: 'Just now',
      icon: Icons.check_circle_outline,
      color: AppColors.mint,
    ),
    _ActivityItem(
      title: 'UPI Repayment Received',
      detail: '₹3,450 received for Loan #MF-8921',
      time: '3 mins ago',
      icon: Icons.qr_code_2,
      color: AppColors.gold,
    ),
    _ActivityItem(
      title: 'Application Approved',
      detail: 'M. Pandian (Personal Loan ₹1,00,000)',
      time: '7 mins ago',
      icon: Icons.verified_user_outlined,
      color: AppColors.info,
    ),
    _ActivityItem(
      title: 'RPS Statement Generated',
      detail: 'Loan #MF-8890 24-Month Schedule exported',
      time: '12 mins ago',
      icon: Icons.receipt_long_outlined,
      color: AppColors.mint,
    ),
    _ActivityItem(
      title: 'Business Loan Disbursed',
      detail: '₹2,50,000 approved & disbursed in Madurai West',
      time: '18 mins ago',
      icon: Icons.business_center_outlined,
      color: AppColors.gold,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _activities.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = _activities[_currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Row(
          key: ValueKey<int>(_currentIndex),
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(activity.title, style: AppText.heading(size: 13, color: AppColors.textDark, weight: FontWeight.w700)),
                      Text(activity.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.detail,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ActivityItem {
  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.color,
  });
}
