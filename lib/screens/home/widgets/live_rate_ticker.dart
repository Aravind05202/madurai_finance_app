import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/fonts.dart';

/// Live Auto-scrolling Financial Rate & Market Ticker Bar
class LiveRateTicker extends StatefulWidget {
  const LiveRateTicker({super.key});

  @override
  State<LiveRateTicker> createState() => _LiveRateTickerState();
}

class _LiveRateTickerState extends State<LiveRateTicker> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final List<_TickerItem> _items = const [
    _TickerItem(icon: '🟢', label: 'Personal Loan', value: 'from 10.5% p.a.'),
    _TickerItem(icon: '⚡', label: 'Fast Disbursal', value: '15 Mins'),
    _TickerItem(icon: '🏢', label: 'Business Credit', value: 'Up to ₹25 Lakhs'),
    _TickerItem(icon: '📲', label: 'UPI Repayments', value: 'Instant & 0% Fee'),
    _TickerItem(icon: '📄', label: 'RPS Statement', value: 'Instant Download'),
    _TickerItem(icon: '🔒', label: 'RBI Compliant', value: '256-Bit SSL'),
    _TickerItem(icon: '💎', label: 'Gold Loan Value', value: '90% LTV'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.gold,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, size: 14, color: AppColors.deepGreen),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: AppText.badge(size: 10, color: AppColors.deepGreen, weight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length * 20, // Infinite loop illusion
              itemBuilder: (context, index) {
                final item = _items[index % _items.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: AppText.body(size: 11.5, color: Colors.white70, weight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.value,
                        style: AppText.mono(size: 11.5, color: AppColors.goldLight, weight: FontWeight.w700),
                      ),
                      const SizedBox(width: 14),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerItem {
  final String icon;
  final String label;
  final String value;
  const _TickerItem({required this.icon, required this.label, required this.value});
}
