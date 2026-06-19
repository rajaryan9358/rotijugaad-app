import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class RejectedCard extends StatelessWidget {
  final VoidCallback onResubmitClicked;

  const RejectedCard(this.onResubmitClicked, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 3, color: context.xcolors.failure),
        Container(
          color: context.xcolors.failureBackground,
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.sm,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_incomplete.svg',
                color: context.xcolors.failure,
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'profile.verification.profile_rejected'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.xcolors.failure,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                    ),
                  ),
                  onPressed: onResubmitClicked,
                  child: Text(
                    'profile.resubmit.title'.tr(),
                    style: context.text.bodySmall!.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
