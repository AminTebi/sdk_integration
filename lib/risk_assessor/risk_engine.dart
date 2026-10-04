import 'dart:math' as math;

/// Dart port of `health-risk-app/src/lib/riskEngine.ts` from
/// https://github.com/AminTebi/risk_assesor.
///
/// The engine is intentionally deterministic and side-effect free. It combines
/// the user-entered profile, optional labs/body measurements, and optional
/// facial-scan/rPPG measurements into an insurance-oriented risk assessment.
///
/// Important: coefficients and premium loadings come from the referenced
/// prototype and must be clinically/actuarially validated before production
/// underwriting use.
enum RiskGender { male, female, other }

enum RiskRace { white, africanAmerican, other }

enum RiskHypertensionTreatment { notNeeded, no, yes }

enum RiskFamilyDiabetes { none, noneFirstDegree, firstDegree }

enum RiskParentalHypertension { none, one, both }

enum RiskPhysicalActivity {
  sedentary,
  lightlyActive,
  moderately,
  veryActive,
  extraActive,
}

enum UnderwritingClass {
  preferred,
  standard,
  substandard1,
  substandard2,
  declineReview,
}

extension UnderwritingClassCode on UnderwritingClass {
  String get code => switch (this) {
        UnderwritingClass.preferred => 'Preferred',
        UnderwritingClass.standard => 'Standard',
        UnderwritingClass.substandard1 => 'Substandard_1',
        UnderwritingClass.substandard2 => 'Substandard_2',
        UnderwritingClass.declineReview => 'Decline_Review',
      };
}

class HealthDataInput {
  const HealthDataInput({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.race,
    required this.country,
    required this.sbp,
    required this.dbp,
    required this.hypertensionTreatment,
    required this.familyDiabetes,
    required this.parentalHypertension,
    required this.isSmoker,
    required this.hasDiabetes,
    required this.historyOfHighGlucose,
    required this.historyOfHypertension,
    required this.physicalActivity,
    required this.vegetableFruitDiet,
    this.cholesterol,
    this.hdl,
    this.triglyceride,
    this.fastingGlucose,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.heartRateBpm,
    this.systolicBloodPressureMmhg,
    this.diastolicBloodPressureMmhg,
    this.breathingRateBpm,
    this.hrvSdnnMs,
    this.stressIndex,
    this.averageSignalQuality,
  });

  // Required demographics.
  final int age;
  final RiskGender gender;
  final double heightCm;
  final double weightKg;
  final RiskRace race;
  final String country;

  // Manual blood pressure.
  final double sbp;
  final double dbp;

  // Optional labs.
  final double? cholesterol;
  final double? hdl;
  final double? triglyceride;
  final double? fastingGlucose;

  // Optional anthropometrics.
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;

  // Medical history.
  final RiskHypertensionTreatment hypertensionTreatment;
  final RiskFamilyDiabetes familyDiabetes;
  final RiskParentalHypertension parentalHypertension;
  final bool isSmoker;
  final bool hasDiabetes;
  final bool historyOfHighGlucose;
  final bool historyOfHypertension;

  // Lifestyle.
  final RiskPhysicalActivity physicalActivity;
  final bool vegetableFruitDiet;

  // Optional device / sensor outputs from face scan.
  final double? heartRateBpm;
  final double? systolicBloodPressureMmhg;
  final double? diastolicBloodPressureMmhg;
  final double? breathingRateBpm;
  final double? hrvSdnnMs;
  final double? stressIndex;
  final double? averageSignalQuality;

