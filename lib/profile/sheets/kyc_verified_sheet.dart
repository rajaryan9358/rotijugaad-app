import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class KycVerifiedSheet extends StatelessWidget {
  final bool isCurrentUser;

  const KycVerifiedSheet({super.key, this.isCurrentUser = true});

  String _text(BuildContext context, String selfKey, String viewedKey) {
    return (isCurrentUser ? selfKey : viewedKey).tr();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + context.spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(context.radii.md),
                        topRight: Radius.circular(context.radii.md),
                      ),
                      color: context.colors.secondaryContainer,
                    ),
                  ),
                  Container(color: context.colors.onPrimary, height: 30),
                ],
              ),
              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.onPrimary,
                  ),
                  height: 50,
                  width: 50,
                  child: Center(
                    child: XIcon(
                      AppIcon.shield,
                      color: context.colors.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.kyc_verified.title'.tr(),
                  style: context.text.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                Text(
                  _text(
                    context,
                    'profile.kyc_verified.subtitle',
                    'profile.kyc_verified.viewed_subtitle',
                  ),
                  style: context.text.bodyMedium,
                ),
                SizedBox(height: context.spacing.md),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      height: 42,
                      width: 42,
                      child: Center(
                        child: XIcon(
                          AppIcon.selfiePhoto,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: context.spacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.kyc_verified.selfie_title'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        Text(
                          _text(
                            context,
                            'profile.kyc_verified.selfie_desc',
                            'profile.kyc_verified.viewed_selfie_desc',
                          ),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.md),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      height: 42,
                      width: 42,
                      child: Center(
                        child: XIcon(
                          AppIcon.verifyAadhar,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: context.spacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.kyc_verified.aadhaar_title'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        Text(
                          _text(
                            context,
                            'profile.kyc_verified.aadhaar_desc',
                            'profile.kyc_verified.viewed_aadhaar_desc',
                          ),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('common.got_it'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
