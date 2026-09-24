import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/risk_level_bar.dart';

enum RiskBand { low, moderate, elevated, high }

RiskBand riskBandFromPosition(double position) {
  final p = position.clamp(0.0, 1.0);
  if (p < 0.25) {
    return RiskBand.low;
  }
  if (p < 0.5) {
    return RiskBand.moderate;
  }
  if (p < 0.75) {
    return RiskBand.elevated;
  }
  return RiskBand.high;
}

String riskBandLabel(RiskBand band) => switch (band) {
      RiskBand.low => AppStrings.riskLow,
      RiskBand.moderate => AppStrings.riskModerate,
      RiskBand.elevated => AppStrings.riskElevated,
      RiskBand.high => AppStrings.riskHigh,
    };

Color riskBandColor(RiskBand band) => switch (band) {
      RiskBand.low => RiskScaleColors.low,
      RiskBand.moderate => RiskScaleColors.moderate,
      RiskBand.elevated => RiskScaleColors.elevated,
      RiskBand.high => RiskScaleColors.high,
    };

/// Large value + status chip + plain-language scale hint.
class MetricReading extends StatelessWidget {
  const MetricReading({
    super.key,
    required this.value,
    required this.scaleHint,
    this.position,
    this.statusOverride,
    this.statusColorOverride,
    this.directionHint,
    this.fontSize = 40,
  });

  final String value;
  final String scaleHint;

  /// When set, drives the کم/متوسط/بالا chip from the risk bar position.
  final double? position;
  final String? statusOverride;
  final Color? statusColorOverride;

  /// e.g. «عدد پایین‌تر بهتر است»
  final String? directionHint;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final band = position == null ? null : riskBandFromPosition(position!);
    final status = statusOverride ?? (band == null ? null : riskBandLabel(band));
    final statusColor =
        statusColorOverride ?? (band == null ? null : riskBandColor(band));

    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            height: 1.1,
          ),
        ),
        if (status != null && statusColor != null) ...[
          const SizedBox(height: 12),
          _StatusChip(label: status, color: statusColor),
        ],
        const SizedBox(height: 10),
        Text(
          scaleHint,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.mist,
            height: 1.5,
          ),
        ),
        if (directionHint != null) ...[
          const SizedBox(height: 4),
          Text(
            directionHint!,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.champagne,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.yourStatus,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
