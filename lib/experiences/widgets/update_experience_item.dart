import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class UpdateExperienceItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? firmName;
  final String? durationText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UpdateExperienceItem({
    super.key,
    required this.title,
    this.subtitle,
    this.firmName,
    this.durationText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(context.radii.sm)),
        border: Border.all(color: context.xcolors.stroke, width: 1),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.sm,
      ),
      margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: context.spacing.xs),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ],
                    if (firmName != null && firmName!.isNotEmpty) ...[
                      SizedBox(height: context.spacing.xs / 2),
                      Text(
                        firmName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (durationText != null && durationText!.isNotEmpty)
                Text(
                  durationText!,
                  style: context.text.bodyMedium!.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: context.spacing.sm),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.background,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: onEdit,
                    child: Text(
                      'common.edit'.tr(),
                      style: context.text.bodyMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.spacing.md),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.xcolors.failureBackground,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: onDelete,
                    child: Text(
                      'common.delete'.tr(),
                      style: context.text.bodyMedium!.copyWith(
                        color: context.xcolors.failure,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
