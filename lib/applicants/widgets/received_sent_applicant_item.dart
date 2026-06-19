import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';
import '../../utils/i18n_terms.dart';
import '../models/applicants_models.dart';

class ReceivedSentApplicantItem extends StatelessWidget {
  final ApplicantRecord record;
  final bool disabled;
  final String? jobStatusOverride;
  final bool showJobStatus;
  final bool showEmployeePreferenceMeta;
  final bool showEmployeeJobProfiles;
  final bool useSentOnLabel;

  ReceivedSentApplicantItem({
    super.key,
    required this.record,
    this.disabled = false,
    this.jobStatusOverride,
    this.showJobStatus = true,
    this.showEmployeePreferenceMeta = false,
    this.showEmployeeJobProfiles = true,
    this.useSentOnLabel = false,
  });

  final NumberFormat _moneyFmt = NumberFormat.decimalPattern('en_IN');

  String _employeeSalaryLabel(BuildContext context) {
    final salary = record.employee.expectedSalary;
    final freq = (record.employee.expectedSalaryFrequency ?? '').trim();

    if (salary == null) return '-';

    final amount = '₹${_moneyFmt.format(salary)}';
    if (freq.isEmpty) return amount;

    return '$amount/${I18nTerms.fromRaw(context, freq.toLowerCase())}';
  }

  List<String> _employeeJobProfiles(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    return record.employee.jobProfiles
        .map((p) {
          final primary = (isHindi ? p.profileHindi : p.profileEnglish).trim();
          final fallback = (isHindi ? p.profileEnglish : p.profileHindi).trim();
          return primary.isNotEmpty ? primary : fallback;
        })
        .where((value) => value.isNotEmpty)
        .take(3)
        .toList();
  }

  String _preferredLocation(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final city =
        ((isHindi
                    ? record.employee.preferredCityHindi
                    : record.employee.preferredCityEnglish) ??
                (isHindi
                    ? record.employee.preferredCityEnglish
                    : record.employee.preferredCityHindi) ??
                record.employee.preferredCity ??
                '')
            .trim();
    final state =
        ((isHindi
                    ? record.employee.preferredStateHindi
                    : record.employee.preferredStateEnglish) ??
                (isHindi
                    ? record.employee.preferredStateEnglish
                    : record.employee.preferredStateHindi) ??
                record.employee.preferredState ??
                '')
            .trim();

    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return '-';
  }

  String _jobSalaryLabel(BuildContext context) {
    final min = record.job.salaryMin;
    final max = record.job.salaryMax;
    final freq = (record.job.salaryFrequency ?? record.job.salaryType ?? '')
        .trim();

    if (min == null && max == null) return '-';

    String range;
    if (min != null && max != null) {
      range = '₹${_moneyFmt.format(min)} - ₹${_moneyFmt.format(max)}';
    } else if (min != null) {
      range = '₹${_moneyFmt.format(min)}+';
    } else {
      range = 'common.up_to'.tr(args: ['₹${_moneyFmt.format(max)}']);
    }

    if (freq.isEmpty) return range;
    final freqLabel = I18nTerms.fromRaw(context, freq);
    return '$range/$freqLabel';
  }

  String _hiredLabel(BuildContext context) {
    final hired = record.job.hiredCount;
    final total = record.job.noVacancy;
    if (hired == null || total == null) return '';
    return '${'common.of'.tr(args: [hired.toString(), total.toString()])} ${'terms.hired'.tr()}';
  }

  bool get _isKycVerified {
    final v = (record.employee.kycStatus ?? '').toLowerCase();
    return v == 'verified' || v == 'approved';
  }

  String _jobStatusType() {
    final raw = (jobStatusOverride ?? record.job.status ?? '').trim();
    final s = raw.toLowerCase();
    if (s.isEmpty) return 'active';
    if (s == 'expired' || s.contains('expire')) return 'expired';
    if (s == 'inactive' || s == 'closed' || s == 'unpublished') {
      return 'inactive';
    }
    if (s == 'active' || s == 'open' || s == 'published') return 'active';
    return 'active';
  }

  String _jobStatusLabel(BuildContext context) {
    return I18nTerms.fromRaw(context, _jobStatusType());
  }

