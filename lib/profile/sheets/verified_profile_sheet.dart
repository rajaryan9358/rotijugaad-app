import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class VerifiedProfileSheet extends StatelessWidget {
  const VerifiedProfileSheet({super.key});

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
                      AppIcon.verified,
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
                  'profile.verified.title'.tr(),
                  style: context.text.titleMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                Text(
                  'profile.verified.subtitle'.tr(),
                  style: context.text.bodyMedium,
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
