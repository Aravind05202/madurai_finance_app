import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import 'app_logo.dart';

/// Mirrors .login-aside from app/css/styles.css: dark green→black gradient,
/// a soft gold radial glow, a dotted "kolam" texture, and an arch motif —
/// adapted from a side panel (desktop) to a top panel (mobile).
class LoginHero extends StatelessWidget {
  final String title;
  final String tagline;
  final List<String> features;
  const LoginHero({super.key, required this.title, required this.tagline, this.features = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 36),
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _KolamDotsPainter()),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 38, showGlow: true, showBorder: true),
                  const SizedBox(width: 12),
                  Text('Madurai Finance', style: AppText.display(color: Colors.white, size: 17, weight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 24),
              Text(title, style: AppText.display(color: Colors.white, size: 26)),
              const SizedBox(height: 8),
              Text(tagline, style: AppText.body(color: Colors.white.withValues(alpha: 0.85), size: 13.5)),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(f, style: AppText.body(color: Colors.white.withValues(alpha: 0.9), size: 12.5))),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _KolamDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.goldTint.withValues(alpha: 0.22);
    const spacing = 22.0;
    for (double y = 0; y < size.height * 0.75; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

