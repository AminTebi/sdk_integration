import 'dart:math' as math;

import 'package:shenai_skd_integration/risk_assessor/risk_engine.dart';

/// Dart port of `health-risk-app/src/lib/coach.ts` from
/// https://github.com/AminTebi/risk_assesor.
///
/// The coaching module simulates each suggested intervention by re-running the
/// same deterministic risk engine on a modified copy of the input.
enum CoachingEffort { low, medium, high }

enum CoachingCategory {
  medical,
  nutrition,
  activity,
  sleep,
  stress,
  labs,
  monitoring,
}

typedef CoachingApply = HealthDataInput Function(HealthDataInput input);

class CoachSuggestion {
  const CoachSuggestion({
    required this.id,
    required this.phase,
    required this.category,
    required this.title,
    required this.body,
    required this.why,
    required this.effort,
    required this.duration,
    required this.markers,
    required this.apply,
  });

  final String id;
  final int phase;
  final CoachingCategory category;
  final String title;
  final String body;
  final String why;
  final CoachingEffort effort;
  final String duration;
  final String markers;
  final CoachingApply apply;
}

class PlanStep {
  const PlanStep({
    required this.suggestion,
    required this.before,
    required this.after,
    required this.delta,
  });

  final CoachSuggestion suggestion;
  final int before;
  final int after;
  final int delta;
}

class CoachingPlanData {
  const CoachingPlanData({
    required this.steps,
    required this.effective,
    required this.deferred,
    required this.currentScore,
    required this.finalScore,
    required this.currentClass,
    required this.finalClass,
    required this.maintain,
    required this.immutable,
    required this.maintainTips,
  });

  final List<PlanStep> steps;
  final List<PlanStep> effective;
  final List<PlanStep> deferred;
  final int currentScore;
  final int finalScore;
  final UnderwritingClass currentClass;
  final UnderwritingClass finalClass;
  final bool maintain;
  final List<String> immutable;
  final List<String> maintainTips;
}

abstract final class RiskCoach {
  static const loadingByClass = <UnderwritingClass, int>{
    UnderwritingClass.preferred: -10,
    UnderwritingClass.standard: 0,
    UnderwritingClass.substandard1: 30,
    UnderwritingClass.substandard2: 65,
    UnderwritingClass.declineReview: 120,
  };

  static const classRank = <UnderwritingClass, int>{
    UnderwritingClass.preferred: 0,
    UnderwritingClass.standard: 1,
    UnderwritingClass.substandard1: 2,
    UnderwritingClass.substandard2: 3,
    UnderwritingClass.declineReview: 4,
  };

  static CoachingPlanData buildPlan(
    HealthDataInput input,
    EngineResult result,
  ) {
    final suggestions = _buildSuggestionList(input);
    int score(HealthDataInput data) => RiskEngine
        .computeComprehensiveHealthRisk(data)
        .compositeInsuranceRisk
        .overallScore;

    var work = input;
    final steps = <PlanStep>[];
    for (final suggestion in suggestions) {
      final before = score(work);
      final next = suggestion.apply(work);
      final after = score(next);
      steps.add(
        PlanStep(
          suggestion: suggestion,
          before: before,
          after: after,
          delta: before - after,
        ),
      );
      work = next;
    }

    final finalResult = RiskEngine.computeComprehensiveHealthRisk(work);
    final immutable = <String>[
      'سن ${_faNum(input.age)}',
      _genderFa(input.gender),
      _raceFa(input.race),
      'کشور ${input.country}',
    ];
    if (input.familyDiabetes != RiskFamilyDiabetes.none) {
      immutable.add(_familyDiabetesFa(input.familyDiabetes));
    }
    if (input.parentalHypertension != RiskParentalHypertension.none) {
      immutable.add(
        'فشارخون والدین: ${_parentalHypertensionFa(input.parentalHypertension)}',
      );
    }

    final effective = steps.where((step) => step.delta > 0).toList();
    final deferred = steps.where((step) => step.delta <= 0).toList();

    return CoachingPlanData(
      steps: List.unmodifiable(steps),
      effective: List.unmodifiable(effective),
      deferred: List.unmodifiable(deferred),
      currentScore: result.compositeInsuranceRisk.overallScore,
      finalScore: finalResult.compositeInsuranceRisk.overallScore,
      currentClass: result.compositeInsuranceRisk.underwritingClass,
      finalClass: finalResult.compositeInsuranceRisk.underwritingClass,
      maintain: suggestions.isEmpty,
      immutable: List.unmodifiable(immutable),
      maintainTips: const [
        'حداقل ۱۵۰ دقیقه فعالیت متوسط در هفته را حفظ کنید',
        'هر ۱۲ ماه یک‌بار پایش کامل (فشار، چربی، قند) انجام دهید',
        'روزانه ۱۰ دقیقه تمرین تنفس برای حفظ HRV',
        'رژیم مدیترانه‌ای با میوه و سبزی ادامه‌دار',
      ],
    );
  }

