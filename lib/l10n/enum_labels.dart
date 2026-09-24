import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';

/// Persian display labels for Shen AI risk-factor enums.
abstract final class EnumLabels {
  static String gender(Gender value) => switch (value) {
        Gender.male => 'مرد',
        Gender.female => 'زن',
        Gender.other => 'سایر',
      };

  static String physicalActivity(PhysicalActivity value) => switch (value) {
        PhysicalActivity.sedentary => 'کم‌تحرک',
        PhysicalActivity.lightlyActive => 'فعالیت سبک',
        PhysicalActivity.moderately => 'فعالیت متوسط',
        PhysicalActivity.veryActive => 'بسیار فعال',
        PhysicalActivity.extraActive => 'فوق‌فعال',
      };

  static String race(Race value) => switch (value) {
        Race.white => 'سفیدپوست',
        Race.africanAmerican => 'آفریقایی‌آمریکایی',
        Race.other => 'سایر',
      };

  static String hypertensionTreatment(HypertensionTreatment value) =>
      switch (value) {
        HypertensionTreatment.notNeeded => 'نیازی نیست',
        HypertensionTreatment.no => 'خیر',
        HypertensionTreatment.yes => 'بله',
      };

  static String parentalHistory(ParentalHistory value) => switch (value) {
        ParentalHistory.none => 'هیچ‌کدام',
        ParentalHistory.one => 'یکی از والدین',
        ParentalHistory.both => 'هر دو والد',
      };

  static String familyHistory(FamilyHistory value) => switch (value) {
        FamilyHistory.none => 'ندارد',
        FamilyHistory.noneFirstDegree => 'بدون درجه یک',
        FamilyHistory.firstDegree => 'درجه یک',
      };

  static String nafldRisk(NAFLDRisk? value) {
    if (value == null) {
      return '—';
    }
    return switch (value) {
      NAFLDRisk.low => 'کم',
      NAFLDRisk.moderate => 'متوسط',
      NAFLDRisk.high => 'زیاد',
    };
  }

  static String forEnum(Enum value) {
    return switch (value) {
      final Gender v => gender(v),
      final PhysicalActivity v => physicalActivity(v),
      final Race v => race(v),
      final HypertensionTreatment v => hypertensionTreatment(v),
      final ParentalHistory v => parentalHistory(v),
      final FamilyHistory v => familyHistory(v),
      final NAFLDRisk v => nafldRisk(v),
      _ => value.name,
    };
  }
}

/// Convenience re-export of common units for metric tiles.
abstract final class MetricUnits {
  static const bpm = AppStrings.unitBpm;
  static const mmHg = AppStrings.unitMmHg;
  static const brpm = AppStrings.unitBrpm;
}
