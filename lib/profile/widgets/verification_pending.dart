import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class VerificationPending extends StatelessWidget {
  const VerificationPending({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 3, color: context.xcolors.warning),
        Container(
          color: context.xcolors.warningBackground,
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.md,
            vertical: context.spacing.md,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_pending.svg',
                color: context.xcolors.warning,
              ),
              SizedBox(width: context.spacing.sm),
              Text(
                'profile.verification.kyc_in_review'.tr(),
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