  HealthDataInput copyWith({
    int? age,
    RiskGender? gender,
    double? heightCm,
    double? weightKg,
    RiskRace? race,
    String? country,
    double? sbp,
    double? dbp,
    double? cholesterol,
    double? hdl,
    double? triglyceride,
    double? fastingGlucose,
    double? waistCm,
    double? neckCm,
    double? hipCm,
    RiskHypertensionTreatment? hypertensionTreatment,
    RiskFamilyDiabetes? familyDiabetes,
    RiskParentalHypertension? parentalHypertension,
    bool? isSmoker,
    bool? hasDiabetes,
    bool? historyOfHighGlucose,
    bool? historyOfHypertension,
    RiskPhysicalActivity? physicalActivity,
    bool? vegetableFruitDiet,
    double? heartRateBpm,
    double? systolicBloodPressureMmhg,
    double? diastolicBloodPressureMmhg,
    double? breathingRateBpm,
    double? hrvSdnnMs,
    double? stressIndex,
    double? averageSignalQuality,
  }) {
    return HealthDataInput(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      race: race ?? this.race,
      country: country ?? this.country,
      sbp: sbp ?? this.sbp,
      dbp: dbp ?? this.dbp,
      cholesterol: cholesterol ?? this.cholesterol,
      hdl: hdl ?? this.hdl,
      triglyceride: triglyceride ?? this.triglyceride,
      fastingGlucose: fastingGlucose ?? this.fastingGlucose,
      waistCm: waistCm ?? this.waistCm,
      neckCm: neckCm ?? this.neckCm,
      hipCm: hipCm ?? this.hipCm,
      hypertensionTreatment:
          hypertensionTreatment ?? this.hypertensionTreatment,
      familyDiabetes: familyDiabetes ?? this.familyDiabetes,
      parentalHypertension:
          parentalHypertension ?? this.parentalHypertension,
      isSmoker: isSmoker ?? this.isSmoker,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      historyOfHighGlucose:
          historyOfHighGlucose ?? this.historyOfHighGlucose,
      historyOfHypertension:
          historyOfHypertension ?? this.historyOfHypertension,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      vegetableFruitDiet: vegetableFruitDiet ?? this.vegetableFruitDiet,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      systolicBloodPressureMmhg:
          systolicBloodPressureMmhg ?? this.systolicBloodPressureMmhg,
      diastolicBloodPressureMmhg:
          diastolicBloodPressureMmhg ?? this.diastolicBloodPressureMmhg,
      breathingRateBpm: breathingRateBpm ?? this.breathingRateBpm,
      hrvSdnnMs: hrvSdnnMs ?? this.hrvSdnnMs,
      stressIndex: stressIndex ?? this.stressIndex,
      averageSignalQuality:
          averageSignalQuality ?? this.averageSignalQuality,
    );
  }
}

class EngineResult {
  const EngineResult({
    required this.cardiovascularRisk,
    required this.diabetesMetabolicRisk,
    required this.adiposityAndOsaRisk,
    required this.autonomicStressIndex,
    required this.biologicalAge,
    required this.chronologicalAge,
    required this.compositeInsuranceRisk,
  });

  final CardiovascularRisk cardiovascularRisk;
  final DiabetesMetabolicRisk diabetesMetabolicRisk;
  final AdiposityAndOsaRisk adiposityAndOsaRisk;
  final AutonomicStressIndex autonomicStressIndex;
  final double biologicalAge;
  final int chronologicalAge;
  final CompositeInsuranceRisk compositeInsuranceRisk;
}

class CardiovascularRisk {
  const CardiovascularRisk({
    required this.score,
    required this.percentage,
    required this.level,
  });

  final double score;
  final double percentage;
  final String level;
}

class DiabetesMetabolicRisk {
  const DiabetesMetabolicRisk({
    required this.findrisc,
    required this.tygIndex,
    required this.level,
  });

  final int findrisc;
  final double? tygIndex;
  final String level;
}

class AdiposityAndOsaRisk {
  const AdiposityAndOsaRisk({
    required this.whtr,
    required this.whr,
    required this.osaRisk,
  });

  final double whtr;
  final double? whr;
  final String osaRisk;
}

class AutonomicStressIndex {
  const AutonomicStressIndex({
    required this.score,
    required this.qualityDiscountApplied,
    required this.level,
  });

  final int score;
  final bool qualityDiscountApplied;
  final String level;
}

class CompositeInsuranceRisk {
  const CompositeInsuranceRisk({
    required this.overallScore,
    required this.underwritingClass,
    required this.premiumLoadingPercent,
    required this.criticalWarnings,
  });

  final int overallScore;
  final UnderwritingClass underwritingClass;
  final int premiumLoadingPercent;
  final List<String> criticalWarnings;
}

