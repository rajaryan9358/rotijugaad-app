import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';
import '../models/applicants_models.dart';

class ApplicantItem extends StatelessWidget {
  final ApplicantRecord record;

  ApplicantItem({super.key, required this.record});

  final NumberFormat _moneyFmt = NumberFormat.decimalPattern('en_IN');

  String _salaryLabel() {
    final amount = record.employee.expectedSalary;
    final freq = record.employee.expectedSalaryFrequency;
    if (amount == null) return '-';

    final a = amount.toDouble().round();
    final freqText = (freq ?? '').trim();
    if (freqText.isEmpty) return '₹${_moneyFmt.format(a)}';

    return '₹${_moneyFmt.format(a)}/$freqText';
  }

  bool get _isKycVerified {
    final v = (record.employee.kycStatus ?? '').toLowerCase();
    return v == 'verified' || v == 'approved';
  }

  @override
  Widget build(BuildContext context) {
    final genderAsset = employeeGenderIconAsset(record.employee.gender);
    final status = (record.jobInterest.status ?? 'applied').trim();
    final location = record.employeeLocation;

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
                  SizedBox(height: context.spacing.xs),
                  Text(
                    '#${record.employee.id ?? '-'}',
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: context.spacing.sm,
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
                        status,
                        style: context.text.bodyMedium!.copyWith(
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          IconText(XIcon(AppIcon.salary, size: 16), _salaryLabel()),
          SizedBox(height: context.spacing.sm),
          if (location.isNotEmpty)
            IconText(XIcon(AppIcon.location, size: 16), location),
          if (location.isNotEmpty) SizedBox(height: context.spacing.sm),
          Row(
            children: [
              if (record.jobInterest.createdAtLabel.isNotEmpty)
                IconText(
                  XIcon(AppIcon.jobTime, size: 16),
                  'Applied on ${record.jobInterest.createdAtLabel}',
                ),
              SizedBox(width: context.spacing.md),
              IconText(XIcon(AppIcon.vacancy, size: 16), record.jobProfileName),
            ],
          ),
          SizedBox(height: context.spacing.sm),
        ],
      ),
    );
  }
}
