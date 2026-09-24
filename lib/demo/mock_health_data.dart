import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/models/risk_profile.dart';

/// Deterministic sample data for UI demos (no camera / SDK required).
abstract final class MockHealthData {
  static MeasurementResults measurementResults() {
    return MeasurementResults(
      heart_rate_bpm: 72,
      hrv_sdnn_ms: 48.5,
      hrv_lnrmssd_ms: 3.6,
      stress_index: 2.4,
      parasympathetic_activity: 0.42,
      breathing_rate_bpm: 14.2,
      systolic_blood_pressure_mmhg: 118,
      diastolic_blood_pressure_mmhg: 76,
      cardiac_workload_mmhg_per_sec: 8200,
      age_years: 34,
      bmi_kg_per_m2: 23.4,
      bmi_category: BmiCategory.normal,
      weight_kg: 70,
      height_cm: 173,
      heartbeats: const [],
      average_signal_quality: 0.91,
    );
  }

  static RiskProfile profile({MeasurementResults? results}) {
    final scan = results ?? measurementResults();
    return RiskProfile(
      age: 34,
      heightCm: 173,
      weightKg: 70,
      waistCm: 82,
      neckCm: 37,
      hipCm: 96,
      cholesterol: 185,
      hdl: 55,
      triglyceride: 110,
      fastingGlucose: 92,
      sbp: scan.systolic_blood_pressure_mmhg ?? 118,
      dbp: scan.diastolic_blood_pressure_mmhg ?? 76,
      isSmoker: false,
      hypertensionTreatment: HypertensionTreatment.no,
      hasDiabetes: false,
      gender: Gender.male,
      physicalActivity: PhysicalActivity.moderately,
      country: 'IR',
      race: Race.other,
      vegetableFruitDiet: true,
      historyOfHighGlucose: false,
      historyOfHypertension: false,
      familyDiabetes: FamilyHistory.noneFirstDegree,
      parentalHypertension: ParentalHistory.none,
    );
  }

  /// Rich report sample roughly matching the reference layout numbers.
  static HealthRisks healthRisks() {
    return HealthRisks(
      vascularAge: 30,
      wellnessScore: 78.5,
      waistToHeightRatio: 0.47,
      bodyFatPercentage: 18.5,
      basalMetabolicRate: 1680,
      bodyRoundnessIndex: 3.2,
      conicityIndex: 1.18,
      aBodyShapeIndex: 0.075,
      totalDailyEnergyExpenditure: 2450,
      hypertensionRisk: 0.12,
      diabetesRisk: 0.08,
      nonAlcoholicFattyLiverDiseaseRisk: NAFLDRisk.low,
      cvDiseases: CVDiseasesRisks(
        overallRisk: 0.017,
        coronaryHeartDiseaseRisk: 0.012,
        strokeRisk: 0.008,
        heartFailureRisk: 0.005,
        peripheralVascularDiseaseRisk: 0.004,
      ),
      hardAndFatalEvents: HardAndFatalEventsRisks(
        hardCVEventRisk: 0.022,
        totalCVMortalityRisk: 0.011,
        coronaryDeathEventRisk: 0.009,
        fatalStrokeEventRisk: 0.006,
      ),
      scores: RisksFactorsScores(
        totalScore: -1,
        ageScore: -2,
        sbpScore: 0,
        smokingScore: 0,
        diabetesScore: 0,
        bmiScore: 0,
        cholesterolScore: 1,
        cholesterolHdlScore: 0,
      ),
    );
  }
}
