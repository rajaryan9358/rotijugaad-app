import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/applicants/dialogs/verify_hire_otp_dialog.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class HireApplicantSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HireApplicantSheetState();
}

class _HireApplicantSheetState extends State<HireApplicantSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.spacing.lg,
        right: context.spacing.lg,
        top: context.spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + context.spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.xs,
                  vertical: context.spacing.sm,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: context.spacing.xxl,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              Text(
                'applicants.hire.title'.tr(),
                style: context.text.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'applicants.hire.subtitle'.tr(),
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Column(
            children:
                [
                      'applicants.hire.points.1'.tr(),
                      'applicants.hire.points.2'.tr(),
                    ]
                    .map(
                      (points) => Container(
                        margin: EdgeInsets.symmetric(
                          vertical: context.spacing.xs,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: context.colors.onPrimaryContainer,
                                shape: BoxShape.circle,
                              ),
                              width: 5,
                              height: 5,
                            ),
                            SizedBox(width: context.spacing.sm),
                            Text(
                              points,
                              style: context.text.bodySmall!.copyWith(
                                color: context.colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),

          SizedBox(height: context.spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: true, // allows tap outside to close
                  builder: (context) => VerifyHireOtpDialog(),
                );
              },
              child: Text('common.click_to_continue'.tr()),
            ),
          ),
          SizedBox(height: context.spacing.md),
        ],
      ),
    );
  }
}
