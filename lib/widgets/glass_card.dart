import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 18,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppColors.surface,
        border: Border.all(
          color: highlight
              ? AppColors.champagne.withValues(alpha: 0.35)
              : AppColors.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1F27).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