abstract final class RiskEngine {
  static EngineResult computeComprehensiveHealthRisk(HealthDataInput input) {
    final warnings = <String>[];

    // 1. Resolve effective BP: reliable scan values override manual form BP.
    var sbp = input.sbp;
    var dbp = input.dbp;
    final rawQuality = input.averageSignalQuality ?? 0;
    final signalQuality = rawQuality > 1.0 ? rawQuality / 100 : rawQuality;
    final isScanReliable = signalQuality >= 0.55;

    if (isScanReliable &&
        input.systolicBloodPressureMmhg != null &&
        input.diastolicBloodPressureMmhg != null) {
      sbp = input.systolicBloodPressureMmhg!;
      dbp = input.diastolicBloodPressureMmhg!;
    } else if (!isScanReliable && input.systolicBloodPressureMmhg != null) {
      warnings.add(
        'کیفیت اسکن چهره زیر ۵۵٪ بود؛ مقادیر تن‌سنجی دستی اولویت یافتند.',
      );
    }

    // 2. Anthropometric indices.
    final heightM = input.heightCm / 100.0;
    final bmi = input.weightKg / (heightM * heightM);
    final waistCm = input.waistCm;
    final hipCm = input.hipCm;
    final whtr = waistCm != null ? waistCm / input.heightCm : (bmi / 50.0) + 0.05;
    final whr = waistCm != null && hipCm != null ? waistCm / hipCm : null;

    var osaRisk = 'Low';
    final neckCm = input.neckCm;
    if (neckCm != null) {
      final neckThreshold = input.gender == RiskGender.male ? 43 : 38;
      if (neckCm >= neckThreshold) {
        osaRisk = 'High';
        warnings.add(
          'دور گردن بالاتر از حد استاندارد ($neckCm cm) نشان‌دهنده خطر بالای آپنه انسدادی خواب است.',
        );
      }
    }

    // 3. Cardiovascular risk sub-engine.
    var cvdBase = (input.age - 20) * 0.75;
    if (input.gender == RiskGender.male) {
      cvdBase += 6;
    }
    if (input.race == RiskRace.africanAmerican) {
      cvdBase += 4;
    }
    if (input.country.toUpperCase() == 'IR') {
      cvdBase += 3;
    }

    if (sbp >= 160) {
      cvdBase += 12;
    } else if (sbp >= 140) {
      cvdBase += 7;
    } else if (sbp >= 130) {
      cvdBase += 4;
    }

    final pulsePressure = sbp - dbp;
    if (pulsePressure > 60) {
      cvdBase += 3;
    }

    if (input.hypertensionTreatment == RiskHypertensionTreatment.yes) {
      cvdBase += 3;
    }
    if (input.hypertensionTreatment == RiskHypertensionTreatment.no &&
        (sbp >= 140 || dbp >= 90)) {
      cvdBase += 6;
      warnings.add('فشار خون بالا بدون درمان دارویی شناسایی شد.');
    }

    if (input.parentalHypertension == RiskParentalHypertension.both) {
      cvdBase += 4;
    } else if (input.parentalHypertension == RiskParentalHypertension.one) {
      cvdBase += 2;
    }

    if (input.isSmoker) {
      cvdBase += 9;
    }
    if (input.hasDiabetes) {
      cvdBase += 10;
    }

    if (input.cholesterol != null && input.hdl != null) {
      final ratio = input.cholesterol! / input.hdl!;
      if (ratio > 5) {
        cvdBase += 6;
      } else if (ratio > 4) {
        cvdBase += 3;
      }
    } else {
      if (bmi >= 30) {
        cvdBase += 4;
      } else if (bmi >= 25) {
        cvdBase += 2;
      }
    }

    final cvdPercentage =
        _round1((cvdBase / 65) * 25).clamp(1.5, 75.0).toDouble();
    final cvdLevel = cvdPercentage >= 20
        ? 'High'
        : cvdPercentage >= 10
            ? 'Moderate'
            : 'Low';

    // 4. Diabetes and metabolic sub-engine.
    var findrisc = 0;
    if (input.age >= 65) {
      findrisc += 4;
    } else if (input.age >= 55) {
      findrisc += 3;
    } else if (input.age >= 45) {
      findrisc += 2;
    }

    if (bmi >= 30) {
      findrisc += 3;
    } else if (bmi >= 25) {
      findrisc += 1;
    }

    if (waistCm != null) {
      if (input.gender == RiskGender.male) {
        if (waistCm > 102) {
          findrisc += 4;
        } else if (waistCm >= 94) {
          findrisc += 3;
        }
      } else {
        if (waistCm > 88) {
          findrisc += 4;
        } else if (waistCm >= 80) {
          findrisc += 3;
        }
      }
    }

    if (input.physicalActivity == RiskPhysicalActivity.sedentary ||
        input.physicalActivity == RiskPhysicalActivity.lightlyActive) {
      findrisc += 2;
    }
    if (!input.vegetableFruitDiet) {
      findrisc += 1;
    }
    if (input.hypertensionTreatment == RiskHypertensionTreatment.yes ||
        input.historyOfHypertension) {
      findrisc += 2;
    }
    if (input.historyOfHighGlucose || input.hasDiabetes) {
      findrisc += 5;
    }

    if (input.familyDiabetes == RiskFamilyDiabetes.firstDegree) {
      findrisc += 5;
    } else if (input.familyDiabetes == RiskFamilyDiabetes.noneFirstDegree) {
      findrisc += 3;
    }

    double? tygIndex;
    if (input.fastingGlucose != null && input.triglyceride != null) {
      final computedTyg = _round2(
        math.log((input.triglyceride! * input.fastingGlucose!) / 2),
      );
      tygIndex = computedTyg;
      if (computedTyg > 8.8) {
        findrisc += 3;
        warnings.add(
          'شاخص TyG معادل $computedTyg نشان‌دهنده مقاومت به انسولین است.',
        );
      }
    }

    final metabolicLevel = findrisc >= 15
        ? 'High'
        : findrisc >= 10
            ? 'Moderate'
            : 'Low';

    // 5. Autonomic and sensor stress sub-engine.
    var sensorPenalty = 0;
    if (isScanReliable) {
      final hr = input.heartRateBpm ?? 72;
      if (hr > 90) {
        sensorPenalty += 6;
      } else if (hr > 82) {
        sensorPenalty += 3;
      } else if (hr < 50) {
        sensorPenalty += 2;
      }

      final sdnn = input.hrvSdnnMs ?? 45;
      if (sdnn < 25) {
        sensorPenalty += 8;
      } else if (sdnn < 35) {
        sensorPenalty += 4;
      }

      final br = input.breathingRateBpm ?? 16;
      if (br > 22 || br < 9) {
        sensorPenalty += 3;
      }

      final stress = input.stressIndex ?? 50;
      if (stress > 150) {
        sensorPenalty += 4;
      }
    } else {
      sensorPenalty = 2;
    }

    final autonomicScore = math.min(sensorPenalty * 4, 30);
    final autonomicLevel = autonomicScore > 18
        ? 'High'
        : autonomicScore > 8
            ? 'Moderate'
            : 'Normal';

    // 6. Biological age.
    var bioAgeDelta = 0.0;
    if (cvdPercentage > 15) {
      bioAgeDelta += 3.5;
    }
    if (input.isSmoker) {
      bioAgeDelta += 4.0;
    }
    if (whtr > 0.58) {
      bioAgeDelta += 2.5;
    }
    if (input.hrvSdnnMs != null && input.hrvSdnnMs! < 30) {
      bioAgeDelta += 2.0;
    }
    if (input.physicalActivity == RiskPhysicalActivity.veryActive ||
        input.physicalActivity == RiskPhysicalActivity.extraActive) {
      bioAgeDelta -= 2.5;
    }
    if (input.vegetableFruitDiet) {
      bioAgeDelta -= 1.0;
    }

    final biologicalAge = _round1(input.age + bioAgeDelta);

    // 7. Composite actuarial score.
    final compositeScore = math.min(
      ((cvdPercentage * 1.6) +
              (findrisc * 1.3) +
              autonomicScore +
              (whtr > 0.6
                  ? 8
                  : whtr > 0.5
                      ? 4
                      : 0) +
              (input.isSmoker ? 6 : 0))
          .round(),
      100,
    );

    var underwritingClass = UnderwritingClass.standard;
    var premiumLoadingPercent = 0;

    if (compositeScore < 25) {
      underwritingClass = UnderwritingClass.preferred;
      premiumLoadingPercent = -10;
    } else if (compositeScore <= 48) {
      underwritingClass = UnderwritingClass.standard;
      premiumLoadingPercent = 0;
    } else if (compositeScore <= 68) {
      underwritingClass = UnderwritingClass.substandard1;
      premiumLoadingPercent = 30;
    } else if (compositeScore <= 85) {
      underwritingClass = UnderwritingClass.substandard2;
      premiumLoadingPercent = 65;
    } else {
      underwritingClass = UnderwritingClass.declineReview;
      premiumLoadingPercent = 120;
      warnings.add(
        'متقاضی مشمول بررسی ویژه پزشک ارشد بیمه (CMO) به دلیل شاخص ریسک بحرانی است.',
      );
    }

    return EngineResult(
      cardiovascularRisk: CardiovascularRisk(
        score: cvdBase,
        percentage: cvdPercentage,
        level: cvdLevel,
      ),
      diabetesMetabolicRisk: DiabetesMetabolicRisk(
        findrisc: findrisc,
        tygIndex: tygIndex,
        level: metabolicLevel,
      ),
      adiposityAndOsaRisk: AdiposityAndOsaRisk(
        whtr: _round2(whtr),
        whr: whr,
        osaRisk: osaRisk,
      ),
      autonomicStressIndex: AutonomicStressIndex(
        score: autonomicScore,
        qualityDiscountApplied: !isScanReliable,
        level: autonomicLevel,
      ),
      biologicalAge: biologicalAge,
      chronologicalAge: input.age,
      compositeInsuranceRisk: CompositeInsuranceRisk(
        overallScore: compositeScore,
        underwritingClass: underwritingClass,
        premiumLoadingPercent: premiumLoadingPercent,
        criticalWarnings: List.unmodifiable(warnings),
      ),
    );
  }

  static double _round1(double value) => (value * 10).round() / 10;

  static double _round2(double value) => (value * 100).round() / 100;
}
