import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/widgets/icon_text.dart';

class HiredJobItem extends StatelessWidget {
  final String title;
  final String organization;
  final String location;
  final String phone;
  final String hiredOn;

  const HiredJobItem({
    super.key,
    required this.title,
    required this.organization,
    required this.location,
    required this.phone,
    required this.hiredOn,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone.trim().isNotEmpty && phone.trim() != '—';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        color: context.colors.onPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12), // shadow color
            blurRadius: 10, // softness
            spreadRadius: 1, // spread
            offset: Offset(0, 4), // shadow position (x, y)
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
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
                  Text(
                    title,
                    style: context.text.bodyLarge!.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.spacing.sm),
                  Text(
                    organization,
                    style: context.text.bodyMedium!.copyWith(
                      color: context.colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(context.radii.sm),
                  ),
                  border: Border.all(
                    color: context.xcolors.hiredStatusStroke,
                    width: 1,
                  ),
                  color: context.xcolors.hiredStatusBackground,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.sm,
                  vertical: context.spacing.xs,
                ),
                child: Row(
                  children: [
                    XIcon(
                      AppIcon.hired,
                      color: context.xcolors.hiredStatusForeground,
                      size: 18,
                    ),
                    SizedBox(width: context.spacing.xs),
                    Text(
                      'terms.hired'.tr(),
                      style: context.text.bodyMedium!.copyWith(
                        color: context.xcolors.hiredStatusForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              IconText(XIcon(AppIcon.location, size: 16), location),
              if (hasPhone) ...[
                SizedBox(width: context.spacing.md),
                IconText(XIcon(AppIcon.call, size: 16), phone),
              ],
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: IconText(XIcon(AppIcon.dateTime, size: 16), hiredOn),
          ),
        ],
      ),
    );
  }
}
