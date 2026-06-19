import 'package:flutter/material.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/xicon.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';

class SendInterestJobItem extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final ValueChanged<bool?>? onChanged;

  final String title;
  final String? organizationName;
  final String? location;
  final String? shift;
  final String? salary;
  final String? vacancy;

  const SendInterestJobItem({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    required this.title,
    this.organizationName,
    this.location,
    this.shift,
    this.salary,
    this.vacancy,
  });

  @override
  Widget build(BuildContext context) {
    final org = (organizationName ?? '').trim();
    final loc = (location ?? '').trim();
    final time = (shift ?? '').trim();
    final sal = (salary ?? '').trim();
    final vac = (vacancy ?? '').trim();

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
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
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.sm,
        ),
        margin: EdgeInsets.symmetric(vertical: context.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: enabled ? onChanged : null,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                SizedBox(width: context.spacing.sm),
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
                      if (org.isNotEmpty)
                        Text(
                          org,
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.sm),
            if (loc.isNotEmpty || time.isNotEmpty)
              Row(
                children: [
                  if (loc.isNotEmpty)
                    Flexible(
                      child: IconText(XIcon(AppIcon.location, size: 16), loc),
                    ),
                  if (loc.isNotEmpty && time.isNotEmpty)
                    SizedBox(width: context.spacing.md),
                  if (time.isNotEmpty)
                    Flexible(
                      child: IconText(XIcon(AppIcon.jobTime, size: 16), time),
                    ),
                ],
              ),
            if (loc.isNotEmpty || time.isNotEmpty)
              SizedBox(height: context.spacing.sm),
            if (sal.isNotEmpty || vac.isNotEmpty)
              Row(
                children: [
                  if (sal.isNotEmpty)
                    Flexible(
                      child: IconText(XIcon(AppIcon.salary, size: 16), sal),
                    ),
                  if (sal.isNotEmpty && vac.isNotEmpty)
                    SizedBox(width: context.spacing.md),
                  if (vac.isNotEmpty)
                    Flexible(
                      child: IconText(XIcon(AppIcon.vacancy, size: 16), vac),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
