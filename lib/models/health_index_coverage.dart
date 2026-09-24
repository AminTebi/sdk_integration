import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/l10n/enum_labels.dart';
import 'package:shenai_skd_integration/models/risk_profile.dart';

/// One health-index row with either a computed value or a missing-data reason.
class HealthIndexDisplay {
  const HealthIndexDisplay({
    required this.label,
    this.value,
    this.missingInputs = const [],
  });

  final String label;
  final String? value;
  final List<String> missingInputs;

  bool get isComputed => value != null && missingInputs.isEmpty;

  String get displayValue {
    if (isComputed) {
      return value!;
    }
    return AppStrings.notCalculated;
  }

  String? get missingReason {
    if (missingInputs.isEmpty) {
      return null;
    }
    return AppStrings.notCalculatedBecause(missingInputs.join('، '));
  }
}

/// Maps Shen Health Indices docs to which optional inputs unlock which metrics.
abstract final class HealthIndexCoverage {
  static List<HealthIndexDisplay> build({
    required RiskProfile profile,
    required MeasurementResults measurement,
    required HealthRisks risks,
  }) {
    final hasScanBp = measurement.systolic_blood_pressure_mmhg != null &&
        measurement.diastolic_blood_pressure_mmhg != null;

    return [
      HealthIndexDisplay(
        label: AppStrings.vascularAge,
        value: risks.vascularAge == null
            ? null
            : '${risks.vascularAge} ${AppStrings.unitYears}',
        missingInputs: _missingForFraminghamLike(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.wellnessScore,
        value: _formatNumber(risks.wellnessScore, decimals: 1),
        missingInputs: _missingForWellness(profile, measurement),
      ),
      HealthIndexDisplay(
        label: AppStrings.cvdOverallRisk,
        value: _formatPercent(risks.cvDiseases.overallRisk),
        missingInputs: _missingForFraminghamLike(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.coronaryHeartDisease,
        value: _formatPercent(risks.cvDiseases.coronaryHeartDiseaseRisk),
        missingInputs: _missingForFraminghamLike(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.strokeRisk,
        value: _formatPercent(risks.cvDiseases.strokeRisk),
        missingInputs: _missingForFraminghamLike(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.heartFailureRisk,
        value: _formatPercent(risks.cvDiseases.heartFailureRisk),
        missingInputs: _missingForFraminghamLike(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.hardCvEventRisk,
        value: _formatPercent(risks.hardAndFatalEvents.hardCVEventRisk),
        missingInputs: _missingForHardCvEvents(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.totalCvMortality,
        value: _formatPercent(risks.hardAndFatalEvents.totalCVMortalityRisk),
        missingInputs: _missingForFatalCvEvents(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.hypertensionRisk,
        value: _formatPercent(risks.hypertensionRisk),
        missingInputs: _missingForHypertension(profile, hasScanBp: hasScanBp),
      ),
      HealthIndexDisplay(
        label: AppStrings.diabetesRisk,
        value: _formatPercent(risks.diabetesRisk),
        missingInputs: _missingForDiabetes(profile),
      ),
      HealthIndexDisplay(
        label: AppStrings.bodyFat,
        value: _formatNumber(risks.bodyFatPercentage, suffix: '%', decimals: 1),
        missingInputs: const [],
      ),
      HealthIndexDisplay(
        label: AppStrings.waistToHeight,
        value: _formatNumber(risks.waistToHeightRatio, decimals: 2),
        missingInputs: risks.waistToHeightRatio == null && profile.waistCm == null
            ? [AppStrings.waistCm]
            : const [],
      ),
      HealthIndexDisplay(
        label: AppStrings.bmr,
        value: _formatNumber(
          risks.basalMetabolicRate,
          suffix: ' ${AppStrings.unitKcal}',
          decimals: 0,
        ),
        missingInputs: const [],
      ),
      HealthIndexDisplay(
        label: AppStrings.tdee,
        value: _formatNumber(
          risks.totalDailyEnergyExpenditure,
          suffix: ' ${AppStrings.unitKcal}',
          decimals: 0,
        ),
        missingInputs: const [],
      ),
      HealthIndexDisplay(
        label: AppStrings.nafldRisk,
        value: risks.nonAlcoholicFattyLiverDiseaseRisk == null
            ? null
            : EnumLabels.nafldRisk(risks.nonAlcoholicFattyLiverDiseaseRisk),
        missingInputs:
            risks.nonAlcoholicFattyLiverDiseaseRisk == null &&
                    profile.waistCm == null
                ? [AppStrings.waistCm]
                : const [],
      ),
    ].map((row) {
      // If SDK returned a value, treat as computed even if we guessed missing inputs.
      if (row.value != null) {
        return HealthIndexDisplay(label: row.label, value: row.value);
      }
      // If we have no missing-input explanation but value is null, keep generic note.
      if (row.missingInputs.isEmpty) {
        return HealthIndexDisplay(
          label: row.label,
          missingInputs: [AppStrings.insufficientData],
        );
      }
      return row;
    }).toList();
  }

  static List<String> _missingForFraminghamLike(RiskProfile profile) {
    // Docs: cholesterol+HDL OR height+weight. Height/weight are mandatory in our form.
    return const [];
  }

  static List<String> _missingForHardCvEvents(RiskProfile profile) {
    final missing = <String>[];
    if (profile.cholesterol == null) {
      missing.add(AppStrings.cholesterol);
    }
    if (profile.hdl == null) {
      missing.add(AppStrings.hdl);
    }
    return missing;
  }

  static List<String> _missingForFatalCvEvents(RiskProfile profile) {
    if (profile.cholesterol == null) {
      return [AppStrings.cholesterol];
    }
    return const [];
  }

  static List<String> _missingForHypertension(
    RiskProfile profile, {
    required bool hasScanBp,
  }) {
    // Age/gender/BMI/smoking/parental history always present via form defaults.
    return const [];
  }

  static List<String> _missingForDiabetes(RiskProfile profile) {
    // Framingham path needs labs; FINDRISC can work with waist + lifestyle.
    if (profile.waistCm != null) {
      return const [];
    }
    final needsLabs = profile.fastingGlucose == null ||
        profile.hdl == null ||
        profile.triglyceride == null;
    if (!needsLabs) {
      return const [];
    }
    return [AppStrings.diabetesNeedsLabsOrWaist];
  }

  static List<String> _missingForWellness(
    RiskProfile profile,
    MeasurementResults measurement,
  ) {
    final missing = <String>[];
    if (measurement.heart_rate_bpm <= 0) {
      missing.add(AppStrings.heartRate);
    }
    // Wellness docs list cholesterol levels among user-provided data.
    if (profile.cholesterol == null) {
      missing.add(AppStrings.cholesterol);
    }
    if (profile.hdl == null) {
      missing.add(AppStrings.hdl);
    }
    return missing;
  }

  static String? _formatNumber(
    double? value, {
    int decimals = 0,
    String suffix = '',
  }) {
    if (value == null) {
      return null;
    }
    return '${value.toStringAsFixed(decimals)}$suffix';
  }

  static String? _formatPercent(double? value) {
    if (value == null) {
      return null;
    }
    final asPercent = value <= 1.0 ? value * 100 : value;
    return '${asPercent.toStringAsFixed(1)}%';
  }
}
