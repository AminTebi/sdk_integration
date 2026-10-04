import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/risk_assessor/risk_engine.dart';

/// User-provided inputs for Shen AI Health Indices.
///
/// Basic fields are required. Lab / advanced measurements are optional —
/// missing ones simply leave dependent indices uncomputed.
class RiskProfile {
  const RiskProfile({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.sbp,
    required this.dbp,
    required this.isSmoker,
    required this.hypertensionTreatment,
    required this.hasDiabetes,
    required this.gender,
    required this.physicalActivity,
    required this.country,
    required this.race,
    required this.vegetableFruitDiet,
    required this.historyOfHighGlucose,
    required this.historyOfHypertension,
    required this.familyDiabetes,
    required this.parentalHypertension,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.cholesterol,
    this.hdl,
    this.triglyceride,
    this.fastingGlucose,
  });

  factory RiskProfile.defaults({MeasurementResults? results}) {
    return RiskProfile(
      age: 45,
      heightCm: 172,
      weightKg: 74,
      sbp: results?.systolic_blood_pressure_mmhg ?? 120,
      dbp: results?.diastolic_blood_pressure_mmhg ?? 80,
      isSmoker: false,
      hypertensionTreatment: HypertensionTreatment.no,
      hasDiabetes: false,
      gender: Gender.female,
      physicalActivity: PhysicalActivity.moderately,
      country: 'IR',
      race: Race.white,
      vegetableFruitDiet: true,
      historyOfHighGlucose: false,
      historyOfHypertension: false,
      familyDiabetes: FamilyHistory.noneFirstDegree,
      parentalHypertension: ParentalHistory.none,
    );
  }

  /// Required basics
  final int age;
  final double heightCm;
  final double weightKg;
  final double sbp;
  final double dbp;
  final bool isSmoker;
  final HypertensionTreatment hypertensionTreatment;
  final bool hasDiabetes;
  final Gender gender;
  final PhysicalActivity physicalActivity;
  final String country;
  final Race race;
  final bool vegetableFruitDiet;
  final bool historyOfHighGlucose;
  final bool historyOfHypertension;
  final FamilyHistory familyDiabetes;
  final ParentalHistory parentalHypertension;

  /// Optional anthropometrics
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;

  /// Optional lab values
  final double? cholesterol;
  final double? hdl;
  final double? triglyceride;
  final double? fastingGlucose;

  RisksFactors toRisksFactors({MeasurementResults? results}) {
    return RisksFactors(
      age: age,
      cholesterol: cholesterol,
      cholesterolHdl: hdl,
      sbp: results?.systolic_blood_pressure_mmhg ?? sbp,
      dbp: results?.diastolic_blood_pressure_mmhg ?? dbp,
      isSmoker: isSmoker,
      hypertensionTreatment: hypertensionTreatment,
      hasDiabetes: hasDiabetes,
      bodyHeight: heightCm,
      bodyWeight: weightKg,
      waistCircumference: waistCm,
      neckCircumference: neckCm,
      hipCircumference: hipCm,
      gender: gender,
      physicalActivity: physicalActivity,
      country: country,
      race: race,
      vegetableFruitDiet: vegetableFruitDiet,
      historyOfHighGlucose: historyOfHighGlucose,
      historyOfHypertension: historyOfHypertension,
      triglyceride: triglyceride,
      fastingGlucose: fastingGlucose,
      familyDiabetes: familyDiabetes,
      parentalHypertension: parentalHypertension,
    );
  }

  /// Maps this app's Shen AI profile plus optional face-scan results to the
  /// ShenRisk / risk_assesor domain contract.
  ///
  /// Manual SBP/DBP remain on the input. The risk engine itself decides whether
  /// to replace them with scan BP based on scan quality (>= 55%).
  HealthDataInput toRiskAssessmentInput({MeasurementResults? results}) {
    return HealthDataInput(
      age: age,
      gender: _riskGender(gender),
      heightCm: heightCm,
      weightKg: weightKg,
      race: _riskRace(race),
      country: country,
      sbp: sbp,
      dbp: dbp,
      cholesterol: cholesterol,
      hdl: hdl,
      triglyceride: triglyceride,
      fastingGlucose: fastingGlucose,
      waistCm: waistCm,
      neckCm: neckCm,
      hipCm: hipCm,
      hypertensionTreatment: _riskHypertensionTreatment(hypertensionTreatment),
      familyDiabetes: _riskFamilyDiabetes(familyDiabetes),
      parentalHypertension: _riskParentalHypertension(parentalHypertension),
      isSmoker: isSmoker,
      hasDiabetes: hasDiabetes,
      historyOfHighGlucose: historyOfHighGlucose,
      historyOfHypertension: historyOfHypertension,
      physicalActivity: _riskPhysicalActivity(physicalActivity),
      vegetableFruitDiet: vegetableFruitDiet,
      heartRateBpm: results?.heart_rate_bpm,
      systolicBloodPressureMmhg: results?.systolic_blood_pressure_mmhg,
      diastolicBloodPressureMmhg: results?.diastolic_blood_pressure_mmhg,
      breathingRateBpm: results?.breathing_rate_bpm,
      hrvSdnnMs: results?.hrv_sdnn_ms,
      stressIndex: results?.stress_index,
      averageSignalQuality: results?.average_signal_quality,
    );
  }
}

RiskGender _riskGender(Gender value) => switch (value) {
      Gender.male => RiskGender.male,
      Gender.female => RiskGender.female,
      Gender.other => RiskGender.other,
    };

RiskRace _riskRace(Race value) => switch (value) {
      Race.white => RiskRace.white,
      Race.africanAmerican => RiskRace.africanAmerican,
      Race.other => RiskRace.other,
    };

RiskHypertensionTreatment _riskHypertensionTreatment(
  HypertensionTreatment value,
) =>
    switch (value) {
      HypertensionTreatment.notNeeded => RiskHypertensionTreatment.notNeeded,
      HypertensionTreatment.no => RiskHypertensionTreatment.no,
      HypertensionTreatment.yes => RiskHypertensionTreatment.yes,
    };

RiskFamilyDiabetes _riskFamilyDiabetes(FamilyHistory value) => switch (value) {
      FamilyHistory.none => RiskFamilyDiabetes.none,
      FamilyHistory.noneFirstDegree => RiskFamilyDiabetes.noneFirstDegree,
      FamilyHistory.firstDegree => RiskFamilyDiabetes.firstDegree,
    };

RiskParentalHypertension _riskParentalHypertension(
  ParentalHistory value,
) =>
    switch (value) {
      ParentalHistory.none => RiskParentalHypertension.none,
      ParentalHistory.one => RiskParentalHypertension.one,
      ParentalHistory.both => RiskParentalHypertension.both,
    };

RiskPhysicalActivity _riskPhysicalActivity(PhysicalActivity value) =>
    switch (value) {
      PhysicalActivity.sedentary => RiskPhysicalActivity.sedentary,
      PhysicalActivity.lightlyActive => RiskPhysicalActivity.lightlyActive,
      PhysicalActivity.moderately => RiskPhysicalActivity.moderately,
      PhysicalActivity.veryActive => RiskPhysicalActivity.veryActive,
      PhysicalActivity.extraActive => RiskPhysicalActivity.extraActive,
    };