  @override
  Widget build(BuildContext context) {
    final genderAsset = employeeGenderIconAsset(record.employee.gender);
    final employeeLocation = record.employeeLocation;
    final jobLocation = record.jobLocation;
    final jobLabel = record.jobProfileName;
    final orgLabel = record.organizationName;
    final appliedOn = record.jobInterest.createdAtLabel;
    final preferredLocation = _preferredLocation(context);
    final employeeJobProfiles = _employeeJobProfiles(context);

    final jobStatusType = _jobStatusType();
    final isActive = jobStatusType == 'active';

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: context.spacing.sm,
          horizontal: context.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.md,
          vertical: context.spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              record.employeeName,
                              style: context.text.bodyLarge!.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: context.spacing.sm),
                          if (_isKycVerified) ...[
                            SizedBox(width: context.spacing.xs),
                            const KycVerifiedBadgeIcon(size: 20),
                          ],
                          if (genderAsset != null) ...[
                            SizedBox(width: context.spacing.xs),
                            EmployeeGenderIcon(gender: record.employee.gender),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.xxs),
            if (!showEmployeePreferenceMeta && employeeLocation.isNotEmpty)
              Text(
                employeeLocation,
                style: context.text.bodySmall!.copyWith(
                  color: context.colors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!showEmployeePreferenceMeta && employeeLocation.isNotEmpty)
              SizedBox(height: context.spacing.xxs),
            if (showEmployeePreferenceMeta) ...[
              IconText(
                XIcon(AppIcon.salary, size: 16),
                _employeeSalaryLabel(context),
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                preferredLocation,
                style: context.text.bodySmall!.copyWith(
                  color: context.colors.secondary,
                ),
              ),
              SizedBox(height: context.spacing.sm),
              if (appliedOn.isNotEmpty) ...[
                IconText(
                  XIcon(AppIcon.jobTime, size: 16),
                  useSentOnLabel
                      ? 'job_details.sent_on'.tr(args: [appliedOn])
                      : 'common.applied_on'.tr(args: [appliedOn]),
                ),
                SizedBox(height: context.spacing.sm),
              ],
              if (showEmployeeJobProfiles && employeeJobProfiles.isNotEmpty)
                Wrap(
                  spacing: context.spacing.md,
                  runSpacing: context.spacing.sm,
                  children: [
                    for (final profile in employeeJobProfiles)
                      IconText(XIcon(AppIcon.jobType, size: 16), profile),
                  ],
                )
              else if (showEmployeeJobProfiles)
                IconText(XIcon(AppIcon.jobType, size: 16), '-'),
              if (showEmployeeJobProfiles) SizedBox(height: context.spacing.sm),
            ],
            if (!showEmployeePreferenceMeta)
              Padding(
                padding: EdgeInsets.only(
                  top: context.spacing.sm,
                  bottom: context.spacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobLabel,
                                style: context.text.bodyLarge!.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (orgLabel.isNotEmpty)
                                Text(
                                  orgLabel,
                                  style: context.text.bodyMedium!.copyWith(
                                    color: context.colors.secondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (showJobStatus) ...[
                          SizedBox(width: context.spacing.xxs),
                          Container(
                            constraints: const BoxConstraints(minHeight: 36),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.spacing.md,
                              vertical: context.spacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? context.colors.secondary
                                  : context.colors.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                context.radii.sm,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                XIcon(
                                  AppIcon.activeJob,
                                  color: isActive
                                      ? context.colors.onSecondary
                                      : context.colors.onBackground.withValues(
                                          alpha: 0.7,
                                        ),
                                  size: 16,
                                ),
                                SizedBox(width: context.spacing.xs),
                                Text(
                                  _jobStatusLabel(context),
                                  style: context.text.bodyMedium!.copyWith(
                                    color: isActive
                                        ? context.colors.onSecondary
                                        : context.colors.onBackground
                                              .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: context.spacing.sm),
                    IconText(
                      XIcon(AppIcon.salary, size: 16),
                      _jobSalaryLabel(context),
                    ),
                    SizedBox(height: context.spacing.sm),
                    if (jobLocation.isNotEmpty)
                      IconText(XIcon(AppIcon.location, size: 16), jobLocation),
                    if (jobLocation.isNotEmpty)
                      SizedBox(height: context.spacing.sm),
                    Row(
                      children: [
                        if (appliedOn.isNotEmpty)
                          IconText(
                            XIcon(AppIcon.jobTime, size: 16),
                            useSentOnLabel
                                ? 'job_details.sent_on'.tr(args: [appliedOn])
                                : 'common.applied_on'.tr(args: [appliedOn]),
                          ),
                        SizedBox(width: context.spacing.md),
                        if (_hiredLabel(context).isNotEmpty)
                          IconText(
                            XIcon(AppIcon.hired, size: 16),
                            _hiredLabel(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (!showEmployeePreferenceMeta)
              SizedBox(height: context.spacing.sm),
          ],
        ),
      ),
    );
  }
}
