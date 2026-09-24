import 'package:flutter/material.dart';
import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_sdk/shenai_sdk.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/demo/mock_health_data.dart';
import 'package:shenai_skd_integration/models/health_index_coverage.dart';
import 'package:shenai_skd_integration/models/risk_profile.dart';
import 'package:shenai_skd_integration/pages/risk_form_page.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/app_page_header.dart';
import 'package:shenai_skd_integration/widgets/atmosphere_background.dart';
import 'package:shenai_skd_integration/widgets/glass_card.dart';
import 'package:shenai_skd_integration/widgets/health_report_section.dart';
import 'package:shenai_skd_integration/widgets/luxury_button.dart';
import 'package:shenai_skd_integration/widgets/metric_tile.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
    required this.results,
    this.initialProfile,
    this.initialRisks,
    this.useMockRisks = false,
  });

  final MeasurementResults results;
  final RiskProfile? initialProfile;
  final HealthRisks? initialRisks;

  /// When true, health-index compute uses [MockHealthData] instead of the SDK.
  final bool useMockRisks;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late RiskProfile _profile = widget.initialProfile ??
      RiskProfile.defaults(results: widget.results);
  HealthRisks? _risks;
  List<HealthIndexDisplay> _healthRows = const [];
  bool _isComputing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final seeded = widget.initialRisks;
    if (seeded != null) {
      _risks = seeded;
      _healthRows = HealthIndexCoverage.build(
        profile: _profile,
        measurement: widget.results,
        risks: seeded,
      );
    }
  }

  Future<void> _openRiskFormAndCompute() async {
    final profile = await Navigator.of(context).push<RiskProfile>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RiskFormPage(profile: _profile),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
    if (profile == null || !mounted) {
      return;
    }

    setState(() {
      _profile = profile;
      _isComputing = true;
      _error = null;
    });

    try {
      final HealthRisks risks;
      if (widget.useMockRisks) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        risks = MockHealthData.healthRisks();
      } else {
        risks = await ShenaiSdk.computeHealthRisks(
          profile.toRisksFactors(results: widget.results),
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _risks = risks;
        _healthRows = HealthIndexCoverage.build(
          profile: profile,
          measurement: widget.results,
          risks: risks,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = AppStrings.errorComputeRisks(error));
    } finally {
      if (mounted) {
        setState(() => _isComputing = false);
      }
    }
  }

  String _format(double? value, String unit, {int decimals = 0}) {
    if (value == null) {
      return '—';
    }
    final number = value.toStringAsFixed(decimals);
    return unit.isEmpty ? number : '$number $unit';
  }

  String _heroValue(double? value, {int decimals = 0}) {
    if (value == null) {
      return '—';
    }
    return value.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.results;
    final textTheme = Theme.of(context).textTheme;
    final risks = _risks;
    final skippedRows =
        _healthRows.where((row) => !row.isComputed).toList(growable: false);

    final measurementRows = <(String, String)>[
      (
        AppStrings.heartRate,
        _format(results.heart_rate_bpm, AppStrings.unitBpm),
      ),
      (
        AppStrings.breathingRate,
        _format(
          results.breathing_rate_bpm,
          AppStrings.unitBrpm,
          decimals: 1,
        ),
      ),
      (
        AppStrings.systolicBp,
        _format(
          results.systolic_blood_pressure_mmhg,
          AppStrings.unitMmHg,
        ),
      ),
      (
        AppStrings.diastolicBp,
        _format(
          results.diastolic_blood_pressure_mmhg,
          AppStrings.unitMmHg,
        ),
      ),
      (
        AppStrings.hrvSdnn,
        _format(results.hrv_sdnn_ms, AppStrings.unitMs, decimals: 1),
      ),
      (
        AppStrings.stressIndex,
        _format(results.stress_index, '', decimals: 2),
      ),
      (
        AppStrings.signalQuality,
        _format(results.average_signal_quality * 100, '%', decimals: 0),
      ),
    ];

    return Scaffold(
      body: AtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(title: AppStrings.results),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Text(
                      AppStrings.yourVitals,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.capturedFromScan,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            label: AppStrings.heartRate,
                            value: _heroValue(results.heart_rate_bpm),
                            unit: AppStrings.unitBpm,
                            accent: AppColors.coral,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroMetric(
                            label: AppStrings.stress,
                            value: _heroValue(
                              results.stress_index,
                              decimals: 2,
                            ),
                            unit: AppStrings.unitIndex,
                            accent: AppColors.champagne,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: AppStrings.systolic,
                            value: _heroValue(
                              results.systolic_blood_pressure_mmhg,
                            ),
                            unit: AppStrings.unitMmHg,
                            accent: AppColors.champagne,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: AppStrings.diastolic,
                            value: _heroValue(
                              results.diastolic_blood_pressure_mmhg,
                            ),
                            unit: AppStrings.unitMmHg,
                            accent: AppColors.champagneSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MetricTile(
                      label: AppStrings.breathingRate,
                      value: _heroValue(
                        results.breathing_rate_bpm,
                        decimals: 1,
                      ),
                      unit: AppStrings.unitBrpm,
                      accent: AppColors.sage,
                      icon: Icons.air_rounded,
                    ),
                    const SizedBox(height: 28),
                    const SectionEyebrow(AppStrings.fullMeasurement),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < measurementRows.length; i++)
                            ResultRow(
                              label: measurementRows[i].$1,
                              value: measurementRows[i].$2,
                              isLast: i == measurementRows.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionEyebrow(AppStrings.healthIndices),
                    const SizedBox(height: 12),
                    GlassCard(
                      highlight: risks != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            risks == null
                                ? AppStrings.unlockHealthIndices
                                : AppStrings.computedHealthIndices,
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          LuxuryButton(
                            label: risks == null
                                ? AppStrings.calculateIndices
                                : AppStrings.recalculate,
                            icon: Icons.favorite_border_rounded,
                            onPressed: _isComputing
                                ? null
                                : _openRiskFormAndCompute,
                            isLoading: _isComputing,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _error!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.coral,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (risks != null) ...[
                      const SizedBox(height: 28),
                      HealthReportSection(
                        risks: risks,
                        profile: _profile,
                      ),
                    ],
                    if (skippedRows.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionEyebrow(AppStrings.skippedIndices),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < skippedRows.length; i++)
                              ResultRow(
                                label: skippedRows[i].label,
                                value: skippedRows[i].displayValue,
                                subtitle: skippedRows[i].missingReason,
                                isLast: i == skippedRows.length - 1,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      highlight: true,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: accent,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              fontSize: 36,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
