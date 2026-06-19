import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';

class EmployerReceivedSentApplicantItem extends StatelessWidget {
  final bool isSent;

  EmployerReceivedSentApplicantItem(this.isSent);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), // shadow color
            blurRadius: 10, // softness
            spreadRadius: 1, // spread
            offset: Offset(0, 4), // shadow position (x, y)
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.md,
      ),
      margin: EdgeInsets.symmetric(
        vertical: context.spacing.sm,
        horizontal: context.spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Nitish Kumar Reddy",
                    style: context.text.bodyLarge!.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: context.spacing.sm),
                  const KycVerifiedBadgeIcon(size: 20),
                  SizedBox(width: context.spacing.xs),
                  const EmployeeGenderIcon(gender: 'male'),
                ],
              ),
              Text(
                "Mumbai, Maharashtra",
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          IconText(XIcon(AppIcon.salary, size: 16), "₹35,000/month"),
          SizedBox(height: context.spacing.sm),
          IconText(XIcon(AppIcon.location, size: 16), "Mumbai, Maharashtra"),
          SizedBox(height: context.spacing.sm),
          IconText(
            XIcon(AppIcon.jobTime, size: 16),
            "${isSent ? "Interest sent " : "Applied "} on 20th Dec, 2024",
          ),
          SizedBox(height: context.spacing.sm),
          IconText(XIcon(AppIcon.jobType, size: 16), "3 out of 6 hired"),
          SizedBox(height: context.spacing.sm),
          if (!isSent) ...[
            Row(
              children: [
                IconText(XIcon(AppIcon.vacancy, size: 16), "Sales Man"),
                SizedBox(width: context.spacing.sm),
                IconText(XIcon(AppIcon.vacancy, size: 16), "Accountant"),
                SizedBox(width: context.spacing.sm),
                IconText(XIcon(AppIcon.vacancy, size: 16), "Chef"),
              ],
            ),
            SizedBox(height: context.spacing.sm),
          ],
        ],
      ),
    );
  }
}