  static List<CoachSuggestion> _buildSuggestionList(HealthDataInput input) {
    final out = <CoachSuggestion>[];
    final rawQuality = input.averageSignalQuality ?? 0;
    final quality = rawQuality > 1 ? rawQuality / 100 : rawQuality;
    final (esbp, edbp) = _effectiveBp(input);
    final bmi = input.weightKg / math.pow(input.heightCm / 100, 2);
    final whtr = input.waistCm != null
        ? input.waistCm! / input.heightCm
        : bmi / 50 + 0.05;
    final tyg = input.fastingGlucose != null && input.triglyceride != null
        ? math.log((input.triglyceride! * input.fastingGlucose!) / 2)
        : null;
    final ratio = input.cholesterol != null && input.hdl != null
        ? input.cholesterol! / input.hdl!
        : null;

    // Phase 0: urgent / immediate actions.
    if (input.hypertensionTreatment == RiskHypertensionTreatment.no &&
        (esbp >= 140 || edbp >= 90)) {
      out.add(
        CoachSuggestion(
          id: 'bp-urgent',
          phase: 0,
          category: CoachingCategory.medical,
          title: 'ویزیت فوری پزشکی — شروع مدیریت فشارخون',
          body:
              'فشارخون شما بالاست و هنوز درمان نشده است. همین هفته ویزیت و شروع دارو (با نظر پزشک) معمولاً در ماه اول، سیستولیک را ۱۵ تا ۲۰ میلی‌جیوه کاهش می‌دهد.',
          why:
              'ESH/ESC — فشار کنترل‌نشده بزرگ‌ترین فاکتور مستقل قلبی‌عروقی است',
          effort: CoachingEffort.low,
          duration: 'یک‌باره + دارو روزانه',
          markers: 'فشار منزل < ۱۳۵/۸۵',
          apply: (w) => _bpShift(w, -20, -10).copyWith(
            hypertensionTreatment: RiskHypertensionTreatment.yes,
          ),
        ),
      );
    }

    if (input.hypertensionTreatment == RiskHypertensionTreatment.yes &&
        (esbp >= 130 || edbp >= 80)) {
      out.add(
        CoachSuggestion(
          id: 'bp-control',
          phase: 0,
          category: CoachingCategory.medical,
          title: 'رعایت دارو + رژیم DASH (کم‌نمک) + پایش فشار در منزل',
          body:
              'درمان می‌شوید ولی فشار هنوز روی هدف نیست. ثبت روزانه فشار + کاهش نمک به زیر ۵ گرم در روز معمولاً ۵ تا ۱۰ میلی‌جیوه سیستولیک دیگر کم می‌کند.',
          why: 'AHA/ACC 2017 — هدف < ۱۳۰/۸۰؛ رژیم DASH تا ۱۴ mmHg کاهش SBP',
          effort: CoachingEffort.medium,
          duration: 'روزانه',
          markers: 'فشار منزل < ۱۳۰/۸۰',
          apply: (w) => _bpShift(w, -8, -5),
        ),
      );
    }

    if (input.isSmoker) {
      out.add(
        CoachSuggestion(
          id: 'smoking',
          phase: 0,
          category: CoachingCategory.medical,
          title: 'متوقف‌سازی دخانیات — بزرگ‌ترین اهرم کاهش ریسک',
          body:
              'امروز با جایگزین نیکوتین و مشاوره شروع کنید؛ در ۴ تا ۱۲ هفته، نمره بیمه‌ای به‌طور محسوس افت می‌کند.',
          why: 'INTERHEART — دخانیات ریسک قلبی را حدود ۲ برابر می‌کند',
          effort: CoachingEffort.high,
          duration: 'شروع امروز، اثر ۴–۱۲ هفته',
          markers: 'صفر نخ در روز',
          apply: (w) => w.copyWith(isSmoker: false),
        ),
      );
    }

    if (input.hasDiabetes) {
      out.add(
        CoachSuggestion(
          id: 'diabetes',
          phase: 0,
          category: CoachingCategory.medical,
          title: 'ویزیت غدد — کنترل قند خون (HbA1c زیر ۷٪)',
          body:
              'دیابت معادل خطر CAD است. بازبینی درمان و آزمایش HbA1c معمولاً قند ناشتا را ۱۰ تا ۱۵ درصد کاهش می‌دهد.',
          why: 'ADA Standards of Care — کاهش HbA1c با کاهش رویدادهای عروقی همراه است',
          effort: CoachingEffort.medium,
          duration: '۲–۴ هفته (برنامه درمانی)',
          markers: 'قند ناشتا < ۱۳۰ · HbA1c < ۷٪',
          apply: (w) => w.fastingGlucose != null && w.fastingGlucose! > 140
              ? w.copyWith(fastingGlucose: (w.fastingGlucose! * 0.85).roundToDouble())
              : w,
        ),
      );
    }

    if (!input.vegetableFruitDiet) {
      out.add(
        CoachSuggestion(
          id: 'diet',
          phase: 0,
          category: CoachingCategory.nutrition,
          title: 'رژیم مدیترانه‌ای — روزانه ۵+ وعده میوه و سبزی',
          body:
              'از امروز شروع کنید: نیمی از هر وعده سبزی، صبحانه با میوه، حذف غذاهای اولتراپروسس‌شده. سریع‌ترین اهرم کاهش ریسک همین است.',
          why: "AHA Life's Essential 8 — کیفیت رژیم ریسک متابولیک را کاهش می‌دهد",
          effort: CoachingEffort.low,
          duration: 'روزانه — اثر فوری',
          markers: 'میوه و سبزی در هر روز',
          apply: (w) => w.copyWith(vegetableFruitDiet: true),
        ),
      );
    }

    // Phase 1: first week to first month.
    if (!input.hasDiabetes &&
        (input.historyOfHighGlucose || (tyg != null && tyg > 8.8))) {
      out.add(
        CoachSuggestion(
          id: 'insulin',
          phase: 1,
          category: CoachingCategory.nutrition,
          title: 'کاهش کربوهیدرات ساده + ۱۰ دقیقه پیاده‌روی بعد از شام',
          body:
              "شاخص TyG شما ${tyg != null ? _faNum(tyg.toStringAsFixed(2)) : '—'} است. قند و شیرینی‌های ساده را کم کنید و بعد از هر وعده ۱۰ دقیقه قدم بزنید.",
          why: 'TyG > 8.8 معادل مقاومت به انسولین است',
          effort: CoachingEffort.low,
          duration: '۱۰ دقیقه/روز — ۴ تا ۸ هفته',
          markers: 'TyG < 8.8 · قند ناشتا < ۱۰۰',
          apply: (w) => w.copyWith(
            fastingGlucose: w.fastingGlucose == null
                ? null
                : (w.fastingGlucose! * 0.85).roundToDouble(),
            triglyceride: w.triglyceride == null
                ? null
                : (w.triglyceride! * 0.75).roundToDouble(),
          ),
        ),
      );
    }

    if (quality >= 0.55 &&
        ((input.heartRateBpm ?? 72) > 82 ||
            (input.hrvSdnnMs ?? 45) < 40 ||
            (input.stressIndex ?? 50) > 100 ||
            (input.breathingRateBpm ?? 16) > 20)) {
      out.add(
        CoachSuggestion(
          id: 'vagal',
          phase: 1,
          category: CoachingCategory.stress,
          title: 'روان‌سازی روزانه سیستم پاراسمپاتیک — تنفس ۴-۷-۸',
          body:
              'روزی ۱۰ دقیقه تمرین تنفس ۴-۷-۸ (صبح و شب) در ۲ تا ۴ هفته می‌تواند ضربان استراحت را کم و HRV را بهتر کند.',
          why: 'HRV پایین پیش‌بین مستقل بار قلبی‌عروقی است',
          effort: CoachingEffort.low,
          duration: '۱۰ دقیقه/روز — ۲ تا ۴ هفته',
          markers: 'RHR < ۸۰ · SDNN > ۴۵ ms',
          apply: (w) => w.copyWith(
            heartRateBpm: w.heartRateBpm == null
                ? null
                : math.max(60.0, (w.heartRateBpm! - 8).roundToDouble()),
            hrvSdnnMs: w.hrvSdnnMs == null
                ? null
                : math.min(90.0, (w.hrvSdnnMs! + 12).roundToDouble()),
            stressIndex: w.stressIndex == null
                ? null
                : math.max(30.0, (w.stressIndex! - 50).roundToDouble()),
            breathingRateBpm: w.breathingRateBpm != null &&
                    (w.breathingRateBpm! > 20 || w.breathingRateBpm! < 9)
                ? 16.0
                : null,
          ),
        ),
      );
    }

    if (input.physicalActivity == RiskPhysicalActivity.sedentary ||
        input.physicalActivity == RiskPhysicalActivity.lightlyActive) {
      out.add(
        CoachSuggestion(
          id: 'activity',
          phase: 1,
          category: CoachingCategory.activity,
          title: '۱۵۰ دقیقه پیاده‌روی متوسط در هفته — از روزی ۱۰ دقیقه شروع کنید',
          body:
              'روزی ۱۰ دقیقه پیاده‌روی تند که تا ۳۰ دقیقه بزرگ می‌شود، نمره متابولیک را کم می‌کند.',
          why: 'WHO — ۱۵۰ دقیقه فعالیت متوسط در هفته با کاهش ریسک قلبی‌عروقی همراه است',
          effort: CoachingEffort.medium,
          duration: '۱۰ → ۳۰ دقیقه/روز — ۲ تا ۴ هفته',
          markers: '۱۵۰ دقیقه/هفته پیاده‌روی تند',
          apply: (w) => w.copyWith(
            physicalActivity: RiskPhysicalActivity.moderately,
          ),
        ),
      );
    }

    final osaHigh = input.neckCm != null &&
        input.neckCm! >= (input.gender == RiskGender.male ? 43 : 38);
    if (osaHigh) {
      out.add(
        CoachSuggestion(
          id: 'osa',
          phase: 1,
          category: CoachingCategory.sleep,
          title: 'آزمون خواب (پلی‌اسومنوگرافی) + خوابیدن روی پهلو',
          body:
              'دور گردن شما بالای آستانه OSA است. آزمون خواب تشخیص را تأیید می‌کند؛ خوابیدن روی پهلو و کاهش وزن شدت آن را کم می‌کند.',
          why: 'OSA فاکتور مستقل فشارخون و آریتمی قلبی است',
          effort: CoachingEffort.medium,
          duration: '۱ هفته (آزمون) + بلندمدت',
          markers: 'دور گردن < ۴۳ (مرد) / ۳۸ (زن) · AHI < ۱۵',
          apply: (w) => w.hrvSdnnMs != null
              ? w.copyWith(hrvSdnnMs: math.min(90.0, w.hrvSdnnMs! + 8))
              : w,
        ),
      );
    }

    if (ratio != null && ratio > 4) {
      out.add(
        CoachSuggestion(
          id: 'lipids',
          phase: 1,
          category: CoachingCategory.labs,
          title: 'ویزیت قلب‌پزشکی — پروفایل چربی (TC/HDL = ${_faNum(ratio.toStringAsFixed(1))})',
          body:
              'نسبت آتروژنیک شما بالاست. متخصص با آزمایش نهایی نیاز به دارو را مشخص می‌کند؛ سبک زندگی در ۸ هفته این نسبت را بهتر می‌کند.',
          why: 'ATP III — TC/HDL بالای ۴ بالا محسوب می‌شود',
          effort: CoachingEffort.medium,
          duration: 'یک‌باره + ۸ هفته',
          markers: 'TC/HDL < ۴',
          apply: (w) => w.copyWith(
            cholesterol: w.cholesterol == null
                ? null
                : (w.cholesterol! * 0.92).roundToDouble(),
            hdl: w.hdl == null
                ? null
                : math.min(80.0, (w.hdl! * 1.1).roundToDouble()),
          ),
        ),
      );
    }

    // Phase 2: 12-week structural changes.
    if (bmi >= 25 || whtr > 0.5) {
      final severe = bmi >= 30 || whtr > 0.6;
      out.add(
        CoachSuggestion(
          id: 'weight',
          phase: 2,
          category: CoachingCategory.nutrition,
          title: severe
              ? 'کاهش وزن ساختاریافته — ۱۰٪ وزن در ۳ ماه'
              : 'مدیریت وزن متعادل — ۵٪ وزن در ۳ ماه',
          body:
              'BMI شما ${_faNum(bmi.toStringAsFixed(1))} و WHtR حدود ${_faNum(whtr.toStringAsFixed(2))} است. هدف WHtR ≤ ۰٫۵ است.',
          why: 'WHO/Ashwell — WHtR > 0.5 یعنی چاقی مرکزی',
          effort: CoachingEffort.high,
          duration: '۱۲ هفته',
          markers: 'WHtR < ۰٫۵ · BMI ${severe ? '< ۲۸' : '< ۲۵'}',
          apply: (w) {
            final factor = severe ? 0.9 : 0.95;
            return w.copyWith(
              weightKg: _round1(w.weightKg * factor),
              waistCm: w.waistCm == null ? null : _round1(w.waistCm! * factor),
            );
          },
        ),
      );
    }

    return out;
  }

