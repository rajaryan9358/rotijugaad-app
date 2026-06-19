import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';
import '../../utils/i18n_terms.dart';
import '../models/applicants_models.dart';

class ShortlistedHiredRejectedApplicantItem extends StatelessWidget {
  final ApplicantRecord record;
  final String statusLabel;
  final bool showStatusLabel;

  ShortlistedHiredRejectedApplicantItem({
    super.key,
    required this.record,
    required this.statusLabel,
    this.showStatusLabel = true,
  });

  final NumberFormat _moneyFmt = NumberFormat.decimalPattern('en_IN');

  String _salaryLabel(BuildContext context) {
    final amount = record.employee.expectedSalary;
    final freq = record.employee.expectedSalaryFrequency;
    if (amount == null) return '-';

    final a = amount.toDouble().round();
    final freqText = (freq ?? '').trim();
    if (freqText.isEmpty) return '₹${_moneyFmt.format(a)}';

    return '₹${_moneyFmt.format(a)}/${I18nTerms.fromRaw(context, freqText)}';
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
        .toList();
  }

  bool get _isKycVerified {
    final v = (record.employee.kycStatus ?? '').toLowerCase();
    return v == 'verified' || v == 'approved';
  }

  String _dateLabel(BuildContext context) {
    final rawStatus = (record.jobInterest.status ?? statusLabel).toLowerCase();
    if (rawStatus.contains('hired')) {
      final date = record.jobInterest.updatedAtLabel;
      return date.isEmpty ? '' : 'common.hired_on'.tr(args: [date]);
    }
    if (rawStatus.contains('reject')) {
      final date = record.jobInterest.updatedAtLabel;
      return date.isEmpty ? '' : 'common.rejected_on'.tr(args: [date]);
    }
    final date = record.jobInterest.createdAtLabel;
    return date.isEmpty ? '' : 'common.applied_on'.tr(args: [date]);
  }

  @override
  Widget build(BuildContext context) {
    final genderAsset = employeeGenderIconAsset(record.employee.gender);
    final location = record.employeeLocation;
    final dateLabel = _dateLabel(context);
    final employeeJobProfiles = _employeeJobProfiles(context);

    return Container(
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
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.employeeName,
                        style: context.text.bodyLarge!.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
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
              if (showStatusLabel)
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: context.spacing.md,
                      ),
                    ),
                    onPressed: null,
                    child: Row(
                      children: [
                        XIcon(
                          AppIcon.hired,
                          color: context.colors.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: context.spacing.xs),
                        Text(
                          statusLabel,
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // SizedBox(height: context.spacing.sm),
          IconText(XIcon(AppIcon.salary, size: 16), _salaryLabel(context)),
          SizedBox(height: context.spacing.sm),
          if (location.isNotEmpty)
            IconText(XIcon(AppIcon.location, size: 16), location),
          if (location.isNotEmpty) SizedBox(height: context.spacing.sm),
          if (dateLabel.isNotEmpty)
            IconText(XIcon(AppIcon.jobTime, size: 16), dateLabel),
          if (dateLabel.isNotEmpty) SizedBox(height: context.spacing.sm),
          if (employeeJobProfiles.isNotEmpty)
            Wrap(
              spacing: context.spacing.md,
              runSpacing: context.spacing.sm,
              children: [
                for (final profile in employeeJobProfiles)
                  IconText(XIcon(AppIcon.jobType, size: 16), profile),
              ],
            )
          else
            IconText(XIcon(AppIcon.jobType, size: 16), '-'),
          SizedBox(height: context.spacing.sm),
        ],
      ),
    );
  }
}
