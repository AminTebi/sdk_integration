import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

/// Soft light canvas — subtle depth without neon orbs or dark drama.
class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  final Widget child;

  /// Retained for API compatibility; animation intentionally unused.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.atmosphere),
          ),
          Positioned(
            top: -120,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.champagneSoft.withValues(alpha: 0.07),
                      AppColors.champagneSoft.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.champagne.withValues(alpha: 0.05),
                      AppColors.champagne.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
