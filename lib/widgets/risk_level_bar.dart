import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

/// Medical risk scale colors (green → red), matching clinical report UX.
abstract final class RiskScaleColors {
  static const low = Color(0xFF22C55E);
  static const moderate = Color(0xFFEAB308);
  static const elevated = Color(0xFFF97316);
  static const high = Color(0xFFEF4444);
}

class RiskLevelBar extends StatelessWidget {
  const RiskLevelBar({
    super.key,
    required this.position,
    this.label = AppStrings.riskLevel,
  });

  /// 0.0 = lowest risk (start in RTL = right), 1.0 = highest.
  final double position;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clamped = position.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const height = 10.0;
            final width = constraints.maxWidth;
            // In RTL, low risk sits on the right; marker moves left as risk rises.
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            final markerX = isRtl
                ? width * (1 - clamped)
                : width * clamped;

            return SizedBox(
              height: height + 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height),
                        gradient: LinearGradient(
                          begin: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          end: isRtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          colors: const [
                            RiskScaleColors.low,
                            RiskScaleColors.moderate,
                            RiskScaleColors.elevated,
                            RiskScaleColors.high,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: (markerX - 9).clamp(0.0, width - 18),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.ink.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              AppStrings.riskLow,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RiskScaleColors.low,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Text(
              AppStrings.riskHigh,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RiskScaleColors.high,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class VascularAgeGauge extends StatelessWidget {
  const VascularAgeGauge({
    super.key,
    required this.vascularAge,
    required this.chronologicalAge,
  });

  final int vascularAge;
  final int chronologicalAge;

  @override
  Widget build(BuildContext context) {
    final maxAge = math.max(chronologicalAge, vascularAge).clamp(40, 100);
    final progress = (vascularAge / maxAge).clamp(0.15, 1.0);
    final younger = vascularAge <= chronologicalAge;

    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _GaugePainter(
          progress: progress,
          color: younger ? RiskScaleColors.low : AppColors.champagneSoft,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$vascularAge',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.years,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 6;
    const stroke = 8.0;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.hairline
      ..strokeCap = StrokeCap.round;

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Maps a risk fraction/percent into a 0–1 bar position.
double riskPercentPosition(double? value, {double highAtPercent = 20}) {
  if (value == null) {
    return 0;
  }
  final asPercent = value <= 1.0 ? value * 100 : value;
  return (asPercent / highAtPercent).clamp(0.0, 1.0);
}

double ratioPosition(double? value, {required double low, required double high}) {
  if (value == null) {
    return 0;
  }
  if (high <= low) {
    return 0;
  }
  return ((value - low) / (high - low)).clamp(0.0, 1.0);
}
