import 'package:shenai_sdk/pigeon.dart';

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
}
