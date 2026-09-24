import 'package:flutter/material.dart';
import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/l10n/enum_labels.dart';
import 'package:shenai_skd_integration/models/risk_profile.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/glass_card.dart';
import 'package:shenai_skd_integration/widgets/metric_reading.dart';
import 'package:shenai_skd_integration/widgets/risk_level_bar.dart';

/// Card-based health report matching the clinical indices layout.
class HealthReportSection extends StatelessWidget {
  const HealthReportSection({
    super.key,
    required this.risks,
    required this.profile,
  });

  final HealthRisks risks;
  final RiskProfile profile;

  String _pct(double? value, {int decimals = 1}) {
    if (value == null) {
      return '—';
    }
    final asPercent = value <= 1.0 ? value * 100 : value;
    return '${asPercent.toStringAsFixed(decimals)}%';
  }

  String _num(double? value, {int decimals = 2, String suffix = ''}) {
    if (value == null) {
      return '—';
    }
    return '${value.toStringAsFixed(decimals)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cv = risks.cvDiseases;
    final hard = risks.hardAndFatalEvents;
    final scores = risks.scores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.healthRiskIndices,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (risks.vascularAge != null)
          _ReportCard(
            title: AppStrings.vascularAge,
            description: AppStrings.vascularAgeDesc,
            child: _VascularAgeReading(
              vascularAge: risks.vascularAge!,
              chronologicalAge: profile.age,
            ),
          ),
        if (cv.overallRisk != null) ...[
          const SizedBox(height: 14),
          _ReportCard(
            title: AppStrings.cvdRiskTitle,
            description: AppStrings.cvdRiskDesc,
            child: Column(
              children: [
                MetricReading(
                  value: _pct(cv.overallRisk),
                  position: riskPercentPosition(cv.overallRisk),
                  scaleHint: AppStrings.scalePercentCvd,
                  directionHint: AppStrings.lowerIsBetter,
                  fontSize: 44,
                ),
                const SizedBox(height: 16),
                _BulletRows(
                  rows: [
                    if (cv.coronaryHeartDiseaseRisk != null)
                      (
                        AppStrings.coronaryHeartDisease,
                        _pct(cv.coronaryHeartDiseaseRisk),
                      ),
                    if (cv.strokeRisk != null)
                      (AppStrings.strokeRisk, _pct(cv.strokeRisk)),
                    if (cv.heartFailureRisk != null)
                      (AppStrings.heartFailureRisk, _pct(cv.heartFailureRisk)),
                    if (cv.peripheralVascularDiseaseRisk != null)
                      (
                        AppStrings.peripheralVascularDisease,
                        _pct(cv.peripheralVascularDiseaseRisk),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                RiskLevelBar(position: riskPercentPosition(cv.overallRisk)),
              ],
            ),
          ),
        ],
        if (hard.hardCVEventRisk != null ||
            hard.totalCVMortalityRisk != null ||
            hard.coronaryDeathEventRisk != null ||
            hard.fatalStrokeEventRisk != null) ...[
          const SizedBox(height: 14),
          _ReportCard(
            title: AppStrings.hardFatalTitle,
            description: AppStrings.hardFatalDesc,
            child: Column(
              children: [
                if (hard.hardCVEventRisk != null)
                  MetricReading(
                    value: _pct(hard.hardCVEventRisk),
                    position: riskPercentPosition(
                      hard.hardCVEventRisk,
                      highAtPercent: 15,
                    ),
                    scaleHint: AppStrings.scalePercentHard,
                    directionHint: AppStrings.lowerIsBetter,
                    fontSize: 44,
                  ),
                if (hard.coronaryDeathEventRisk != null ||
                    hard.fatalStrokeEventRisk != null) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (hard.coronaryDeathEventRisk != null)
                        _RiskChip(
                          label: AppStrings.chip10yCoronaryDeath,
                          value: _pct(hard.coronaryDeathEventRisk),
                        ),
                      if (hard.fatalStrokeEventRisk != null)
                        _RiskChip(
                          label: AppStrings.chip10yFatalStroke,
                          value: _pct(hard.fatalStrokeEventRisk),
                        ),
                    ],
                  ),
                ],
                if (hard.totalCVMortalityRisk != null) ...[
                  const SizedBox(height: 14),
                  _BulletRows(
                    rows: [
                      (
                        AppStrings.totalCvMortality,
                        _pct(hard.totalCVMortalityRisk),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                RiskLevelBar(
                  position: riskPercentPosition(
                    hard.hardCVEventRisk ?? hard.totalCVMortalityRisk,
                    highAtPercent: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (scores.totalScore != null) ...[
          const SizedBox(height: 14),
          _ReportCard(
            title: AppStrings.cvRiskScoreTitle,
            description: AppStrings.cvRiskScoreDesc,
            child: Column(
              children: [
                MetricReading(
                  value: '${scores.totalScore}',
                  position: _scorePosition(scores.totalScore!),
                  scaleHint: AppStrings.scaleScore,
                  directionHint: AppStrings.lowerIsBetter,
                  fontSize: 44,
                ),
                const SizedBox(height: 16),
                _BulletRows(
                  rows: [
                    if (scores.ageScore != null)
                      (AppStrings.scoreAge, '${scores.ageScore}'),
                    if (scores.sbpScore != null)
                      (AppStrings.scoreBp, '${scores.sbpScore}'),
                    if (scores.cholesterolScore != null)
                      (
                        AppStrings.scoreCholesterol,
                        '${scores.cholesterolScore}',
                      ),
                    if (scores.cholesterolHdlScore != null)
                      (AppStrings.scoreHdl, '${scores.cholesterolHdlScore}'),
                    if (scores.smokingScore != null)
                      (AppStrings.scoreSmoking, '${scores.smokingScore}'),
                    if (scores.diabetesScore != null)
                      (AppStrings.scoreDiabetes, '${scores.diabetesScore}'),
                    if (scores.bmiScore != null)
                      (AppStrings.scoreBmi, '${scores.bmiScore}'),
                  ],
                ),
                const SizedBox(height: 18),
                RiskLevelBar(position: _scorePosition(scores.totalScore!)),
              ],
            ),
          ),
        ],
        if (risks.hypertensionRisk != null) ...[
          const SizedBox(height: 14),
          _ValueRiskCard(
            title: AppStrings.hypertensionRisk,
            description: AppStrings.hypertensionRiskDesc,
            value: _pct(risks.hypertensionRisk),
            position: riskPercentPosition(risks.hypertensionRisk),
            scaleHint: AppStrings.scaleHypertension,
            directionHint: AppStrings.lowerIsBetter,
          ),
        ],
        if (risks.diabetesRisk != null) ...[
          const SizedBox(height: 14),
          _ValueRiskCard(
            title: AppStrings.diabetesRisk,
            description: AppStrings.diabetesRiskDesc,
            value: _pct(risks.diabetesRisk),
            position: riskPercentPosition(risks.diabetesRisk),
            scaleHint: AppStrings.scaleDiabetes,
            directionHint: AppStrings.lowerIsBetter,
          ),
        ],
        if (risks.wellnessScore != null) ...[
          const SizedBox(height: 14),
          _ValueRiskCard(
            title: AppStrings.wellnessScore,
            description: AppStrings.wellnessScoreDesc,
            value: _num(risks.wellnessScore, decimals: 1),
            scaleHint: AppStrings.scaleWellness,
            directionHint: AppStrings.higherIsBetter,
            statusOverride: _wellnessStatus(risks.wellnessScore!),
            statusColorOverride: _wellnessColor(risks.wellnessScore!),
            showRiskBar: false,
          ),
        ],
        const SizedBox(height: 28),
        Text(
          AppStrings.bodyCompositionSection,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (risks.waistToHeightRatio != null) ...[
          _ValueRiskCard(
            title: AppStrings.whtrTitle,
            description: AppStrings.whtrDesc,
            value: _num(risks.waistToHeightRatio, decimals: 2),
            position: ratioPosition(
              risks.waistToHeightRatio,
              low: 0.4,
              high: 0.7,
            ),
            scaleHint: AppStrings.scaleWhtr,
            directionHint: AppStrings.lowerIsBetter,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.bodyFatPercentage != null) ...[
          _ValueRiskCard(
            title: AppStrings.bfpTitle,
            description: AppStrings.bfpDesc,
            value: _num(risks.bodyFatPercentage, decimals: 1, suffix: '%'),
            position: ratioPosition(
              risks.bodyFatPercentage,
              low: 10,
              high: 40,
            ),
            scaleHint: AppStrings.scaleBfp,
            directionHint: AppStrings.lowerIsBetter,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.bodyRoundnessIndex != null) ...[
          _ValueRiskCard(
            title: AppStrings.briTitle,
            description: AppStrings.briDesc,
            value: _num(risks.bodyRoundnessIndex, decimals: 2),
            position: ratioPosition(
              risks.bodyRoundnessIndex,
              low: 1,
              high: 8,
            ),
            scaleHint: AppStrings.scaleBri,
            directionHint: AppStrings.lowerIsBetter,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.aBodyShapeIndex != null) ...[
          _ValueRiskCard(
            title: AppStrings.absiTitle,
            description: AppStrings.absiDesc,
            value: _num(risks.aBodyShapeIndex, decimals: 2),
            position: ratioPosition(
              risks.aBodyShapeIndex,
              low: 0.06,
              high: 0.1,
            ),
            scaleHint: AppStrings.scaleAbsi,
            directionHint: AppStrings.lowerIsBetter,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.conicityIndex != null) ...[
          _ValueRiskCard(
            title: AppStrings.conicityTitle,
            description: AppStrings.conicityDesc,
            value: _num(risks.conicityIndex, decimals: 2),
            position: ratioPosition(
              risks.conicityIndex,
              low: 1.0,
              high: 1.5,
            ),
            scaleHint: AppStrings.scaleConicity,
            directionHint: AppStrings.lowerIsBetter,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.basalMetabolicRate != null) ...[
          _ReportCard(
            title: AppStrings.bmrTitle,
            description: AppStrings.bmrDesc,
            child: Column(
              children: [
                MetricReading(
                  value:
                      '${risks.basalMetabolicRate!.toStringAsFixed(0)} ${AppStrings.unitKcal}',
                  scaleHint: AppStrings.scaleBmr,
                  fontSize: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.bmrFootnote,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (risks.totalDailyEnergyExpenditure != null) ...[
          _ValueRiskCard(
            title: AppStrings.tdeeTitle,
            description: AppStrings.tdeeDesc,
            value:
                '${risks.totalDailyEnergyExpenditure!.toStringAsFixed(0)} ${AppStrings.unitKcal}',
            scaleHint: AppStrings.scaleTdee,
            showRiskBar: false,
          ),
          const SizedBox(height: 14),
        ],
        if (risks.nonAlcoholicFattyLiverDiseaseRisk != null)
          _ValueRiskCard(
            title: AppStrings.nafldRisk,
            description: AppStrings.nafldRiskDesc,
            value: EnumLabels.nafldRisk(
              risks.nonAlcoholicFattyLiverDiseaseRisk,
            ),
            position: switch (risks.nonAlcoholicFattyLiverDiseaseRisk!) {
              NAFLDRisk.low => 0.2,
              NAFLDRisk.moderate => 0.55,
              NAFLDRisk.high => 0.9,
            },
            scaleHint: AppStrings.scaleNafld,
            directionHint: AppStrings.lowerIsBetter,
          ),
      ],
    );
  }

  double _scorePosition(int total) {
    return ((total + 5) / 25).clamp(0.0, 1.0);
  }

  String _wellnessStatus(double score) {
    if (score >= 75) {
      return AppStrings.riskLow;
    }
    if (score >= 50) {
      return AppStrings.riskModerate;
    }
    if (score >= 25) {
      return AppStrings.riskElevated;
    }
    return AppStrings.riskHigh;
  }

  Color _wellnessColor(double score) {
    if (score >= 75) {
      return RiskScaleColors.low;
    }
    if (score >= 50) {
      return RiskScaleColors.moderate;
    }
    if (score >= 25) {
      return RiskScaleColors.elevated;
    }
    return RiskScaleColors.high;
  }
}

class _VascularAgeReading extends StatelessWidget {
  const _VascularAgeReading({
    required this.vascularAge,
    required this.chronologicalAge,
  });

  final int vascularAge;
  final int chronologicalAge;

  @override
  Widget build(BuildContext context) {
    final diff = vascularAge - chronologicalAge;
    final status = diff <= -3
        ? AppStrings.yearsYounger(diff.abs())
        : diff >= 3
            ? AppStrings.yearsOlder(diff)
            : AppStrings.vascularAgeSame;
    final color = diff <= -3
        ? RiskScaleColors.low
        : diff >= 3
            ? RiskScaleColors.elevated
            : RiskScaleColors.moderate;

    return Column(
      children: [
        VascularAgeGauge(
          vascularAge: vascularAge,
          chronologicalAge: chronologicalAge,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${AppStrings.chronologicalAge}: $chronologicalAge ${AppStrings.years}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mist,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.lowerIsBetter,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.champagne,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.mist,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ValueRiskCard extends StatelessWidget {
  const _ValueRiskCard({
    required this.title,
    required this.description,
    required this.value,
    required this.scaleHint,
    this.position,
    this.directionHint,
    this.statusOverride,
    this.statusColorOverride,
    this.showRiskBar = true,
  });

  final String title;
  final String description;
  final String value;
  final String scaleHint;
  final double? position;
  final String? directionHint;
  final String? statusOverride;
  final Color? statusColorOverride;
  final bool showRiskBar;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      title: title,
      description: description,
      child: Column(
        children: [
          MetricReading(
            value: value,
            position: position,
            scaleHint: scaleHint,
            directionHint: directionHint,
            statusOverride: statusOverride,
            statusColorOverride: statusColorOverride,
          ),
          if (showRiskBar && position != null) ...[
            const SizedBox(height: 18),
            RiskLevelBar(position: position!),
          ],
        ],
      ),
    );
  }
}

class _BulletRows extends StatelessWidget {
  const _BulletRows({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagneSoft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    row.$1,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mist,
                    ),
                  ),
                ),
                Text(
                  row.$2,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            size: 14,
            color: AppColors.champagneSoft,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
