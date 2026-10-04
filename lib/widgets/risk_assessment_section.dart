import 'package:flutter/material.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/risk_assessor/coach.dart';
import 'package:shenai_skd_integration/risk_assessor/risk_engine.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/glass_card.dart';
import 'package:shenai_skd_integration/widgets/metric_tile.dart';
import 'package:shenai_skd_integration/widgets/risk_level_bar.dart';

/// Presents the integrated ShenRisk/risk_assesor calculation inside the
/// existing Flutter results flow.
class RiskAssessmentSection extends StatelessWidget {
  const RiskAssessmentSection({
    super.key,
    required this.input,
    required this.result,
    required this.plan,
  });

  final HealthDataInput input;
  final EngineResult result;
  final CoachingPlanData plan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final composite = result.compositeInsuranceRisk;
    final underwriting = composite.underwritingClass;
    final loading = composite.premiumLoadingPercent;
    final basePremium = 10000000.0;
    final currentPremium =
        basePremium * (1 + RiskCoach.loadingByClass[plan.currentClass]! / 100);
    final targetPremium =
        basePremium * (1 + RiskCoach.loadingByClass[plan.finalClass]! / 100);
    final savings = (currentPremium - targetPremium).clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.insuranceRiskAssessment,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.insuranceRiskAssessmentDesc,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.mist,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.compositeInsuranceScore,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.mist,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _faNum(composite.overallScore),
                          style: textTheme.displayMedium?.copyWith(
                            color: _scoreColor(composite.overallScore),
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'از ۱۰۰',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Badge(
                    label: _classFa(underwriting),
                    color: _classColor(underwriting),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              RiskLevelBar(
                position: composite.overallScore / 100,
                label: 'مقیاس ریسک بیمه‌ای',
              ),
              const SizedBox(height: 18),
              _KeyValuePanel(
                rows: [
                  (
                    AppStrings.underwritingDecision,
                    '${_classFa(underwriting)} · ${underwriting.code}',
                  ),
                  (
                    AppStrings.premiumLoading,
                    _loadingLabel(loading),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _RiskTiles(input: input, result: result),
        if (composite.criticalWarnings.isNotEmpty) ...[
          const SizedBox(height: 14),
          _WarningsCard(warnings: composite.criticalWarnings),
        ],
        const SizedBox(height: 22),
        _CoachingCard(
          plan: plan,
          currentPremium: currentPremium,
          targetPremium: targetPremium,
          savings: savings.toDouble(),
        ),
      ],
    );
  }
}

class _RiskTiles extends StatelessWidget {
  const _RiskTiles({required this.input, required this.result});

  final HealthDataInput input;
  final EngineResult result;

  @override
  Widget build(BuildContext context) {
    final bmi = input.weightKg / ((input.heightCm / 100) * (input.heightCm / 100));
    final q = _qualityPct(input.averageSignalQuality);
    final ageDelta = result.biologicalAge - result.chronologicalAge;
    final bioAgeSubtitle = ageDelta > 0
        ? '+${_fmt(ageDelta, 1)} سال نسبت به سن تقویمی'
        : ageDelta < 0
            ? '${_fmt(ageDelta, 1)} سال نسبت به سن تقویمی'
            : 'تقریباً برابر با سن تقویمی';

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;
        final width = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _RiskTile(
              width: width,
              title: AppStrings.cardiovascularRisk10y,
              value: '${_fmt(result.cardiovascularRisk.percentage, 1)}٪',
              subtitle:
                  'سطح ${_levelFa(result.cardiovascularRisk.level)} · امتیاز پایه ${_fmt(result.cardiovascularRisk.score, 0)}',
              color: _levelColor(result.cardiovascularRisk.level),
              icon: Icons.favorite_rounded,
            ),
            _RiskTile(
              width: width,
              title: AppStrings.diabetesMetabolicRisk,
              value:
                  '${_faNum(result.diabetesMetabolicRisk.findrisc)} / ۳۶',
              subtitle:
                  '${AppStrings.findriscScore} · ${AppStrings.tyGIndex}: ${result.diabetesMetabolicRisk.tygIndex == null ? '—' : _fmt(result.diabetesMetabolicRisk.tygIndex!, 2)}',
              color: _levelColor(result.diabetesMetabolicRisk.level),
              icon: Icons.water_drop_rounded,
            ),
            _RiskTile(
              width: width,
              title: AppStrings.centralAdiposityOsa,
              value: 'WHtR ${_fmt(result.adiposityAndOsaRisk.whtr, 2)}',
              subtitle:
                  'BMI ${_fmt(bmi, 1)} · WHR ${result.adiposityAndOsaRisk.whr == null ? '—' : _fmt(result.adiposityAndOsaRisk.whr!, 2)} · OSA ${_osaFa(result.adiposityAndOsaRisk.osaRisk)}',
              color: result.adiposityAndOsaRisk.osaRisk == 'High'
                  ? RiskScaleColors.high
                  : _whtrColor(result.adiposityAndOsaRisk.whtr),
              icon: Icons.straighten_rounded,
            ),
            _RiskTile(
              width: width,
              title: AppStrings.autonomicLoad,
              value:
                  '${_faNum(result.autonomicStressIndex.score)} / ۳۰',
              subtitle:
                  'سطح ${_levelFa(result.autonomicStressIndex.level)} · کیفیت اسکن ${q == null ? '—' : '${_fmt(q, 0)}٪'}',
              color: _levelColor(result.autonomicStressIndex.level),
              icon: Icons.monitor_heart_rounded,
            ),
            _RiskTile(
              width: width,
              title: AppStrings.biologicalAgeEstimated,
              value: '${_fmt(result.biologicalAge, 1)} ${AppStrings.years}',
              subtitle: bioAgeSubtitle,
              color: ageDelta > 0
                  ? RiskScaleColors.elevated
                  : ageDelta < 0
                      ? RiskScaleColors.low
                      : RiskScaleColors.moderate,
              icon: Icons.calendar_month_rounded,
            ),
          ],
        );
      },
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.mist,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningsCard extends StatelessWidget {
  const _WarningsCard({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: RiskScaleColors.high,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.criticalWarnings,
                style: textTheme.titleMedium?.copyWith(
                  color: RiskScaleColors.high,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final warning in warnings) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: RiskScaleColors.high,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.mist,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _CoachingCard extends StatelessWidget {
  const _CoachingCard({
    required this.plan,
    required this.currentPremium,
    required this.targetPremium,
    required this.savings,
  });

  final CoachingPlanData plan;
  final double currentPremium;
  final double targetPremium;
  final double savings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentClass = _classFa(plan.currentClass);
    final finalClass = _classFa(plan.finalClass);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.riskReductionPlan,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (plan.maintain) ...[
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: RiskScaleColors.low),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.maintainRiskTitle,
                        style: textTheme.titleMedium?.copyWith(
                          color: RiskScaleColors.low,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final tip in plan.maintainTips)
                  _Bullet(text: tip, color: RiskScaleColors.low),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _ScoreSummary(
                        label: AppStrings.currentScore,
                        score: plan.currentScore,
                        subtitle: currentClass,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.champagne,
                      ),
                    ),
                    Expanded(
                      child: _ScoreSummary(
                        label: AppStrings.targetScore,
                        score: plan.finalScore,
                        subtitle: finalClass,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _KeyValuePanel(
                  rows: [
                    (
                      AppStrings.basePremiumAnnual,
                      '${_money(10000000)} ${AppStrings.rial}',
                    ),
                    (
                      AppStrings.currentPremium,
                      '${_money(currentPremium)} ${AppStrings.rial}',
                    ),
                    (
                      AppStrings.targetPremium,
                      '${_money(targetPremium)} ${AppStrings.rial}',
                    ),
                    (
                      AppStrings.annualSavings,
                      '${_money(savings)} ${AppStrings.rial}',
                    ),
                  ],
                ),
                if (plan.effective.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _PlanStepList(
                    title: AppStrings.effectiveActions,
                    steps: plan.effective,
                    color: RiskScaleColors.low,
                  ),
                ],
                if (plan.deferred.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _PlanStepList(
                    title: AppStrings.deferredActions,
                    steps: plan.deferred,
                    color: AppColors.champagneSoft,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Text(
                AppStrings.immutableFactors,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.mist,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final factor in plan.immutable)
                    _Badge(label: factor, color: AppColors.champagne),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({
    required this.label,
    required this.score,
    required this.subtitle,
  });

  final String label;
  final int score;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.mist,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _faNum(score),
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _PlanStepList extends StatelessWidget {
  const _PlanStepList({
    required this.title,
    required this.steps,
    required this.color,
  });

  final String title;
  final List<PlanStep> steps;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.mist,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final step in steps) _PlanStepTile(step: step, color: color),
      ],
    );
  }
}

class _PlanStepTile extends StatelessWidget {
  const _PlanStepTile({required this.step, required this.color});

  final PlanStep step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final suggestion = step.suggestion;
    final deltaLabel = step.delta > 0
        ? '${AppStrings.scoreDelta}: −${_faNum(step.delta)}'
        : 'اثر در ارزیابی بعدی';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_categoryIcon(suggestion.category), color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.body,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.mist,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: deltaLabel, color: color),
              _Badge(label: _effortFa(suggestion.effort), color: AppColors.champagne),
              _Badge(label: _phaseFa(suggestion.phase), color: AppColors.champagneSoft),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${suggestion.duration} · هدف: ${suggestion.markers}',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValuePanel extends StatelessWidget {
  const _KeyValuePanel({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            ResultRow(
              label: rows[i].$1,
              value: rows[i].$2,
              isLast: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mist,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

String _fmt(num? value, int decimals) {
  if (value == null) {
    return '—';
  }
  return _faNum(value.toStringAsFixed(decimals));
}

String _faNum(Object value) {
  const digits = '۰۱۲۳۴۵۶۷۸۹';
  return value
      .toString()
      .replaceAllMapped(RegExp('[0-9]'), (m) => digits[int.parse(m[0]!)])
      .replaceAll('-', '−');
}

String _money(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) {
      buffer.write('٬');
    }
    buffer.write(rounded[i]);
  }
  return _faNum(buffer.toString());
}

double? _qualityPct(double? raw) {
  if (raw == null) {
    return null;
  }
  return raw > 1 ? raw : raw * 100;
}

String _loadingLabel(int loading) {
  if (loading < 0) {
    return 'تخفیف ${_faNum(loading.abs())}٪';
  }
  if (loading == 0) {
    return 'بدون تعدیل نرخ';
  }
  return 'افزودگی ${_faNum(loading)}٪';
}

String _levelFa(String level) => switch (level) {
      'Low' => AppStrings.riskLow,
      'Normal' => 'طبیعی',
      'Moderate' => AppStrings.riskModerate,
      'High' => AppStrings.riskHigh,
      _ => level,
    };

Color _levelColor(String level) => switch (level) {
      'Low' || 'Normal' => RiskScaleColors.low,
      'Moderate' => RiskScaleColors.moderate,
      'High' => RiskScaleColors.high,
      _ => AppColors.champagne,
    };

String _osaFa(String osa) => switch (osa) {
      'Low' => AppStrings.riskLow,
      'High' => AppStrings.riskHigh,
      _ => osa,
    };

Color _whtrColor(double whtr) {
  if (whtr > 0.6) {
    return RiskScaleColors.high;
  }
  if (whtr > 0.5) {
    return RiskScaleColors.moderate;
  }
  return RiskScaleColors.low;
}

String _classFa(UnderwritingClass value) => switch (value) {
      UnderwritingClass.preferred => 'کلاس ترجیحی',
      UnderwritingClass.standard => 'کلاس استاندارد',
      UnderwritingClass.substandard1 => 'زیراستاندارد ۱',
      UnderwritingClass.substandard2 => 'زیراستاندارد ۲',
      UnderwritingClass.declineReview => 'رد / بررسی ویژه',
    };

Color _classColor(UnderwritingClass value) => switch (value) {
      UnderwritingClass.preferred => RiskScaleColors.low,
      UnderwritingClass.standard => AppColors.champagne,
      UnderwritingClass.substandard1 => RiskScaleColors.moderate,
      UnderwritingClass.substandard2 => RiskScaleColors.elevated,
      UnderwritingClass.declineReview => RiskScaleColors.high,
    };

Color _scoreColor(int score) {
  if (score < 25) {
    return RiskScaleColors.low;
  }
  if (score <= 48) {
    return AppColors.champagneSoft;
  }
  if (score <= 68) {
    return RiskScaleColors.moderate;
  }
  if (score <= 85) {
    return RiskScaleColors.elevated;
  }
  return RiskScaleColors.high;
}

String _effortFa(CoachingEffort value) => switch (value) {
      CoachingEffort.low => 'تلاش کم',
      CoachingEffort.medium => 'تلاش متوسط',
      CoachingEffort.high => 'تلاش بالا',
    };

String _phaseFa(int phase) => switch (phase) {
      0 => 'اقدام فوری',
      1 => 'هفته‌های اول',
      2 => '۱۲ هفته',
      _ => 'بلندمدت',
    };

IconData _categoryIcon(CoachingCategory value) => switch (value) {
      CoachingCategory.medical => Icons.medical_services_rounded,
      CoachingCategory.nutrition => Icons.restaurant_rounded,
      CoachingCategory.activity => Icons.directions_walk_rounded,
      CoachingCategory.sleep => Icons.bedtime_rounded,
      CoachingCategory.stress => Icons.air_rounded,
      CoachingCategory.labs => Icons.science_rounded,
      CoachingCategory.monitoring => Icons.monitor_heart_rounded,
    };
