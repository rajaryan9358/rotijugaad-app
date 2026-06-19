import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/job_text_utils.dart';

import '../../common/widgets/icon_text.dart';

class JobItem extends StatelessWidget {
  final JobDto job;
  final VoidCallback? onBookmarkTap;

  const JobItem({super.key, required this.job, this.onBookmarkTap});

  static String? _joinLocation(String? city, String? state) {
    final parts = <String>[];
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String _formatDisplayTime(BuildContext context, String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '-';

    String formatPart(String input) {
      final v = input.trim();
      if (v.isEmpty) return '';
      final formats = [
        DateFormat('HH:mm:ss'),
        DateFormat('HH:mm'),
        DateFormat('H:mm'),
        DateFormat('hh:mm a'),
        DateFormat('h:mm a'),
      ];
      for (final format in formats) {
        try {
          final parsed = format.parseStrict(v);
          return DateFormat(
            'hh:mm a',
            context.locale.toString(),
          ).format(parsed);
        } catch (_) {}
      }
      return v;
    }

    final normalized = value.replaceAll(' to ', ' - ');
    final parts = normalized.split(' - ');
    if (parts.length == 2) {
      final start = formatPart(parts[0]);
      final end = formatPart(parts[1]);
      if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    }

    final formatted = formatPart(value);
    if (formatted != value) return formatted;
    return I18nTerms.fromRaw(context, value);
  }

  String _salaryText(BuildContext context) {
    final min = job.salaryMin;
    final max = job.salaryMax;
    final t = (job.salaryType ?? '').trim();

    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    String? range;
    if (min != null && max != null) {
      range = '${fmt.format(min)} - ${fmt.format(max)}';
    } else if (min != null) {
      range = '${'common.from'.tr()} ${fmt.format(min)}';
    } else if (max != null) {
      range = 'common.up_to'.tr(args: [fmt.format(max)]);
    }

    if (range == null) {
      return t.isEmpty ? 'common.salary_not_specified'.tr() : t;
    }

    if (t.isEmpty) return range;

    final localizedType = I18nTerms.fromRaw(context, t);
    final lower = t.toLowerCase();
    if (lower.startsWith('per ')) {
      return '$range $localizedType';
    }
    if (t.startsWith('/')) {
      return '$range/$localizedType';
    }
    return '$range/$localizedType';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final title = job.jobProfile ?? 'jobs.card.job_fallback'.tr();
    final revealOrg = job.showOrganization || job.isContactUnlocked;
    final org = revealOrg ? (job.organizationName ?? job.employerName) : null;
    final location = _joinLocation(job.jobCity, job.jobState) ?? '-';
    final timing = _formatDisplayTime(context, job.shiftTimingDisplay);
    final isWishlisted = job.isInWishlist;
    final vacancyText = job.noVacancy == null
        ? '-'
        : formatVacancyCountText(job.noVacancy);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.xs,
        horizontal: spacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(spacing.sm)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.md,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (revealOrg) ...[
                    SizedBox(height: spacing.xxs),
                    Row(
                      children: [
                        if (org != null)
                          Flexible(
                            child: Text(
                              org,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.secondary,
                              ),
                            ),
                          ),
                        if (job.isKycVerified) ...[
                          if (org != null) SizedBox(width: spacing.xs),
                          const KycVerifiedBadgeIcon(
                            size: 16,
                            isCurrentUser: false,
                          ),
                        ],
                      ],
                    ),
                  ],
                  SizedBox(height: spacing.sm),
                  Row(
                    children: [
                      IconText(XIcon(AppIcon.location, size: 16), location),
                      SizedBox(width: spacing.md),
                      IconText(XIcon(AppIcon.time, size: 16), timing),
                    ],
                  ),
                  SizedBox(height: spacing.sm),
                  Row(
                    children: [
                      IconText(
                        XIcon(AppIcon.salary, size: 16),
                        _salaryText(context),
                      ),
                      SizedBox(width: spacing.md),
                      IconText(XIcon(AppIcon.vacancy, size: 16), vacancyText),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: IconButton(
                onPressed: onBookmarkTap,
                icon: XIcon(
                  isWishlisted ? AppIcon.wishlist : AppIcon.bookmarkJob,
                  color: isWishlisted ? context.colors.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
