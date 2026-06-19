import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/candidate_detail_models.dart';
import '../widgets/candidate_detail_field.dart';
import '../../theme/context_ext.dart';
import '../../utils/i18n_terms.dart';

class CandidateAboutScreen extends StatelessWidget {
  final CandidateEmployeeDetailDto employee;
  final bool isContactUnlocked;
  final ValueChanged<String>? onCallNow;

  const CandidateAboutScreen({
    super.key,
    required this.employee,
    required this.isContactUnlocked,
    this.onCallNow,
  });

  int? _ageFromDob(DateTime? dob) {
    if (dob == null) return null;

    final now = DateTime.now();
    var age = now.year - dob.year;
    final hadBirthdayThisYear =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthdayThisYear) age -= 1;

    if (age < 0 || age > 120) return null;
    return age;
  }

  String _salaryText(BuildContext context) {
    final salary = employee.expectedSalary;
    if (salary == null) return '-';

    final asInt = salary is int
        ? salary
        : (salary % 1 == 0)
        ? salary.toInt()
        : null;

    final amount = asInt != null ? asInt.toString() : salary.toString();

    final freq = (employee.expectedSalaryFrequency ?? '').trim();
    if (freq.isEmpty) return '₹$amount';
    return '₹$amount / ${I18nTerms.fromRaw(context, freq)}';
  }

  String _preferredLocation(bool isHindi) {
    final city =
        ((isHindi
                    ? employee.preferredCityHindi
                    : employee.preferredCityEnglish) ??
                employee.preferredCity ??
                '')
            .trim();
    final state =
        ((isHindi
                    ? employee.preferredStateHindi
                    : employee.preferredStateEnglish) ??
                employee.preferredState ??
                '')
            .trim();
    if (city.isEmpty && state.isEmpty) return '-';
    if (city.isEmpty) return state;
    if (state.isEmpty) return city;
    return '$city, $state';
  }

  String _currentLocation(bool isHindi) {
    final city =
        ((isHindi ? employee.currentCityHindi : employee.currentCityEnglish) ??
                employee.currentCity ??
                '')
            .trim();
    final state =
        ((isHindi
                    ? employee.currentStateHindi
                    : employee.currentStateEnglish) ??
                employee.currentState ??
                '')
            .trim();
    if (city.isEmpty && state.isEmpty) return '-';
    if (city.isEmpty) return state;
    if (state.isEmpty) return city;
    return '$city, $state';
  }

  String _preferredShift(BuildContext context, bool isHindi) {
    final raw =
        ((isHindi
                    ? employee.preferredShiftHindi
                    : employee.preferredShiftEnglish) ??
                employee.preferredShift ??
                '')
            .trim();
    if (raw.isEmpty) return '-';
    return I18nTerms.fromRaw(context, raw);
  }

  String _skillsText(bool isHindi) {
    final items = (isHindi ? employee.skillsHindi : employee.skillsEnglish)
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return '-';
    return items.join(', ');
  }

  String _safePhone(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value.startsWith('-')) return '';
    final digits = value.replaceAll(RegExp(r'\D+'), '');
    if (digits.isEmpty) return '';
    final parsed = int.tryParse(digits);
    if (parsed != null && parsed < 0) return '';
    return value;
  }

  bool get _isKycVerified {
    return (employee.kycStatus ?? '').trim().toLowerCase() == 'verified';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    final dobDate = employee.dobDate;
    final age = _ageFromDob(dobDate);
    final about =
        ((isHindi ? employee.aboutUserHindi : employee.aboutUserEnglish) ??
                employee.aboutUser ??
                '')
            .trim();
    final qualification =
        ((isHindi
                    ? employee.qualificationHindi
                    : employee.qualificationEnglish) ??
                employee.qualification ??
                '-')
            .trim();
    final phone = _safePhone(employee.mobile);
    final email = (employee.email ?? '').trim();
    final aadhaarNumber = (employee.aadharNumber ?? '').trim();

    final genderRaw = (employee.gender ?? '').trim();
    final genderText = genderRaw.isEmpty ? '' : I18nTerms.fromRaw(context, genderRaw);
    final currentLocation = _currentLocation(isHindi);
    final preferredLocation = _preferredLocation(isHindi);
    final skillsText = _skillsText(isHindi);
    final salaryText = employee.expectedSalary != null ? _salaryText(context) : '';
    final preferredShift = _preferredShift(context, isHindi);

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing.md),
            if (about.isNotEmpty)
              CandidateDetailField(
                'candidates.detail.about'.tr(),
                about,
              ),
            if (isContactUnlocked && phone.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: CandidateDetailField(
                      'candidates.detail.mobile_number'.tr(),
                      phone,
                    ),
                  ),
                  GestureDetector(
                    onTap: onCallNow == null
                        ? null
                        : () => onCallNow!.call(phone),
                    child: Text(
                      'candidates.detail.call_now'.tr(),
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            if (age != null)
              CandidateDetailField(
                'candidates.detail.age'.tr(),
                age.toString(),
              ),
            if (genderText.isNotEmpty)
              CandidateDetailField(
                'candidates.detail.gender'.tr(),
                genderText,
              ),
            if (_isKycVerified && aadhaarNumber.isNotEmpty)
              CandidateDetailField(
                'candidates.detail.aadhaar_number'.tr(),
                aadhaarNumber,
              ),
            if (currentLocation != '-')
              CandidateDetailField(
                'candidates.detail.current_location'.tr(),
                currentLocation,
              ),
            if (preferredLocation != '-')
              CandidateDetailField(
                'candidates.detail.preferred_job_location'.tr(),
                preferredLocation,
              ),
            if (skillsText != '-')
              CandidateDetailField(
                'candidates.detail.skills'.tr(),
                skillsText,
              ),
            if (qualification.isNotEmpty && qualification != '-')
              CandidateDetailField(
                'candidates.detail.qualifications'.tr(),
                qualification,
              ),
            if (salaryText.isNotEmpty)
              CandidateDetailField(
                'candidates.detail.expected_salary'.tr(),
                salaryText,
              ),
            if (preferredShift != '-')
              CandidateDetailField(
                'candidates.detail.preferred_shift'.tr(),
                preferredShift,
              ),
            if (isContactUnlocked && email.isNotEmpty)
              CandidateDetailField(
                'candidates.detail.email'.tr(),
                email,
              ),
            SizedBox(height: spacing.xxxl),
          ],
        ),
      ),
    );
  }
}
