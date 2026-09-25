import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;
  final IconData? icon;
  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.deepGreen;
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed == null || loading
            ? []
            : [
                BoxShadow(
                  color: btnColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: btnColor == AppColors.gold ? AppColors.deepGreen : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: btnColor == AppColors.gold ? AppColors.deepGreen : Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: btnColor == AppColors.gold ? AppColors.deepGreen : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
