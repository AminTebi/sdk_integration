import 'package:flutter_test/flutter_test.dart';
import 'package:shenai_skd_integration/risk_assessor/coach.dart';
import 'package:shenai_skd_integration/risk_assessor/risk_engine.dart';

void main() {
  group('RiskEngine ShenRisk parity scenarios', () {
    test('healthy athlete lands in Preferred class', () {
      final result = RiskEngine.computeComprehensiveHealthRisk(_preferred);
      final plan = RiskCoach.buildPlan(_preferred, result);

      expect(result.compositeInsuranceRisk.overallScore, 9);
      expect(
        result.compositeInsuranceRisk.underwritingClass,
        UnderwritingClass.preferred,
      );
      expect(plan.maintain, isTrue);
    });

    test('medium-risk profile lands in Substandard 1 and improves to Standard', () {
      final result = RiskEngine.computeComprehensiveHealthRisk(_substandard1);
      final plan = RiskCoach.buildPlan(_substandard1, result);

      expect(result.compositeInsuranceRisk.overallScore, 63);
      expect(
        result.compositeInsuranceRisk.underwritingClass,
        UnderwritingClass.substandard1,
      );
      expect(plan.finalScore, 39);
      expect(plan.finalClass, UnderwritingClass.standard);
      expect(plan.effective, isNotEmpty);
    });

    test('acute low-quality scan lands in Decline Review with deferred actions', () {
      final result = RiskEngine.computeComprehensiveHealthRisk(_decline);
      final plan = RiskCoach.buildPlan(_decline, result);

      expect(result.compositeInsuranceRisk.overallScore, 100);
      expect(
        result.compositeInsuranceRisk.underwritingClass,
        UnderwritingClass.declineReview,
      );
      expect(plan.finalScore, 92);
      expect(plan.finalClass, UnderwritingClass.declineReview);
      expect(plan.deferred, isNotEmpty);
      expect(result.compositeInsuranceRisk.criticalWarnings, isNotEmpty);
    });
  });
}

const _preferred = HealthDataInput(
  age: 28,
  gender: RiskGender.male,
  heightCm: 181,
  weightKg: 74,
  race: RiskRace.white,
  country: 'IR',
  sbp: 118,
  dbp: 74,
  cholesterol: 168,
  hdl: 54,
  triglyceride: 92,
  fastingGlucose: 88,
  waistCm: 80,
  neckCm: 37,
  hipCm: 99,
  hypertensionTreatment: RiskHypertensionTreatment.notNeeded,
  familyDiabetes: RiskFamilyDiabetes.none,
  parentalHypertension: RiskParentalHypertension.none,
  isSmoker: false,
  hasDiabetes: false,
  historyOfHighGlucose: false,
  historyOfHypertension: false,
  physicalActivity: RiskPhysicalActivity.veryActive,
  vegetableFruitDiet: true,
  heartRateBpm: 58,
  systolicBloodPressureMmhg: 116,
  diastolicBloodPressureMmhg: 72,
  breathingRateBpm: 13,
  hrvSdnnMs: 68,
  stressIndex: 34,
  averageSignalQuality: 0.94,
);

const _substandard1 = HealthDataInput(
  age: 54,
  gender: RiskGender.male,
  heightCm: 171,
  weightKg: 88,
  race: RiskRace.white,
  country: 'IR',
  sbp: 136,
  dbp: 87,
  cholesterol: 226,
  hdl: 44,
  triglyceride: 198,
  fastingGlucose: 104,
  waistCm: 101,
  neckCm: 42,
  hipCm: 106,
  hypertensionTreatment: RiskHypertensionTreatment.yes,
  familyDiabetes: RiskFamilyDiabetes.none,
  parentalHypertension: RiskParentalHypertension.one,
  isSmoker: false,
  hasDiabetes: false,
  historyOfHighGlucose: false,
  historyOfHypertension: true,
  physicalActivity: RiskPhysicalActivity.moderately,
  vegetableFruitDiet: true,
  heartRateBpm: 84,
  systolicBloodPressureMmhg: 138,
  diastolicBloodPressureMmhg: 88,
  breathingRateBpm: 16,
  hrvSdnnMs: 42,
  stressIndex: 68,
  averageSignalQuality: 0.81,
);

const _decline = HealthDataInput(
  age: 67,
  gender: RiskGender.male,
  heightCm: 168,
  weightKg: 96,
  race: RiskRace.white,
  country: 'IR',
  sbp: 168,
  dbp: 96,
  cholesterol: 268,
  hdl: 34,
  triglyceride: 312,
  fastingGlucose: 196,
  waistCm: 112,
  neckCm: 45,
  hipCm: 108,
  hypertensionTreatment: RiskHypertensionTreatment.no,
  familyDiabetes: RiskFamilyDiabetes.firstDegree,
  parentalHypertension: RiskParentalHypertension.both,
  isSmoker: true,
  hasDiabetes: true,
  historyOfHighGlucose: true,
  historyOfHypertension: true,
  physicalActivity: RiskPhysicalActivity.sedentary,
  vegetableFruitDiet: false,
  heartRateBpm: 96,
  systolicBloodPressureMmhg: 172,
  diastolicBloodPressureMmhg: 98,
  breathingRateBpm: 24,
  hrvSdnnMs: 22,
  stressIndex: 176,
  averageSignalQuality: 0.38,
);
