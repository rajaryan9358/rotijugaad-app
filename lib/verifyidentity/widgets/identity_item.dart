import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class IdentityItem extends StatefulWidget {
  final String title;
  final String description;
  final AppIcon appIcon;
  final bool isVerified;
  final VoidCallback onVerifyClicked;
  final String buttonText;
  final bool showAction;

  const IdentityItem({
    super.key,
    required this.title,
    required this.description,
    required this.appIcon,
    required this.isVerified,
    required this.onVerifyClicked,
    this.buttonText = 'Verify',
    this.showAction = true,
  });

  @override
  State<StatefulWidget> createState() => _IdentityItemState();
}

class _IdentityItemState extends State<IdentityItem> {
  @override
  Widget build(BuildContext context) {
    final buttonLabel = widget.buttonText == 'Verify'
        ? 'common.verify'.tr()
        : widget.buttonText;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        color: context.colors.onPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.xs,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    XIcon(
                      widget.appIcon,
                      color: widget.isVerified
                          ? context.colors.onPrimaryContainer
                          : context.colors.primary,
                    ),
                    SizedBox(width: context.spacing.sm),
                    Text(
                      widget.title,
                      style: context.text.bodyLarge!.copyWith(
                        color: widget.isVerified
                            ? context.colors.onPrimaryContainer
                            : context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.xs),
                Text(widget.description, style: context.text.bodyMedium),
              ],
            ),
          ),
          widget.isVerified
              ? XIcon(AppIcon.success, color: context.xcolors.success, size: 20)
              : (widget.showAction
                    ? SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: context.spacing.sm,
                            ),
                          ),
                          onPressed: widget.onVerifyClicked,
                          child: Text(buttonLabel),
                        ),
                      )
                    : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