  static (double, double) _effectiveBp(HealthDataInput input) {
    final rawQuality = input.averageSignalQuality ?? 0;
    final quality = rawQuality > 1 ? rawQuality / 100 : rawQuality;
    if (quality >= 0.55 &&
        input.systolicBloodPressureMmhg != null &&
        input.diastolicBloodPressureMmhg != null) {
      return (input.systolicBloodPressureMmhg!, input.diastolicBloodPressureMmhg!);
    }
    return (input.sbp, input.dbp);
  }

  static HealthDataInput _bpShift(
    HealthDataInput input,
    double dsbp,
    double ddbp,
  ) {
    return input.copyWith(
      sbp: math.max(90.0, input.sbp + dsbp),
      dbp: math.max(55.0, input.dbp + ddbp),
      systolicBloodPressureMmhg: input.systolicBloodPressureMmhg == null
          ? null
          : math.max(90.0, input.systolicBloodPressureMmhg! + dsbp),
      diastolicBloodPressureMmhg: input.diastolicBloodPressureMmhg == null
          ? null
          : math.max(55.0, input.diastolicBloodPressureMmhg! + ddbp),
    );
  }

  static double _round1(double value) => (value * 10).round() / 10;

  static String _faNum(Object value) {
    const digits = '۰۱۲۳۴۵۶۷۸۹';
    return value
        .toString()
        .replaceAllMapped(RegExp('[0-9]'), (m) => digits[int.parse(m[0]!)])
        .replaceAll('-', '−');
  }

  static String _genderFa(RiskGender value) => switch (value) {
        RiskGender.male => 'مرد',
        RiskGender.female => 'زن',
        RiskGender.other => 'سایر',
      };

  static String _raceFa(RiskRace value) => switch (value) {
        RiskRace.white => 'سفیدپوست',
        RiskRace.africanAmerican => 'آفریقایی-آمریکایی',
        RiskRace.other => 'سایر',
      };

  static String _familyDiabetesFa(RiskFamilyDiabetes value) => switch (value) {
        RiskFamilyDiabetes.none => 'سابقه خانوادگی ندارد',
        RiskFamilyDiabetes.noneFirstDegree => 'دارد — ولی نه در درجه اول',
        RiskFamilyDiabetes.firstDegree => 'دارد — در خویشاوندان درجه یک',
      };

  static String _parentalHypertensionFa(
    RiskParentalHypertension value,
  ) =>
      switch (value) {
        RiskParentalHypertension.none => 'هر دو طبیعی',
        RiskParentalHypertension.one => 'یکی از والدین',
        RiskParentalHypertension.both => 'هر دو والد',
      };
}
