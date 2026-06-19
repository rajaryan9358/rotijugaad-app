import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';

class EmployerJobItem extends StatelessWidget {
  final bool isActive;
  final String statusType;
  final String title;
  final String subtitle;
  final String location;
  final String salary;
  final String hired;
  final String statusInfo;
  final Color cardBackgroundColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;
  final Color infoBackgroundColor;
  final Color infoForegroundColor;

  const EmployerJobItem({
    super.key,
    required this.isActive,
    required this.statusType,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.salary,
    required this.hired,
    required this.statusInfo,
    required this.cardBackgroundColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
    required this.infoBackgroundColor,
    required this.infoForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = statusType.trim().toLowerCase();
    final statusText = normalizedStatus.isEmpty
        ? (isActive ? 'terms.active'.tr() : 'terms.inactive'.tr())
        : 'terms.$normalizedStatus'.tr();
    final defaultCardBackgroundColor = isActive
        ? context.colors.onPrimary
        : context.colors.primaryContainer;
    final defaultBadgeBackgroundColor = isActive
        ? context.colors.secondary
        : context.colors.primaryContainer;
    final defaultBadgeForegroundColor = isActive
        ? context.colors.onPrimary
        : context.colors.onBackground.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
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
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: defaultCardBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.radii.sm),
                topRight: Radius.circular(context.radii.sm),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.text.bodyLarge!.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: context.text.bodyMedium!.copyWith(
                              color: context.colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.spacing.sm),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacing.md,
                            vertical: 0,
                          ),
                          disabledBackgroundColor: defaultBadgeBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(context.radii.sm),
                            ),
                            side: BorderSide(
                              color: defaultBadgeForegroundColor.withValues(
                                alpha: 0.18,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        onPressed: null,
                        child: Row(
                          children: [
                            XIcon(
                              AppIcon.activeJob,
                              color: defaultBadgeForegroundColor,
                              size: 16,
                            ),
                            SizedBox(width: context.spacing.xs),
                            Text(
                              statusText,
                              style: context.text.bodyMedium!.copyWith(
                                color: defaultBadgeForegroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.sm),
                IconText(XIcon(AppIcon.location, size: 16), location),
                SizedBox(height: context.spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: IconText(XIcon(AppIcon.salary, size: 16), salary),
                    ),
                    SizedBox(width: context.spacing.md),
                    Expanded(
                      child: IconText(XIcon(AppIcon.vacancy, size: 16), hired),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: infoBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(context.radii.sm),
                bottomRight: Radius.circular(context.radii.sm),
              ),
            ),
            child: Text(
              statusInfo,
              style: context.text.bodySmall!.copyWith(
                color: infoForegroundColor,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
