import 'package:flutter/widgets.dart';

import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class CandidateExperienceItem extends StatelessWidget {
  final String title;
  final String? firm;
  final String? duration;
  final String? certificateName;
  final VoidCallback? onCertificateTap;

  const CandidateExperienceItem({
    super.key,
    required this.title,
    this.firm,
    this.duration,
    this.certificateName,
    this.onCertificateTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final safeFirm = (firm ?? '').trim();
    final safeDuration = (duration ?? '').trim();
    final safeCert = (certificateName ?? '').trim();

    return Container(
      margin: EdgeInsets.symmetric(vertical: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.bodyMedium!.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  safeFirm.isEmpty ? '-' : safeFirm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall,
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                safeDuration.isEmpty ? '-' : safeDuration,
                style: context.text.bodySmall!.copyWith(
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          if (safeCert.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Row(
              children: [
                XIcon(
                  AppIcon.attachment,
                  color: context.colors.secondary,
                  size: 20,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: GestureDetector(
                    onTap: onCertificateTap,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.only(bottom: spacing.xxs),
                        decoration: onCertificateTap == null
                            ? null
                            : BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: context.colors.secondary,
                                    width: 1,
                                  ),
                                ),
                              ),
                        child: Text(
                          safeCert,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
