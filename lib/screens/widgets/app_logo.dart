import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';

/// Madurai Finance Official Brand Logo Widget
/// Renders either the high-resolution brand asset or a high-precision vector emblem.
class AppLogo extends StatefulWidget {
  final double size;
  final bool showGlow;
  final bool showBorder;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showGlow = true,
    this.showBorder = true,
    this.animated = false,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget logoCore = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: widget.showGlow
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: widget.size * 0.35,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.deepGreen.withValues(alpha: 0.5),
                  blurRadius: widget.size * 0.2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback Vector Logo
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _VectorLogoPainter(),
            );
          },
        ),
      ),
    );

    if (widget.animated && _controller != null) {
      return AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          final scale = 1.0 + (_controller!.value * 0.04);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: logoCore,
      );
    }

    return logoCore;
  }
}

/// Fallback Vector Logo Painter for high-res vector rendering
class _VectorLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background Circle
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF0E4D3A), Color(0xFF062319)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Gold Outer Rim
    final goldBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF3DB7A), Color(0xFFC9A227), Color(0xFF947214)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - (size.width * 0.028), goldBorderPaint);

    // Inner subtle ring
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015
      ..color = const Color(0x66E7C766);
    canvas.drawCircle(center, radius * 0.82, innerRingPaint);

    // Center Rupee / Gopuram Emblem
    final textPainter = TextPainter(
      text: TextSpan(
        text: '₹',
        style: TextStyle(
          color: const Color(0xFFF3DB7A),
          fontSize: size.width * 0.44,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2) - (size.height * 0.02),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full Brand Header with Logo, Title, and Subtitle
class AppBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoSize;
  final bool dark;

  const AppBrandHeader({
    super.key,
    this.title = 'Madurai Finance',
    this.subtitle = 'Loans made simple & secure',
    this.logoSize = 48,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppLogo(size: logoSize, showGlow: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppText.display(
                  size: 20,
                  color: dark ? Colors.white : AppColors.textDark,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppText.body(
                  size: 12.5,
                  color: dark ? AppColors.goldLight : AppColors.textMuted,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Live Real-time Status Badge (Pulsing Green dot)
class LiveServerBadge extends StatefulWidget {
  final String label;
  const LiveServerBadge({super.key, this.label = 'LIVE API ACTIVE'});

  @override
  State<LiveServerBadge> createState() => _LiveServerBadgeState();
}

class _LiveServerBadgeState extends State<LiveServerBadge> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: AppColors.deepGreen.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return Container(
                width: 7.5,
                height: 7.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.liveGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.liveGreen.withValues(alpha: 0.4 + (_anim.value * 0.5)),
                      blurRadius: 6 + (_anim.value * 4),
                      spreadRadius: 1 + (_anim.value * 1.5),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 7),
          Text(
            widget.label,
            style: AppText.badge(
              size: 10,
              color: AppColors.goldLight,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
