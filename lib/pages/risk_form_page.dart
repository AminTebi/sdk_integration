import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shenai_sdk/pigeon.dart';
import 'package:shenai_skd_integration/l10n/app_strings.dart';
import 'package:shenai_skd_integration/l10n/enum_labels.dart';
import 'package:shenai_skd_integration/models/risk_profile.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';
import 'package:shenai_skd_integration/widgets/app_page_header.dart';
import 'package:shenai_skd_integration/widgets/atmosphere_background.dart';
import 'package:shenai_skd_integration/widgets/glass_card.dart';
import 'package:shenai_skd_integration/widgets/luxury_button.dart';
import 'package:shenai_skd_integration/widgets/metric_tile.dart';

class RiskFormPage extends StatefulWidget {
  const RiskFormPage({super.key, required this.profile});

  final RiskProfile profile;

  @override
  State<RiskFormPage> createState() => _RiskFormPageState();
}

class _RiskFormPageState extends State<RiskFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _age = TextEditingController(text: '${widget.profile.age}');
  late final _height =
      TextEditingController(text: _num(widget.profile.heightCm));
  late final _weight =
      TextEditingController(text: _num(widget.profile.weightKg));
  late final _waist =
      TextEditingController(text: _optionalNum(widget.profile.waistCm));
  late final _neck =
      TextEditingController(text: _optionalNum(widget.profile.neckCm));
  late final _hip =
      TextEditingController(text: _optionalNum(widget.profile.hipCm));
  late final _cholesterol =
      TextEditingController(text: _optionalNum(widget.profile.cholesterol));
  late final _hdl =
      TextEditingController(text: _optionalNum(widget.profile.hdl));
  late final _triglyceride =
      TextEditingController(text: _optionalNum(widget.profile.triglyceride));
  late final _fastingGlucose =
      TextEditingController(text: _optionalNum(widget.profile.fastingGlucose));
  late final _sbp = TextEditingController(text: _num(widget.profile.sbp));
  late final _dbp = TextEditingController(text: _num(widget.profile.dbp));
  late final _country = TextEditingController(text: widget.profile.country);

  late bool _smoker = widget.profile.isSmoker;
  late bool _diabetes = widget.profile.hasDiabetes;
  late bool _vegetableFruitDiet = widget.profile.vegetableFruitDiet;
  late bool _historyOfHighGlucose = widget.profile.historyOfHighGlucose;
  late bool _historyOfHypertension = widget.profile.historyOfHypertension;
  late Gender _gender = widget.profile.gender;
  late HypertensionTreatment _hypertensionTreatment =
      widget.profile.hypertensionTreatment;
  late PhysicalActivity _physicalActivity = widget.profile.physicalActivity;
  late Race _race = widget.profile.race;
  late FamilyHistory _familyDiabetes = widget.profile.familyDiabetes;
  late ParentalHistory _parentalHypertension =
      widget.profile.parentalHypertension;

  String _num(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _optionalNum(double? value) {
    if (value == null) {
      return '';
    }
    return _num(value);
  }

  double? _parseOptionalDouble(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return double.parse(text);
  }

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _waist.dispose();
    _neck.dispose();
    _hip.dispose();
    _cholesterol.dispose();
    _hdl.dispose();
    _triglyceride.dispose();
    _fastingGlucose.dispose();
    _sbp.dispose();
    _dbp.dispose();
    _country.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = RiskProfile(
      age: int.parse(_age.text.trim()),
      heightCm: double.parse(_height.text.trim()),
      weightKg: double.parse(_weight.text.trim()),
      waistCm: _parseOptionalDouble(_waist),
      neckCm: _parseOptionalDouble(_neck),
      hipCm: _parseOptionalDouble(_hip),
      cholesterol: _parseOptionalDouble(_cholesterol),
      hdl: _parseOptionalDouble(_hdl),
      triglyceride: _parseOptionalDouble(_triglyceride),
      fastingGlucose: _parseOptionalDouble(_fastingGlucose),
      sbp: double.parse(_sbp.text.trim()),
      dbp: double.parse(_dbp.text.trim()),
      isSmoker: _smoker,
      hypertensionTreatment: _hypertensionTreatment,
      hasDiabetes: _diabetes,
      gender: _gender,
      physicalActivity: _physicalActivity,
      country: _country.text.trim().toUpperCase(),
      race: _race,
      vegetableFruitDiet: _vegetableFruitDiet,
      historyOfHighGlucose: _historyOfHighGlucose,
      historyOfHypertension: _historyOfHypertension,
      familyDiabetes: _familyDiabetes,
      parentalHypertension: _parentalHypertension,
    );

    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AtmosphereBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(title: AppStrings.healthProfile),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Text(
                        AppStrings.riskFactors,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.riskFactorsHint,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      const SectionEyebrow(AppStrings.sectionBody),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.requiredSectionHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.age,
                                    controller: _age,
                                    integer: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _EnumDropdown<Gender>(
                                    label: AppStrings.gender,
                                    value: _gender,
                                    values: Gender.values,
                                    onChanged: (value) =>
                                        setState(() => _gender = value),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.heightCm,
                                    controller: _height,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.weightKg,
                                    controller: _weight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SectionEyebrow(AppStrings.sectionBlood),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.requiredSectionHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _NumberField(
                                label: AppStrings.sbpMmHg,
                                controller: _sbp,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _NumberField(
                                label: AppStrings.dbpMmHg,
                                controller: _dbp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SectionEyebrow(AppStrings.sectionOptionalLabs),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.optionalSectionHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.cholesterol,
                                    controller: _cholesterol,
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.hdl,
                                    controller: _hdl,
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.triglyceride,
                                    controller: _triglyceride,
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.fastingGlucose,
                                    controller: _fastingGlucose,
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SectionEyebrow(AppStrings.sectionOptionalBody),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.optionalSectionHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.waistCm,
                                    controller: _waist,
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NumberField(
                                    label: AppStrings.neckCm,
                                    controller: _neck,
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _NumberField(
                              label: AppStrings.hipCm,
                              controller: _hip,
                              required: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SectionEyebrow(AppStrings.sectionHistory),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            _EnumDropdown<HypertensionTreatment>(
                              label: AppStrings.hypertensionTreatment,
                              value: _hypertensionTreatment,
                              values: HypertensionTreatment.values,
                              onChanged: (value) => setState(
                                () => _hypertensionTreatment = value,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _EnumDropdown<FamilyHistory>(
                              label: AppStrings.familyDiabetes,
                              value: _familyDiabetes,
                              values: FamilyHistory.values,
                              onChanged: (value) =>
                                  setState(() => _familyDiabetes = value),
                            ),
                            const SizedBox(height: 12),
                            _EnumDropdown<ParentalHistory>(
                              label: AppStrings.parentalHypertension,
                              value: _parentalHypertension,
                              values: ParentalHistory.values,
                              onChanged: (value) => setState(
                                () => _parentalHypertension = value,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _LuxurySwitch(
                              value: _smoker,
                              title: AppStrings.smoker,
                              onChanged: (v) => setState(() => _smoker = v),
                            ),
                            _LuxurySwitch(
                              value: _diabetes,
                              title: AppStrings.diabetes,
                              onChanged: (v) => setState(() => _diabetes = v),
                            ),
                            _LuxurySwitch(
                              value: _historyOfHighGlucose,
                              title: AppStrings.historyHighGlucose,
                              onChanged: (v) =>
                                  setState(() => _historyOfHighGlucose = v),
                            ),
                            _LuxurySwitch(
                              value: _historyOfHypertension,
                              title: AppStrings.historyHypertension,
                              onChanged: (v) =>
                                  setState(() => _historyOfHypertension = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const SectionEyebrow(AppStrings.sectionLifestyle),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: Column(
                          children: [
                            _EnumDropdown<PhysicalActivity>(
                              label: AppStrings.physicalActivity,
                              value: _physicalActivity,
                              values: PhysicalActivity.values,
                              onChanged: (value) =>
                                  setState(() => _physicalActivity = value),
                            ),
                            const SizedBox(height: 12),
                            _EnumDropdown<Race>(
                              label: AppStrings.race,
                              value: _race,
                              values: Race.values,
                              onChanged: (value) =>
                                  setState(() => _race = value),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _country,
                              textCapitalization: TextCapitalization.characters,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.ink,
                              ),
                              decoration: const InputDecoration(
                                labelText: AppStrings.countryIso,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length != 2) {
                                  return AppStrings.countryValidation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            _LuxurySwitch(
                              value: _vegetableFruitDiet,
                              title: AppStrings.vegetableFruitDiet,
                              onChanged: (v) =>
                                  setState(() => _vegetableFruitDiet = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      LuxuryButton(
                        label: AppStrings.computeHealthIndices,
                        icon: Icons.auto_awesome_rounded,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxurySwitch extends StatelessWidget {
  const _LuxurySwitch({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.ink,
            ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.integer = false,
    this.required = true,
  });

  final String label;
  final TextEditingController controller;
  final bool integer;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.ink,
          ),
      inputFormatters: [
        if (integer)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.singleLineFormatter,
      ],
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return required ? AppStrings.required : null;
        }
        if (integer) {
          if (int.tryParse(text) == null) {
            return AppStrings.invalid;
          }
        } else if (double.tryParse(text) == null) {
          return AppStrings.invalid;
        }
        return null;
      },
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: AppColors.surface,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.ink,
          ),
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(
            value: item,
            child: Text(EnumLabels.forEnum(item)),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
